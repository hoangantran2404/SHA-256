`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 11/29/2025 03:02:56 PM
// Design Name: Message Packer_ testbench
// Module Name: MP_tb
// Project Name: SHA256
// Target Devices: ZCU102 
// Tool Versions: Vivado 2022.2
// Description: The module verifies the activities of module Message Packer in RTL. 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module MP_tb;

    //==================================================//
    //                      Parameter                   //
    //==================================================//
    parameter DATA_WIDTH = 32;

    //==================================================//
    //                      Signal                      //
    //==================================================//
    reg clk;
    reg rst_n;
    reg [7:0] uart_byte_in;
    reg RX_DV_in;

    wire [DATA_WIDTH-1:0] data_out;
    wire MP_dv_out;

    reg [7:0] test_data [0:63]; 
    integer i;

    //==================================================//
    //                        DUT                       //
    //==================================================//
    Message_Packer uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .uart_byte_in(uart_byte_in), 
        .RX_DV_in(RX_DV_in), 
        .data_out(data_out), 
        .MP_dv_out(MP_dv_out)
    );

    //==================================================//
    //           Clock Generation                       //
    //==================================================//
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //==================================================//
    //                      Task                       //
    //==================================================//
    task SEND_BYTE;
        input [7:0] i_Data;
        begin
            @(posedge clk);
            uart_byte_in = i_Data;
            RX_DV_in     = 1;       
            @(posedge clk);
            RX_DV_in     = 0;      
       
            #50; 
        end
    endtask

    //==================================================//
    //                  LOAD DATA                       //
    //==================================================//
    initial begin
     
        for (i = 0; i < 64; i = i + 1) begin
            test_data[i] = 8'h00;
        end

       
        test_data[0] = 8'h61; 
        test_data[1] = 8'h62; 
        test_data[2] = 8'h63;
        test_data[3] = 8'h80;

    
        test_data[63] = 8'h18; 
    end

    //==================================================//
    //           Main Test Sequence                     //
    //==================================================//
    initial begin
     
        rst_n = 0;
        uart_byte_in = 0;
        RX_DV_in = 0;
        #100;
        rst_n = 1;
        #100;

        $display("-------------------------------------------");
        $display(" BAT DAU TEST MESSAGE PACKER (Input: 'abc')");
        $display("-------------------------------------------");

        for (i = 0; i < 64; i = i + 1) begin
            SEND_BYTE(test_data[i]);
        end

        $display("-------------------------------------------");
        $display(" [INFO] Da gui xong 64 bytes. Dang cho Output...");

    
        wait(MP_dv_out == 1);
        
  
        #500;

        $display("-------------------------------------------");
        $display(" TEST HOAN THANH ");
        $display("-------------------------------------------");
        $stop;
    end
    
    //==================================================//
    //                    MONITOR                       //
    //==================================================//

    integer word_count = 0;
    
    always @(posedge clk) begin
        if (MP_dv_out) begin
            $display("Time: %0t | Word %0d: 0x%h", $time, word_count, data_out);
            
            case (word_count)
                0: if (data_out !== 32'h61626380) $display("   --> LOI! Word 0 sai. Mong doi: 61626380");
                   else $display("   --> Word 0 OK (abc + padding)");
                
                15: if (data_out !== 32'h00000018) $display("   --> LOI! Word 15 sai. Mong doi: 00000018");
                    else $display("   --> Word 15 OK (Length = 24 bits)");
            endcase

            word_count = word_count + 1;
        end
    end

endmodule
