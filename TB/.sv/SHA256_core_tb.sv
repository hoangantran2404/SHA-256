
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2025 10:53:35 AM
// Design Name: 
// Module Name: SHA256_core_tb
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
interface SHA256_core_interface #(parameter DATA_WIDTH =32) (input bit clk);
    logic                  rst_n;
    logic                  MP_dv_in;
    logic [DATA_WIDTH-1:0] data_in, data_out;
    logic                  core_dv_flag;

    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
        output MP_dv_in, data_in;
        input data_out, core_dv_flag;
    endclocking
endinterface

module SHA256_core_tb;
    timeunit      1ns;
    timeprecision 1ps;
    parameter DATA_WIDTH =32;

    bit clk;
    integer errors;
    logic [DATA_WIDTH-1:0] initial_message [16];
    logic [255:0]          expected_H    ;
    logic [255:0]          actual_H      ;

    SHA256_core_interface #(.DATA_WIDTH(DATA_WIDTH)) vif (clk);

    SHA256_core #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut 
    (
        .clk            (clk         ),
        .rst_n          (vif.rst_n   ),
        .MP_dv_in       (vif.MP_dv_in),
        .message_in     (vif.data_in ),
        
        .hash_out       (vif.data_out),
        .core_dv_flag   (vif.core_dv_flag)
    );

    initial begin
        clk = 0;
        forever #5 clk =~clk;
    end

    initial begin
        $display("========================================");
        $display("   TESTBENCH STARTING: SHA-256 CORE     ");
        $display("========================================");

            initial_message[0]  = 32'h61626380; 
            initial_message[1]  = 32'h00000000;
            initial_message[2]  = 32'h00000000;
            initial_message[3]  = 32'h00000000;
            initial_message[4]  = 32'h00000000;
            initial_message[5]  = 32'h00000000;
            initial_message[6]  = 32'h00000000;
            initial_message[7]  = 32'h00000000;
            initial_message[8]  = 32'h00000000;
            initial_message[9]  = 32'h00000000;
            initial_message[10] = 32'h00000000;
            initial_message[11] = 32'h00000000;
            initial_message[12] = 32'h00000000;
            initial_message[13] = 32'h00000000;
            initial_message[14] = 32'h00000000;
            initial_message[15] = 32'h00000018;
            
            expected_H = 256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad;

        errors = 0;
        initialize_input();
        repeat(2) @(vif.cb);
        vif.cb.rst_n        <= 1;
        $display("[Time %0t] Loading Input Data...", $time);
        vif.cb.MP_dv_in     <= 1;
        SEND_data();
        wait(vif.cb.core_dv_flag);
        RX_data();
        repeat(5) @(vif.cb);
        verification();
        $stop;
    end
    task initialize_input();
        begin
            vif.cb.rst_n    <= 0;
            vif.cb.data_in  <= 0;
        end
    endtask
    task SEND_data();
        begin
            for(int i=0; i< 16; i++)begin
                vif.cb.data_in <= initial_message[i];
                @(vif.cb);
            end
        end
    endtask
    task RX_data ();
        begin
            for(int i=0; i<8; i++) begin
                actual_H = {actual_H[223:0],vif.cb.data_out};
                if(i<7)
                    @(vif.cb);
            end
        end
    endtask
    task automatic verification();
        begin
            $display("----------------------------------------");
            $display("RESULT CHECK:");
            $display("   Expected: %h", expected_H);
            $display("   Actual  : %h", actual_H);
            
            assert (actual_H == expected_H) 
                $display("   STATUS  : [PASSED] Success!");
            else 
                $error("   STATUS  : [FAILED] Output mismatch!");
                
            $display("========================================");
        end
    endtask
endmodule
