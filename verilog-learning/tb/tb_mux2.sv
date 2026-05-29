`timescale 1ns/1ps

module tb_mux2;

    logic a;
    logic b;
    logic sel;
    logic y;

    mux2 dut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    initial begin
        $dumpfile("build/mux2.vcd");
        $dumpvars(0, tb_mux2);

        sel = 0; a = 0; b = 0; #10;
        sel = 0; a = 0; b = 1; #10;
        sel = 0; a = 1; b = 0; #10;
        sel = 0; a = 1; b = 1; #10;

        sel = 1; a = 0; b = 0; #10;
        sel = 1; a = 0; b = 1; #10;
        sel = 1; a = 1; b = 0; #10;
        sel = 1; a = 1; b = 1; #10;

        $finish;
    end

endmodule