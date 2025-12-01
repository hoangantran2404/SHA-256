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
)(
    input wire                      clk, rst_n,
    input wire                      MP_dv_in,
    input wire [DATA_WIDTH -1 :0]   message_in,

    output wire [7 :0]               hash_out,
    output wire                     core_dv_flag
);
//==================================================//
//                  Wire                            //
//==================================================//
    wire                            load_flag_w;
    wire                            load_ME_flag_w;
    wire                            EXE_flag_w;
    wire                            RX_flag_w;
    wire                            send_flag_w;
    wire [DATA_WIDTH -1:0]          ME_byte_out_w;
    wire [DATA_WIDTH -1:0]          MC_byte_out_w;

//==================================================//
//              State Encoding                      //
//==================================================//
    reg [2:0] current_state_r       = s_IDLE ;
    reg [2:0] next_state_r;

    parameter s_IDLE                =  3'b000;
    parameter s_LOAD                =  3'b001;
    parameter s_LOAD_ME             =  3'b010; 
    parameter s_EXE_BIT             =  3'b011; 
    parameter s_RX_MC               =  3'b100; 
    parameter s_SEND_TX             =  3'b101;
    parameter s_CLEANUP             =  3'b110;
//==================================================//
//                  Registers                       //
//==================================================//
    reg [DATA_WIDTH -1 :0]          ME_byte_in_r ;
    reg [DATA_WIDTH -1 :0]          address_in_r[0:15] ;

    reg [255 :0]                    address_out_r ;
    reg [6:0]                       core_count_r ; 

//==================================================//
//                  Combinational Logic             //
//==================================================//
    assign core_dv_flag    = (current_state_r == s_SEND_TX );
    assign load_flag_w     = (current_state_r == s_LOAD    && core_count_r == 7'd16);
    assign load_ME_flag_w  = (current_state_r == s_LOAD_ME && core_count_r == 7'd16);// It is 7'd16 because when core_count_r =7'd15, 
                                                                                     //W[15] is on the wire and it does not have enough time to load to rME so we will wait one dead cylce.
    assign EXE_flag_w      = (current_state_r == s_EXE_BIT && core_count_r == 7'd63);
    assign RX_flag_w       = (current_state_r == s_RX_MC   && core_count_r == 7'd8);
    assign send_flag_w     = (current_state_r == s_SEND_TX && core_count_r == 7'd31);

    assign hash_out        = (current_state_r == s_SEND_TX)? address_out_r[255 - core_count_r*8 -:8]: 8'd0;
//==================================================//
//                  Instantiate module              //
//==================================================//
    rME # (
        .DATA_WIDTH(DATA_WIDTH)
    ) Message_Expansion(
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        // .start_in           ( ME_dv_flag_w           ),
        .core_count_in      ( core_count_r          ),
        .FSM_core_in        ( current_state_r       ),
        .data_in            ( ME_byte_in_r          ),

        .ME_dv_out          ( ME_dv_out_w           ),
        .data_out           ( ME_byte_out_w         )
    );
    MC #(
        .DATA_WIDTH(DATA_WIDTH)
    ) Message_Compression(
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        // .start_in           ( MC_dv_flag_w          ),
        .data_in            ( ME_byte_out_w         ),
        .FSM_core_in        ( current_state_r       ),
        .core_count_in      ( core_count_r          ),

        .data_out           ( MC_byte_out_w         ),
        .MC_dv_out          ( MC_dv_out_w           )
    );

//==================================================//
//                  Next State LogicS               //
//==================================================//
always @(MP_dv_in or load_flag_w or load_ME_flag_w or EXE_flag_w or RX_flag_w or send_flag_w or current_state_r) begin
    case(current_state_r)
        s_IDLE: 
            if (MP_dv_in == 1'b1)
                next_state_r = s_LOAD;
            else 
                next_state_r =s_IDLE;
        s_LOAD:
            if (load_flag_w)
                next_state_r = s_LOAD_ME;
            else
                next_state_r = s_LOAD;
            
        s_LOAD_ME: 
            if (load_ME_flag_w)
                next_state_r = s_EXE_BIT;
            else 
                next_state_r = s_LOAD_ME;
      
        s_EXE_BIT:
            if(EXE_flag_w)
                next_state_r = s_RX_MC;
            else
                next_state_r = s_EXE_BIT;
           
        s_RX_MC:
            if(RX_flag_w)
                next_state_r = s_SEND_TX;
            else
                next_state_r = s_RX_MC;
           
        s_SEND_TX:
            if(send_flag_w)
                next_state_r = s_CLEANUP;
            else 
                next_state_r = s_SEND_TX;
           
        s_CLEANUP:
                next_state_r = s_IDLE;
        default:
                next_state_r = s_IDLE;
    endcase
end

//==================================================//
//              State Register (FSM)                //
//==================================================//
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        current_state_r <= s_IDLE;
    else
        current_state_r <= next_state_r;
end

//==================================================//
//                     Datapath                     //
//==================================================//
integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_count_r                    <= 0;
        address_out_r                   <= 0;
        ME_byte_in_r                    <= 0;
        for(i=0 ; i<16 ;i= i + 1) 
            address_in_r[i] <= 0;
    end else begin
        if(current_state_r != next_state_r) begin
            core_count_r                <= 0;
        end else begin
        case(current_state_r)
            s_IDLE: begin
                if(MP_dv_in) 
                    address_in_r[0]           <= message_in;
                    core_count_r              <= 1;
            end
            s_LOAD: begin
                if(MP_dv_in) begin
                    address_in_r[core_count_r] <= message_in;
                    core_count_r               <= core_count_r + 1;
                end
            end
            s_LOAD_ME: begin
                ME_byte_in_r            <= address_in_r[core_count_r];
                core_count_r            <= core_count_r + 1;
            end
            s_EXE_BIT: begin
                core_count_r            <= core_count_r + 1;
            end
            s_RX_MC: begin
                if(MC_dv_out_w) begin
                    address_out_r[255 - core_count_r*32 -:32] <= MC_byte_out_w ;
                    core_count_r                              <= core_count_r + 1;
                end
            end
            s_SEND_TX: begin
                core_count_r            <= core_count_r + 1;
            end
            s_CLEANUP: begin
            end
        endcase
        end
    end
end

endmodule
