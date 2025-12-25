//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2025 10:53:35 AM
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
interface MC_interface #(parameter DATA_WIDTH =32) (input bit clk);
    logic rst_n;
    logic [DATA_WIDTH-1:0] data_in;
    logic [2:0]            FSM_core_in;
    logic [6:0]            core_count_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic                  MC_dv_out;

    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
        output FSM_core_in, core_count_in,data_in;
        input data_out,MC_dv_out;
    endclocking
endinterface

module MC_tb;
    timeunit      1ns;
    timeprecision 1ps;
    parameter DATA_WIDTH =32;
    
    bit clk;
    integer errors;
    logic [DATA_WIDTH-1:0] expected_H [8];
    logic [DATA_WIDTH-1:0] W_expanded [64];

    MC_interface #(.DATA_WIDTH(DATA_WIDTH)) vif (clk);

    MC #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut 
    (
        .clk            (clk               ),
        .rst_n          (vif.rst_n         ),
        .data_in        (vif.data_in       ),
        .FSM_core_in    (vif.FSM_core_in   ),
        .core_count_in  (vif.core_count_in ),

        .data_out       (vif.data_out      ),
        .MC_dv_out      (vif.MC_dv_out     )
    );

    initial begin
        clk = 0;
        forever #5 clk =~clk;
    end

    initial begin 
        $display("========================================");
        $display("   TESTBENCH STARTING: SHA-256 MC       ");
        $display("========================================");


        $readmemh("/home/hoangan2404/Project_0/code_C/Project_SHA256/expected_H.txt", expected_H);

        $readmemh("/home/hoangan2404/Project_0/code_C/Project_SHA256/expected_W.txt", W_expanded);

        errors = 0;
        initialize_input();
        repeat(2)@(vif.cb);
        vif.cb.rst_n        <= 1;
        repeat(2)@(vif.cb);
        $display ("[Time %0t] Starting Compression Loop (64 Rounds)...", $time);
        vif.cb.FSM_core_in  <= 3'b011;
        SEND_data();
        vif.cb.FSM_core_in  <= 3'b100;
        @(vif.cb);
        $display("[Time %0t] Checking Final Hash against C Reference...", $time);
        RX_data();
        verification();
        $stop;

    end
    task initialize_input();
        begin
            vif.cb.rst_n        <= 0;
            vif.cb.data_in      <= 0;
            vif.cb.FSM_core_in  <= 0;
            vif.cb.core_count_in<= 0;
        end
    endtask
    task SEND_data();
        begin
            for(int i=0; i<64; i++) begin
                vif.cb.core_count_in <=  i[6:0];
                vif.cb.data_in       <=  W_expanded[i];
                @(vif.cb);
            end
        end
    endtask
    task RX_data();
        begin
            for(int i=0;i<8;i++) begin
                vif.cb.core_count_in <= i[6:0];
                @(vif.cb);
                if(vif.cb.data_out !== expected_H[i]) begin
                    $display("ERROR at Hash Word %0d: Expected %h | Got %h", i, expected_H[i], vif.cb.data_out);
                    errors = errors + 1;
                end else begin
                end
            end
        end
    endtask
    task automatic verification();
        begin
            $display("----------------------------------------");
            if (errors == 0) begin
                $display("SUCCESS");
            end else begin
                $display("FAILURE: Found %0d mismatches in MC module.", errors);
            end
            $display("----------------------------------------");
        end
    endtask
endmodule
