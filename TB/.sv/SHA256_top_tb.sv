//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2025 10:53:35 AM
// Design Name: 
// Module Name: SHA256_top_tb
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
interface SHA256_top_interface #(parameter DATA_WIDTH =32) (input bit clk);
    logic clk;
    logic rst_n;
    logic data_in;
    logic data_out;

    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n, data_in;
        input data_out;
    endclocking
endinterface

module SHA256_top_tb;
    timeunit      1ns;
    timeprecision 1ps;
    parameter DATA_WIDTH   = 32;
    parameter CLK_PERIOD   = 10;
    parameter CLKS_PER_BIT = 868;
    parameter BIT_PERIOD   = CLKS_PER_BIT * CLK_PERIOD;

    bit clk;
    int errors;
    logic [7:0]  input_block  [64];
    logic [7:0]  expected_hash[32];
    logic [255:0]received_hash_full; 
    SHA256_top_interface #(.DATA_WIDTH(DATA_WIDTH)) vif(clk);

    SHA256_top dut(
        .clk     (clk        ),
        .rst_n   (vif.rst_n  ),
        .data_in (vif.data_in),

        .data_out(vif.data_out)
    );

    initial begin
        clk = 0;
        forever #5 clk =~clk;
    end

    initial begin
        $display("========================================");
        $display("   TESTBENCH STARTING: SHA-256_top      ");
        $display("========================================");
        for (int k = 0; k < 64; k++) input_block[k] = 8'h00; // Secure Hash Algorithm 256
            input_block[0]  = 8'h53; 
            input_block[1]  = 8'h65; 
            input_block[2]  = 8'h63; 
            input_block[3]  = 8'h75; 
            input_block[4]  = 8'h72; 
            input_block[5]  = 8'h65; 
            input_block[6]  = 8'h20; 

        
            input_block[7]  = 8'h48; 
            input_block[8]  = 8'h61; 
            input_block[9]  = 8'h73; 
            input_block[10] = 8'h68; 
            input_block[11] = 8'h20; 

        
            input_block[12] = 8'h41; 
            input_block[13] = 8'h6C; 
            input_block[14] = 8'h67; 
            input_block[15] = 8'h6F; 
            input_block[16] = 8'h72; 
            input_block[17] = 8'h69; 
            input_block[18] = 8'h74; 
            input_block[19] = 8'h68; 
            input_block[20] = 8'h6D; 
            input_block[21] = 8'h20; 

        
            input_block[22] = 8'h32; 
            input_block[23] = 8'h35; 
            input_block[24] = 8'h36; 

        
            input_block[25] = 8'h80; 
            input_block[63] = 8'hC8; 

            expected_hash[0]  = 8'h5f; expected_hash[1]  = 8'h80; expected_hash[2]  = 8'h6d; expected_hash[3]  = 8'h26;
            expected_hash[4]  = 8'h1a; expected_hash[5]  = 8'h57; expected_hash[6]  = 8'h9f; expected_hash[7]  = 8'h2e;
            expected_hash[8]  = 8'hee; expected_hash[9]  = 8'ha4; expected_hash[10] = 8'h77; expected_hash[11] = 8'h39;
            expected_hash[12] = 8'h63; expected_hash[13] = 8'h94; expected_hash[14] = 8'h69; expected_hash[15] = 8'h9a;
            expected_hash[16] = 8'hc2; expected_hash[17] = 8'hde; expected_hash[18] = 8'haf; expected_hash[19] = 8'h34;
            expected_hash[20] = 8'h2e; expected_hash[21] = 8'hc8; expected_hash[22] = 8'hda; expected_hash[23] = 8'h3b;
            expected_hash[24] = 8'h18; expected_hash[25] = 8'h9d; expected_hash[26] = 8'h84; expected_hash[27] = 8'h27;
            expected_hash[28] = 8'h25; expected_hash[29] = 8'ha4; expected_hash[30] = 8'ha6; expected_hash[31] = 8'h97;
        initialize_input();
        repeat(2) @(vif.cb);
        vif.cb.rst_n <= 1;
        #100;
        fork
            SEND_data();
            #200;
            RX_data();
        join
        #1000;
        verification();
        
        $stop;

    end
    task initialize_input();
        begin
            received_hash_full = 0;
            errors             = 0;
            vif.cb.rst_n       <= 0;
            vif.cb.data_in     <= 1;
        end
    endtask
    task UART_SEND_BYTE();
        input [7:0] i_Data;
        begin
            vif.cb.data_in <= 1'b0; 
            #(BIT_PERIOD);
            for (int i=0; i<8; i=i+1) begin
                vif.cb.data_in <= i_Data[i];
                #(BIT_PERIOD);
            end
            vif.cb.data_in <= 1'b1; 
            #(BIT_PERIOD);
            #(BIT_PERIOD); 
        end
    endtask
    task UART_RX_BYTE();
        output [7:0] o_Data;
        begin
            @(vif.data_out == 1'b0); 
            #(BIT_PERIOD + (BIT_PERIOD / 2)); 
            
            for (int i=0; i<8; i=i+1) begin
                o_Data[i] = vif.data_out;
                #(BIT_PERIOD);
            end
            #(BIT_PERIOD / 2);
        end
    endtask
    task SEND_data();
        begin
            $display(" [TX] STARTING SENDING 64 BYTES...");
            for(int i=0; i<64; i++) begin
                UART_SEND_BYTE(input_block[i]);
            end
            $display(" [TX] FINISHED SENDING.");
        end
    endtask
    task RX_data();
        logic [7:0] received_byte;
        begin
            $display(" [RX] RECEIVER LISTENING...");
            for(int i=0; i<32; i++) begin
                UART_RX_BYTE(received_byte);

               if (received_byte !== expected_hash[i]) begin
                    $display("[RX] Byte %0d: 0x%h (Expected: 0x%h) --> ERROR", i, received_byte, expected_hash[i]);
                    errors = errors + 1;
                end else begin
                    $display("[RX] Byte %0d: 0x%h (OK)", i, received_byte);
                end 

                received_hash_full[(31 - i)*8 +: 8] = received_byte;
            end


        end
    endtask
    task automatic verification();
        begin
            $display("==================================================");
        if (errors == 0) begin
            $display(" RESULT: *** PASSED *** (Hash Match)");
        $display("--------------------------------------------------");
            $display(" FULL HASH: %h", received_hash_full);
        end else 
            $display(" RESULT: *** FAILED *** (Errors: %0d)", errors);
        $display("==================================================");
        end
    endtask
endmodule
