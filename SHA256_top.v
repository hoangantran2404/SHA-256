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
    input  wire clk,   // ZCU102 clock input
    input  wire rst_n,
    input  wire uart_rx_pin,

    output wire hash_out 
);


//UART Receiver
wire [7:0]  UART_data_out  ;
wire        UART_done_flag ;
//Message Packer
wire [31:0] MP_data_out    ;
wire        MP_dv_flag     ;
//SHA256_core
wire [7:0]  SHA_core_out   ;
wire        SHA_dv_flag    ;

// Instantiate UART Receiver
receiver module_receiver (
     			.CLK            (clk            ),
		        .Rx_Serial_in   (uart_rx_pin    ),

                .Rx_DV_out      (UART_done_flag ),
                .Rx_Byte_out    (UART_data_out  )

);

// Instantiate message packer
Message_Packer module_message_packer(
                .clk            (clk           ),
                .rst_n          (rst_n         ),
                .Rx_DV          (UART_done_flag),       
                .uart_byte_in   (UART_data_out ),        

                .data_out       (MP_data_out   ),
                .data_valid     (MP_dv_flag    )  
);

// Instantiate SHA256_core
SHA256_core module_SHA256_core(
                .clk            (clk          ), 
                .rst_n          (rst_n        ), 
                .MP_dv          (MP_dv_flag   ),
                .message_in     (MP_data_out  ),

                .hash_out       (SHA_core_out ),
                .core_dv_flag   (SHA_dv_flag  )
);

// Instantiate UART Transmitter
transmitter module_transmitter(
                .CLK            (clk          ),
                .Tx_DV_in       (SHA_dv_flag  ),
                .Tx_Byte_in     (SHA_core_out ),

                .Tx_Serial_out  (hash_out     )
             
);
endmodule
