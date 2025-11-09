`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2025 12:07:14 PM
// Design Name: 
// Module Name: WRAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: WRAM contains L x 64 words x 32 bits
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module WRAM #(
        parameter DATA_WIDTH =32,
        parameter L =8 // L hash function
)
(
    input wire  [DATA_WIDTH*64-1:0] i_in,
    input wire                    clk,
    input wire  [$clog2(L)-1:0]  hash_address,// $clog2(L) using in generate L different items 
    input wire                    i_WE,
    input wire                    i_RE,

    output reg  [DATA_WIDTH*64-1:0] o_result 
);
// Declare reg and wire
reg [DATA_WIDTH-1:0] i_wram_rg [0:L-1] [0:63];
integer i;
    always @(posedge clk) begin
// It will paste or copy entirely 32 words in 1 clock cycle
        if( i_WE) begin 

            // We have to use the for loop because it is patse every bit not a serial
            for (i=0; i<64; i=i + 1) begin
                i_wram_rg[hash_address] [i] <= i_in[i*DATA_WIDTH+:DATA_WIDTH];//Paste every word(32bit/words)
            end
        end else if (i_RE) begin

            for (i=0; i<64; i=i + 1) begin
                o_result[i*DATA_WIDTH+:DATA_WIDTH]<= i_wram_rg[hash_address] [i];
            end  

        end
    end

endmodule
