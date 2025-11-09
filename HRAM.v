`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2025 01:20:41 PM
// Design Name: 
// Module Name: HRAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: HRAM contains L x 8w x 32 bit
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module HRAM #(
    parameter DATA_WIDTH =32,
    parameter L=8
)
(
    input wire [DATA_WIDTH*8-1:0] i_hash,
    input wire clk,
    input wire i_RE, i_WE,
    
    output reg [DATA_WIDTH*8-1:0] o_hash
);
// Declare wire and reg
wire [DATA_WIDTH-1:0] i_hash_rg [0:L-1] [0:L-1];

// Declare the i_hash_rg is inital hash value
assign i_hash_rg [0] [0]= 32'h6a09e667;
assign i_hash_rg [0] [1]= 32'hbb67ae85;
assign i_hash_rg [0] [2]= 32'h3c6ef372;
assign i_hash_rg [0] [3]= 32'ha54ff53a;
assign i_hash_rg [0] [4]= 32'h510e527f;
assign i_hash_rg [0] [5]= 32'h9b05688c;
assign i_hash_rg [0] [6]= 32'h1f83d9ab;
assign i_hash_rg [0] [7]= 32'h5be0cd19;


endmodule
