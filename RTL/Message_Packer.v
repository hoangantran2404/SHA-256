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
    parameter DATA_WIDTH    = 32,
    parameter TIMEOUT_LIMIT = 4340 // wait for 2 byte (2170 clock/1 byte)
)(
    input  wire                             clk,    
    input  wire                             rst_n,  
    input  wire [7:0]                       uart_byte_in,     
    input  wire                             Rx_DV_in,

    output wire [DATA_WIDTH-1 :0]           data_out,
    output wire [7:0]                       MP_counter_out, 
    output wire                             MP_dv_out     
);

    //==================================================//
    //                 State Encoding                   //
    //==================================================//
    reg  [2:0] current_state_r;
    reg  [2:0] next_state_r;

    localparam s_PRELOAD      = 3'b000;
    localparam s_RX_DATA_BITS = 3'b001; 
    localparam s_EXE_BIT      = 3'b010;
    localparam s_WAIT_CORE    = 3'b011; 
    localparam s_SEND         = 3'b100;
    localparam s_CLEANUP      = 3'b101;

    //==================================================//
    //                   Registers                      //
    //==================================================//
    reg                           Rx_Data_r, Rx_Data_R_r;    
    reg [6:0]                     MP_count_r;
    reg [6:0]                     RX_len_bit;
    reg [7:0]                     address_r [0:63]; 
    reg [31:0]                    time_cnt_r; // time control  

    wire                          RX_done_flag_w; 
    wire                          SEND_done_flag_w;   
    wire                          timeout_flag_w; 
    wire [63:0]                   msg_len_bits;      

    //==================================================//
    //             Input Synchronization                //
    //==================================================//
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
                Rx_Data_R_r <= 0; 
                Rx_Data_r <= 0;
        end else begin
                Rx_Data_R_r <= Rx_DV_in; 
                Rx_Data_r <= Rx_Data_R_r;
        end
    end

    //==================================================//
    //             Combinational Logic                  //
    //==================================================//
    
    assign MP_dv_out       = (current_state_r == s_SEND || current_state_r == s_WAIT_CORE);
    assign MP_counter_out   = MP_count_r; 

    assign timeout_flag_w   = (time_cnt_r == TIMEOUT_LIMIT);
    assign RX_done_flag_w   = (current_state_r == s_RX_DATA_BITS) && ((MP_count_r == 7'd64) || timeout_flag_w) ; 
    assign SEND_done_flag_w = (current_state_r == s_SEND && MP_count_r == 7'd15); 

    assign msg_len_bits     = {53'd0, RX_len_bit, 3'b000}; 

    assign data_out = (current_state_r == s_SEND || current_state_r == s_WAIT_CORE) ? 
                                                                                    {address_r[MP_count_r*4 + 0],
                                                                                    address_r[MP_count_r*4 + 1],
                                                                                    address_r[MP_count_r*4 + 2],
                                                                                    address_r[MP_count_r*4 + 3]} : 32'd0;

    //==================================================//
    //                  Next State Logic                //
    //==================================================//
    always @(current_state_r or Rx_Data_r or RX_done_flag_w or SEND_done_flag_w) begin
        case(current_state_r)
            s_PRELOAD: 
                if(Rx_Data_r) 
                    next_state_r = s_RX_DATA_BITS;
                else          
                    next_state_r = s_PRELOAD;
            
            s_RX_DATA_BITS: 
                if(RX_done_flag_w) 
                    next_state_r = s_EXE_BIT; 
                else               
                    next_state_r = s_RX_DATA_BITS;
            
            s_EXE_BIT: // DONE in one cycle
                next_state_r = s_WAIT_CORE; 
                
            s_WAIT_CORE:
                next_state_r = s_SEND;

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
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            time_cnt_r <=0;
        else if(current_state_r == s_RX_DATA_BITS)begin
            if(Rx_Data_r)
                time_cnt_r <= 0;
            else if(time_cnt_r < TIMEOUT_LIMIT)
                time_cnt_r <= time_cnt_r + 1;
        end else
            time_cnt_r <= 0;
    end
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            MP_count_r <= 0;
            RX_len_bit <= 0;
            for (i=0 ; i<64 ; i=i+1) 
                address_r[i] <= 8'd0;
        end else begin

            case(current_state_r)
                s_PRELOAD: begin
                   if (Rx_Data_r) begin
                       
                        address_r[0] <= uart_byte_in;
                        MP_count_r   <= 1;
                        RX_len_bit   <= 1;
                    end else begin
                        MP_count_r   <= 0;
                        RX_len_bit   <= 0;
                    end
                end

                s_RX_DATA_BITS: begin
                    if(Rx_Data_r)
                        if(MP_count_r < 7'd64) begin
                            address_r[MP_count_r] <= uart_byte_in;             
                            MP_count_r            <= MP_count_r + 1;
                            RX_len_bit            <= MP_count_r + 1; 
                        end
                end

                s_EXE_BIT: begin
                    address_r[RX_len_bit] <= 8'h80;
                    
                    for (i=0; i<64; i=i+1) begin
                        if (i > RX_len_bit && i < 56)
                            address_r[i] <= 8'h00;
                    end
                    
                    for (i=0; i<8; i=i+1) begin
                        address_r[63 - i] <= msg_len_bits[i*8 +: 8];
                    end
                    MP_count_r <= 0;
                end

                s_WAIT_CORE: begin
                    
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


