`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2025 04:37:13 PM
// Design Name: 
// Module Name: SHA256_top
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
module SHA256_top(
    input wire          clk,   // ZCU102 clock input
    input wire          rst_n,
    input wire          data_in,

    output wire         data_out
);
    //==================================================//
    //                   Registers                      //
    //==================================================//
    wire [31:0] MP_data_out     ;
    wire        MP_dv_flag      ;
    wire        UART_done_flag  ;
    wire [7:0]  UART_rx_out     ;
    wire [7:0]  SHA_core_out    ;
    wire        SHA_dv_flag     ;
    wire        Tx_Done_w       ;
    wire        Tx_Active_w     ;
    //==================================================//
    //                  Instantiate                     //
    //==================================================//
receiver UART_receiver(
                .CLK            (clk            ),
                .Rx_Serial_in   (data_in        ),
                
                .Rx_DV_out      (UART_done_flag ),
                .Rx_Byte_out    (UART_rx_out    )
);
    

Message_Packer module_message_packer(
                .clk            (clk           ),
                .rst_n          (rst_n         ),
                .RX_DV_in       (UART_done_flag),       
                .uart_byte_in   (UART_rx_out   ),        

                .data_out       (MP_data_out   ),
                .MP_dv_out      (MP_dv_flag    )

);


SHA256_core module_SHA256_core(
                .clk            (clk          ), 
                .rst_n          (rst_n        ), 
                .Tx_Active_in   (Tx_Active_w  ),
                .Tx_Done_in     (Tx_Done_w    ),
                .MP_dv_in       (MP_dv_flag   ),
                .message_in     (MP_data_out  ),

                .hash_out       (SHA_core_out ),
                .core_dv_flag   (SHA_dv_flag  )
);

transmitter UART_transmitter(
                .CLK            (clk         ),
                .Tx_DV_in       (SHA_dv_flag ),
                .Tx_Byte_in     (SHA_core_out),

                .Tx_Serial_out  (data_out    ),
                .Tx_Done_out    (Tx_Done_w   ),
                .Tx_Active_out  (Tx_Active_w )
);

endmodule
