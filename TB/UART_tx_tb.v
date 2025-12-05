`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2025 01:50:53 PM
// Design Name: 
// Module Name: UART_tx_tb
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

`timescale 1ns / 1ps

module UART_tx_tb;

    //==================================================//
    //              PARAMETERS & CONFIGURATION          //
    //==================================================//
    parameter CLK_PERIOD    = 10;               
    parameter CLKS_PER_BIT  = 868;              
    parameter BIT_PERIOD    = CLK_PERIOD * CLKS_PER_BIT;

    //==================================================//
    //                 SIGNALS DECLARATION              //
    //==================================================//
    reg             CLK;
    reg             Tx_DV_in;      
    reg [7:0]       Tx_Byte_in;    

    wire            Tx_Active_out;  
    wire            Tx_Serial_out;  
    wire            Tx_Done_out;    


    reg [7:0]       decoded_byte;   

    //==================================================//
    //               DUT INSTANTIATION                  //
    //==================================================//
    transmitter #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uut (
        .CLK           (CLK),
        .Tx_DV_in      (Tx_DV_in),
        .Tx_Byte_in    (Tx_Byte_in),
        .Tx_Active_out (Tx_Active_out),
        .Tx_Serial_out (Tx_Serial_out),
        .Tx_Done_out   (Tx_Done_out)
    );

    //==================================================//
    //               CLOCK GENERATION                   //
    //==================================================//
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    //==================================================//
    //           TASK: DRIVE TRANSMITTER                //
    //==================================================//
 
    task SEND_BYTE_TO_TX;
        input [7:0] i_Data;
        begin
            @(posedge CLK);
            $display("Time: %0t | System requests sending: '%c' (0x%h)", $time, i_Data, i_Data);
            
            Tx_Byte_in <= i_Data;
            Tx_DV_in   <= 1'b1;  
            @(posedge CLK);
            Tx_DV_in   <= 1'b0; 
            
          
            @(posedge Tx_Done_out);
            $display("Time: %0t | UART TX reported DONE.", $time);
            
            #2000; 
        end
    endtask

    //==================================================//
    //           TASK: SOFTWARE SERIAL RECEIVER         //
    //==================================================//
    task VERIFY_SERIAL_OUTPUT;
        input [7:0] expected_data;
        integer i;
        begin
            // 1. Wait for Start Bit (Falling Edge on Tx_Serial_out)
            wait(Tx_Serial_out == 1'b0);
            
            // 2. Wait 1.5 bit periods to align with the center of Bit 0
            #(BIT_PERIOD + (BIT_PERIOD / 2));
            
            // 3. Sample 8 Data Bits
            for (i=0; i<8; i=i+1) begin
                decoded_byte[i] = Tx_Serial_out;
                #(BIT_PERIOD);
            end
            
            // 4. Verify Stop Bit (Should be 1)
            if (Tx_Serial_out == 1'b1) begin
                if (decoded_byte == expected_data)
                    $display("[PASS] Serial Line Check: Output matched expected 0x%h ('%c')", expected_data, expected_data);
                else
                    $display("[FAIL] Serial Line Check: Expected 0x%h but saw 0x%h", expected_data, decoded_byte);
            end else begin
                $display("[FAIL] Stop Bit missing or incorrect timing!");
            end
        end
    endtask

    //==================================================//
    //            MAIN TEST SEQUENCE                    //
    //==================================================//
    
    // Process 1: Driving the DUT inputs
    initial begin
        Tx_DV_in   = 0;
        Tx_Byte_in = 0;
        
        #100; // Wait for reset/stable
        $display("--------------------------------------");
        $display(" STARTING UART TX TESTBENCH ");
        $display("--------------------------------------");

        // Send 'a'
        SEND_BYTE_TO_TX(8'h61);

        // Send 'b'
        SEND_BYTE_TO_TX(8'h62);

        // Send 'c'
        SEND_BYTE_TO_TX(8'h63);

        #1000;
        $display("--------------------------------------");
        $display(" TEST COMPLETED ");
        $display("--------------------------------------");
        $stop;
    end

    initial begin
        // Waits to verify 'a'
        VERIFY_SERIAL_OUTPUT(8'h61);
        
        // Waits to verify 'b'
        VERIFY_SERIAL_OUTPUT(8'h62);
        
        // Waits to verify 'c'
        VERIFY_SERIAL_OUTPUT(8'h63);
    end

endmodule
