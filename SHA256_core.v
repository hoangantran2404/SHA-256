`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 11/11/2025 05:04:58 PM
// Design Name: 
// Module Name: SHA256_core
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


module SHA256_core#(
    parameter DATA_WIDTH =32
)
(   
    input wire clock, reset_n, load,
    input wire [DATA_WIDTH-1:0] message0,
    input wire [DATA_WIDTH-1:0] message1,
    input wire [DATA_WIDTH-1:0] message2,
    input wire [DATA_WIDTH-1:0] message3,
    input wire [DATA_WIDTH-1:0] message4,
    input wire [DATA_WIDTH-1:0] message5,
    input wire [DATA_WIDTH-1:0] message6,
    input wire [DATA_WIDTH-1:0] message7,
    input wire [DATA_WIDTH-1:0] message8,
    input wire [DATA_WIDTH-1:0] message9,
    input wire [DATA_WIDTH-1:0] message10,
    input wire [DATA_WIDTH-1:0] message11,
    input wire [DATA_WIDTH-1:0] message12,
    input wire [DATA_WIDTH-1:0] message13,
    input wire [DATA_WIDTH-1:0] message14,
    input wire [DATA_WIDTH-1:0] message15,

    output wire [DATA_WIDTH-1:0] o_0,
    output wire [DATA_WIDTH-1:0] o_1,
    output wire [DATA_WIDTH-1:0] o_2,
    output wire [DATA_WIDTH-1:0] o_3,
    output wire [DATA_WIDTH-1:0] o_4,
    output wire [DATA_WIDTH-1:0] o_5,
    output wire [DATA_WIDTH-1:0] o_6,
    output wire [DATA_WIDTH-1:0] o_7,
    output wire valid_out
);
// Internal signal
wire [1:0] FSM_state_w;
wire [5:0] round_w;
wire [DATA_WIDTH-1:0] message_out;
wire load;

rME # (
    .DATA_WIDTH(DATA_WIDTH)
) Message_Expansion
(
    .i_m0         (message0),
    .i_m1         (message1),
    .i_m2         (message2),
    .i_m3         (message3),
    .i_m4         (message4),
    .i_m5         (message5),
    .i_m6         (message6),
    .i_m7         (message7),
    .i_m8         (message8),
    .i_m9         (message9),
    .i_m10        (message10),
    .i_m11        (message11),
    .i_m12        (message12),
    .i_m13        (message13),
    .i_m14        (message14),
    .i_m15        (message15),

    .clk          (clock),
    .rst_n        (reset_n),
    .start_in     (load),
    .o_message    (message_out),
    .o_round      (round_w),
    .o_FSM_state  (FSM_state_w)
);

MC #(
    .DATA_WIDTH(DATA_WIDTH)
)  Message_Compression
(
    .clk           (clock),
    .rst_n         (reset_n),
    .start_in      (load),
    .data_in       (message_out),
    .FSM_state_in  (FSM_state_w),
    .round_in      (round_w), 
    .out0          (o_0),
    .out1          (o_1),
    .out2          (o_2),
    .out3          (o_3),
    .out4          (o_4),
    .out5          (o_5),
    .out6          (o_6),
    .out7          (o_7),
    .valid_out     (valid_out)
);
endmodule


