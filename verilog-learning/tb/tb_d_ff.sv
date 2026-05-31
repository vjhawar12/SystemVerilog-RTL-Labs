`timescale 1ns/1ps

module tb_d_ff;

    logic D;
    logic clk;
    logic n_rst; // reset when 0, normal operation on 1
    logic Q;
    logic Q_not;

    d_ff dut (
        .Q(Q),
        .Q_not(Q_not),
        .n_rst(n_rst),
        .D(D),
        .clk(clk)
    );

    task automatic check_reset (); 

    begin
        n_rst = 1'b0; // reset enabled
        #1;

        if (Q !== 1'b0 || Q_not !== 1'b1) begin
            $fatal(1, "Failed reset task"); 
        end

        n_rst = 1'b1;
        #1;

    end

    endtask

    task automatic check_capture (
        input logic D_test,
        input logic Q_expected,
        input logic Q_not_expected
    );

        begin
            n_rst = 1; // disable reset
            D = D_test;

            @(posedge clk)
            #1;
            if (Q !== Q_expected || Q_not !== Q_not_expected) begin
                $fatal(1, "Failed capture test"); 
            end
        end

    endtask

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/d_ff.vcd");
        $dumpvars(0, tb_d_ff);

        clk = 1'b0;
        D = 1'b0;
        n_rst = 1'b0; // reset when 0, normal operation on 1

        check_reset();
        check_capture(1'b0, 1'b0, 1'b1);
        check_capture(1'b1, 1'b1, 1'b0);
        check_capture(1'b0, 1'b0, 1'b1);
        check_capture(1'b1, 1'b1, 1'b0);
        
        $finish;
    end

endmodule