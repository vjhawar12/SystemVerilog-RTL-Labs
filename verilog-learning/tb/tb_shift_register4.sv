`timescale 1ns/1ps

module tb_shift_register4;

    logic clk;
    logic n_rst;
    logic enable;
    logic shift_in;
    logic shift_out;
    logic [3:0] q;
    
    shift_register4 dut (
        .clk(clk),
        .n_rst(n_rst),
        .enable(enable),
        .shift_in(shift_in),
        .shift_out(shift_out),
        .q(q)
    );

    always #5 clk = ~clk;

    task automatic check_reset(); 
        begin
            n_rst   = 1'b0;
            enable  = 1'b0;
            shift_in = 1'b0;
            #1;

            if (q !== 4'b0000 || shift_out !== 1'b0) begin
                $fatal(1, "FAILED reset: expected q=0000 shift_out=0, got q=%04b shift_out=%0b",
                       q, shift_out); 
            end

            n_rst = 1'b1;
            #1;
        end
    endtask

    task automatic check_shift(
        input logic       test_shift_in,
        input logic [3:0] expected_q,
        input logic       expected_shift_out
    );
        begin
            n_rst    = 1'b1;
            enable   = 1'b1;
            shift_in = test_shift_in;

            @(posedge clk);
            #1;

            if (q !== expected_q || shift_out !== expected_shift_out) begin
                $fatal(1, "FAILED shift: shift_in=%0b expected q=%04b shift_out=%0b, got q=%04b shift_out=%0b",
                       shift_in, expected_q, expected_shift_out, q, shift_out);
            end
        end
    endtask

    task automatic check_hold(
        input logic       test_shift_in,
        input logic [3:0] expected_q,
        input logic       expected_shift_out
    );
        begin
            n_rst    = 1'b1;
            enable   = 1'b0;
            shift_in = test_shift_in;

            @(posedge clk);
            #1;

            if (q !== expected_q || shift_out !== expected_shift_out) begin
                $fatal(1, "FAILED hold: expected q=%04b shift_out=%0b, got q=%04b shift_out=%0b",
                       expected_q, expected_shift_out, q, shift_out);
            end
        end
    endtask

    initial begin
        $dumpfile("build/shift_register4.vcd");
        $dumpvars(0, tb_shift_register4);

        clk      = 1'b0;
        n_rst    = 1'b1;
        enable   = 1'b0;
        shift_in = 1'b0;
        
        check_reset();

        // RTL assumption:
        // shift_out <= q[0];
        // q         <= {shift_in, q[3:1]};

        check_shift(1'b1, 4'b1000, 1'b0);
        check_shift(1'b0, 4'b0100, 1'b0);
        check_shift(1'b1, 4'b1010, 1'b0);
        check_shift(1'b1, 4'b1101, 1'b0);

        // Hold: q and shift_out should not change when enable=0
        check_hold(1'b0, 4'b1101, 1'b0);

        // Continue shifting to observe bits leaving through shift_out
        check_shift(1'b0, 4'b0110, 1'b1);
        check_shift(1'b0, 4'b0011, 1'b0);
        check_shift(1'b0, 4'b0001, 1'b1);
        check_shift(1'b0, 4'b0000, 1'b1);

        $display("4-bit shift register test passed.");
        $finish;
    end

endmodule