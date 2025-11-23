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
    input wire [4:0]             Rx_core_count, // Count how many word pass from Core to ME
    input wire [DATA_WIDTH-1:0]  data_in,
    
    output reg [DATA_WIDTH-1:0] data_out,
    output wire [1:0]            o_FSM_state,
    output wire [5:0]            o_round,
    output wire                  ME_dv_out
);
//==================================================//
//                   Registers                      //
//==================================================//
reg [DATA_WIDTH-1:0] i_m_r [0:63]      ;
//wire [DATA_WIDTH-1:0] data_out_r       ; // Save output temporaly

reg [5:0]            round_r           ; // Internal counter   

wire [DATA_WIDTH-1:0] i_sig0_w, i_sig1_w;
wire [DATA_WIDTH-1:0] o_sig0_w;
wire [DATA_WIDTH-1:0] o_sig1_w;
wire [DATA_WIDTH-1:0] data_out_r       ; // Save output temporaly
//==================================================//
//                 State Encoding                   //
//==================================================//
reg [1:0]            current_state_r;
reg [1:0]            next_state_r;

parameter s_IDLE         = 2'b00;
parameter s_ROUND0to15   = 2'b01;
parameter s_ROUND16to63  = 2'b10;
parameter s_CLEANUP      = 2'b11;


//==================================================//
//             Combinational Logic                  //
//==================================================//
assign o_FSM_state  = current_state_r;
assign o_round      = round_r;
assign ME_dv_out    = (current_state_r == s_ROUND16to63 && round_r == 6'd63)? 1'b1: 1'b0;

assign i_sig0_w     = (current_state_r == s_ROUND16to63 && round_r >= 6'd15)? i_m_r[round_r - 6'd15] : {DATA_WIDTH{1'b0}} ;
assign i_sig1_w     = (current_state_r == s_ROUND16to63 && round_r >= 6'd2)? i_m_r [round_r - 6'd2]  : {DATA_WIDTH{1'b0}} ;
assign data_out_r   = i_m_r[round_r - 6'd16 ] + o_sig0_w + i_m_r[round_r - 6'd7] + o_sig1_w;  
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
//                State Register (FSM)              //
//==================================================//
always @(posedge clk or negedge rst_n) begin  
        if (!rst_n) 
            current_state_r <= s_IDLE;
        else 
            current_state_r <= next_state_r;
end
//==================================================//
//                  Next State Logic                //
//==================================================//
always @(current_state_r or start_in or round_r) begin 
    case(current_state_r)                            
        s_IDLE:        
            if(start_in) begin
                if( Rx_core_count < 5'd15)
                next_state_r = s_IDLE;
            else
                next_state_r = s_ROUND0to15;
            end else 
                next_state_r = s_IDLE;
        s_ROUND0to15:  
            if(round_r < 6'd15) 
                next_state_r = s_ROUND0to15;
            else
                next_state_r = s_ROUND16to63;
        s_ROUND16to63:
            if(round_r < 6'd63)
                next_state_r = s_ROUND16to63;
            else 
                next_state_r = s_CLEANUP;
        s_CLEANUP:
            next_state_r = s_IDLE;


        default: next_state_r = s_IDLE;
    endcase
end
//==================================================//
//                   Datapath                       //
//==================================================//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        round_r <= 6'd0;
    end else begin
        if (current_state_r == s_ROUND0to15 || current_state_r == s_ROUND16to63) begin
            round_r <= round_r + 6'd1;
        end else begin
            round_r <= 6'd0;
        end
    end
end

integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_out        <= 32'd0;
        for (i=0; i < 64 ; i=i+1 ) begin
            i_m_r[i]    <= 32'd0;
        end
    end else begin
        case(current_state_r) 
            s_IDLE: begin
                if(start_in) begin
                    i_m_r [Rx_core_count] <= data_in;
                end else begin
                    for (i=0; i<64 ; i=i+1 ) begin
                        i_m_r[i]        <= 32'd0;
                    end
                end
            end
            s_ROUND0to15: begin
                    data_out            <= i_m_r[round_r];
            
            end
            s_ROUND16to63: begin
                    i_m_r[round_r]      <= data_out_r;
                    data_out            <= data_out_r;
            end
        default: begin
        end
    endcase
end
end
endmodule
