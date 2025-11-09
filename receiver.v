/*
 *-----------------------------------------------------------------------------
 * Title         : UART Receiver Core
 * Project       : UART Communication Module for FPGA Systems
 *-----------------------------------------------------------------------------
 * File          : receiver.v
 * Author        : Pham Hoai Luan
 *                 <pham.hoailuan@is.naist.jp>
 * Created       : 06.09.2025
 * Last modified : 06.09.2025
 *-----------------------------------------------------------------------------
 * Description   : UART Receiver module to deserialize serial data into 8-bit
 *                 parallel output. Supports standard UART protocol: 1 start bit,
 *                 8 data bits (LSB first), and 1 stop bit.
 *
 *                 Set parameter CLKS_PER_BIT based on system clock frequency
 *                 and desired UART baud rate:
 *
 *                 CLKS_PER_BIT = (Frequency of CLK) / (Baud Rate)
 *
 *                 Example for this design:
 *                   - CLK    = 25 MHz
 *                   - Baud Rate = 115200
 *                   => CLKS_PER_BIT = 25_000_000 / 115200 ≈ 217
 *
 *                 This means each UART bit will be sampled every 217 clock cycles.
 *-----------------------------------------------------------------------------
 * Copyright (c) 2025 by NAIST. This model is the confidential and proprietary
 * property of NAIST, and the possession or use of this file requires a written
 * license from NAIST.
 *-----------------------------------------------------------------------------
 * Modification history :
 * 06.09.2025 : Created
 *-----------------------------------------------------------------------------
 */

`timescale 1ns / 1ps

module receiver #(
    parameter CLKS_PER_BIT = 217 // Time for read 1 bit UART
)(
    input  wire        			CLK,
    input  wire        			Rx_Serial_in,
    output wire        			Rx_DV_out,
    output wire [7:0]  			Rx_Byte_out,
	output wire [7:0]  			LED_out
);

    //==================================================//
    //                 State Encoding                   //
    //==================================================//
    localparam s_IDLE         	= 3'b000;
    localparam s_RX_START_BIT 	= 3'b001;
    localparam s_RX_DATA_BITS 	= 3'b010;
    localparam s_RX_STOP_BIT  	= 3'b011;
    localparam s_CLEANUP      	= 3'b100;

    //==================================================//
    //                   Registers                      //
    //==================================================//
    reg           Rx_Data_R_r   = 1'b1; // SYnchronize the UART signal with FPGA clock
    reg           Rx_Data_r     = 1'b1;

    //Đây là bộ đếm clock để đo thời gian trong 1 bit UART.
    //Mỗi khi FPGA clock lên 1 lần, Clock_Count_r tăng 1.
    //Khi Clock_Count_r = CLKS_PER_BIT - 1 → đã đi hết thời gian của 1 bit UART.
    reg  [7:0]    Clock_Count_r = 0;
    reg  [2:0]    Bit_Index_r   = 0;    //confirm what bit we are converting
    reg  [7:0]    Rx_Byte_r     = 0;    // Save temporaly the byte we receive
    reg           Rx_DV_r       = 0;    // Data_valid
	reg  [7:0]    LED_r			= 0;    

    reg  [2:0]    current_state_r = s_IDLE;   // current state
    reg  [2:0]    next_state_r;          // next state

    //==================================================//
    //             Input Synchronization                //
    //==================================================//
    always @(posedge CLK) begin 
        Rx_Data_R_r <= Rx_Serial_in;
        Rx_Data_r   <= Rx_Data_R_r; // to avoid mestable
    end

    //==================================================//
    //                  Next State Logic                //
    //==================================================//
    always @* begin
        case (current_state_r)
            s_IDLE:
                if (Rx_Data_r == 1'b0)
                    next_state_r = s_RX_START_BIT;
                else
                    next_state_r = s_IDLE;

            s_RX_START_BIT:
                if (Clock_Count_r == (CLKS_PER_BIT - 1) / 2)
                    if (Rx_Data_r == 1'b0)
                        next_state_r = s_RX_DATA_BITS;
                    else
                        next_state_r = s_IDLE;
                else
                    next_state_r = s_RX_START_BIT;

            s_RX_DATA_BITS: 
                if (Clock_Count_r < CLKS_PER_BIT - 1)
                    next_state_r = s_RX_DATA_BITS;
                else if (Bit_Index_r < 7) // Keep do until get enough data 
                    next_state_r = s_RX_DATA_BITS;
                else
                    next_state_r = s_RX_STOP_BIT;

            s_RX_STOP_BIT:
                if (Clock_Count_r < CLKS_PER_BIT - 1)
                    next_state_r = s_RX_STOP_BIT;
                else
                    next_state_r = s_CLEANUP;

            s_CLEANUP: //Reset to the initial state
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
                Rx_DV_r       <= 1'b0;
                Clock_Count_r <= 0;
                Bit_Index_r   <= 0;
            end

            s_RX_START_BIT: begin
                if (Clock_Count_r == (CLKS_PER_BIT - 1) / 2) begin
                    if (Rx_Data_r == 1'b0)
                        Clock_Count_r <= 0;
                end else
                    Clock_Count_r <= Clock_Count_r + 1;
            end

            s_RX_DATA_BITS: begin
                if (Clock_Count_r < CLKS_PER_BIT - 1) begin
                    Clock_Count_r <= Clock_Count_r + 1;
                end else begin
                    Clock_Count_r          <= 0;
                    Rx_Byte_r[Bit_Index_r] <= Rx_Data_r;
                    if (Bit_Index_r < 7)
                        Bit_Index_r <= Bit_Index_r + 1;
                    else
                        Bit_Index_r <= 0;
                end
            end

            s_RX_STOP_BIT: begin
                if (Clock_Count_r < CLKS_PER_BIT - 1) begin
                    Clock_Count_r <= Clock_Count_r + 1; // keep counting if we do not have enough data 
                end else begin // If yes, reset data and send the signal 
                    Rx_DV_r       <= 1'b1;
                    Clock_Count_r <= 0;
                end
            end

            s_CLEANUP: begin
                Rx_DV_r <= 1'b0;
            end

            default: begin
                Rx_DV_r       <= 1'b0;
                Clock_Count_r <= 0;
                Bit_Index_r   <= 0;
            end
        endcase
    end

    //==================================================//
    //                     Output                       //
    //==================================================//
     assign Rx_DV_out   = Rx_DV_r;
     assign Rx_Byte_out = Rx_Byte_r;
	
	always @(posedge CLK) begin
		if(Rx_DV_r)
			LED_r	<= Rx_Byte_r;
		else
			LED_r	<= LED_r;
	end
	
	assign LED_out	= LED_r;

endmodule
