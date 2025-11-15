`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 11/10/2025 10:12:33 PM
// Design Name: 
// Module Name: ME
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
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2025 07:26:12 PM
// Design Name: 
// Module Name: rME
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


module ME #(
    parameter DATA_WIDTH =32
) 
(
    input wire clk,
    input wire rst_n,
    input wire start_in,

    input wire [DATA_WIDTH-1:0] i_m0,
    input wire [DATA_WIDTH-1:0] i_m1,
    input wire [DATA_WIDTH-1:0] i_m2,
    input wire [DATA_WIDTH-1:0] i_m3,
    input wire [DATA_WIDTH-1:0] i_m4,
    input wire [DATA_WIDTH-1:0] i_m5,
    input wire [DATA_WIDTH-1:0] i_m6,
    input wire [DATA_WIDTH-1:0] i_m7,
    input wire [DATA_WIDTH-1:0] i_m8,
    input wire [DATA_WIDTH-1:0] i_m9,
    input wire [DATA_WIDTH-1:0] i_m10,
    input wire [DATA_WIDTH-1:0] i_m11,
    input wire [DATA_WIDTH-1:0] i_m12,
    input wire [DATA_WIDTH-1:0] i_m13,
    input wire [DATA_WIDTH-1:0] i_m14,
    input wire [DATA_WIDTH-1:0] i_m15,
    
    output wire                  dout_valid,
    output wire [DATA_WIDTH-1:0] o_message,
    output wire [1:0]            o_FSM_state,
    output wire [5:0]            o_round
);
// Wire and reg
reg [DATA_WIDTH-1:0] i_m_r [0:63] ;
reg [5:0]            round_r;
reg [DATA_WIDTH-1:0] o_message_r;

reg [1:0]            current_state_r;
reg [1:0]            next_state_r;
reg [DATA_WIDTH-1:0] i_sig0_r, i_sig1_r;

wire [DATA_WIDTH-1:0] i_sig0_w, i_sig1_w;
wire [DATA_WIDTH-1:0] o_sig0_w;
wire [DATA_WIDTH-1:0] o_sig1_w;

// State Declarations
parameter IDLE         = 2'b00;
parameter ROUND0to15   = 2'b01;
parameter ROUND16to63  = 2'b10;
parameter DONE         = 2'b11;

// Assign
assign o_FSM_state  = current_state_r;
assign o_message    = o_message_r ;
assign o_round      = round_r;
assign dout_valid   = (current_state_r== ROUND16to63 && round_r == 6'd63)? 1'b1: 1'b0;
assign i_sig0_w     = (current_state_r == ROUND16to63 && round_r >= 6'd15)? i_m_r[round_r - 6'd15] : {DATA_WIDTH{1'b0}} ;
assign i_sig1_w     = (current_state_r == ROUND16to63 && round_r >= 6'd2)? i_m_r [round_r - 6'd2]  : {DATA_WIDTH{1'b0}} ;

            SIG0 #(
                    .DATA_WIDTH(DATA_WIDTH)
                ) sig0_inst (
                    .S_SIG0_in(i_sig0_r), 
                    .D_SIG0_out(o_sig0_w)
                );
            SIG1 #(
                    .DATA_WIDTH(DATA_WIDTH)
                ) sig1_inst (
                    .S_SIG1_in(i_sig1_r), 
                    .D_SIG1_out(o_sig1_w)
                );

//Control Unit
always @(posedge clk or negedge rst_n) begin  
        if (!rst_n) 
            current_state_r <= IDLE;
        else 
            current_state_r <= next_state_r;
end

always @(current_state_r or start_in or round_r) begin 
    case(current_state_r)                            
        IDLE:        next_state_r  = (start_in)         ? ROUND0to15  : IDLE;
        ROUND0to15:  next_state_r  = (round_r == 6'd15) ? ROUND16to63 : ROUND0to15;
        ROUND16to63: next_state_r  = (round_r == 6'd63) ? IDLE        : ROUND16to63;

        default: next_state_r = IDLE;
    endcase
end
//Datapath registers
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        round_r <= 6'd0;
    end else begin
        if (current_state_r == ROUND0to15 || current_state_r == ROUND16to63) begin
            round_r <= round_r + 6'd1;
        end else begin
            round_r <= 6'd0;
        end
    end
end

integer i;
always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
        i_sig0_r <= 32'd0;
        i_sig1_r <= 32'd0;
        o_message_r <= 32'd0;

        for (i=0; i<64 ; i=i+1 ) begin
            i_m_r[i] <= 32'd0;
        end
    end else begin
            if (current_state_r == ROUND0to15 || current_state_r == ROUND16to63) begin
                o_message_r      <= i_m_r[round_r];
                i_sig0_r         <= i_sig0_w;
                i_sig1_r         <= i_sig1_w;
            end
            if(current_state_r == IDLE) begin 
                    if (start_in) begin 
                        i_m_r[0]  <= i_m0;
                        i_m_r[1]  <= i_m1;
                        i_m_r[2]  <= i_m2;
                        i_m_r[3]  <= i_m3;
                        i_m_r[4]  <= i_m4;
                        i_m_r[5]  <= i_m5;
                        i_m_r[6]  <= i_m6;
                        i_m_r[7]  <= i_m7;
                        i_m_r[8]  <= i_m8;
                        i_m_r[9]  <= i_m9;
                        i_m_r[10] <= i_m10;
                        i_m_r[11] <= i_m11;
                        i_m_r[12] <= i_m12;
                        i_m_r[13] <= i_m13;
                        i_m_r[14] <= i_m14;
                        i_m_r[15] <= i_m15;
                    end else begin
                        for (i=0; i<64 ; i=i+1 ) begin
                            i_m_r[i] <= 32'd0;
                        end
                    end
            end else if (current_state_r == ROUND0to15) begin  // Start at round_r =0;
                     //DO nothing. Do not reload all input to output again
        
            end else if (current_state_r == ROUND16to63) begin                   

                        i_m_r[round_r] <= i_m_r[round_r - 6'd16 ] + o_sig0_w + i_m_r[round_r - 6'd7] + o_sig1_w;         
            
            end else begin 
                        i_sig0_r <= 32'd0;
                        i_sig1_r <= 32'd0;
                        
                        for (i=0; i<64 ; i=i+1 ) begin
                            i_m_r[i] <= 32'd0;
                        end
            end
    end
end
endmodule
