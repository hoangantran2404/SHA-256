`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 10:47:54 AM
// Design Name: 
// Module Name: rME_t
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
module tb_rME;

    // ==========================================
    // 1. Parameters & Signals
    // ==========================================
    parameter DATA_WIDTH = 32;
    
    reg                  clk;
    reg                  rst_n;
    reg [2:0]            FSM_state_r;
    reg [6:0]            core_count_r;
    reg [DATA_WIDTH-1:0] data_in;
    
    wire [DATA_WIDTH-1:0] data_out;
    wire                  ME_dv_out;

    reg [DATA_WIDTH-1:0]  expected_W [0:63]; 
    
    reg [DATA_WIDTH-1:0]  input_msg [0:15];  
    
    integer i, errors;

    // ==========================================
    // 2. DUT Instantiation
    // ==========================================
    rME #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk            (clk),
        .rst_n          (rst_n),
        .core_count_in  (core_count_r),
        .data_in        (data_in),
        .FSM_core_in    (FSM_state_r),

        .data_out       (data_out),
        .ME_dv_out      (ME_dv_out)
    );

    // ==========================================
    // 3. Clock Generation
    // ==========================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end

    // ==========================================
    // 4. Main Test Sequence
    // ==========================================
    initial begin
        $display("========================================");
        $display("   TESTBENCH STARTING: SHA-256 ME       ");
        $display("========================================");

        $readmemh("/home/hoangan2404/Project_0/code_C/Project_SHA256/expected_W.txt", expected_W);
        
        input_msg[0]  = 32'h61626380;
        input_msg[1]  = 32'h00000000;
        input_msg[2]  = 32'h00000000;
        input_msg[3]  = 32'h00000000;
        input_msg[4]  = 32'h00000000;
        input_msg[5]  = 32'h00000000;
        input_msg[6]  = 32'h00000000;
        input_msg[7]  = 32'h00000000;
        input_msg[8]  = 32'h00000000;
        input_msg[9]  = 32'h00000000;
        input_msg[10] = 32'h00000000;
        input_msg[11] = 32'h00000000;
        input_msg[12] = 32'h00000000;
        input_msg[13] = 32'h00000000;
        input_msg[14] = 32'h00000000;
        input_msg[15] = 32'h00000018; 

        // --- C. Reset ---
        initialize_inputs();
        @(posedge clk);
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        
        // --- D. Load Data Phase (s_IDLE) ---
        $display("[Time %0t] Loading Input Data...", $time);
        
        FSM_state_r = 3'b010;
        for (i = 0; i < 16; i = i + 1) begin
            core_count_r = i[6:0]; 
            data_in      = input_msg[i];
            @(posedge clk); 
        end
        
   
        FSM_state_r  = 3'b011;
        core_count_r = 7'd16; 
        
        // --- E. Verification Phase ---
        $display("[Time %0t] Checking Outputs against C Reference...", $time);

        errors = 0;

        for (i = 0; i < 64; i = i + 1) begin
            core_count_r = i[6:0];
          
            @(posedge clk);
            #1; 
        
            if (data_out !== expected_W[i]) begin
                $display("ERROR at Round %02d: Expected %h | Got %h", 
                         i, expected_W[i], data_out);
                errors = errors + 1;
            end else begin
            end
        end

        // --- F. Final Report ---
        $display("----------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS: Verilog matches C code perfectly!");
        end else begin
            $display("FAILURE: Found %0d mismatches.", errors);
        end
        $display("----------------------------------------");
        
        $stop;
    end


    task initialize_inputs;
        begin
            rst_n        = 1;
            FSM_state_r  = 0;
            core_count_r = 0;
            data_in      = 0;
            errors       = 0;
        end
    endtask

endmodule
