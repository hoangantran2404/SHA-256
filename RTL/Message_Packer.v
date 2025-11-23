`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 11/17/2025 02:51:29 PM
// Design Name: 
// Module Name: Message_Packer
// Project Name: SHA 256 (hash algorithm)
// Target Devices: ZCU102 FPGA Board
// Tool Versions: Vivado on Linux
// Description: Message_Packer's functionality is combined all data receiving from UART receiver (8 bits/clock) to 16 words (32 bits/1 word) 
// and passes it to SHA-256 core.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Message_Packer #(
    parameter DATA_WIDTH = 32
)(
    input  wire                             clk,    
    input  wire                             rst_n,  
    input  wire [7:0]                       uart_byte_in,     
    input  wire                             Rx_DV,                      //=1 means load input 

    output reg [DATA_WIDTH-1 :0]            data_out,
    output wire                             data_valid     
);

    //==================================================//
    //                 State Encoding                   //
    //==================================================//
    reg  [2:0] current_state_r = s_IDLE;
    reg  [2:0] next_state_r;

    localparam s_IDLE         = 3'b000;
    localparam s_RX_DATA_BITS = 3'b001; 
    localparam s_EXE_BIT      = 3'b011;
    localparam s_SEND         = 3'b100;
    localparam s_CLEANUP      = 3'b101;


    //==================================================//
    //                   Registers                      //
    //==================================================//
    reg [63:0]                    msg_len_bit            ;
    reg [7:0]                     uart_byte_r            ;    // Store the input 
    reg [7:0]                     mem [0:63]             ;  
    reg                           Rx_Data_r              ; 
    reg                           Rx_Data_R_r            ;   
    reg [5:0]                     din_count_r            ;    // counter BYTE from UART Receiver
    reg [4:0]                     dout_count_r           ;   
    reg                           dv_flag_r   =   1'b0   ;   // output flag done when 1 byte has converted
    reg [511:0]                   MP_out_r               ; 

    wire                          EXE_flag_r             ;        
    //==================================================//
    //             Input Synchronization                //
    //==================================================//
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
                Rx_Data_R_r             <= 0          ;
                Rx_Data_r               <= 0          ;
        end else begin
                Rx_Data_R_r             <= Rx_DV      ;
                Rx_Data_r               <= Rx_Data_R_r;
        end
    end

    //==================================================//
    //             Combinational Logic                  //
    //==================================================//
    //assign data_out = (current_state_r == s_CLEANUP )? MP_out_r : 0;
    assign data_valid           = dv_flag_r;
    assign EXE_flag_r           = (current_state_r == s_EXE_BIT && din_count_r == 6'd63)? 1'b1 : 1'b0;

    //==================================================//
    //                  Next State Logic                //
    //==================================================//
    always @(Rx_Data_r or din_count_r or EXE_flag_r or dout_count_r) begin
        case(current_state_r)
            s_IDLE: 
                if(Rx_Data_r == 1'b1) 
                    next_state_r = s_RX_DATA_BITS;
                else
                    next_state_r = s_IDLE;
            s_RX_DATA_BITS: 
                if(din_count_r < 6'd63) 
                    next_state_r = s_RX_DATA_BITS;
                else 
                    next_state_r = s_EXE_BIT;
            s_EXE_BIT: // Block 512 bit
                if(EXE_flag_r == 1'b1) // Done make block
                    next_state_r = s_SEND;
                else 
                    next_state_r = s_EXE_BIT;
            s_SEND: // Send BYTE to SHA256 core one by one per clock
                if (dout_count_r < 5'd15)
                   next_state_r = s_SEND;    
                else
                    next_state_r = s_CLEANUP;
            s_CLEANUP: 
                    next_state_r = s_IDLE;
            default: 
                next_state_r     =  s_IDLE;
        endcase
    end

    //==================================================//
    //                State Register (FSM)              //
    //==================================================//
    always @(posedge clk ) begin
        current_state_r <= next_state_r;
    end

    //==================================================//
    //                   Datapath                       //
    //==================================================//
    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            uart_byte_r              <= 0;
            din_count_r              <= 0;
            dv_flag_r                <= 1'b0;
            MP_out_r                 <= {512{1'b0}};
            for (i=0 ; i<64 ; i=i+1) begin
                mem[i]  <= 8'd0;
            end
        end else begin
                case(current_state_r)
                    s_IDLE: begin
                        uart_byte_r              <= 0;
                        din_count_r              <= 0;
                        dv_flag_r                <= 1'b0;

                        if (Rx_Data_r)
                            uart_byte_r          <=  uart_byte_in;
                    end
                    s_RX_DATA_BITS: begin
                        if (Rx_Data_r) begin
                            mem[din_count_r] <=  uart_byte_r;
                            if(din_count_r < 6'd63)              
                                din_count_r      <=  din_count_r + 1;
                        end
                    end
                    s_EXE_BIT: begin
                        msg_len_bit             <= ( {58'd0, din_count_r} << 3 ); // din_count_r * 8
                        for (i=0; i<64; i=i+1) begin
                            if (i < din_count_r)
                                    MP_out_r[511 - i*8 -: 8] <= mem[i];
                            else
                                    MP_out_r[511 - i*8 -: 8] <= 8'd0;  // zeros
                        end
                        if (din_count_r < 6'd64) begin
                            MP_out_r[511 - din_count_r*8 -: 8] <= 8'h80;
                        end
                        
                        for (i=0; i<8; i=i+1) begin
                            MP_out_r[63 - i*8 -: 8] <= msg_len_bit[(7-i)*8 +: 8];
                        end


                    end
                    s_SEND: begin
                        if(EXE_flag_r == 1'b1 ) begin
                            data_out                        <= MP_out_r [511 - (dout_count_r)*32 -: 32];
                            dv_flag_r                       <= 1'b1;
                            if (dout_count_r < 5'd15)
                                dout_count_r                <= dout_count_r + 1'b1;
                        end else begin
                            dout_count_r                    <= 0   ;
                            dv_flag_r                       <= 1'b0;
                        end           
                    end
                    
                    s_CLEANUP: begin
                        din_count_r                         <= 6'd0;
                        dout_count_r                        <= 5'd0;
                        dv_flag_r                           <= 1'b0;
                    end

                    default: begin
                        uart_byte_r                         <= 8'd0;
                        din_count_r                         <= 6'd0;
                        dout_count_r                        <= 5'd0;
                        dv_flag_r                           <= 1'b0;
                    end
                endcase
        end
    end

endmodule


