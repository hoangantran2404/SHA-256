`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2025 03:59:05 PM
// Design Name: 
// Module Name: maj
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


module maj#(
    parameter DATA_WIDTH =32
)
(
    input wire [DATA_WIDTH-1:0] in0,
    input wire [DATA_WIDTH-1:0] in1,
    input wire [DATA_WIDTH-1:0] in2,

    output wire [DATA_WIDTH-1:0] data_out
);
    assign data_out= (in0 & in1) ^ (in0 & in2) ^ (in1 & in2);
    
endmodule
