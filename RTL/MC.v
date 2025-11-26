`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 11/11/2025 01:18:27 PM
// Design Name: 
// Module Name: MC
// Project Name: SHA-256
// Target Devices: ZCU102 (FPGA Board)
// Tool Versions: Vivado on Linux
// Description: Message Compression does 64 loops based 64 words from ME and 8 initial hash value to produce the final 8 hash values.
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
    input wire                  start_in,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire [1:0]            FSM_state_in,
    input wire [5:0]            round_in,    

    output reg [DATA_WIDTH-1:0] data_out,
    output wire                 valid_out,
    output wire  [3:0]          send_counter
    
);
    //==================================================//
    //                   Registers                      //
    //==================================================//
    wire                  SEND_flag_w    ;
    wire [1:0]            FSM_state_w    ;   
    wire [5:0]            round_count_w  ;
    wire [DATA_WIDTH-1:0] out_choose_w   ;
    wire [DATA_WIDTH-1:0] out_ep1_w      ;
    wire [DATA_WIDTH-1:0] out_ep0_w      ;
    wire [DATA_WIDTH-1:0] out_major_w    ;
    wire [DATA_WIDTH-1:0] T1_w,T2_w      ;


    wire [DATA_WIDTH-1:0] a_w,  b_w,    c_w,    d_w,    e_w,    f_w,    g_w,    h_w;
    wire [DATA_WIDTH-1:0] fa_w, fb_w,   fc_w,   fd_w,   fe_w,   ff_w,   fg_w,   fh_w;

    reg  [3:0]            send_count_r   ;
    reg  [DATA_WIDTH-1:0] i_T1, i_T2;
    reg  [DATA_WIDTH-1:0] k_r;// Initial Hash value
    reg  [DATA_WIDTH-1:0] a_r   ,b_r    ,c_r    ,d_r,   e_r,   f_r,     g_r,    h_r;

    //==================================================//
    //                 State Encoding                   //
    //==================================================//
    localparam  [DATA_WIDTH-1:0] H0 = 32'h6a09e667;
    localparam  [DATA_WIDTH-1:0] H1 = 32'hbb67ae85;
    localparam  [DATA_WIDTH-1:0] H2 = 32'h3c6ef372;
    localparam  [DATA_WIDTH-1:0] H3 = 32'ha54ff53a;
    localparam  [DATA_WIDTH-1:0] H4 = 32'h510e527f;
    localparam  [DATA_WIDTH-1:0] H5 = 32'h9b05688c;
    localparam  [DATA_WIDTH-1:0] H6 = 32'h1f83d9ab;
    localparam  [DATA_WIDTH-1:0] H7 = 32'h5be0cd19;


    // Initial hash value
    always @(*) begin
    case (round_count_w)
            6'h00:k_r= 32'h428a2f98;
            6'h01:k_r= 32'h71374491;
            6'h02:k_r= 32'hb5c0fbcf;
            6'h03:k_r= 32'he9b5dba5;
            6'h04:k_r= 32'h3956c25b;
            6'h05:k_r= 32'h59f111f1;
            6'h06:k_r= 32'h923f82a4;
            6'h07:k_r= 32'hab1c5ed5;
            6'h08:k_r= 32'hd807aa98;
            6'h09:k_r= 32'h12835b01;
            6'd10:k_r= 32'h243185be;
            6'd11:k_r= 32'h550c7dc3;
            6'd12:k_r= 32'h72be5d74;
            6'd13:k_r= 32'h80deb1fe;
            6'd14:k_r= 32'h9bdc06a7;
            6'd15:k_r= 32'hc19bf174;
            6'd16:k_r= 32'he49b69c1;
            6'd17:k_r= 32'hefbe4786;
            6'd18:k_r= 32'h0fc19dc6;
            6'd19:k_r= 32'h240ca1cc;
            6'd20:k_r= 32'h2de92c6f;
            6'd21:k_r= 32'h4a7484aa;
            6'd22:k_r= 32'h5cb0a9dc;
            6'd23:k_r= 32'h76f988da;
            6'd24:k_r= 32'h983e5152;
            6'd25:k_r= 32'ha831c66d;
            6'd26:k_r= 32'hb00327c8;
            6'd27:k_r= 32'hbf597fc7;
            6'd28:k_r= 32'hc6e00bf3;
            6'd29:k_r= 32'hd5a79147;
            6'd30:k_r= 32'h06ca6351;
            6'd31:k_r= 32'h14292967;
            6'd32:k_r= 32'h27b70a85;
            6'd33:k_r= 32'h2e1b2138;
            6'd34:k_r= 32'h4d2c6dfc;
            6'd35:k_r= 32'h53380d13;
            6'd36:k_r= 32'h650a7354;
            6'd37:k_r= 32'h766a0abb;
            6'd38:k_r= 32'h81c2c92e;
            6'd39:k_r= 32'h92722c85;
            6'd40:k_r= 32'ha2bfe8a1;
            6'd41:k_r= 32'ha81a664b;
            6'd42:k_r= 32'hc24b8b70;
            6'd43:k_r= 32'hc76c51a3;
            6'd44:k_r= 32'hd192e819;
            6'd45:k_r= 32'hd6990624;
            6'd46:k_r= 32'hf40e3585;
            6'd47:k_r= 32'h106aa070;
            6'd48:k_r= 32'h19a4c116;
            6'd49:k_r= 32'h1e376c08;
            6'd50:k_r= 32'h2748774c;
            6'd51:k_r= 32'h34b0bcb5;
            6'd52:k_r= 32'h391c0cb3;
            6'd53:k_r= 32'h4ed8aa4a;
            6'd54:k_r= 32'h5b9cca4f;
            6'd55:k_r= 32'h682e6ff3;
            6'd56:k_r= 32'h748f82ee;
            6'd57:k_r= 32'h78a5636f;
            6'd58:k_r= 32'h84c87814;
            6'd59:k_r= 32'h8cc70208;
            6'd60:k_r= 32'h90befffa;
            6'd61:k_r= 32'ha4506ceb;
            6'd62:k_r= 32'hbef9a3f7;
            6'd63:k_r= 32'hc67178f2; 
            default:k_r=32'h0;

    endcase
    end
    //==================================================//
    //             Instantiate module                   //
    //==================================================//

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
    //==================================================//
    //             Combinational Logic                  //
    //==================================================//

    assign FSM_state_w    = FSM_state_in;
    assign round_count_w  = round_in;
    assign valid_out      = (FSM_state_w == 2'b11);
    assign send_counter   = send_count_r;

    assign T1_w =(FSM_state_w == 2'b01|| FSM_state_w == 2'b10) ? h_r + out_ep1_w + out_choose_w + k_r + data_in : 32'h0; 
    assign T2_w =(FSM_state_w == 2'b01|| FSM_state_w == 2'b10) ? out_ep0_w + out_major_w : 32'h0;

    // Paste output of round 0 to 63 to wire 
    assign a_w  = T1_w + T2_w;
    assign e_w  = d_r  + T1_w;

    assign b_w  = a_r;
    assign c_w  = b_r;
    assign d_w  = c_r;
    assign f_w  = e_r;
    assign g_w  = f_r;
    assign h_w  = g_r;

    //==================================================//
    //                   Datapath                       //
    //==================================================//

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            send_count_r    <= 0;
            data_out        <= {DATA_WIDTH{1'b0}};

            a_r             <= H0;// Delete a_r = 0; at reset block
            b_r             <= H1;
            c_r             <= H2;
            d_r             <= H3;
            e_r             <= H4;
            f_r             <= H5;
            g_r             <= H6;
            h_r             <= H7;
        end
        else begin
                if ( FSM_state_w == 2'b00 )begin      
                    if (start_in) begin
                        send_count_r    <= 0;
                        a_r             <= a_w;
                        b_r             <= b_w;
                        c_r             <= c_w;
                        d_r             <= d_w;
                        e_r             <= e_w;
                        f_r             <= f_w;
                        g_r             <= g_w;
                        h_r             <= h_w;
                    end

                end else if ((FSM_state_w == 2'b01|| FSM_state_w == 2'b10)) begin
                    //update working register on each round
                        a_r             <= a_w;
                        b_r             <= b_w;
                        c_r             <= c_w;
                        d_r             <= d_w;
                        e_r             <= e_w;
                        f_r             <= f_w;
                        g_r             <= g_w;
                        h_r             <= h_w;
                    
                end else if (FSM_state_w == 2'b11) begin 
                    if (send_count_r < 4'd8) begin
                        case (send_count_r)
                                3'd0: data_out <= H0 + a_r;
                                3'd1: data_out <= H1 + b_r;
                                3'd2: data_out <= H2 + c_r;
                                3'd3: data_out <= H3 + d_r;
                                3'd4: data_out <= H4 + e_r;
                                3'd5: data_out <= H5 + f_r;
                                3'd6: data_out <= H6 + g_r;
                                3'd7: data_out <= H7 + h_r;
                        endcase
                        send_count_r <= send_count_r + 1;
                    end
                end
            end
    end
endmodule
