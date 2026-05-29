module full_adder (
    input logic A0,
    input logic B0,
    input logic Cin,
    output logic Sum,
    output logic Cout
);

assign Sum = A0 ^ B0 ^ Cin;
assign Cout = (A0 & B0) | (Cin & B0) | (Cin & A0);

endmodule