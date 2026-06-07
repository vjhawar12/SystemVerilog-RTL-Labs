`timescale 1ns/1ps

module tb_uart_rx;

    logic clk;
    logic n_rst;
    logic tick;
    logic rx_serial;
    localparam DATA_FRAME_LENGTH = 8;
    localparam OVERSAMPLE_RATE = 16;
    logic [DATA_FRAME_LENGTH - 1:0]data_out;
    
    uart_rx #(
        .DATA_FRAME_LENGTH(DATA_FRAME_LENGTH),
        .OVERSAMPLE_RATE(OVERSAMPLE_RATE)
    ) dut (
        .clk(clk),
        .n_rst(n_rst),
        .tick(tick),
        .rx_serial(rx_serial),
        .data_out(data_out)
    );

    logic [DATA_FRAME_LENGTH - 1 : 0]data_in = 0;
    always #5 clk = ~clk;
    assign tick = 1'b1;

    task automatic send_one_bit(
       input logic data_bit
    );
        begin
            rx_serial = data_bit;
            for (int i = 0; i < OVERSAMPLE_RATE; i++) begin
                @(posedge clk);
            end
        end
    endtask

    task automatic send_one_byte (
        input logic [DATA_FRAME_LENGTH - 1 : 0]data_frame
    ); 
        begin
            data_in = data_frame;
            // start bit
            send_one_bit(0);
            // data byte
            for (int i = 0; i < DATA_FRAME_LENGTH; i++) begin
                send_one_bit(data_frame[i]);
            end
            // stop bit
            send_one_bit(1);
        end

    endtask

    task automatic send_one_byte_test(
        input logic [DATA_FRAME_LENGTH - 1 : 0]data_frame
    ); 
        begin
            send_one_byte(data_frame);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            if (data_out != data_frame) begin
                $fatal(1, "data_out != data_frame: Received: data_out=%0b Expected: data_out=%0b", data_out, data_frame);
            end     
        end

    endtask

    task automatic _reset();
        begin
            n_rst = 0;
            #5;
            n_rst = 1; 
        end
    endtask

    initial begin
        $dumpfile("build/uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        clk       = 1'b0;
        n_rst     = 1'b1;
        rx_serial = 1'b1;

        _reset();

        for (int i = 0; i < 256; i++) begin
            send_one_byte_test(i);
        end

        $display("UART RX test passed.");
        $finish;
    end

endmodule