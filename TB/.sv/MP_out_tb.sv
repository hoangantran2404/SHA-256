//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2025 01:54:22 PM
// Design Name: 
// Module Name: MP_in
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
interface MP_out_interface #(parameter DATA_WIDTH =32) (input bit clk);
    logic                   rst_n;
    logic [DATA_WIDTH-1:0]  core_byte_in;
    logic                   TX_active_in, TX_done_in, RX_DV_in;
    logic [7:0]             MP_data_out;
    logic                   MP_dv_out;
    
    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
        output core_byte_in, TX_active_in, TX_done_in, RX_DV_in;
        input  MP_data_out, MP_dv_out;
    endclocking
endinterface

module MP_out_tb;
    timeunit      1ns;
    timeprecision 1ps;
    parameter DATA_WIDTH =32;

    bit clk;
    logic [255:0] expected_result;
    logic [255:0] actual_result;
    MP_out_interface #(.DATA_WIDTH(DATA_WIDTH)) vif (clk);

    MP_out #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk            (clk             ),
        .rst_n          (vif.rst_n       ),
        .core_byte_in   (vif.core_byte_in),
        .TX_active_in   (vif.TX_active_in),
        .TX_done_in     (vif.TX_done_in  ),
        .RX_DV_in       (vif.RX_DV_in    ),

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

            expected_result= 256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad;   

        initialize_input();
        repeat(2) @(vif.cb);
        vif.cb.rst_n <= 1;
        @(vif.cb);
        $display("[Time %0t] Sending 8 Words to MP_out...", $time);
        SEND_data();
        wait(vif.cb.MP_dv_out);
        $display("[Time %0t] Receiving 32 Bytes from MP_out...", $time);
        RX_data();
        verification();

        $stop;
    end
    task initialize_input();
        begin 
            vif.cb.rst_n        <= 0;
            vif.cb.core_byte_in <= 0;
            vif.cb.TX_active_in <= 0;
            vif.cb.TX_done_in   <= 0;
            vif.cb.RX_DV_in     <= 0;
            actual_result       <= 0;
        end
    endtask
    task SEND_data();
        begin
            for(int i=0; i< 8; i++) begin
                vif.cb.RX_DV_in     <= 1'b1;
                vif.cb.core_byte_in <= expected_result[255-32*i -:32];
                @(vif.cb);
            end
            vif.cb.RX_DV_in <= 1'b0;
            @(vif.cb);
        end
    endtask
    task RX_data();
        begin
            for(int i=0; i<32; i++) begin
                wait(vif.cb.MP_dv_out);
                actual_result       <= {actual_result[247:0], vif.cb.MP_data_out};
                vif.cb.TX_active_in <= 1'b1; 
                repeat(2) @(vif.cb);
                vif.cb.TX_done_in   <= 1'b1; 
                @(vif.cb);
                vif.cb.TX_done_in   <= 1'b0;
                vif.cb.TX_active_in <= 1'b0; 
                
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