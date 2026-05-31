module shift_register4 (
    input logic n_rst,
    input logic enable,
    input logic clk,
    input logic shift_in,
    output logic shift_out,
    output logic [3:0]q
);

always_ff @( posedge clk or negedge n_rst ) begin
    if (!n_rst) begin
        q <= 4'b0;
        shift_out <= 4'b0;
    end else if (enable) begin
        shift_out <= q[0];
        q[0] <= q[1];
        q[1] <= q[2];
        q[2] <= q[3];
        q[3] <= shift_in;
    end
end

endmodule
