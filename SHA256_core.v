`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 11/11/2025 05:04:58 PM
// Design Name: 
// Module Name: SHA256_core
// Project Name: SHA-256
// Target Devices: ZCU102 FPGA Board
// Tool Versions: Vivado 2022 on Linux
// Description: SHA256 core receives data from Message Packer. Firstly, it generates a block of 512 bits and load 32 bits/ 1 cycle clock to Message Expander. 
// Secondly, it receives 256 bits of final hash value from Message Compression. Lastly, it sends 8 bits/clock to UART transmitter.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SHA256_core#(
    parameter DATA_WIDTH =32
)
(   
    input wire                    clk, rst_n, 
    input wire                    MP_dv,  //signal for receive 32 bit
    input wire [DATA_WIDTH -1 :0] message_in,

    output reg [7 :0]             hash_out,
    output wire                   core_dv_flag
);
// Internal signal
wire           [1:0]              FSM_state_w      ;
wire           [5:0]              round_w          ;
wire                              ME_block_flag_w  ;
wire      [DATA_WIDTH -1: 0]      MC_byte_in_w     ;
wire                              MC_dv_in_w       ;
wire                              MC_dv_out_w      ;
wire       [DATA_WIDTH -1 :0]     MC_byte_out_w    ;
//==================================================//
//                 State Encoding                   //
//==================================================//
reg [2:0]  current_state_r = s_IDLE ;
reg [2:0]  next_state_r;

localparam s_IDLE           =3'b000;
localparam s_BLOCK_ME       =3'b001;
localparam s_SEND_ME        =3'b010;
localparam s_SEND_MC        =3'b011;
localparam s_EXE_BIT        =3'b100; // Compile 256 hash value
localparam s_SEND           =3'b101; // Send to UART transmitter
localparam s_CLEANUP        =3'b110;

//==================================================//
//                   Registers                      //
//==================================================//
reg                             Rx_Data_r              ;   // Flag using for load input from MP to ME block
reg                             Rx_Data_R_r            ; 
// reg      [DATA_WIDTH -1 :0]     MC_byte_out_r          ;
reg      [DATA_WIDTH -1 :0]     ME_byte_in_r           ;   // Input of ME
reg      [DATA_WIDTH -1 :0]     mem_in [0:15]          ; // store the input
reg      [255 :0]               mem_out                ; // store the output
reg      [4:0]                  din_count_r            ; // Counter to compile 512 bits and send to ME respectively 
reg      [4:0]                  dout_count_r           ; // Counter to receive 256 bit from MC 
reg      [4:0]                  Rx_ME_count_r          ;    
reg      [5:0]                  UART_ts_count_r        ; // Counter to send 8 bit/ clock to UART transmitter  
reg                             ME_dv_in_r             ;

//==================================================//
//             Combinational Logic                  //
//==================================================//
assign ME_block_flag_w = (din_count_r == 5'd15)                                 ? 1'b1 :1'b0;
assign core_dv_flag    = (current_state_r == s_SEND && UART_ts_count_r < 6'd32 )? 1'b1 :1'b0; 

//==================================================//
//             Instantiate module                   //
//==================================================//

rME # (
    .DATA_WIDTH(DATA_WIDTH)
) Message_Expansion
(
    .data_in        (   ME_byte_in_r     ),   
    .clk            (   clk              ),
    .rst_n          (   rst_n            ),
    .start_in       (   ME_dv_in_r       ),
    .Rx_core_count  (   Rx_ME_count_r    ),

    .ME_dv_out      (   MC_dv_in_w       ),     
    .data_out       (   MC_byte_in_w     ),
    .o_round        (   round_w          ),
    .o_FSM_state    (   FSM_state_w      )

);

MC #(
    .DATA_WIDTH(DATA_WIDTH)
)  Message_Compression
(
    .clk           (clk             ),
    .rst_n         (rst_n           ),
    .start_in      (MC_dv_in_w      ),
    .data_in       (MC_byte_in_w    ),
    .FSM_state_in  (FSM_state_w     ),
    .round_in      (round_w         ), 
    
    .data_out      (MC_byte_out_r   ),
    .valid_out     (MC_dv_out_w     )
);

//==================================================//
//             Input Synchronization                //
//==================================================//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
            Rx_Data_R_r <= 0;
            Rx_Data_r   <= 0;
    end else begin
            Rx_Data_R_r <= MP_dv;
            Rx_Data_r   <= Rx_Data_R_r;
    end
end


//==================================================//
//                  Next State Logic                //
//==================================================//
always @(Rx_Data_R_r or din_count_r or Rx_ME_count_r or MC_dv_in_w or MC_dv_out_w or round_w or dout_count_r or UART_ts_count_r) begin
    case(current_state_r)
        s_IDLE:
            if (Rx_Data_R_r    == 1'b1)     // Must set Rx_data_r_r =0 after this step
                next_state_r   = s_BLOCK_ME;
            else 
                next_state_r   = s_IDLE;
        s_BLOCK_ME: // Generate 512 bit block
            if(din_count_r < 5'd16)
                next_state_r    =   s_BLOCK_ME;
            else
                next_state_r    =   s_SEND_ME;
        s_SEND_ME: // Send data to ME 
            if(Rx_ME_count_r    < 5'd16)
                next_state_r    =   s_SEND_ME;
            else 
                next_state_r    =   s_SEND_MC;
        s_SEND_MC:// Receiver signal dv from ME to load to MC
            if(MC_dv_in_w  == 1'b1 && round_w < 6'd64)
                next_state_r    =   s_SEND_MC;
            else
                next_state_r    =   s_EXE_BIT;
        s_EXE_BIT: // Generate 256 bit block
            if(MC_dv_out_w == 1'b1 && dout_count_r < 5'd8)
                next_state_r    = s_EXE_BIT;
            else
                next_state_r    = s_SEND;
        s_SEND: // send to UART Transmitter
            if(UART_ts_count_r < 6'd32)
                next_state_r    = s_SEND;
            else 
                next_state_r    = s_CLEANUP;
        s_CLEANUP:
            next_state_r        = s_IDLE;
        default: 
            next_state_r        = s_IDLE;
    endcase
end
//==================================================//
//                State Register (FSM)              //
//==================================================//
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        current_state_r <= s_IDLE;
    else
        current_state_r <= next_state_r;
end
//==================================================//
//                   Datapath                       //
//==================================================//
integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
            for (i = 0; i < 16; i = i+1) begin
                mem_in[i]      <= {DATA_WIDTH{1'b0}};
            end
            mem_out         <= {256{1'b0}};
            din_count_r     <= 5'd0;
            dout_count_r    <= 5'd0;
            Rx_ME_count_r   <= 5'd0;
            UART_ts_count_r <= 6'd0;
            ME_byte_in_r    <= {DATA_WIDTH{1'b0}};
            ME_dv_in_r      <= 1'b0;
            hash_out        <= {DATA_WIDTH{1'b0}};

    end
    else begin 
        case(current_state_r)
                s_IDLE: begin 
                    for (i = 0; i < 16; i = i+1) begin
                        mem_in[i]               <= 0;
                    end
                end
                s_BLOCK_ME: begin
                    ME_byte_in_r   <= 0;
                    if(Rx_Data_r == 1'b1 ) begin
                        mem_in[din_count_r]     <= message_in;
                        if(din_count_r < 5'd15 ) 
                            din_count_r         <= din_count_r + 1; 
                    end
                end
                s_SEND_ME: begin
                    if(ME_block_flag_w) begin
                            ME_byte_in_r        <= mem_in[Rx_ME_count_r]; //= Rx_core_count
                            ME_dv_in_r          <= 1'b1;
                            if (Rx_ME_count_r < 5'd15) //Load mem_in[14] before increasing to 15
                                Rx_ME_count_r   <= Rx_ME_count_r + 1 ;                   
                    end else begin
                            ME_dv_in_r          <= 1'b0;
                    end    
                end
                s_SEND_MC:begin
                    
                    dout_count_r      <=  0 ;
                    UART_ts_count_r   <=  0 ;
                end
                s_EXE_BIT: begin
                    if(MC_dv_out_w) begin
                        mem_out[255 - dout_count_r*32 -: 32]    <= MC_byte_out_w;
                        if(dout_count_r < 5'd7) 
                            dout_count_r                        <= dout_count_r + 1;  
                    end
                end
                s_SEND: begin
                        hash_out            <= mem_out[255 - UART_ts_count_r*8 -:8];
                        if (UART_ts_count_r < 6'd31)
                            UART_ts_count_r <= UART_ts_count_r + 1;
                end
                s_CLEANUP: begin
                        din_count_r     <= 5'd0;
                        dout_count_r    <= 5'd0;
                        Rx_ME_count_r   <= 5'd0;
                        UART_ts_count_r <= 6'd0;
                        ME_dv_in_r      <= 1'b0;
                        for (i = 0; i < 16; i = i+1) begin
                            mem_in[i] <= {DATA_WIDTH{1'b0}};
                        end
                end
                default: begin

                end
        endcase
    end
end
endmodule


