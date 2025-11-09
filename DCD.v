`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2025 05:30:08 PM
// Design Name: 
// Module Name: DCD
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


module DCD(
    input wire [7:0]    Rx_Byte_in, //Output from UART
    input wire          Rx_DV_in,   // Receive Data Valid
    input wire          clk, 


    output reg          A_Ena_out,  // Enable for the Matrix A Memory CLuster
    output reg          A_Wena_out, // Writing enabble 
    output reg          A_Dina_out, // Input
    output reg [13:0]   A_Addra_out,

    output reg          X_Ena_out,  // Vector data X
    output reg          X_Wena_out,
    output reg          X_Dina_out,
    output reg [6:0]    X_Addra_out,

    output reg          Load_out, // FSM & Controller
    output reg          Start_out,

    output reg [7:0]    N_out,
    output reg          N_valid_out,
    output reg          Done_in,
    output reg          RST
);
// Reg and Wire
reg [13:0] Count_r; // Caculate how many bit we receive from UART
reg [2:0]  current_state_r, next_state_r;
reg [15:0] A_size;
// Local Parameter
    localparam s_IDLE   = 3'b000,
               s_LOAD_N = 3'b001,
               s_LOAD_X = 3'b010,
               s_LOAD_A = 3'b011,
               s_START  = 3'b100,
               s_WAIT   = 3'b101;

    always @(posedge clk) begin
        current_state_r <= next_state_r;
    end


// Current State-Next State
always @(posedge clk ) begin
    case (current_state_r)
        s_START: //trigger the operation
                if (Done_in)
                    next_state_r = s_IDLE;
                else
                    next_state_r = s_WAIT;
        s_IDLE:
                if (Rx_DV_in) 
                    next_state_r = s_LOAD_N;
                else 
                    next_state_r = s_IDLE;
        s_LOAD_N:
                    next_state_r = s_LOAD_X;
            
        s_LOAD_X:
                if (Rx_DV_in && Count_r == N_out)
                    next_state_r = s_LOAD_A;
                else
                    next_state_r = s_LOAD_X;
        
        s_LOAD_A:
                if (Rx_DV_in && Count_r == A_size)
                    next_state_r = s_START;
                else
                    next_state_r = s_LOAD_A;

        s_WAIT:// wait until that operation is done
                if (Done_in)
                    next_state_r = s_IDLE;
                else
                    next_state_r = s_WAIT;

        default: next_state_r =s_IDLE;
    endcase
end

// Datapath
    always @(posedge clk) begin
        case (current_state_r)
            s_IDLE: begin
                Count_r <= 0;
                A_Addra_out <= 0;
                X_Addra_out <= 0;
                Load_out <= 0;
                Start_out <= 0;
                RST <= 0;
            end

            s_LOAD_N: begin
                if (Rx_DV_in) begin
                    N_out <= 2 << (Rx_Byte_in - 1);
                    N_valid_out <= 1;
                    Load_out <= 1;
                    Count_r <= 0;
                    A_size <= N_out*(N_out + 1);
                end
            end

            s_LOAD_X: begin
                if (Rx_DV_in) begin
                    X_Ena_out <= 1;
                    X_Wena_out <= 1;
                    X_Dina_out <= Rx_Byte_in;
                    X_Addra_out <= X_Addra_out + 1;
                    Count_r <= Count_r + 1;
                end
            end

            s_LOAD_A: begin
                if (Rx_DV_in) begin
                    A_Ena_out <= 1;
                    A_Wena_out <= 1;
                    A_Dina_out <= Rx_Byte_in;
                    A_Addra_out <= A_Addra_out + 1;
                    Count_r <= Count_r + 1;
                end
            end

            s_START: begin
                Start_out <= 1;
                A_Addra_out <= 0;
                X_Addra_out <= 0;
            end

            s_WAIT: begin
                if (Done_in)
                    RST <= 1;
            end
        endcase
    end
endmodule
