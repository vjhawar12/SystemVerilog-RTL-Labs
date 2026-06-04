// 2 flop synchronizer useful for signals wiht differnet clock domains to reduce the chance of metastability
// in case a value changes right before a clock edge transition the 2 flop synchronizer can reduce that risk
// placed on the rx side

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