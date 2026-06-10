`timescale 1ns/1ps

module tb_uart_top;

localparam int DATA_FRAME_LENGTH = 8;
localparam int OVERSAMPLING_RATE = 16;
localparam int CLKS_PER_TICK = 27;
logic clk;
logic n_rst;
logic enable;
logic rx_serial;
logic [DATA_FRAME_LENGTH - 1 : 0]tx_data_in;
logic tx_start;
logic tx_busy;
logic tx_done;
logic tx_serial;
logic rx_done;
logic [DATA_FRAME_LENGTH - 1 : 0]data_out;

uart_top #(
    .DATA_FRAME_LENGTH(DATA_FRAME_LENGTH),
    .OVERSAMPLING_RATE(OVERSAMPLING_RATE),
    .CLKS_PER_TICK(CLKS_PER_TICK)
) dut (
    .clk(clk),
    .n_rst(n_rst),
    .enable(enable),
    .tx_data_in(tx_data_in),
    .tx_start(tx_start),
    .tx_busy(tx_busy),
    .tx_done(tx_done),
    .tx_serial(tx_serial),
    .rx_serial(rx_serial),
    .rx_done(rx_done),
    .data_out(data_out)
);

always #5 clk = ~clk;
assign rx_serial = tx_serial;

task automatic check_reset() begin
    n_rst = 1'b1;
    #1;
    n_rst = 0;
    #1;
    if (tx_busy || tx_done || !tx_serial || data_out || rx_done) begin
        $fatal(
            1, 
            "Reset failed: Received: tx_busy=%0b tx_done=%0b tx_serial=%0b data_out=%0b rx_done=%0b Expected: tx_busy=%0b tx_done=%0b tx_serial=%0b data_out=%0b rx_done=%0b", 
            tx_busy, tx_done, tx_serial, data_out, rx_done, 0, 0, 1, 0, 0
        );
    end
    n_rst = 1'b1;
    #1;
end

endtask


task automatic tx_start_test (
    
) begin
    @(negedge clk)
    tx_start = 1'b1;
    #1;
    wait(tx_serial == 1'b0);
    if (tx_busy !== 1'b1 || tx_done !== 1'b0 || tx_serial !== 1'b0) begin
        $fatal(
        1, 
        "TX start test failed: Received: tx_busy=%0b tx_done=%0b tx_serial=%0b Expected: tx_busy=%0b tx_done=%0b tx_serial=%0b", 
        tx_busy, tx_done, tx_serial,
        1'b1, 1'b0, 1'b0
        ); 
    end
    tx_start = 1'b0;
end

endtask

task automatic wait_for_uart_bit(int ticks) 
    begin
        repeat (ticks * CLKS_PER_TICK) begin
            @(posedge clk);
        end
    end
endtask

task automatic wait_one_uart_bit() 
    begin
        wait_for_uart_bit(OVERSAMPLING_RATE); 
    end
endtask

task automatic wait_half_uart_bit() 
    begin
        wait_for_uart_bit(OVERSAMPLING_RATE / 2); 
    end
endtask

task automatic tx_serial_test (
    input logic [DATA_FRAME_LENGTH - 1:0]_data_in
) begin
    wait(tx_busy == 1'b0 && tx_serial == 1'b1 && tx_done == 1'b0);
    tx_data_in = _data_in;
    @(negedge clk);
    tx_start = 1'b1;
    @(negedge clk);
    tx_start = 1'b0;
    wait(tx_serial == 1'b0);
    wait_half_uart_bit();
    if (tx_serial != 1'b0) begin
        $fatal(
        1, 
        "TX start bit not cleared" 
        ); 
    end
    if (tx_busy !== 1'b1) begin
        $fatal(
        1, 
        "TX serial test failed: Received: tx_busy=%0b Expected: tx_busy=%0b", 
        tx_busy, 1'b1
        ); 
    end
    for (int i = 0; i < DATA_FRAME_LENGTH; i++) begin
        wait_one_uart_bit();
        if (tx_serial != _data_in[i]) begin
            $fatal(
            1, 
            "TX serial test failed at index %0b: Received: tx_serial=%0b Expected: tx_serial=%0b", 
            i, tx_serial, _data_in[i]
            ); 
        end
    end
end

endtask

task automatic rx_serial_test (
    input logic [DATA_FRAME_LENGTH - 1 : 0]expected_rx_serial;
)

begin
    wait(rx_done == 1'b1);
    for (int i = 0; i <= DATA_FRAME_LENGTH - 1; i++) begin
        if (expected_rx_serial[i] !== data_out[i]) begin
            $fatal(
            1, 
            "RX serial test failed at index %0b: Received: data_out=%0b Expected: rx_serial=%0b", 
            i, data_out[i], expected_rx_serial[i]
            ); 
        end
    end
    wait_one_uart_bit();
    if (rx_serial !== 1'b1) begin
        $fatal(
        1, 
        "Stop bit not set"
        ); 
    end
end

endtask

task automatic tx_done_received_test (
    
) 

begin
    if (tx_busy !== 1'b0 || tx_done !== 1'b1 || tx_serial !== 1'b1) begin
        $fatal(
        1, 
        "TX done test failed: Received: tx_busy=%0b tx_done=%0b tx_serial=%0b Expected: tx_busy=%0b tx_done=%0b tx_serial=%0b", 
        tx_busy, tx_done, tx_serial,
        1'b0, 1'b1, 1'b1
        ); 
    end
end

endtask

initial begin
    $dumpfile("build/uart_top.vcd");
    $dumpvars(0, tb_uart_top);

    clk       = 1'b0;
    n_rst     = 1'b1;
    enable    = 1'b1;
    tx_start  = 1'b0;

    check_reset(); 

    for (int i = 0; i < 256; i++) begin
        tx_serial_test(i);
        rx_serial_test(i);
    end

    @(posedge clk)
    #1;
    tx_done_received_test();
    
    $display("UART Top test passed.");
    $finish;
end

endmodule

