`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 11/11/2025 04:03:21 PM
// Design Name: 
// Module Name: EP0
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


module EP0 #(
    parameter DATA_WIDTH =32
)
(
    input wire [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out
);
wire [DATA_WIDTH-1:0] ROTR2_w, ROTR13_w, ROTR22_w;


assign ROTR2_w=  {data_in[1:0] , data_in[DATA_WIDTH -1:2]};
assign ROTR13_w= {data_in[12:0], data_in[DATA_WIDTH -1:13]};
assign ROTR22_w= {data_in[21:0], data_in[DATA_WIDTH -1:22]};

assign data_out= ROTR2_w ^ ROTR13_w ^ ROTR22_w;

endmodule
