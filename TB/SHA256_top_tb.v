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
module SHA256_top_tb;
    //==================================================//
    //                      PARAMETERS                  //
    //==================================================//
    parameter CLK_PERIOD      = 10;             
    parameter CLKS_PER_BIT    = 868;            
    parameter BIT_PERIOD      = CLKS_PER_BIT * CLK_PERIOD; 

    //==================================================//
    //                       SIGNALS                     //
    //==================================================//
    reg         clk;
    reg         rst_n;
    reg         data_in;
    wire        data_out;

    reg [7:0]   input_block [0:63]; 
    reg [7:0]   expected_hash [0:31];
    
    integer     error_count = 0;

    //==================================================//
    //                          DUT                     //
    //==================================================//
    SHA256_top uut (
        .clk            (clk), 
        .rst_n          (rst_n), 
        .data_in        (data_in), 
        .data_out       (data_out)
    );

    //==================================================//
    //                  CLOCK Generation                //
    //==================================================//
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    //==================================================//
    //                      DATA PREP                   //
    //==================================================//
    integer k;
    initial begin
        for (k = 0; k < 64; k = k + 1) input_block[k] = 8'h00;
        input_block[0] = 8'h61; // a
        input_block[1] = 8'h62; // b
        input_block[2] = 8'h63; // c
        input_block[3] = 8'h80; // Padding
        input_block[63] = 8'h18; // Length
        
        expected_hash[0]  = 8'hba; expected_hash[1]  = 8'h78; expected_hash[2]  = 8'h16; expected_hash[3]  = 8'hbf;
        expected_hash[4]  = 8'h8f; expected_hash[5]  = 8'h01; expected_hash[6]  = 8'hcf; expected_hash[7]  = 8'hea;
        expected_hash[8]  = 8'h41; expected_hash[9]  = 8'h41; expected_hash[10] = 8'h40; expected_hash[11] = 8'hde;
        expected_hash[12] = 8'h5d; expected_hash[13] = 8'hae; expected_hash[14] = 8'h22; expected_hash[15] = 8'h23;
        expected_hash[16] = 8'hb0; expected_hash[17] = 8'h03; expected_hash[18] = 8'h61; expected_hash[19] = 8'ha3;
        expected_hash[20] = 8'h96; expected_hash[21] = 8'h17; expected_hash[22] = 8'h7a; expected_hash[23] = 8'h9c;
        expected_hash[24] = 8'hb4; expected_hash[25] = 8'h10; expected_hash[26] = 8'hff; expected_hash[27] = 8'h61;
        expected_hash[28] = 8'hf2; expected_hash[29] = 8'h00; expected_hash[30] = 8'h15; expected_hash[31] = 8'had;
    end

    //==================================================//
    //                       TASKS                      //
    //==================================================//
    task UART_SEND_BYTE;
        input [7:0] i_Data;
        integer i;
        begin
            data_in = 1'b0; 
            #(BIT_PERIOD);
            for (i=0; i<8; i=i+1) begin
                data_in = i_Data[i];
                #(BIT_PERIOD);
            end
            data_in = 1'b1; 
            #(BIT_PERIOD);
            #(BIT_PERIOD); 
        end
    endtask

   
    task UART_RECEIVE_BYTE;
        output [7:0] o_Data;
        integer i;
        begin
            wait(data_out == 1'b0); 
            #(BIT_PERIOD + (BIT_PERIOD / 2)); 
            
            for (i=0; i<8; i=i+1) begin
                o_Data[i] = data_out;
                #(BIT_PERIOD);
            end
             #(BIT_PERIOD / 2);
        end
    endtask

    //==================================================//
    //                  TX PROCESS                      //
    //==================================================//
    integer tx_i;
    initial begin
        // Reset hệ thống
        rst_n   = 0;
        data_in = 1; 
        #100;
        rst_n   = 1;
        #100;

        $display("--------------------------------------------------");
        $display(" [TX] STARTING SENDING 64 BYTES...");
        
        for (tx_i = 0; tx_i < 64; tx_i = tx_i + 1) begin
            UART_SEND_BYTE(input_block[tx_i]);
        end
        
        $display(" [TX] FINISHED SENDING.");
    end

    //==================================================//
    //                  RX PROCESS                       //
    //==================================================//
 
    integer rx_i;
    reg [7:0] received_byte;
    
    initial begin

        #200; 
        
        $display(" [RX] RECEIVER LISTENING...");

        for (rx_i = 0; rx_i < 32; rx_i = rx_i + 1) begin
    
            UART_RECEIVE_BYTE(received_byte);
            
        
            if (received_byte !== expected_hash[rx_i]) begin
                $display("[RX] Byte %0d: 0x%h (Expected: 0x%h) --> ERROR", rx_i, received_byte, expected_hash[rx_i]);
                error_count = error_count + 1;
            end else begin
                $display("[RX] Byte %0d: 0x%h (OK)", rx_i, received_byte);
            end
        end

        
        #1000;
        $display("==================================================");
        if (error_count == 0) 
            $display(" RESULT: *** PASSED *** (Hash Match)");
        else 
            $display(" RESULT: *** FAILED *** (Errors: %0d)", error_count);
        $display("==================================================");
        $stop; 
    end

endmodule
