// DIVISOR = sys_clock / (baud_rate * oversampling factor) = 50 MHz / (115200 * 16) = 27

module tick_gen #(
    parameter int SYS_CLOCK_FREQ = 50_000_000;
    parameter int BAUD_RATE = 115200;
    parameter int OVERSAMPLING_FACTOR = 16;
)(
    input logic clk,
    input logic n_rst,
    input logic enable,
    output logic [4:0]count,
    output logic tick
); 

localparam int DIVISOR = SYS_CLOCK_FREQ / (BAUD_RATE * OVERSAMPLING_FACTOR); 

always_ff @( posedge clk or negedge n_rst ) begin
    if (!n_rst) begin
        count <= 0;
        tick <= 0;    
    end else if (enable) begin
        count <= count + 1;
        if (count == DIVISOR - 1) begin
            tick <= 1; 
            count <= 0; 
        end else begin
            tick <= 0; 
        end
    end 
end

endmodule;