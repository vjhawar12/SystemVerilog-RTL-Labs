module uart_top #(
    parameter int DATA_FRAME_LENGTH = 8,
    parameter int OVERSAMPLING_RATE = 16,
    parameter int CLKS_PER_TICK = 27
)(
    input logic clk,
    input logic n_rst,
    input logic enable,
    input logic rx_serial,
    input logic [DATA_FRAME_LENGTH - 1 : 0]tx_data_in,
    input logic tx_start,

    output logic tx_busy,
    output logic tx_done,
    output logic tx_serial,
    output logic rx_done,
    output logic [DATA_FRAME_LENGTH - 1 : 0]data_out
);

logic tick;
logic [4:0]count;
logic rx_serial_sync;

tick_gen _tick_gen (
    .clk(clk),
    .n_rst(n_rst),
    .enable(enable),
    .count(count),
    .tick(tick)
);

uart_rx #(
    .DATA_FRAME_LENGTH(DATA_FRAME_LENGTH),
    .OVERSAMPLE_RATE(OVERSAMPLING_RATE)
) rx (
    .clk(clk),
    // tick comes from the tick_gen module
    .tick(tick),
    .n_rst(n_rst),
    // incoming bit
    .rx_serial(rx_serial_sync),
    // data being sent out
    .data_out(data_out),
    .rx_done(rx_done)
);

uart_tx #(
    .DATA_FRAME_LENGTH(DATA_FRAME_LENGTH),
    .OVERSAMPLE_RATE(OVERSAMPLING_RATE)
) tx (
    .clk(clk),
    .tick(tick),
    .n_rst(n_rst),
    .tx_start(tx_start),
    .data_in(tx_data_in),
    .tx_serial(tx_serial),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

synchronizer sync (
    .clk(clk),
    .n_rst(n_rst),
    .in_sig(rx_serial),
    .out_sig(rx_serial_sync)
);

endmodule