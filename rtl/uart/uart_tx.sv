module uart_tx #(
    parameter int DATA_FRAME_LENGTH = 8,
    parameter int OVERSAMPLE_RATE = 16
)(
    input logic clk,
    input logic tick,
    input logic n_rst,
    input logic tx_start,
    input logic [DATA_FRAME_LENGTH - 1 : 0]data_in,
    output logic tx_serial
);

typedef enum logic [2:0] {
    IDLE,
    START,
    DATA,
    STOP,
    DONE
} state_t;

state_t state;
int bit_counter = 0;
int tick_count = 0;
logic [DATA_FRAME_LENGTH - 1 : 0]shift_reg;

always_ff @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        shift_reg <= '0;
        tx_serial <= 1'b1;
        bit_counter <= 0;
        tick_count <= 0;
        state <= IDLE;
    end else if (tick) begin
        case (state)
            IDLE:
                begin
                    bit_counter <= 0;
                    tick_count <= 0;
                    tx_serial <= 1'b1;
                    if (tx_start) begin
                        state <= START;
                        shift_reg <= data_in;
                    end 
                end
            START:
                begin
                    tx_serial <= 1'b0; 
                    if (tick_count == OVERSAMPLE_RATE - 1) begin
                        state <= DATA;
                        tick_count <= 0;
                    end else begin
                        tick_count <= tick_count + 1;
                    end
                end
            DATA:
                begin
                    tx_serial <= shift_reg[bit_counter];
                    if (tick_count == OVERSAMPLE_RATE - 1) begin
                        tick_count <= 0;
                        if (bit_counter == DATA_FRAME_LENGTH - 1) begin
                            state <= STOP;
                            bit_counter <= 0;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end else begin
                        tick_count <= tick_count + 1;
                    end
                end
            STOP:
                begin
                    tx_serial <= 1'b1;
                    if (tick_count == OVERSAMPLE_RATE - 1) begin
                        state <= DONE;
                        bit_counter <= 0;
                        tick_count <= 0;
                    end else begin
                        tick_count <= tick_count + 1; 
                    end
                end
            DONE:
                begin
                    state <= IDLE;
                    bit_counter <= 0;
                    tick_count <= 0;
                    tx_serial <= 1'b1;
                end
        endcase
    end
end

endmodule