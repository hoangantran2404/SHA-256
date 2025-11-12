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


module ME #(
    parameter DATA_WIDTH =32
)
(
    input wire clk,
    input wire rst_n,
    input wire i_load,

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

    output wire [DATA_WIDTH-1:0] o_message,
    output wire [6:0] o_round,
    output wire [1:0] o_FSM_state
);
// internal signals
reg [DATA_WIDTH-1:0] i_m0_r;
reg [DATA_WIDTH-1:0] i_m1_r;
reg [DATA_WIDTH-1:0] i_m2_r;
reg [DATA_WIDTH-1:0] i_m3_r;
reg [DATA_WIDTH-1:0] i_m4_r;
reg [DATA_WIDTH-1:0] i_m5_r;
reg [DATA_WIDTH-1:0] i_m6_r;
reg [DATA_WIDTH-1:0] i_m7_r;
reg [DATA_WIDTH-1:0] i_m8_r;
reg [DATA_WIDTH-1:0] i_m9_r;
reg [DATA_WIDTH-1:0] i_m10_r;
reg [DATA_WIDTH-1:0] i_m11_r;
reg [DATA_WIDTH-1:0] i_m12_r;
reg [DATA_WIDTH-1:0] i_m13_r;
reg [DATA_WIDTH-1:0] i_m14_r;
reg [DATA_WIDTH-1:0] i_m15_r;

reg [6:0] round_r;
reg [1:0] current_state_r;
reg [1:0] next_state_r;

wire [DATA_WIDTH-1:0] o_sig0_w;
wire [DATA_WIDTH-1:0] o_sig1_w;
wire [DATA_WIDTH-1:0] o_m16_w;
wire [DATA_WIDTH-1:0] o_m9_w;
wire [DATA_WIDTH-1:0] o_m0_w;

// State Declarations
parameter IDLE         = 2'b00;
parameter ROUND0to15   = 2'b01;
parameter ROUND16to63  = 2'b10;
parameter ROUND64      = 2'b11;

// Combinational logic for outputs
assign o_message    =   (round_r == 7'd0)  ? i_m0_r :
                        (round_r == 7'd1)  ? i_m1_r :
                        (round_r == 7'd2)  ? i_m2_r :
                        (round_r == 7'd3)  ? i_m3_r :
                        (round_r == 7'd4)  ? i_m4_r :
                        (round_r == 7'd5)  ? i_m5_r :
                        (round_r == 7'd6)  ? i_m6_r :
                        (round_r == 7'd7)  ? i_m7_r :
                        (round_r == 7'd8)  ? i_m8_r :
                        (round_r == 7'd9)  ? i_m9_r :
                        (round_r == 7'd10) ? i_m10_r :
                        (round_r == 7'd11) ? i_m11_r :
                        (round_r == 7'd12) ? i_m12_r :
                        (round_r == 7'd13) ? i_m13_r :
                        (round_r == 7'd14) ? i_m14_r :
                        (round_r == 7'd15) ? i_m15_r : o_m16_w;
assign o_round      = round_r;
assign o_FSM_state  = current_state_r;

assign o_m9_w = i_m9_r;//W(16-7)
assign o_m0_w = i_m0_r;//W(16-16)
assign o_m16_w = o_sig1_w + o_sig0_w + o_m9_w + o_m0_w;





//Instantiate SIG0 and SIG1 modules 
SIG0 #(
    .DATA_WIDTH(DATA_WIDTH)
) sig0_inst (
    .S_SIG0_in(i_m1_r), 
    .D_SIG0_out(o_sig0_w)
);
SIG1 #(
    .DATA_WIDTH(DATA_WIDTH)
) sig1_inst (
    .S_SIG1_in(i_m14_r), 
    .D_SIG1_out(o_sig1_w)
);

// Sequential logic for state transition
always @(posedge clk or negedge rst_n) begin  
        if (!rst_n) 
            current_state_r <= IDLE;
        else 
            current_state_r <= next_state_r;
end

always @(current_state_r or i_load or round_r) begin // Reason for not event using clk or rst_n that we should take a look at the condition in case
    case(current_state_r)                            // which changed will be the sensitive signal to trigger this always block
        IDLE: next_state_r        = (i_load)           ? ROUND0to15  : IDLE;
        ROUND0to15: next_state_r  = (round_r == 7'd15) ? ROUND16to63 : ROUND0to15;
        ROUND16to63: next_state_r = (round_r == 7'd63) ? ROUND64     : ROUND16to63;
        ROUND64: next_state_r     = (round_r == 7'd64) ? IDLE        : ROUND64;

        default: next_state_r = IDLE;
    endcase
end
//data path registers
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        round_r <= 7'd0;
    end else begin
        if (current_state_r != IDLE) begin
            round_r <= round_r + 7'd1;
        end else begin
            round_r <= 7'd0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i_m0_r  <= 32'd0;
        i_m1_r  <= 32'd0;
        i_m2_r  <= 32'd0;
        i_m3_r  <= 32'd0;
        i_m4_r  <= 32'd0;
        i_m5_r  <= 32'd0;
        i_m6_r  <= 32'd0;
        i_m7_r  <= 32'd0;
        i_m8_r  <= 32'd0;
        i_m9_r  <= 32'd0;
        i_m10_r <= 32'd0;
        i_m11_r <= 32'd0;
        i_m12_r <= 32'd0;
        i_m13_r <= 32'd0;
        i_m14_r <= 32'd0;
        i_m15_r <= 32'd0;
    end else begin
            case(current_state_r)
                IDLE: begin 
                    if (i_load) begin // Load input to registers
                        i_m0_r  <= i_m0;
                        i_m1_r  <= i_m1;
                        i_m2_r  <= i_m2;
                        i_m3_r  <= i_m3;
                        i_m4_r  <= i_m4;
                        i_m5_r  <= i_m5;
                        i_m6_r  <= i_m6;
                        i_m7_r  <= i_m7;
                        i_m8_r  <= i_m8;
                        i_m9_r  <= i_m9;
                        i_m10_r <= i_m10;
                        i_m11_r <= i_m11;
                        i_m12_r <= i_m12;
                        i_m13_r <= i_m13;
                        i_m14_r <= i_m14;
                        i_m15_r <= i_m15;
                    end else begin
                        i_m0_r  <= 32'd0;
                        i_m1_r  <= 32'd0;
                        i_m2_r  <= 32'd0;
                        i_m3_r  <= 32'd0;
                        i_m4_r  <= 32'd0;
                        i_m5_r  <= 32'd0;
                        i_m6_r  <= 32'd0;
                        i_m7_r  <= 32'd0;
                        i_m8_r  <= 32'd0;
                        i_m9_r  <= 32'd0;
                        i_m10_r <= 32'd0;
                        i_m11_r <= 32'd0;
                        i_m12_r <= 32'd0;
                        i_m13_r <= 32'd0;
                        i_m14_r <= 32'd0;
                        i_m15_r <= 32'd0;
                    end
                end
                ROUND0to15: begin
                    //Pass the input to output or keep the same
                    i_m0_r  <= i_m0_r;
                    i_m1_r  <= i_m1_r;
                    i_m2_r  <= i_m2_r;
                    i_m3_r  <= i_m3_r;
                    i_m4_r  <= i_m4_r;
                    i_m5_r  <= i_m5_r;
                    i_m6_r  <= i_m6_r;
                    i_m7_r  <= i_m7_r;
                    i_m8_r  <= i_m8_r;
                    i_m9_r  <= i_m9_r;
                    i_m10_r <= i_m10_r;
                    i_m11_r <= i_m11_r;
                    i_m12_r <= i_m12_r;
                    i_m13_r <= i_m13_r;
                    i_m14_r <= i_m14_r;
                    i_m15_r <= i_m15_r; 
                end
                ROUND16to63: begin
                    // Update new input o_m16_w message schedule for rounds 16 to 63
                    i_m0_r  <= i_m1_r;
                    i_m1_r  <= i_m2_r;
                    i_m2_r  <= i_m3_r;
                    i_m3_r  <= i_m4_r;
                    i_m4_r  <= i_m5_r;
                    i_m5_r  <= i_m6_r;
                    i_m6_r  <= i_m7_r;
                    i_m7_r  <= i_m8_r;
                    i_m8_r  <= i_m9_r;
                    i_m9_r  <= i_m10_r;
                    i_m10_r <= i_m11_r;
                    i_m11_r <= i_m12_r;
                    i_m12_r <= i_m13_r;
                    i_m13_r <= i_m14_r;
                    i_m14_r <= i_m15_r;
                    i_m15_r <= o_m16_w; // New message word
                end
                ROUND64: begin
                    // Clear registers after completion
                    i_m0_r  <= 32'd0;
                    i_m1_r  <= 32'd0;
                    i_m2_r  <= 32'd0;
                    i_m3_r  <= 32'd0;
                    i_m4_r  <= 32'd0;
                    i_m5_r  <= 32'd0;
                    i_m6_r  <= 32'd0;
                    i_m7_r  <= 32'd0;
                    i_m8_r  <= 32'd0;
                    i_m9_r  <= 32'd0;
                    i_m10_r <= 32'd0;
                    i_m11_r <= 32'd0;
                    i_m12_r <= 32'd0;
                    i_m13_r <= 32'd0;
                    i_m14_r <= 32'd0;
                    i_m15_r <= 32'd0;
                end
                default: begin //Why we cannot return to IDLE? Because we have a i_load signal.
                              // We should have a default instead of using IDLE state.
                        i_m0_r  <= 32'd0;
                        i_m1_r  <= 32'd0;
                        i_m2_r  <= 32'd0;
                        i_m3_r  <= 32'd0;
                        i_m4_r  <= 32'd0;
                        i_m5_r  <= 32'd0;
                        i_m6_r  <= 32'd0;
                        i_m7_r  <= 32'd0;
                        i_m8_r  <= 32'd0;
                        i_m9_r  <= 32'd0;
                        i_m10_r <= 32'd0;
                        i_m11_r <= 32'd0;
                        i_m12_r <= 32'd0;
                        i_m13_r <= 32'd0;
                        i_m14_r <= 32'd0;
                        i_m15_r <= 32'd0;
                end
            endcase
    end
end
endmodule
