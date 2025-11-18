`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 02:51:29 PM
// Design Name: 
// Module Name: Message_Packer
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


// module Message_Packer #(
//     parameter DATA_WIDTH =512
// )
// (
//     input wire          clk, rst_n,
//     input wire          uart_dv,
//     input wire [7:0]    uart_byte,

//     output wire [DATA_WIDTH-1:0] data_out,
//     output reg               data_valid     
// );
//     wire LOAD_flag_w, EXE_flag_w;
//     wire SEND_flag_w, IDLE_flag_w;
//     wire DONE_flag_w; // of EXEs
//     reg  [DATA_WIDTH-1:0]dout_r;

//     reg [1:0]  current_state_r, next_state_r;
//     reg [5:0]  load_count_r;
//     reg [5:0]  send_count_r;
//     reg [7:0]  mem  [0:63];
//     reg [63:0] total_bit_r;


//     localparam IDLE    =2'b00;
//     localparam LOAD    =2'b01;
//     localparam EXE     =2'b10; // padding
//     localparam SEND    =2'b11;

//     assign LOAD_flag_w = uart_dv;
//     assign EXE_flag_w  = (load_count_r == 5'd63)? 1'b1   : 1'b0;
//     assign SEND_flag_w = (DONE_flag_w)          ? 1'b1   : 1'b0;
//     assign data_out    = (current_state_r == SEND)? dout_r : 0; 


// // Controller

//     always @(LOAD_flag_w or EXE_flag_w or SEND_flag_w ) begin
//         case(current_state_r) 
//             IDLE: begin
//                 if(LOAD_flag_w)
//                     next_state_r = LOAD;
//                 else 
//                     next_state_r = IDLE;
//             end
//             LOAD: begin
//                 if (EXE_flag_w) 
//                     next_state_r = EXE;
//                 else 
//                     next_state_r = LOAD;
//             end
//             EXE: begin
//                 if(SEND_flag_w) 
//                     next_state_r = SEND;
//                 else 
//                     next_state_r = EXE;
//             end
//             SEND: begin
//                     next_state_r = IDLE;
//             end
//             default: next_state_r = IDLE;
//         endcase
//     end

//     always @(posedge clk or negedge rst_n) begin
//         if(!rst_n) begin
//             current_state_r <= IDLE;
//         end else begin
//             current_state_r <= next_state_r;
//         end
//     end
// // Datapath

// integer i;
// integer pad_bytes;

//     always @(posedge clk or negedge rst_n) begin
//         if(!rst_n) begin
//                 load_count_r <=0; 
//                 total_bit_r    <=0;
//         end else begin
//             if(current_state_r == LOAD && uart_dv) begin
//                 load_count_r <= load_count_r + 6'd1;
//                 total_bit_r    <= total_bit_r    + 64'd8;
//             end else begin
//                 load_count_r <= load_count_r; 
//                 total_bit_r    <= total_bit_r   ;
//             end

//         end
//     end
//     always @(posedge clk or negedge rst_n) begin
//         if(!rst_n) begin
//                 load_count_r <=0;
//                 total_bit_r    <=0;
//                 for(i=0; i<64 ; i = i+1) begin
//                     mem[i] <= 8'd0;
//                 end
//         end else begin
//             if (current_state_r == IDLE) begin
//                 load_count_r <=0;
//                 total_bit_r    <=0;
//                 for(i=0; i<64 ; i = i+1) begin
//                     mem[i] <= 8'd0;
//                 end
//             end else if (current_state_r == LOAD) begin
//                     mem[load_count_r] <= uart_byte;
            
//             end else if(current_state_r == EXE) begin

//                 for(i = 0; i < load_count_r; i=i+1) begin   
//                     dout_r[(511 - i*8) -: 8] <= mem[i];
//                 end

//                     dout_r[(511 - load_count_r*8) -: 8] <= 8'h80;

//                     pad_bytes = (448 - (total_bit_r + 8)) / 8;
//                 for(i = 0; i < pad_bytes; i=i+1) begin
//                     dout_r[(511 - (load_count_r+1+i)*8) -: 8] <= 8'h00;
//                 end

//                 for(i = 0; i < 8; i=i+1)begin
//                     dout_r[(63 - i*8) -: 8] <= total_bit_r[(7-i)*8 +: 8];
//                 end
//             end else if(current_state_r == SEND) begin
//                     //Paste dout_r to data_out
//             end else begin
//                 load_count_r <=0;
//                 total_bit_r    <=0;
//                 for(i=0; i<64 ; i = i+1) begin
//                     mem[i] <= 8'd0;
//                 end
//             end
//         end
//     end
// endmodule



// =============================
// Message_Packer.v
// Collect bytes from UART, pad to 512-bit for SHA-256
// Synthesis-friendly version
// =============================
module Message_Packer #(
    parameter DATA_WIDTH = 512
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              uart_dv,       // 1-cycle pulse when uart_byte is valid
    input  wire [7:0]        uart_byte,     // byte from UART
    input  wire              uart_done,     // 1-cycle pulse when UART finishes sending message

    output reg [DATA_WIDTH-1:0] data_out,
    output reg               data_valid     // pulse when 512-bit block is ready
);

    // --------------------------------------
    // State machine
    // --------------------------------------
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam EXE  = 2'b10; // generate padded block
    localparam SEND = 2'b11;

    reg [1:0] current_state_r, next_state_r;

    // --------------------------------------
    // Registers / memory
    // --------------------------------------
    reg [7:0] mem [0:63];       // store bytes from UART
    reg [5:0] load_count_r;     // how many bytes loaded
    reg [63:0] total_bit_r;     // total bits received
    reg [DATA_WIDTH-1:0] dout_r; // output block
    integer i;

    // --------------------------------------
    // State machine: combinational
    // --------------------------------------
    always @(*) begin
        case(current_state_r)
            IDLE: next_state_r = (uart_dv) ? LOAD : IDLE;
            LOAD: next_state_r = (uart_done) ? EXE : LOAD;
            EXE:  next_state_r = SEND;
            SEND: next_state_r = IDLE;
            default: next_state_r = IDLE;
        endcase
    end

    // --------------------------------------
    // State register
    // --------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state_r <= IDLE;
        else
            current_state_r <= next_state_r;
    end

    // --------------------------------------
    // Load bytes from UART
    // --------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_count_r <= 0;
            total_bit_r  <= 0;
            for (i=0; i<64; i=i+1) mem[i] <= 8'd0;
        end else begin
            if (current_state_r == LOAD && uart_dv) begin
                mem[load_count_r] <= uart_byte;
                load_count_r <= load_count_r + 1;
                total_bit_r <= total_bit_r + 8;
            end
        end
    end

    // --------------------------------------
    // Generate padded 512-bit block (synthesis-friendly)
    // --------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dout_r <= 512'd0;
        end else if (current_state_r == EXE) begin
            // 1️⃣ Copy message bytes
            for (i=0; i<64; i=i+1) begin
                if (i < load_count_r)
                    dout_r[511 - i*8 -: 8] <= mem[i];
                else
                    dout_r[511 - i*8 -: 8] <= 8'd0; // clear rest
            end

            // 2️⃣ Add 0x80 byte immediately after message
            dout_r[511 - load_count_r*8 -: 8] <= 8'h80;

            // 3️⃣ Add zero padding up to byte 56 (448 bits)
            // Max padding = 55 bytes
            for (i=0; i<55; i=i+1) begin
                if (i >= (64 - load_count_r - 1)) begin
                    // already covered message+0x80, skip
                end else begin
                    dout_r[511 - (load_count_r + 1 + i)*8 -: 8] <= 8'h00;
                end
            end

            // 4️⃣ Append 64-bit message length (big-endian)
            for (i=0; i<8; i=i+1) begin
                dout_r[63 - i*8 -: 8] <= total_bit_r[(7-i)*8 +: 8];
            end
        end
    end

    // --------------------------------------
    // Output logic
    // --------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 512'd0;
            data_valid <= 1'b0;
        end else if (current_state_r == SEND) begin
            data_out <= dout_r;
            data_valid <= 1'b1;
        end else begin
            data_valid <= 1'b0;
        end
    end

    // --------------------------------------
    // Reset counters when IDLE
    // --------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_count_r <= 0;
            total_bit_r  <= 0;
        end else if (current_state_r == IDLE) begin
            load_count_r <= 0;
            total_bit_r  <= 0;
        end
    end

endmodule


