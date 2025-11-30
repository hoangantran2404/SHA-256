`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2025 03:02:56 PM
// Design Name: 
// Module Name: MP_tb
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


`timescale 1ns/1ps

module MP_tb();
    parameter DATA_WIDTH    = 32;
    parameter TIMEOUT_LIMIT = 4340;

    reg                    clk;
    reg                    rst_n;
    reg  [7:0]             uart_byte_in;
    reg                    RX_dv_in;

    wire [DATA_WIDTH-1:0]  data_out_w;
    wire [7:0]             MP_counter_out_w;
    wire                   MP_dv_out_w;

    reg [7:0]              MP_byte_in[0:2];
    reg [31:0]             init_hash [0:15];
    integer i, errors;

    Message_Packer #(
        .DATA_WIDTH(DATA_WIDTH),
        .TIMEOUT_LIMIT(TIMEOUT_LIMIT)
    ) MP (
        .clk(clk), .rst_n(rst_n), .uart_byte_in(uart_byte_in), .Rx_DV_in(RX_dv_in), 
        .data_out(data_out_w), .MP_counter_out(MP_counter_out_w), .MP_dv_out(MP_dv_out_w)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        $display("========================================");
        $display("   TESTBENCH STARTING: SHA-256 MP       ");
        $display("========================================");

        MP_byte_in[0] = 8'h61; MP_byte_in[1] = 8'h62; MP_byte_in[2] = 8'h63;
        
        init_hash[0]  = 32'h61626380; 
        for(i=1; i<15; i=i+1) init_hash[i] = 32'h00000000;
        init_hash[15] = 32'h00000018;

        rst_n = 1; RX_dv_in = 0; uart_byte_in = 0; errors = 0;
        repeat(5) @(posedge clk); rst_n = 0;
        repeat(5) @(posedge clk); rst_n = 1;
        
        // --- SEND DATA ---
        for (i = 0; i < 3; i = i+1) begin
            uart_byte_in <= MP_byte_in[i]; 
            RX_dv_in <= 1;
            @(posedge clk); 
            RX_dv_in     <= 0;
            repeat(10) @(posedge clk); 
        end

        // --- WAIT FOR VALID ---
        $display("[Time %0t] Waiting for Valid...", $time);
        wait(MP_dv_out_w == 1);
        $display("[Time %0t] Valid Detected!", $time);

        #1; 
        if(data_out_w !== init_hash[0]) begin
            $display("[FAIL] Word 0 (Wait Cycle): Expected %h | Got %h", init_hash[0], data_out_w);
            errors = errors + 1;
        end else begin
            $display("[PASS] Word 0 (Wait Cycle): %h", data_out_w);
        end

       
        @(posedge clk); 
        #1;
       

        
        for (i = 1; i < 16 ; i = i+1 ) begin
            @(posedge clk); 
            #1;
            
            if(data_out_w !== init_hash[i]) begin
                $display("[FAIL] Word %0d: Expected %h | Got %h", i, init_hash[i], data_out_w);
                errors = errors + 1;
            end else begin
                $display("[PASS] Word %0d: %h", i, data_out_w); 
            end
        end
    
        if(errors == 0) 
            $display("SUCCESS: Message Packer works perfectly!");
        else
            $display("FAILURE: Found %0d mismatches", errors);
        $stop;
    end
endmodule
