/*
 *-----------------------------------------------------------------------------
 * Title         : UART Transmitter Core
 * Project       : UART Communication Module for FPGA Systems
 *-----------------------------------------------------------------------------
 * File          : transmitter.v
 * Author        : Pham Hoai Luan
 *                 <pham.hoailuan@is.naist.jp>
 * Created       : 06.13.2025
 * Last modified : 06.13.2025
 *-----------------------------------------------------------------------------
 * Description   : UART Transmitter module to serialize 8-bit parallel data
 *                 into UART serial format. Implements standard UART protocol:
 *                 1 start bit, 8 data bits (LSB first), and 1 stop bit.
 *
 *                 Set parameter CLKS_PER_BIT based on system clock frequency
 *                 and desired UART baud rate:
 *
 *                 CLKS_PER_BIT = (Frequency of CLK) / (Baud Rate)
 *
 *                 Example for this design:
 *                   - CLK = 25 MHz
 *                   - Baud Rate = 115200
 *                   => CLKS_PER_BIT = 25_000_000 / 115200 ≈ 217
 *-----------------------------------------------------------------------------
 * Copyright (c) 2025 by NAIST. This model is the confidential and proprietary
 * property of NAIST, and the possession or use of this file requires a written
 * license from NAIST.
 *-----------------------------------------------------------------------------
 * Modification history :
 * 06.13.2025 : Created
 *-----------------------------------------------------------------------------
 */

`timescale 1ns / 1ps

module transmitter #(
    parameter CLKS_PER_BIT = 868
)(
    input  wire       CLK,
    input  wire       Tx_DV_in,
    input  wire [7:0] Tx_Byte_in,
    output wire       Tx_Active_out,
    output reg        Tx_Serial_out,
    output wire       Tx_Done_out
);

    //==================================================//
    //                 State Encoding                   //
    //==================================================//
    localparam s_IDLE          = 3'b000;
    localparam s_TX_START_BIT  = 3'b001;
    localparam s_TX_DATA_BITS  = 3'b010;
    localparam s_TX_STOP_BIT   = 3'b011;
    localparam s_CLEANUP       = 3'b100;

    //==================================================//
    //                   Registers                      //
    //==================================================//
    reg [2:0] current_state_r = s_IDLE;   // current state
    reg [2:0] next_state_r;               // next state

    reg [10:0] Clock_Count_r  = 8'd0;
    reg [2:0] Bit_Index_r    = 3'd0;
    reg [7:0] Tx_Data_r      = 8'd0;
    reg       Tx_Done_r      = 1'b0;
    reg       Tx_Active_r    = 1'b0;

    //==================================================//
    //                  Next State Logic                //
    //==================================================//
    always @* begin
        case (current_state_r)
            s_IDLE:
                if (Tx_DV_in == 1'b1)
                    next_state_r = s_TX_START_BIT;
                else
                    next_state_r = s_IDLE;

            s_TX_START_BIT:
                if (Clock_Count_r < CLKS_PER_BIT - 1)
                    next_state_r = s_TX_START_BIT;
                else
                    next_state_r = s_TX_DATA_BITS;

            s_TX_DATA_BITS:
                if (Clock_Count_r < CLKS_PER_BIT - 1)
                    next_state_r = s_TX_DATA_BITS;
                else if (Bit_Index_r < 3'd7)
                    next_state_r = s_TX_DATA_BITS;
                else
                    next_state_r = s_TX_STOP_BIT;

            s_TX_STOP_BIT:
                if (Clock_Count_r < CLKS_PER_BIT - 1)
                    next_state_r = s_TX_STOP_BIT;
                else
                    next_state_r = s_CLEANUP;

            s_CLEANUP:
                next_state_r = s_IDLE;

            default:
                next_state_r = s_IDLE;
        endcase
    end

    //==================================================//
    //                State Register (FSM)              //
    //==================================================//
    always @(posedge CLK) begin
        current_state_r <= next_state_r;
    end

    //==================================================//
    //                   Datapath                       //
    //==================================================//
    always @(posedge CLK) begin
        case (current_state_r)
            s_IDLE: begin
                Tx_Serial_out <= 1'b1;       // line idle = '1'
                Tx_Done_r     <= 1'b0;
                Clock_Count_r <= 8'd0;
                Bit_Index_r   <= 3'd0;

                if (Tx_DV_in == 1'b1) begin
                    Tx_Active_r <= 1'b1;
                    Tx_Data_r   <= Tx_Byte_in;
                end else begin
                    Tx_Active_r <= 1'b0;
                end
            end

            s_TX_START_BIT: begin
                Tx_Serial_out <= 1'b0;       // start bit
                if (Clock_Count_r < CLKS_PER_BIT - 1) begin
                    Clock_Count_r <= Clock_Count_r + 1'b1;
                end else begin
                    Clock_Count_r <= 8'd0;
                end
            end

            s_TX_DATA_BITS: begin
                Tx_Serial_out <= Tx_Data_r[Bit_Index_r]; // LSB first
                if (Clock_Count_r < CLKS_PER_BIT - 1) begin
                    Clock_Count_r <= Clock_Count_r + 1'b1;
                end else begin
                    Clock_Count_r <= 8'd0;
                    if (Bit_Index_r < 3'd7)
                        Bit_Index_r <= Bit_Index_r + 1'b1;
                    else
                        Bit_Index_r <= 3'd0;
                end
            end

            s_TX_STOP_BIT: begin
                Tx_Serial_out <= 1'b1;       // stop bit
                if (Clock_Count_r < CLKS_PER_BIT - 1) begin
                    Clock_Count_r <= Clock_Count_r + 1'b1;
                end else begin
                    Tx_Done_r     <= 1'b1;
                    Clock_Count_r <= 8'd0;
                    Tx_Active_r   <= 1'b0;
                end
            end

            s_CLEANUP: begin
                Tx_Done_r <= 1'b1;           // giữ done 1 chu kỳ
            end

            default: begin
                Tx_Serial_out <= 1'b1;
                Tx_Done_r     <= 1'b0;
                Clock_Count_r <= 8'd0;
                Bit_Index_r   <= 3'd0;
                Tx_Active_r   <= 1'b0;
            end
        endcase
    end

    //==================================================//
    //                     Output                       //
    //==================================================//
    assign Tx_Active_out = Tx_Active_r;
    assign Tx_Done_out   = Tx_Done_r;

endmodule
