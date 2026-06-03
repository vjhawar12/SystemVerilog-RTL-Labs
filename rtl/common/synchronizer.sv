module synchronizer (
    input logic clk,
    input logic n_rst,
    input logic in_sig,
    output logic out_sig
);

logic a;
logic b;

always_ff @(posedge clk or negedge n_rst ) begin
    if (!n_rst) begin
        a <= 0;
        b <= 0;
    end else begin    
        a <= in_sig;
        b <= a; 
    end
end

assign out_sig = b;

endmodule