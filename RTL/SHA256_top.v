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
    input wire          clk,   
    input wire          rst_n,
    input wire          data_in,

    output wire         data_out
);
    //==================================================//
    //                      WIRE                        //
    //==================================================//
    wire        RX_dv_out_w         ;
    wire        MP_in_dv_out_w      ;
    wire        core_dv_out_w       ;
    wire        TX_active_w         ;
    wire        TX_done_w           ;
    wire        MP_out_dv_out_w     ;
    wire [7:0]  RX_data_out_w       ;
    wire [7:0]  MP_out_data_out_w   ;
    wire [31:0] MP_in_data_out_w    ;
    wire [31:0] core_data_out_w     ;
    
    //==================================================//
    //                  Instantiate                     //
    //==================================================//
    receiver UART_receiver(
                    .CLK            (clk                ),
                    .Rx_Serial_in   (data_in            ),
                    
                    .Rx_DV_out      (RX_dv_out_w        ),
                    .Rx_Byte_out    (RX_data_out_w      )
    );
        
    MP_in module_MP_in(
                    .clk            (clk                ),
                    .rst_n          (rst_n              ),
                    .RX_DV_in       (RX_dv_out_w        ),       
                    .uart_byte_in   (RX_data_out_w      ),        

                    .MP_data_out    (MP_in_data_out_w   ),
                    .MP_dv_out      (MP_in_dv_out_w     )
    );

    SHA256_core module_SHA256_core(
                    .clk            (clk                ), 
                    .rst_n          (rst_n              ), 
                    .MP_dv_in       (MP_in_dv_out_w     ),
                    .message_in     (MP_in_data_out_w   ),

                    .hash_out       (core_data_out_w    ),
                    .core_dv_flag   (core_dv_out_w      )
    );
    
    MP_out module_MP_out(
                    .clk            (clk                ),
                    .rst_n          (rst_n              ),
                    .core_byte_in   (core_data_out_w    ),
                    .TX_active_in   (TX_active_w        ),
                    .TX_done_in     (TX_done_w          ),
                    .RX_DV_in       (core_dv_out_w      ),

                    .MP_data_out    (MP_out_data_out_w  ),
                    .MP_dv_out      (MP_out_dv_out_w    )
    );                              

    transmitter UART_transmitter(
                    .CLK            (clk                ),
                    .Tx_DV_in       (MP_out_dv_out_w    ),
                    .Tx_Byte_in     (MP_out_data_out_w  ),

                    .Tx_Serial_out  (data_out           ),
                    .Tx_Done_out    (TX_done_w          ),
                    .Tx_Active_out  (TX_active_w        )
    );
endmodule
