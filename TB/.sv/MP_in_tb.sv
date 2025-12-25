//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2025 05:25:34 PM
// Design Name: 
// Module Name: MP_in_tb
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
interface MP_in_interface #(parameter DATA_WIDTH =32) (input bit clk);
    logic                   rst_n;
    logic [7:0]             uart_byte_in;
    logic                   RX_dv_in;
    logic [DATA_WIDTH-1:0]  MP_data_out;
    logic                   MP_dv_out;
    
    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
        output uart_byte_in, RX_dv_in;
        input MP_data_out, MP_dv_out;
    endclocking
endinterface

module MP_in_tb;
    timeunit      1ns;
    timeprecision 1ps;
    parameter DATA_WIDTH =32;

    bit clk;
    logic [511:0] expected_result;
    logic [511:0] actual_result;
    MP_in_interface #(.DATA_WIDTH(DATA_WIDTH)) vif (clk);

    MP_in #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk            (clk             ),
        .rst_n          (vif.rst_n       ),
        .uart_byte_in   (vif.uart_byte_in),
        .RX_DV_in       (vif.RX_dv_in    ),

        .MP_data_out    (vif.MP_data_out ),
        .MP_dv_out      (vif.MP_dv_out   )
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("========================================");
        $display("   TESTBENCH STARTING: SHA-256 MP_in    ");
        $display("========================================");

            expected_result= 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;   

        initialize_input();
        repeat(2) @(vif.cb);
        vif.cb.rst_n <= 1;
        @(vif.cb);
        SEND_data();
        wait(vif.cb.MP_dv_out);
        RX_data();
        verification();

        $stop;
    end
    task initialize_input();
        begin 
            vif.cb.rst_n        <= 0;
            vif.cb.uart_byte_in <= 0;
            vif.cb.RX_dv_in     <= 0;
            actual_result       <= 0;
        end
    endtask
    task SEND_data();
        begin
            for(int i=0; i< 64; i++) begin
                vif.cb.RX_dv_in     <= 1'b1;
                vif.cb.uart_byte_in <= expected_result[511-8*i -:8];
                @(vif.cb);
            end
        end
    endtask
    task RX_data();
        begin
            for(int i=0; i<16; i++) begin
                actual_result <= {actual_result[479:0], vif.cb.MP_data_out};
                    @(vif.cb);
            end
        end
    endtask
    task automatic verification();
        begin
            if(actual_result == expected_result) begin
                $display("Success!!");
                $display("Actual result: %h",actual_result);
            end else begin
                $display("FAIL!!");
                $display("Actual result: %h",actual_result);
            end
        end
    endtask
endmodule
