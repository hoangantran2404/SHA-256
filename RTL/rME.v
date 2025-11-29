`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 11/10/2025 10:12:33 PM
// Design Name: 
// Module Name: ME
// Project Name: SHA-256 
// Target Devices: ZCU102 
// Tool Versions: Vivado 2022 on Linux
// Description: rME receives 1 Word (32 bit/ 1 clock cycle) from SHA-256 core and generate W[16:63] based on initial W[0:15]
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rME #(
    parameter DATA_WIDTH =32
) 
(
    input wire                   clk,
    input wire                   rst_n,
    input wire                   start_in,
    input wire [2:0]             FSM_core_in,
    input wire [6:0]             core_count_in, // Count how many word pass from Core to ME
    input wire [DATA_WIDTH-1:0]  data_in,
    
    output wire [DATA_WIDTH-1:0]  data_out,
    output reg                    ME_dv_out
);
    //==================================================//
    //                   Registers                      //
    //==================================================//
    reg  [DATA_WIDTH-1:0] address_r [0:63]  ; 
    
    wire [DATA_WIDTH-1:0] i_sig0_w, i_sig1_w;
    wire [DATA_WIDTH-1:0] o_sig0_w          ;
    wire [DATA_WIDTH-1:0] o_sig1_w          ;
    wire [DATA_WIDTH-1:0] data_out_r        ; 
    wire [6:0]            round_count_w     ;

    //==================================================//
    //             Combinational Logic                  //
    //==================================================//
    assign round_count_w   = core_count_in;

    assign i_sig0_w        = (FSM_core_in == 3'b011 && round_count_w >= 7'd15)? address_r[round_count_w - 7'd15] : {DATA_WIDTH{1'b0}} ;
    assign i_sig1_w        = (FSM_core_in == 3'b011 && round_count_w >= 7'd2)?  address_r[round_count_w - 7'd2]  : {DATA_WIDTH{1'b0}} ;
    
    
    assign data_out_r      = address_r[round_count_w - 7'd16 ] + o_sig0_w + address_r[round_count_w - 7'd7] + o_sig1_w;  

    assign data_out        = (FSM_core_in == 3'b011) ? ((round_count_w < 16) ? address_r[round_count_w] : data_out_r) : 32'd0;
    //==================================================//
    //             Instantiate module                   //
    //==================================================//
    SIG0 #(
            .DATA_WIDTH(DATA_WIDTH)
        ) sig0_inst (
            .S_SIG0_in(i_sig0_w), 
            .D_SIG0_out(o_sig0_w)
        );
    SIG1 #(
            .DATA_WIDTH(DATA_WIDTH)
        ) sig1_inst (
            .S_SIG1_in(i_sig1_w), 
            .D_SIG1_out(o_sig1_w)
        );
    //==================================================//
    //                   Datapath                       //
    //==================================================//

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ME_dv_out           <= 0;
            for (i=0; i < 64 ; i=i+1 ) begin
                address_r[i]    <= 32'd0;
            end
        end else begin
            if (FSM_core_in == 3'b010)begin
                if(core_count_in > 0)
                    address_r[core_count_in - 1] <= data_in;
            end else if (FSM_core_in == 3'b011) begin
                ME_dv_out               <= 1;
                else if (core_count_in >= 16) begin
                    address_r[core_count_in] <= data_out_r;
                end
            end else begin
                ME_dv_out  <= 0;
            end
        end
    end
endmodule

