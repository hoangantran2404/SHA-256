`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2025 03:32:03 PM
// Design Name: 
// Module Name: SHA256_top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SHA256_top_tb();
    parameter DATA_WIDTH    = 32;
    parameter TIMEOUT_LIMIT = 20000; 

    reg                    clk;
    reg                    rst_n;
    reg  [7:0]             uart_byte_in;
    reg                    RX_dv_in;

 
    wire [7:0]             data_out_w;
    wire                   SHA_dv_out_w;

    reg [7:0]              MP_byte_in[0:2]; // Message "abc" (3 bytes)
    reg [DATA_WIDTH-1 :0]  expected_H[0:7];
    

    reg [31:0]             hash_word_reg; 

    reg [DATA_WIDTH-1 :0]  final_hash_words[0:7];

    integer i, errors;
    reg [4:0] word_count; // Đếm 8 words (0-7)
    reg [2:0] byte_count; // Đếm 4 bytes (0-3)

    SHA256_top DUT(
        .clk                (clk),
        .rst_n              (rst_n),
        .UART_done_flag     (RX_dv_in),
        .UART_data_out      (uart_byte_in),

        .SHA_core_out       (data_out_w), 
        .SHA_dv_flag        (SHA_dv_out_w)
    );

    initial begin 
        clk = 0; 
        forever #5 clk = ~clk; 
    end

    initial begin
        $display("========================================");
        $display("   TESTBENCH STARTING: SHA-256 TOP      ");
        $display("========================================");


        $readmemh("/home/hoangan2404/Project_0/code_C/Project_SHA256/expected_H.txt", expected_H); 
        

        MP_byte_in[0] = 8'h61; // 'a'
        MP_byte_in[1] = 8'h62; // 'b'
        MP_byte_in[2] = 8'h63; // 'c'

        rst_n = 1; 
        RX_dv_in = 0; 
        uart_byte_in = 0; 
        errors = 0;
        hash_word_reg = 0;
        word_count = 0;
        byte_count = 0;
        

        repeat(5) @(posedge clk); 
        rst_n = 0;
        repeat(5) @(posedge clk); 
        rst_n = 1;
        

        $display("[Time %0t] Sending 3 bytes: 'a', 'b', 'c'", $time);
        for (i = 0; i < 3; i = i+1) begin
            uart_byte_in <= MP_byte_in[i]; 
            RX_dv_in     <= 1;
            @(posedge clk); 
            RX_dv_in     <= 0;
            @(posedge clk); 
        end
        uart_byte_in <= 0;

        $display("[Time %0t] Data sent. Waiting for SHA_dv_flag (Core output valid)...", $time);
        

        i = 0;
        while (SHA_dv_out_w !== 1 && i < TIMEOUT_LIMIT) begin
            @(posedge clk);
            i = i + 1;
        end

        if (i == TIMEOUT_LIMIT) begin
            $display("!!! ERROR: TIMEOUT. Valid flag (SHA_dv_out_w) never went HIGH after %0d clocks.", TIMEOUT_LIMIT);
            $stop;
        end
       
        $display("[Time %0t] Valid Detected! Starting data collection.", $time);


        for(i = 0; i < 32; i = i + 1) begin
            
            hash_word_reg = {hash_word_reg[23:0], data_out_w};
            byte_count    = byte_count + 1;

            if(byte_count == 4) begin
                final_hash_words[word_count] = hash_word_reg;
                
                $display("[Word %0d] Expected %h | Got %h", 
                    word_count, expected_H[word_count], final_hash_words[word_count]);

                if (final_hash_words[word_count] !== expected_H[word_count]) begin
                    $display("   --> ERROR MISMATCH: Word %0d is incorrect!", word_count);
                    errors = errors + 1;
                end 
                
                byte_count = 0;
                word_count = word_count + 1;
                hash_word_reg = 0;
            end
            @(posedge clk);
        end

        $display("----------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS: SHA-256 Verilog matches C Reference!");
            $display("Final Hash: %h%h%h%h%h%h%h%h", 
                final_hash_words[0], final_hash_words[1], final_hash_words[2], final_hash_words[3],
                final_hash_words[4], final_hash_words[5], final_hash_words[6], final_hash_words[7]);
        end else begin
            $display("FAILURE: Found %0d mismatches.", errors);
        end
        $display("----------------------------------------");
        $stop;
    end
endmodule
