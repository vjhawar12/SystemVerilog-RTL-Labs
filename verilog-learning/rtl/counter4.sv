module counter4 (
    input logic clk,
    input logic n_rst,
    input logic enable,
    output logic [3:0]count
); 

always_ff @( posedge clk or negedge n_rst ) begin
    if (!n_rst)
        count <= 4'd0;
    else if (enable)
        count <= count + 4'd1;
end

endmodule