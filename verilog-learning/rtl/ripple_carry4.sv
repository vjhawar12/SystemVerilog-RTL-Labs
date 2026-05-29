module ripple_carry4 (
    input logic [3:0] A,
    input logic [3:0] B,
    input logic Cin,
    output logic Cout,
    output logic [3:0] Sum
); 

logic c1, c2, c3;

full_adder fa1 (
    .A0(A[0]),
    .B0(B[0]),
    .Sum(Sum[0]),
    .Cin(Cin),
    .Cout(c1)
);

full_adder fa2 (
    .A0(A[1]),
    .B0(B[1]),
    .Sum(Sum[1]),
    .Cin(c1),
    .Cout(c2)
);

full_adder fa3 (
    .A0(A[2]),
    .B0(B[2]),
    .Sum(Sum[2]),
    .Cin(c2),
    .Cout(c3)
);

full_adder fa4 (
    .A0(A[3]),
    .B0(B[3]),
    .Sum(Sum[3]),
    .Cin(c3),
    .Cout(Cout)
);

endmodule