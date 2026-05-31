`timescale 1ns/1ps

module tb_counter4;

    logic clk;
    logic n_rst;
    logic enable;
    logic [3:0]count;
    
    counter4 dut (
        .clk(clk),
        .n_rst(n_rst),
        .enable(enable),
        .count(count)
    );

    task automatic check_reset (); 

    begin
        n_rst = 1'b0; // reset enabled
        #1;

        if (count != 4'd0) begin
            $display("Failed reset task"); 
        end

        n_rst = 1'b1;
        #1;

    end

    endtask

    task automatic check_enable (
        input logic enable_test,
        input logic [3:0]count_expected
    );

        begin
            n_rst = 1; // disable reset
            enable = enable_test;

            @(posedge clk)
            #1;
            if (count != count_expected) begin
                $display("Failed capture test"); 
            end
        end

    endtask

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/counter4.vcd");
        $dumpvars(0, tb_counter4);

        clk    = 1'b0;
        n_rst  = 1'b1;
        enable = 1'b0;
        
        check_reset();
        check_enable(1'b0, 4'd0);
        check_enable(1'b1, 4'd1);
        check_enable(1'b1, 4'd2);
        check_enable(1'b0, 4'd2);

        for (int i = 3; i < 16; i++) begin
            check_enable(1'b1, i);
        end

        $display("4-bit counter test passed.");
        $finish;
    end

endmodule