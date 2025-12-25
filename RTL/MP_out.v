`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2025 02:17:30 PM
// Design Name: 
// Module Name: MP_out
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

module MP_out#(
    parameter DATA_WIDTH    = 32
)(
    input  wire                             clk,    
    input  wire                             rst_n,  
    input  wire [DATA_WIDTH-1:0]            core_byte_in, 
    input  wire                             TX_active_in,
    input  wire                             TX_done_in,
    input  wire                             RX_DV_in,

    output wire [7:0]                       MP_data_out,
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
    reg [255:0]                   address_r ;  
    reg                           TX_done_prev_r ;

    wire                          RX_done_flag_w; 
    wire                          SEND_done_flag_w;    

    //==================================================//
    //             Combinational Logic                  //
    //==================================================//

    assign MP_dv_out        = (current_state_r == s_SEND && TX_active_in == 1'b0);

    assign RX_done_flag_w   = (current_state_r == s_RX_DATA_BITS && MP_count_r == 7'd7) ; 
    assign SEND_done_flag_w = (current_state_r == s_SEND && MP_count_r == 7'd31 && TX_done_in == 1'b1 && TX_done_prev_r == 1'b0); 

    assign MP_data_out      = (current_state_r == s_SEND) ?  address_r[255 - 8*MP_count_r -:8] : 8'd0;

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
            address_r  <= 256'd0;
        end else begin
            TX_done_prev_r <= TX_done_in;

            case(current_state_r)
                s_PRELOAD: begin
                   if (RX_DV_in) begin
                        address_r[255 -: 32] <= core_byte_in;
                        MP_count_r   <= 1;
                    end
                end
                s_RX_DATA_BITS: begin
                    if(RX_DV_in)
                        if(MP_count_r < 7'd8) begin
                            address_r[255 - 32*MP_count_r -:32] <= core_byte_in;             

                            if(MP_count_r == 7'd7)
                                MP_count_r <= 0;
                            else 
                                MP_count_r <= MP_count_r + 1'b1;
                        end
                end
                s_SEND: begin
                    if(TX_done_in == 1'b1 && TX_done_prev_r == 1'b0)
                        MP_count_r   <= MP_count_r + 1;        
                end

                s_CLEANUP: begin                         
                end
            endcase
        end
    end
endmodule
