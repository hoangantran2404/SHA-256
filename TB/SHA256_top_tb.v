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
    //==================================================//
    //              PARAMETERS & CONFIGURATION          //
    //==================================================//
    parameter CLK_PERIOD    = 10;
    parameter CLKS_PER_BIT  = 868;
    parameter BIT_PERIOD    = CLK_PERIOD * CLKS_PER_BIT;

    //==================================================//
    //                 SIGNALS DECLARATION              //
    //==================================================//
    reg clk;
    reg rst_n;
    reg data_in;
    
    wire data_out;

    reg [7:0] expected_hash [0:31];
    reg [7:0] received_hash [0:31];
    
    integer     byte_idx;
    integer     error_count = 0;
   
    //==================================================//
    //               DUT INSTANTIATION                  //
    //==================================================//
    SHA256_top SHA256(
        .clk        (clk),
        .rst_n      (rst_n),
        .data_in    (data_in),

        .data_out   (data_out)
    );
    //==================================================//
    //               CLOCK GENERATION                   //
    //==================================================//
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    //==================================================//
    //                      TASK                        //
    //==================================================//
    task send_top_byte;
        input [7:0] message_in;
        integer i;
        begin

            data_in = 1'b0;
            #(BIT_PERIOD);

            for(i=0; i< 8; i= i+1) begin
                data_in = message_in[i];
                #(BIT_PERIOD);
            end

            data_in = 1'b1;
            #(BIT_PERIOD);

            #(BIT_PERIOD);
        end
    endtask

    task receive_top_byte;
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
    //             Golden Initialization                //
    //==================================================//
    initial begin
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
    //           MAIN TEST SEQUENCE                     //
    //==================================================//
    initial begin
        rst_n       = 1'b0;
        data_in     = 1;
        #100
        rst_n       = 1'b1;
        #100

        $display("==================================================");
        $display("     STARTING SHA256 SYSTEM TEST (UART)           ");
        $display("==================================================");

        
        $display("[PC -> FPGA] Sending: 'a' (0x61)");
        send_top_byte(8'h61);
        
        $display("[PC -> FPGA] Sending: 'b' (0x62)");
        send_top_byte(8'h62);
        
        $display("[PC -> FPGA] Sending: 'c' (0x63)");
        send_top_byte(8'h63);

        $display("--------------------------------------------------");
        $display("[INFO] Transmission complete. Waiting for FPGA calculation and response...");
        
       
        for (byte_idx = 0; byte_idx < 32; byte_idx = byte_idx + 1) begin
           
            receive_top_byte(received_hash[byte_idx]);
            
            $display("[FPGA -> PC] Byte %0d/32: Received 0x%h | Expected 0x%h", 
                     byte_idx + 1, received_hash[byte_idx], expected_hash[byte_idx]);
                     
            if (received_hash[byte_idx] !== expected_hash[byte_idx]) begin
                $display("   --> ERROR! Mismatch at this byte.");
                error_count = error_count + 1;
            end
        end

      
        #1000;
        $display("==================================================");
        if (error_count == 0) begin
            $display("   FINAL RESULT: *** TEST PASSED ***");
            $display("   Hash for 'abc' is completely correct!");
        end else begin
            $display("   FINAL RESULT: *** TEST FAILED ***");
            $display("   Total incorrect bytes: %0d", error_count);
        end
        $display("==================================================");
        
        $stop;

    end



endmodule
