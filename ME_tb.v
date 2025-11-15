`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 10:47:54 AM
// Design Name: 
// Module Name: rME_t
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




module rME_tb;
    parameter DATA_WIDTH =32;
    
    reg clk_t, rst_n_t, start_in_t;
    reg  [DATA_WIDTH-1:0] i_m0_t;
    reg  [DATA_WIDTH-1:0] i_m1_t;
    reg  [DATA_WIDTH-1:0] i_m2_t;
    reg  [DATA_WIDTH-1:0] i_m3_t;
    reg  [DATA_WIDTH-1:0] i_m4_t;
    reg  [DATA_WIDTH-1:0] i_m5_t;
    reg  [DATA_WIDTH-1:0] i_m6_t;
    reg  [DATA_WIDTH-1:0] i_m7_t;
    reg  [DATA_WIDTH-1:0] i_m8_t;
    reg  [DATA_WIDTH-1:0] i_m9_t;
    reg  [DATA_WIDTH-1:0] i_m10_t;
    reg  [DATA_WIDTH-1:0] i_m11_t;
    reg  [DATA_WIDTH-1:0] i_m12_t;
    reg  [DATA_WIDTH-1:0] i_m13_t;
    reg  [DATA_WIDTH-1:0] i_m14_t;
    reg  [DATA_WIDTH-1:0] i_m15_t;

    wire [DATA_WIDTH-1:0] o_message_t;
    wire [5:0]            o_round_t;
    wire [1:0]            o_FSM_state_t;

// Expectation output
    wire  [DATA_WIDTH-1:0] exp = exp_pipeline[1]; 
    reg  [DATA_WIDTH-1:0] exp_pipeline [0:1]; 
// DUT
    rME #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut
    (
        .clk  (clk_t),
        .rst_n(rst_n_t),
        .start_in(start_in_t),
        .i_m0 (i_m0_t),
        .i_m1 (i_m1_t),
        .i_m2 (i_m2_t),
        .i_m3 (i_m3_t),
        .i_m4 (i_m4_t),
        .i_m5 (i_m5_t),
        .i_m6 (i_m6_t),
        .i_m7 (i_m7_t),
        .i_m8 (i_m8_t),
        .i_m9 (i_m9_t),
        .i_m10(i_m10_t),
        .i_m11(i_m11_t),
        .i_m12(i_m12_t),
        .i_m13(i_m13_t),
        .i_m14(i_m14_t),
        .i_m15(i_m15_t),
        
        .o_message  (o_message_t),
        .o_round    (o_round_t),
        .o_FSM_state(o_FSM_state_t)
    );
    
// clock generation
initial clk_t =0;
always #5 clk_t = ~clk_t;

// Initialization
initial begin
        //Initial Value
        rst_n_t   = 0;
        start_in_t= 0;

        i_m0_t  = 32'h11111111;
        i_m1_t  = 32'h22222222;
        i_m2_t  = 32'h33333333;
        i_m3_t  = 32'h44444444;
        i_m4_t  = 32'h55555555;
        i_m5_t  = 32'h66666666;
        i_m6_t  = 32'h77777777;
        i_m7_t  = 32'h88888888;
        i_m8_t  = 32'h99999999;
        i_m9_t  = 32'hAAAAAAAA;
        i_m10_t = 32'hBBBBBBBB;
        i_m11_t = 32'hCCCCCCCC;
        i_m12_t = 32'hDDDDDDDD;
        i_m13_t = 32'hEEEEEEEE;
        i_m14_t = 32'hFFFFFFFF;
        i_m15_t = 32'h12345678;

// Apply reset
    #12 rst_n_t  = 1;

    #10  start_in_t = 1;
    #10  start_in_t = 0;
// Load input 
     repeat (65) begin
    @(posedge clk_t);
    end

    #50;
        $display("Simulation completed at time %0t", $time);
        $finish;
end
        always  @(negedge clk_t)begin
            case (o_round_t)
                6'd0: exp_pipeline[0]  = 32'h11111111;
                6'd1: exp_pipeline[0]  = 32'h22222222;
                6'd2: exp_pipeline[0]  = 32'h33333333;
                6'd3: exp_pipeline[0]  = 32'h44444444;
                6'd4: exp_pipeline[0]  = 32'h55555555;
                6'd5: exp_pipeline[0]  = 32'h66666666;
                6'd6: exp_pipeline[0]  = 32'h77777777;
                6'd7: exp_pipeline[0]  = 32'h88888888;
                6'd8: exp_pipeline[0]  = 32'h99999999;
                6'd9: exp_pipeline[0]  = 32'hAAAAAAAA;
                6'd10: exp_pipeline[0] = 32'hBBBBBBBB;
                6'd11: exp_pipeline[0] = 32'hCCCCCCCC;
                6'd12: exp_pipeline[0] = 32'hDDDDDDDD;
                6'd13: exp_pipeline[0] = 32'hEEEEEEEE;
                6'd14: exp_pipeline[0] = 32'hFFFFFFFF;
                6'd15: exp_pipeline[0] = 32'h12345678;
                default: exp_pipeline[0] = 32'd0;
            endcase
            exp_pipeline [1] <= exp_pipeline[0];
        end


// PASS/FAIL check like your DFF testbench
    always @(negedge clk_t) begin
        if (o_FSM_state_t != 2'b00) begin 
            if (o_message_t !== exp)
                $display("FAIL:%5t - Round=%2d - Out=%h Exp=%h", $time, o_round_t, o_message_t, exp);
            else
                $display("PASS:%5t - Round=%2d - Out=%h Exp=%h", $time, o_round_t, o_message_t, exp);
        end
    end

endmodule
