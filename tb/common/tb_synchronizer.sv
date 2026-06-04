`timescale 1ns/1ps

module tb_synchronizer;

    logic clk;
    logic n_rst;
    logic in_sig;
    logic out_sig;
    
    synchronizer dut (
        .clk(clk),
        .n_rst(n_rst),
        .in_sig(in_sig),
        .out_sig(out_sig)
    );

    always #5 clk = ~clk;

    task automatic check_reset(); 
        begin
            n_rst   = 1'b0;
            #1;

            if (out_sig != 1'b0) begin
                $fatal(1, "FAILED reset: expected out_sig=0000 got out_sig=%04b", out_sig); 
            end

            n_rst = 1'b1;
            #1;
        end
    endtask

    task automatic check_input_change(
        input realtime delay,
        input logic new_in_sig,
        input logic old_out_sig
    );
        begin
            n_rst = 1'b1;

            @(posedge clk);
            #delay;
            in_sig = new_in_sig;
            if (out_sig != old_out_sig) begin
                $fatal(1, "out_sig changed immediately: Received: out_sig=%0b Expected: out_sig=%0b", out_sig, old_out_sig);
            end

            @(posedge clk);
            #1;
            if (out_sig != old_out_sig) begin
                $fatal(1, "out_sig changed after one edge only: Received: out_sig=%0b Expected: out_sig=%0b", out_sig, old_out_sig);
            end

            @(posedge clk);
            #1;
            if (out_sig != new_in_sig) begin
                $fatal(1, "out_sig != in_sig: Received: out_sig=%0b Expected: out_sig=%0b", out_sig, new_in_sig);
            end
        end
    endtask

    initial begin
        $dumpfile("build/synchronizer.vcd");
        $dumpvars(0, tb_synchronizer);

        clk      = 1'b0;
        n_rst    = 1'b1;
        in_sig   = 1'b0;
        
        check_reset();

        for (int i = 1; i < 10; i++) begin
            if (i != 5) begin    
                check_input_change(i, 1, 0);
                check_input_change(i, 0, 1); 
            end
        end

        check_input_change(0.01, 1, 0);
        check_input_change(9.99, 0, 1);
        check_input_change(0.01, 1, 0);
        check_input_change(9.99, 0, 1);

        $display("Synchronizer test passed.");
        $finish;
    end

endmodule