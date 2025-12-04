`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2025 01:00:52 PM
// Design Name: 
// Module Name: UART_rx_tb
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

module tb_receiver;

    //==================================================//
    //              PARAMETERS & CONFIGURATION          //
    //==================================================//
    // Clock Frequency: 100 MHz => Period = 10ns
    parameter CLK_PERIOD      = 10;             
    
    // UART Baud Rate Configuration: 
    // 100,000,000 Hz / 115200 baud = 868.05 => Round to 868
    parameter CLKS_PER_BIT    = 868;            
    
    parameter BIT_PERIOD      = CLKS_PER_BIT * CLK_PERIOD; 

    //==================================================//
    //                 SIGNALS DECLARATION              //
    //==================================================//
    reg         CLK;
    reg         Rx_Serial_in;
    
    wire        Rx_DV_out;      
    wire [7:0]  Rx_Byte_out;   
    wire [7:0]  LED_out;        
    
    integer     received_count = 0; 
    reg         test_failed    = 0;

    //==================================================//
    //               DUT INSTANTIATION                  //
    //==================================================//
    receiver #(
        .CLKS_PER_BIT       (CLKS_PER_BIT) 
    ) uut (
        .CLK                (CLK), 
        .Rx_Serial_in       (Rx_Serial_in), 
        .Rx_DV_out          (Rx_DV_out), 
        .Rx_Byte_out        (Rx_Byte_out), 
        .LED_out            (LED_out)
    );

    //==================================================//
    //               CLOCK GENERATION                   //
    //==================================================//
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; 
    end

    //==================================================//
    //            TASK: UART SEND BYTE                  //
    //==================================================//

    task UART_SEND_BYTE;
        input [7:0] i_Data;
        integer     i;
        begin
            // 1. Send Start Bit (Drive Low)
            Rx_Serial_in = 1'b0;
            #(BIT_PERIOD);
            
            // 2. Send Data Bits (LSB First)
            for (i=0; i<8; i=i+1) begin
                Rx_Serial_in = i_Data[i];
                #(BIT_PERIOD);
            end
            
            // 3. Send Stop Bit (Drive High)
            Rx_Serial_in = 1'b1;
            #(BIT_PERIOD);
            

             #(BIT_PERIOD); 
        end
    endtask

    //==================================================//
    //            SELF-CHECKING LOGIC                   //
    //==================================================//
    // Automatically verifies the received data against expected values
    always @(posedge CLK) begin
        if (Rx_DV_out) begin
            case (received_count)
                0: begin
                    if (Rx_Byte_out == 8'b01100001) 
                        $display("[PASS] Byte 1: Received 'a' (0x61) - Correct.");
                    else begin
                        $display("[FAIL] Byte 1: Expected 'a' (0x61) but received 0x%h", Rx_Byte_out);
                        test_failed = 1;
                    end
                end

                1: begin 
                    if (Rx_Byte_out == 8'b01100010) 
                        $display("[PASS] Byte 2: Received 'b' (0x62) - Correct.");
                    else begin
                        $display("[FAIL] Byte 2: Expected 'b' (0x62) but received 0x%h", Rx_Byte_out);
                        test_failed = 1;
                    end
                end

                2: begin 
                    if (Rx_Byte_out == 8'b01100011) 
                        $display("[PASS] Byte 3: Received 'c' (0x63) - Correct.");
                    else begin
                        $display("[FAIL] Byte 3: Expected 'c' (0x63) but received 0x%h", Rx_Byte_out);
                        test_failed = 1;
                    end
                end
                
                default: begin
                    $display("[INFO] Received unexpected extra data: 0x%h", Rx_Byte_out);
                end
            endcase
            
            // Increment counter for next byte
            received_count = received_count + 1;
        end
    end

    //==================================================//
    //               MAIN STIMULUS                      //
    //==================================================//
    initial begin
        Rx_Serial_in = 1'b1;
        

        #100;
        
        $display("---------------------------------------------------");
        $display("STARTING UART RX TESTBENCH (Data: 'abc')");
        $display("---------------------------------------------------");

        $display("Time: %0t | Sending char 'a'...", $time);
        UART_SEND_BYTE(8'h61); 
        
        $display("Time: %0t | Sending char 'b'...", $time);
        UART_SEND_BYTE(8'h62); 

        $display("Time: %0t | Sending char 'c'...", $time);
        UART_SEND_BYTE(8'h63); 
        
        #5000;
        
        // Final Result Report
        $display("---------------------------------------------------");
        if (received_count == 3 && test_failed == 0)
            $display("FINAL RESULT: *** TEST PASSED ***");
        else
            $display("FINAL RESULT: *** TEST FAILED ***");
        $display("---------------------------------------------------");
        
        $stop;
    end

endmodule
