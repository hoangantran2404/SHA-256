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
    input wire          UART_done_flag,
    input wire [7:0]    UART_data_out,

    output wire [7:0]   SHA_core_out,
    output wire         SHA_dv_flag
);

wire [31:0] MP_data_out    ;
wire        MP_dv_flag     ;

Message_Packer module_message_packer(
                .clk            (clk           ),
                .rst_n          (rst_n         ),
                .RX_DV_in       (UART_done_flag),       
                .uart_byte_in   (UART_data_out ),        

                .data_out       (MP_data_out   ),
                .MP_dv_out      (MP_dv_flag    )

);



SHA256_core module_SHA256_core(
                .clk            (clk          ), 
                .rst_n          (rst_n        ), 
                .MP_dv_in       (MP_dv_flag   ),
                .message_in     (MP_data_out  ),

                .hash_out       (SHA_core_out ),
                .core_dv_flag   (SHA_dv_flag  )
);

endmodule
