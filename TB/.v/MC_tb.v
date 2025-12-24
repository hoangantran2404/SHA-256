`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2025 03:15:27 PM
// Design Name: 
// Module Name: MC_tb
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
module tb_MC;

    // ==========================================
    //  1. Parameters & Signals
    // ==========================================
    parameter DATA_WIDTH = 32;

    reg                     clk;
    reg                     rst_n;    
    reg [DATA_WIDTH -1: 0]  data_in;      
    reg [2:0]               FSM_state_r;    
    reg [6:0]               core_count_r;  

    wire [DATA_WIDTH-1:0]   data_out;     
    wire                    MC_dv_out;    

    reg  [DATA_WIDTH-1:0]   expected_H [0:7];  
    reg  [DATA_WIDTH-1:0]   W_expanded [0:63]; 
    
    integer i, errors;

    // ==========================================
    // 2. DUT Instantiation
    // ==========================================
    MC #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk             (clk),
        .rst_n           (rst_n),
        .data_in         (data_in),
        .FSM_core_in     (FSM_state_r),   
        .core_count_in   (core_count_r), 

        .data_out        (data_out),
        .MC_dv_out       (MC_dv_out)
    );

    // ==========================================
    //  3. Clock Generation
    // ==========================================
    initial begin 
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ==========================================
    // 4. Main Test Sequence
    // ==========================================
    initial begin
        $display("========================================");
        $display("   TESTBENCH STARTING: SHA-256 MC ONLY  ");
        $display("========================================");

        $readmemh("/home/hoangan2404/Project_0/code_C/Project_SHA256/expected_H.txt", expected_H);

        $readmemh("/home/hoangan2404/Project_0/code_C/Project_SHA256/expected_W.txt", W_expanded);
    
        // --- C. Reset ---
        initialize_inputs();
        @(posedge clk);
        rst_n = 0;       // Nhấn Reset
        @(posedge clk);
        rst_n = 1;            
        

        $display ("[Time %0t] Starting Compression Loop (64 Rounds)...", $time);


        FSM_state_r = 3'b011; 

        for (i = 0; i < 64; i=i+1) begin
            core_count_r = i[6:0];     
            data_in      = W_expanded[i];             
            @(posedge clk); 
        end

    
        $display("[Time %0t] Calculation Done. Transition to Output...", $time);
        

        FSM_state_r   = 3'b100; 
        data_in       = 32'd0; 

       
        $display("[Time %0t] Checking Final Hash against C Reference...", $time);
        
        errors = 0;

       
        for (i = 0; i < 8 ; i = i+1) begin
            core_count_r = i[6:0];
            #1; 
            if (data_out !== expected_H[i]) begin
                $display("ERROR at Hash Word %0d: Expected %h | Got %h", 
                         i, expected_H[i], data_out);
                errors = errors + 1;
            end else begin
            end
        end


        $display("----------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS: MC Module works correctly!");
        end else begin
            $display("FAILURE: Found %0d mismatches in MC module.", errors);
        end
        $display("----------------------------------------");
        
        $stop;
    end


    task initialize_inputs;
        begin
            rst_n        = 1;
            core_count_r = 0;
            data_in      = 0;
            FSM_state_r  = 0;
            errors       = 0;
        end
    endtask

endmodule
