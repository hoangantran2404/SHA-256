`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2025 04:15:37 PM
// Design Name: 
// Module Name: EP1
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


module EP1 #(
    parameter DATA_WIDTH= 32
)
(
    input wire [DATA_WIDTH-1:0] data_in,

    output wire [DATA_WIDTH-1:0] data_out
);
wire [DATA_WIDTH-1:0] ROTR6_w, ROTR11_w, ROTR25_w;

assign ROTR6_w = {data_in[5:0],data_in[DATA_WIDTH-1:6]};
assign ROTR11_w ={data_in[10:0], data_in[DATA_WIDTH-1:11]};
assign ROTR25_w ={data_in[24:0], data_in[DATA_WIDTH-1:25]};

assign data_out= ROTR6_w ^ ROTR11_w ^ ROTR25_w;
endmodule
