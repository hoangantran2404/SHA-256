`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 11/11/2025 12:06:36 PM
// Design Name: 
// Module Name: SIG0
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


module SIG0 #(
    parameter DATA_WIDTH =32
)
(
    input wire  [DATA_WIDTH-1:0] S_SIG0_in,
    output wire [DATA_WIDTH-1:0] D_SIG0_out
);
wire [DATA_WIDTH-1:0] ROTR7_w, ROTR18_w;
wire [DATA_WIDTH-1:0] SHR3_w;

assign ROTR7_w    = {S_SIG0_in[6:0] ,S_SIG0_in[DATA_WIDTH-1:7]};
assign ROTR18_w   = {S_SIG0_in[17:0],S_SIG0_in[DATA_WIDTH-1:18]};
assign SHR3_w     = {{3{1'b0}}      ,S_SIG0_in[DATA_WIDTH-1:3]}; // Syntax Error: 3{1'b0}

assign D_SIG0_out = ROTR7_w ^ ROTR18_w ^ SHR3_w;
endmodule
