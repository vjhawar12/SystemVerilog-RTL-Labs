module d_ff (
    input logic D,
    input logic clk,
    input logic n_rst, // reset when 0, normal operation on 1
    output logic Q,
    output logic Q_not
); 

    always_ff @(posedge clk or negedge n_rst) begin
        if (!n_rst) 
            Q <= 1'b0;
        else   
            Q <= D;
    end

    assign Q_not = ~Q; 

endmodule