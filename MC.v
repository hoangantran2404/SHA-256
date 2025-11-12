`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2025 01:18:27 PM
// Design Name: 
// Module Name: MC
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


module MC#(
        parameter DATA_WIDTH = 32
)
(
    input wire                  clk,
    input wire                  rst_n,
    input wire                  i_load,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire [1:0]            FSM_state_in,
    input wire [6:0]            round_in,

    input wire [DATA_WIDTH-1:0] in0,
    input wire [DATA_WIDTH-1:0] in1,
    input wire [DATA_WIDTH-1:0] in2,
    input wire [DATA_WIDTH-1:0] in3,
    input wire [DATA_WIDTH-1:0] in4,
    input wire [DATA_WIDTH-1:0] in5,
    input wire [DATA_WIDTH-1:0] in6,
    input wire [DATA_WIDTH-1:0] in7,
   
    

    output wire [DATA_WIDTH-1:0] out0,
    output wire [DATA_WIDTH-1:0] out1,
    output wire [DATA_WIDTH-1:0] out2,
    output wire [DATA_WIDTH-1:0] out3,
    output wire [DATA_WIDTH-1:0] out4,
    output wire [DATA_WIDTH-1:0] out5,
    output wire [DATA_WIDTH-1:0] out6,
    output wire [DATA_WIDTH-1:0] out7,
    output wire valid_out
    
);
// Internal signal 
wire [DATA_WIDTH-1:0] out_choose_w;
wire [DATA_WIDTH-1:0] out_ep1_w;
wire [DATA_WIDTH-1:0] out_ep0_w;
wire [DATA_WIDTH-1:0] out_major_w;
wire [DATA_WIDTH-1:0] T1_w,T2_w;

wire [DATA_WIDTH-1:0] a_w,  b_w,    c_w,    d_w,    e_w,    f_w,    g_w,    h_w;
wire [DATA_WIDTH-1:0] fa_w, fb_w,   fc_w,   fd_w,   fe_w,   ff_w,   fg_w,   fh_w;

reg  [DATA_WIDTH-1:0] ih_r;
reg  [DATA_WIDTH-1:0] a_r   ,b_r    ,c_r    ,d_r,   e_r,   f_r,     g_r,    h_r;
//Parameter
parameter IDLE           = 2'b00;
parameter ROUND0to15     = 2'b01;
parameter ROUND16to63    = 2'b10;
parameter ROUND64        = 2'b11;


// Initial hash value
always @(*) begin
case (ih_r) 
        32'd00: ih_r = 32'h428a2f98;
        32'd01: ih_r = 32'h71374491;
        32'd02: ih_r = 32'hb5c0fbcf;
        32'd03: ih_r = 32'he9b5dba5;
        32'd04: ih_r = 32'h3956c25b;
        32'd05: ih_r = 32'h59f111f1;
        32'd06: ih_r = 32'h923f82a4;
        32'd07: ih_r = 32'hab1c5ed5;
        32'd08: ih_r = 32'hd807aa98;
        32'd09: ih_r = 32'h12835b01;
        32'd10: ih_r = 32'h243185be;
        32'd11: ih_r = 32'h550c7dc3;
        32'd12: ih_r = 32'h72be5d74;
        32'd13: ih_r = 32'h80deb1fe;
        32'd14: ih_r = 32'h9bdc06a7;
        32'd15: ih_r = 32'hc19bf174;
        32'd16: ih_r = 32'he49b69c1;
        32'd17: ih_r = 32'hefbe4786;
        32'd18: ih_r = 32'h0fc19dc6;
        32'd19: ih_r = 32'h240ca1cc;
        32'd20: ih_r = 32'h2de92c6f;
        32'd21: ih_r = 32'h4a7484aa;
        32'd22: ih_r = 32'h5cb0a9dc;
        32'd23: ih_r = 32'h76f988da;
        32'd24: ih_r = 32'h983e5152;
        32'd25: ih_r = 32'ha831c66d;
        32'd26: ih_r = 32'hb00327c8;
        32'd27: ih_r = 32'hbf597fc7;
        32'd28: ih_r = 32'hc6e00bf3;
        32'd29: ih_r = 32'hd5a79147;
        32'd30: ih_r = 32'h06ca6351;
        32'd31: ih_r = 32'h14292967;
        32'd32: ih_r = 32'h27b70a85;
        32'd33: ih_r = 32'h2e1b2138;
        32'd34: ih_r = 32'h4d2c6dfc;
        32'd35: ih_r = 32'h53380d13;
        32'd36: ih_r = 32'h650a7354;
        32'd37: ih_r = 32'h766a0abb;
        32'd38: ih_r = 32'h81c2c92e;
        32'd39: ih_r = 32'h92722c85;
        32'd40: ih_r = 32'ha2bfe8a1;
        32'd41: ih_r = 32'ha81a664b;
        32'd42: ih_r = 32'hc24b8b70;
        32'd43: ih_r = 32'hc76c51a3;
        32'd44: ih_r = 32'hd192e819;
        32'd45: ih_r = 32'hd6990624;
        32'd46: ih_r = 32'hf40e3585;
        32'd47: ih_r = 32'h106aa070;
        32'd48: ih_r = 32'h19a4c116;
        32'd49: ih_r = 32'h1e376c08;
        32'd50: ih_r = 32'h2748774c;
        32'd51: ih_r = 32'h34b0bcb5;
        32'd52: ih_r = 32'h391c0cb3;
        32'd53: ih_r = 32'h4ed8aa4a;
        32'd54: ih_r = 32'h5b9cca4f;
        32'd55: ih_r = 32'h682e6ff3;
        32'd56: ih_r = 32'h748f82ee;
        32'd57: ih_r = 32'h78a5636f;
        32'd58: ih_r = 32'h84c87814;
        32'd59: ih_r = 32'h8cc70208;
        32'd60: ih_r = 32'h90befffa;
        32'd61: ih_r = 32'ha4506ceb;
        32'd62: ih_r = 32'hbef9a3f7;
        32'd63: ih_r = 32'hc67178f2; 
        default: ih_r =32'd0;

endcase
end

// Instantiate compu+ out_ep1_w + out_choose_w + ih_r + data_in;
assign T1_w = h_r + out_ep1_w + out_choose_w + ih_r + data_in;
assign T2_w = out_ep0_w + out_major_w;

EP0 EP0_inst(
    .data_in(a_r),
    .data_out(out_ep0_w)
);
EP1 EP1_inst(
    .data_in(e_r),
    .data_out(out_ep1_w)
);
maj maj_inst(
    .in0(a_r),
    .in1(b_r),
    .in2(c_r),
    .data_out(out_major_w)
);
CHS CHS_inst(
    .in0(e_r),
    .in1(f_r),
    .in2(g_r),
    .data_out(out_choose_w)
);

// Paste output of round 0 to 63 to wire 
assign a_w  = T1_w + T2_w;
assign e_w  = d_r  + T1_w;
assign b_w  = a_r;
assign c_w  = b_r;
assign d_w  = c_r;
assign f_w  = e_r;
assign g_w  = f_r;
assign h_w  = g_r;

// Round 64
assign fa_w= in0 + a_w;// final = initial + caculation
assign fb_w= in1 + b_w;
assign fc_w= in2 + c_w;
assign fd_w= in3 + d_w;
assign fe_w= in4 + e_w;
assign ff_w= in5 + e_w;
assign fg_w= in6 + g_w;
assign fh_w= in7 + h_w;

assign out0 = (FSM_state_in==ROUND64)? fa_w: 32'd0;
assign out1 = (FSM_state_in==ROUND64)? fb_w: 32'd0;
assign out2 = (FSM_state_in==ROUND64)? fc_w: 32'd0;
assign out3 = (FSM_state_in==ROUND64)? fd_w: 32'd0;
assign out4 = (FSM_state_in==ROUND64)? fe_w: 32'd0;
assign out5 = (FSM_state_in==ROUND64)? ff_w: 32'd0;
assign out6 = (FSM_state_in==ROUND64)? fg_w: 32'd0;
assign out7 = (FSM_state_in==ROUND64)? fh_w: 32'd0;

assign valid_out = (FSM_state_in==ROUND64)? 1: 0;

//FSM

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        a_r <= 32'd0;
        b_r <= 32'd0;
        c_r <= 32'd0;
        d_r <= 32'd0;
        e_r <= 32'd0;
        f_r <= 32'd0;
        g_r <= 32'd0;
        h_r <= 32'd0;
    end
    else begin
        if(FSM_state_in== IDLE) begin
            if (i_load) begin
                a_r <= in0;
                b_r <= in1;
                c_r <= in2;
                d_r <= in3;
                e_r <= in4;
                f_r <= in5;
                g_r <= in6;
                h_r <= in7;
            end
            else begin 
                a_r <= 32'd0;
                b_r <= 32'd0;   
                c_r <= 32'd0;
                d_r <= 32'd0;
                e_r <= 32'd0;
                f_r <= 32'd0;
                g_r <= 32'd0;
                h_r <= 32'd0;
            end
        end else if ((FSM_state_in == ROUND0to15)||(FSM_state_in == ROUND16to63)) begin
            // Save the result to wire in each round
                a_r <= a_w;
                b_r <= b_w;
                c_r <= c_w;
                d_r <= d_w;
                e_r <= e_w;
                f_r <= f_w;
                g_r <= g_w;
                h_r <= h_w;
        end else begin // ROUND64 
                a_r <= fa_w;
                b_r <= fb_w;
                c_r <= fc_w;
                d_r <= fd_w;
                e_r <= fe_w;
                f_r <= ff_w;
                g_r <= fg_w;
                h_r <= fh_w;
        end
    end
end
endmodule
