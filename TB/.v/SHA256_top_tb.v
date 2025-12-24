`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An 
//           ngotranhoangan2007@gmail.com
// Create Date: 11/30/2025 03:32:03 PM
// Design Name: 
// Module Name: SHA256_top_tb
// Project Name: SHA256
// Target Devices: 
// Tool Versions: 
// Description: I load 16 bytes of string " Secure Hash Algorithm 256" to verify the activation of my project SHA-256.
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

    reg [255:0] received_hash_full;
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
        for (k = 0; k < 64; k = k + 1) input_block[k] = 8'h00; // Secure Hash Algorithm 256
        input_block[0]  = 8'h53; // S
        input_block[1]  = 8'h65; // e
        input_block[2]  = 8'h63; // c
        input_block[3]  = 8'h75; // u
        input_block[4]  = 8'h72; // r
        input_block[5]  = 8'h65; // e
        input_block[6]  = 8'h20; // Space

       
        input_block[7]  = 8'h48; // H
        input_block[8]  = 8'h61; // a
        input_block[9]  = 8'h73; // s
        input_block[10] = 8'h68; // h
        input_block[11] = 8'h20; // Space

      
        input_block[12] = 8'h41; // A
        input_block[13] = 8'h6C; // l
        input_block[14] = 8'h67; // g
        input_block[15] = 8'h6F; // o
        input_block[16] = 8'h72; // r
        input_block[17] = 8'h69; // i
        input_block[18] = 8'h74; // t
        input_block[19] = 8'h68; // h
        input_block[20] = 8'h6D; // m
        input_block[21] = 8'h20; // Space

     
        input_block[22] = 8'h32; // 2
        input_block[23] = 8'h35; // 5
        input_block[24] = 8'h36; // 6

     
        input_block[25] = 8'h80; 
        input_block[63] = 8'hC8; 
        
        // 5f806d26 1a579f2e eea47739 6394699a c2deaf34 2ec8da3b 189d8427 25a4a697
        expected_hash[0]  = 8'h5f; expected_hash[1]  = 8'h80; expected_hash[2]  = 8'h6d; expected_hash[3]  = 8'h26;
        expected_hash[4]  = 8'h1a; expected_hash[5]  = 8'h57; expected_hash[6]  = 8'h9f; expected_hash[7]  = 8'h2e;
        expected_hash[8]  = 8'hee; expected_hash[9]  = 8'ha4; expected_hash[10] = 8'h77; expected_hash[11] = 8'h39;
        expected_hash[12] = 8'h63; expected_hash[13] = 8'h94; expected_hash[14] = 8'h69; expected_hash[15] = 8'h9a;
        expected_hash[16] = 8'hc2; expected_hash[17] = 8'hde; expected_hash[18] = 8'haf; expected_hash[19] = 8'h34;
        expected_hash[20] = 8'h2e; expected_hash[21] = 8'hc8; expected_hash[22] = 8'hda; expected_hash[23] = 8'h3b;
        expected_hash[24] = 8'h18; expected_hash[25] = 8'h9d; expected_hash[26] = 8'h84; expected_hash[27] = 8'h27;
        expected_hash[28] = 8'h25; expected_hash[29] = 8'ha4; expected_hash[30] = 8'ha6; expected_hash[31] = 8'h97;
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
    //                  RX PROCESS                      //
    //==================================================//
 
    integer rx_i;
    reg [7:0] received_byte;
    
    initial begin

        #200; 
        received_hash_full = 256'b0;
        
        $display(" [RX] RECEIVER LISTENING...");

        for (rx_i = 0; rx_i < 32; rx_i = rx_i + 1) begin
    
            UART_RECEIVE_BYTE(received_byte);
            
        
            if (received_byte !== expected_hash[rx_i]) begin
                $display("[RX] Byte %0d: 0x%h (Expected: 0x%h) --> ERROR", rx_i, received_byte, expected_hash[rx_i]);
                error_count = error_count + 1;
            end else begin
                $display("[RX] Byte %0d: 0x%h (OK)", rx_i, received_byte);
            end

            received_hash_full[(31 - rx_i)*8 +: 8] = received_byte;
        end

        
        #1000;
        $display("==================================================");
        if (error_count == 0) begin
            $display(" RESULT: *** PASSED *** (Hash Match)");
        $display("--------------------------------------------------");
            $display(" FULL HASH: %h", received_hash_full);
        end else 
            $display(" RESULT: *** FAILED *** (Errors: %0d)", error_count);
        $display("==================================================");
        $stop; 
    end

endmodule
