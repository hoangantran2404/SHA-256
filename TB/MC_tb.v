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


`timescale 1ns / 1ps

module tb_MC;

    // ==========================================
    // 
    // ==========================================
    parameter DATA_WIDTH = 32;

    reg                     clk;
    reg                     rst_n;
    reg                     start_in;     // TB giả lập tín hiệu Start
    reg [DATA_WIDTH -1: 0]  data_in;      // TB giả lập dòng dữ liệu W[t] từ ME
    reg [1:0]               FSM_state;    // TB giả lập trạng thái FSM từ ME
    reg [5:0]               round_count;  // TB giả lập bộ đếm vòng từ ME

    wire [DATA_WIDTH-1:0]   data_out;     // Kết quả Hash (H0..H7) từ MC
    wire                    valid_out;    // Cờ báo hiệu dữ liệu hợp lệ

    // Bộ nhớ để chứa dữ liệu mẫu (Golden Reference)
    reg  [DATA_WIDTH-1:0]   expected_H [0:7];  // Kết quả Hash mong đợi (từ C)
    reg  [DATA_WIDTH-1:0]   W_expanded [0:63]; // Dữ liệu W đã mở rộng (từ C)
    
    integer i, errors;

    // ==========================================
    // Module MC (DUT)
    // ==========================================
    MC #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk             (clk),
        .rst_n           (rst_n),
        .start_in        (start_in),
        .data_in         (data_in),
        .FSM_state_in    (FSM_state),   // TB tự điều khiển trạng thái này
        .round_in        (round_count), // TB tự điều khiển biến đếm này

        .data_out        (data_out),
        .valid_out       (valid_out)
    );

    // ==========================================
    //  Clock (100MHz)
    // ==========================================
    initial begin 
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ==========================================
    // 4. Kịch bản Kiểm tra (Main Sequence)
    // ==========================================
    initial begin
        $display("========================================");
        $display("   TESTBENCH STARTING: SHA-256 MC ONLY  ");
        $display("========================================");

        $readmemh("/home/hoangan2404/Project_0/code_C/Project_SHA256/expected_H.txt", expected_H);

        $readmemh("/home/hoangan2404/Project_0/code_C/Project_SHA256/expected_W.txt", W_expanded);
    
        // 2. Khởi tạo & Reset hệ thống
        initialize_inputs();
        @(posedge clk);
        rst_n = 0;       // Nhấn Reset
        @(posedge clk);
        rst_n = 1;       
        
        $display("[Time %0t] MC Initialization (Loading H0..H7)...", $time);
        
        FSM_state = 2'b00; 
        start_in  = 1;     
        @(posedge clk);    
        
        start_in  = 0;     
        

        $display ("[Time %0t] Starting Compression Loop (64 Rounds)...", $time);


        FSM_state = 2'b10; 

        // Cấp liên tục 64 từ W[t] vào MC
        for (i = 0; i < 64; i=i+1) begin
            round_count = i[5:0];     // Giả lập số vòng hiện tại
            data_in     = W_expanded[i]; // Cấp W[i] tương ứng vào MC
            
            @(posedge clk); // Chờ 1 chu kỳ để MC xử lý xong vòng này
        end

        // --- PHA 3: XUẤT KẾT QUẢ (Giả lập trạng thái CLEANUP của ME) ---
        $display("[Time %0t] Calculation Done. Transition to Output...", $time);
        
        // Chuyển sang trạng thái 2'b11 để kích hoạt cờ SEND_flag trong MC
        FSM_state   = 2'b11; 
        round_count = 6'd63; 
        data_in     = 32'd0; // Ngắt dữ liệu vào

        // --- PHA 4: SO SÁNH KẾT QUẢ ---
        $display("[Time %0t] Checking Final Hash against C Reference...", $time);
        
        errors = 0;

        // MC sẽ xuất ra 8 từ (H0..H7) liên tiếp trong 8 chu kỳ
        for (i = 0; i < 8 ; i = i+1) begin
            
            // Chờ 1 chu kỳ để dữ liệu ra ổn định
            @(posedge clk);
            #1; // Delay nhỏ để lấy mẫu an toàn

            // So sánh
            if (data_out !== expected_H[i]) begin
                $display("ERROR at Hash Word %0d: Expected %h | Got %h", 
                         i, expected_H[i], data_out);
                errors = errors + 1;
            end else begin
                 // In ra để theo dõi nếu muốn
                 // $display("OK    Hash Word %0d: %h", i, data_out);
            end
        end

        // --- Báo cáo kết quả ---
        $display("----------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS: MC Module works correctly!");
        end else begin
            $display("FAILURE: Found %0d mismatches in MC module.", errors);
        end
        $display("----------------------------------------");
        
        $stop;
    end

    // Task để reset các biến testbench về 0
    task initialize_inputs;
        begin
            rst_n       = 1;
            start_in    = 0;
            round_count = 0;
            data_in     = 0;
            FSM_state   = 0;
            errors      = 0;
        end
    endtask

endmodule
