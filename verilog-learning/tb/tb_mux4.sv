`timescale 1ns/1ps

module tb_mux4;

    logic [3:0]data_in;
    logic [1:0]sel;
    logic y;

    mux4 dut (
        .data_in(data_in),
        .sel(sel),
        .y(y)
    );

    task automatic check (
        input logic [3:0]test_data_in,
        input logic [1:0]test_sel
    ); 

    logic expected_y;

        begin
           data_in = test_data_in;
           sel = test_sel;
           expected_y = test_data_in[test_sel];

           #1;

           if (expected_y !== y) begin
                $fatal(1, "FAILED: data_in=%04b sel=%02b | expected y=%0b, got y=%0b",
                data_in, sel, expected_y, y);
           end

           #9;
        end
    endtask 

    initial begin
        $dumpfile("build/mux4.vcd");
        $dumpvars(0, tb_mux4);

        for (int data = 0; data < 16; data++) begin
            for (int sel = 0; sel < 4; sel++) begin
                check(data[3:0], sel[1:0]);
            end
        end
        $display("4-to-1 mux test passed");
        $finish;
    end

endmodule