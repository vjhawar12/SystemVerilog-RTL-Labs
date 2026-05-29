`timescale 1ns/1ps

module tb_full_adder;

    logic A0;
    logic B0;
    logic Cin;
    logic Cout;
    logic Sum;

    full_adder dut (
        .A0(A0),
        .B0(B0),
        .Cin(Cin),
        .Cout(Cout),
        .Sum(Sum)
    ); 

    task automatic check (
        input logic test_a;
        input logic test_b;
        input logic test_cin;
        output logic expected_cout;
        output logic expected_sum;
    ); 

        begin
           A0 = test_a;
           B0 = test_b;
           Cin = test_cin;
           
           #1;

           if (Sum !== expected_sum || Cout !== expected_cout) begin
                $fatal("Failed: A0=%0b B0=%0b Cin=%0b | expected Sum=%0b Cout=%0b, got Sum=%0b Cout=%0b", A0, B0, Cin, expected_sum, expected_cout, Sum, Cout); 
           end

           #9;
        end
    endtask 

    initial begin
        $dumpfile("build/full_adder.vcd");
        $dumpvars(0, tb_full_adder);

        Cin = 0; A0 = 0; B0 = 0; #10;
        Cin = 0; A0 = 0; B0 = 1; #10;
        Cin = 0; A0 = 1; B0 = 0; #10;
        Cin = 0; A0 = 1; B0 = 1; #10;

        Cin = 1; A0 = 0; B0 = 0; #10;
        Cin = 1; A0 = 0; B0 = 1; #10;
        Cin = 1; A0 = 1; B0 = 0; #10;
        Cin = 1; A0 = 1; B0 = 1; #10;

        $finish;
    end

endmodule