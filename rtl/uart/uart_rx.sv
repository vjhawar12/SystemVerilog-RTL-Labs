module uart_rx #(
    parameter int DATA_FRAME_LENGTH = 8,
    parameter int OVERSAMPLE_RATE = 16
)(
    input logic clk,
    // tick comes from the tick_gen module
    input logic tick,
    input logic n_rst,
    // incoming data
    input logic rx_serial,
    // data being sent out
    output logic [DATA_FRAME_LENGTH - 1:0]data_out
);

/* 
IDLE       waiting for start bit
START      validating/sampling start bit
DATA       receiving 8 data bits
STOP       checking stop bit
*/

typedef enum logic [2:0] {
    IDLE,
    START,
    DATA,
    STOP,
    DONE
} state_t; 

logic [DATA_FRAME_LENGTH - 1:0]shift_reg;
state_t state;
logic [3:0]counter;
logic [3:0]tick_counter;
logic [3:0]bit_count;

always_ff @(posedge clk or negedge n_rst) begin 
    if (!n_rst) begin
        shift_reg <= '0;
        counter = 0;
        tick_counter = 0;
        bit_count = 0;
        state <= IDLE;
    end else if (tick) begin
        case (state)
            IDLE :  begin
                        if (rx_serial == 1'b0) begin
                            state <= START;
                            counter <= 0;
                            bit_count <= 0;
                        end
                    end
            START : begin
                        counter <= counter + 1;
                        if (counter == (OVERSAMPLE_RATE / 2) && rx_serial == 1'b0) begin
                            if (rx_serial == 1'b0) begin
                                state <= DATA
                            end else begin
                                state <= IDLE;
                            end
                            counter <= 0;
                            bit_count <= 0;
                        end
                    end
            DATA :  begin
                        shift_reg[bit_count] <= rx_serial;
                        if (bit_count < DATA_FRAME_LENGTH - 1) begin
                            bit_count <= bit_count + 1;
                        end else begin
                            state <= STOP; 
                        end
                    end
            STOP :  begin
                        if (rx_serial == 1'b1) begin
                           state <= DONE;  
                        end
                    end
            DONE : begin
                data_out <= shift_reg;
                state <= IDLE;
            end
        endcase 
    end
end

endmodule