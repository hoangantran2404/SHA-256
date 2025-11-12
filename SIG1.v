`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 11/11/2025 12:40:47 PM
// Design Name: 
// Module Name: SIG1
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


module SIG1#(
    parameter DATA_WIDTH =32
)
(
    input wire [DATA_WIDTH-1:0] S_SIG1_in,
    output wire [DATA_WIDTH-1:0] D_SIG1_out
);
wire [DATA_WIDTH-1:0] ROTR17_w, ROTR19_w;
wire [DATA_WIDTH-1:0] SHR10_w;

assign ROTR17_w   = {S_SIG1_in[16:0] ,S_SIG1_in[DATA_WIDTH-1:17]};
assign ROTR19_w   = {S_SIG1_in[18:0] ,S_SIG1_in[DATA_WIDTH-1:19]};
assign SHR10_w    = {{10{1'b0}}     ,S_SIG1_in[DATA_WIDTH-1:10]}; 

assign D_SIG1_out = ROTR17_w ^ ROTR19_w ^ SHR10_w;

endmodule
