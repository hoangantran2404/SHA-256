`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 09:46:19 AM
// Design Name: 
// Module Name: SHA_256_core_tb
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


module SHA_256_core_tb();
    parameter DATA_WIDTH = 32;

    reg                             clk, rst_n  ;
    reg                             start_in    ;
    reg [DATA_WIDTH -1: 0]          data_in     ;

    wire [7:0]                      data_out    ;
    wire                            dv_flag     ;

    reg [DATA_WIDTH-1 :0]           core_byte_in [0:15];
    reg [DATA_WIDTH-1 :0]           expected_H   [0:7] ;
    reg [31:0]                      final_hash   [0:7] ; 
    reg [31:0]                      hash_word          ;
    reg [4:0]                       word_count         ;
    reg [2:0]                       byte_count         ;

    integer i, errors;

    //==================================================//
    //                   DUT                            //
    //==================================================//
    SHA256_core #(
        .DATA_WIDTH(DATA_WIDTH)
    ) SHA_256_core (
        .clk            (clk),
        .rst_n          (rst_n),
        .MP_dv_in       (start_in),
        .message_in     (data_in),

        .hash_out       (data_out),
        .core_dv_flag   (dv_flag)
    );

    //==================================================//
    //                   Clock generation               //
    //==================================================//
    initial begin 
        clk = 0;
        forever #5 clk = ~clk;
    end

    //==================================================//
    //                   Main test sequence             //
    //==================================================//
    initial begin
        $display("========================================");
        $display("   TESTBENCH STARTING: SHA-256 CORE     ");
        $display("========================================");

  
        $readmemh("/home/hoangan2404/Project_0/code_C/Project_SHA256/expected_H.txt", expected_H);
        core_byte_in[0]  = 32'h61626380; 
        core_byte_in[1]  = 32'h00000000;
        core_byte_in[2]  = 32'h00000000;
        core_byte_in[3]  = 32'h00000000;
        core_byte_in[4]  = 32'h00000000;
        core_byte_in[5]  = 32'h00000000;
        core_byte_in[6]  = 32'h00000000;
        core_byte_in[7]  = 32'h00000000;
        core_byte_in[8]  = 32'h00000000;
        core_byte_in[9]  = 32'h00000000;
        core_byte_in[10] = 32'h00000000;
        core_byte_in[11] = 32'h00000000;
        core_byte_in[12] = 32'h00000000;
        core_byte_in[13] = 32'h00000000;
        core_byte_in[14] = 32'h00000000;
        core_byte_in[15] = 32'h00000018;

        initialize_inputs();
        

        @(posedge clk); 
        rst_n = 0;
        @(posedge clk); 
        rst_n = 1;

        $display("[Time %0t] Loading Input Data...", $time);
        

        start_in = 1;
        repeat(3) @(posedge clk);

        for (i = 0; i < 16; i = i+1) begin
            data_in = core_byte_in[i];
            @(posedge clk); 
        end
        start_in = 0;
        data_in  = 32'd0;

        $display("[Time %0t] Waiting for Core Calculation...", $time);
        

        @(posedge dv_flag);
        $display("[Time %0t] Data Valid Detected. Collecting Hash...", $time);
   
        byte_count  = 0;
        word_count  = 0;
        hash_word   = 0;
        errors      = 0;

        for(i = 0; i < 32; i = i + 1) begin

            #1; 
            hash_word = {hash_word[23:0], data_out};
            byte_count = byte_count + 1;

            @(posedge clk);

            // 3. Process completed word
            if(byte_count == 4) begin
                final_hash[word_count] = hash_word;
                
                if (hash_word !== expected_H[word_count]) begin
                    $display("   --> ERROR MISMATCH!");
                    errors = errors + 1;
                end else begin
                    $display("Word %0d: Expected %h | Got %h [MATCH]", word_count, expected_H[word_count], hash_word);
                end
                byte_count = 0;
                word_count = word_count + 1;
                hash_word  = 0;
            end
        end

        $display("----------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS: SHA-256 Verilog matches C Reference!");
            $display("Final Hash: %h%h%h%h%h%h%h%h", 
                final_hash[0], final_hash[1], final_hash[2], final_hash[3],
                final_hash[4], final_hash[5], final_hash[6], final_hash[7]);
        end else begin
            $display("FAILURE: Found %0d mismatches.", errors);
        end
        $display("----------------------------------------");
        #1000
        $stop;
    end

    task initialize_inputs;
        begin
            rst_n       = 1;
            start_in    = 0;
            data_in     = 0;
            errors      = 0;
            byte_count  = 0;
            word_count  = 0;
            hash_word   = 0;
        end
    endtask

endmodule
