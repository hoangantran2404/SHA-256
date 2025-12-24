
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2025 10:53:35 AM
// Design Name: 
// Module Name: ME_tb
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

interface ME_interface #(parameter DATA_WIDTH =32) (input bit clk);
    logic                   rst_n;
    logic [2:0]             FSM_core_in;
    logic [6:0]             core_count_in;
    logic [DATA_WIDTH -1:0] data_in;
    logic [DATA_WIDTH -1:0] data_out;
    logic                   ME_dv_out;

    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
        output FSM_core_in, core_count_in, data_in;
        input data_out, ME_dv_out;
    endclocking
endinterface

module ME_tb;
    timeunit      1ns;
    timeprecision 1ps;
    parameter DATA_WIDTH = 32;
    integer errors;

    bit clk;
    logic [DATA_WIDTH-1:0] expected_W [64];
    logic [DATA_WIDTH-1:0] ME_data_in [16];

    ME_interface#(.DATA_WIDTH(DATA_WIDTH)) vif (clk);

    ME #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut 
    (
        .clk            (clk),
        .rst_n          (vif.rst_n),
        .core_count_in  (vif.core_count_in),
        .data_in        (vif.data_in),
        .FSM_core_in    (vif.FSM_core_in),

        .data_out       (vif.data_out),
        .ME_dv_out      (vif.ME_dv_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("========================================");
        $display("   TESTBENCH STARTING: SHA-256 ME       ");
        $display("========================================");

        $readmemh("/home/hoangan2404/Project_0/code_C/Project_SHA256/expected_W.txt", expected_W);

        ME_data_in[0]  = 32'h61626380;
        ME_data_in[1]  = 32'h00000000;
        ME_data_in[2]  = 32'h00000000;
        ME_data_in[3]  = 32'h00000000;
        ME_data_in[4]  = 32'h00000000;
        ME_data_in[5]  = 32'h00000000;
        ME_data_in[6]  = 32'h00000000;
        ME_data_in[7]  = 32'h00000000;
        ME_data_in[8]  = 32'h00000000;
        ME_data_in[9]  = 32'h00000000;
        ME_data_in[10] = 32'h00000000;
        ME_data_in[11] = 32'h00000000;
        ME_data_in[12] = 32'h00000000;
        ME_data_in[13] = 32'h00000000;
        ME_data_in[14] = 32'h00000000;
        ME_data_in[15] = 32'h00000018; 

        errors = 0;
        initialize_input();
        repeat(2) @(vif.cb);
        vif.cb.rst_n <= 1;

        $display("[Time %0t] Loading Input Data...", $time);

        vif.cb.FSM_core_in      <= 3'b010;

        @(vif.cb);
        SEND_data();

        vif.cb.FSM_core_in      <= 3'b011;
        @(vif.cb);
        $display("[Time %0t] Checking Outputs against C Reference...", $time);
        RX_data();

        verification();
        $stop;

    end
    task SEND_data();
        begin
            for(int i=0; i<16; i++) begin
                vif.cb.core_count_in <= i[6:0];
                vif.cb.data_in       <= ME_data_in[i];
                @(vif.cb);    
            end
        end
    endtask
    task RX_data();
        begin
            for(int i=0; i<64; i++) begin
                vif.cb.core_count_in <= i[6:0];

                @(vif.cb);

                if(vif.cb.data_out !== expected_W[i])begin
                    $display("ERROR at Round %02d: Expected %h | Got %h", i, expected_W[i], vif.cb.data_out);
                    errors = errors + 1;
                end else begin
                end
            end
        end
    endtask
    task verification();
        begin
            $display("----------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS");
        end else begin
            $display("FAILURE");
        end
        $display("----------------------------------------");
        end
    endtask
    task initialize_input();
        begin
            vif.cb.rst_n         <= 0;
            vif.cb.core_count_in <= 0;
            vif.cb.data_in       <= 0;
            vif.cb.FSM_core_in   <= 0;
        end
    endtask
endmodule
