`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 11/17/2025 02:51:29 PM
// Design Name: 
// Module Name: Message_Packer
// Project Name: SHA 256 (hash algorithm)
// Target Devices: 
// Tool Versions: 
// Description: Message_Packer connects UART receiver and SHA 256's core
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

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


