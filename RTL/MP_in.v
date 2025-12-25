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
// Description: Message_Packer's functionality is combined all data receiving from UART receiver (8 bits/clock) to 16 words (32 bits/1 word) and send to core.
// and passes it to SHA-256 core.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module MP_in #(
    parameter DATA_WIDTH    = 32
)(
    input  wire                             clk,    
    input  wire                             rst_n,  
    input  wire [7:0]                       uart_byte_in,     
    input  wire                             RX_DV_in,

    output wire [DATA_WIDTH-1 :0]           MP_data_out,
    output wire                             MP_dv_out     
);

    //==================================================//
    //                 State Encoding                   //
    //==================================================//
    reg  [2:0] current_state_r;
    reg  [2:0] next_state_r;

    localparam s_PRELOAD      = 3'b000;
    localparam s_RX_DATA_BITS = 3'b001; 
    localparam s_SEND         = 3'b010;
    localparam s_CLEANUP      = 3'b011;

    //==================================================//
    //                   Registers                      //
    //==================================================//
    reg [6:0]                     MP_count_r;
    reg [511:0]                   address_r ;  

    wire                          RX_done_flag_w; 
    wire                          SEND_done_flag_w;    

    //==================================================//
    //             Combinational Logic                  //
    //==================================================//

    assign MP_dv_out       = (current_state_r == s_SEND);

    assign RX_done_flag_w   = (current_state_r == s_RX_DATA_BITS && MP_count_r == 7'd64) ; 
    assign SEND_done_flag_w = (current_state_r == s_SEND && MP_count_r == 7'd15); 

    assign MP_data_out      = (current_state_r == s_SEND )?  address_r[511-32*MP_count_r -:32] : 32'd0;

    //==================================================//
    //                  Next State Logic                //
    //==================================================//
    always @(current_state_r or RX_DV_in or RX_done_flag_w or SEND_done_flag_w) begin
        case(current_state_r)
            s_PRELOAD: 
                if(RX_DV_in) 
                    next_state_r = s_RX_DATA_BITS;
                else          
                    next_state_r = s_PRELOAD;
            
            s_RX_DATA_BITS: 
                if(RX_done_flag_w) 
                    next_state_r = s_SEND; 
                else               
                    next_state_r = s_RX_DATA_BITS;
        
            s_SEND: 
                if (SEND_done_flag_w) 
                    next_state_r = s_CLEANUP;    
                else                  
                    next_state_r = s_SEND;
            
            s_CLEANUP: 
                next_state_r = s_PRELOAD;
            
            default: 
                next_state_r = s_PRELOAD;
        endcase
    end

    //==================================================//
    //                State Register (FSM)              //
    //==================================================//
    always @(posedge clk or negedge rst_n ) begin
        if(!rst_n) 
            current_state_r <= s_PRELOAD;
        else       
            current_state_r <= next_state_r;
    end

    //==================================================//
    //                   Datapath                       //
    //==================================================//
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            MP_count_r <= 0;
            address_r  <= 512'd0;
        end else begin
            if (current_state_r != next_state_r) begin
                if (next_state_r == s_SEND)      
                    MP_count_r <= 0; 
                else if (next_state_r == s_PRELOAD) 
                    MP_count_r <= 0;
            end

            case(current_state_r)
                s_PRELOAD: begin
                   if (RX_DV_in) begin
                        address_r[511 -: 8] <= uart_byte_in;
                        MP_count_r   <= 1;
                    end
                end

                s_RX_DATA_BITS: begin
                    if(RX_DV_in)
                        if(MP_count_r < 7'd64) begin
                            address_r[511 - 8*MP_count_r -:8] <= uart_byte_in;             
                            MP_count_r                        <= MP_count_r + 1;
                        end
                end

                s_SEND: begin
                    if(MP_count_r < 7'd15)
                        MP_count_r   <= MP_count_r + 1;        
                end

                s_CLEANUP: begin                         
                end
            endcase
        end
    end
endmodule


