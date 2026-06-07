`timescale 1ns/1ps

module tb_uart_tx;
    localparam DATA_FRAME_LENGTH = 8;
    localparam OVERSAMPLE_RATE = 16;
    localparam CLKS_PER_TICK = 27;
    logic clk;
    logic tick;
    logic n_rst;
    logic tx_start;
    logic [DATA_FRAME_LENGTH - 1 : 0]data_in;
    logic tx_serial;
    logic tx_busy;
    logic tx_done;
    
    uart_tx #(
        .DATA_FRAME_LENGTH(DATA_FRAME_LENGTH),
        .OVERSAMPLE_RATE(OVERSAMPLE_RATE)
    ) dut (
        .clk(clk),
        .n_rst(n_rst),
        .tick(tick),
        .tx_start(tx_start),
        .tx_serial(tx_serial),
        .data_in(data_in),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    always #5 clk = ~clk;

    task automatic wait_one_uart_bit(); 
        begin
            repeat (OVERSAMPLE_RATE) begin
                tick = 1'b0;
                repeat(CLKS_PER_TICK) begin
                    @(posedge clk);
                    #1;
                end
                tick = 1'b1;
                @(posedge clk);
                #1;
                tick = 1'b0; 
            end 
        end
    endtask

    task automatic send_one_byte(
        input logic [DATA_FRAME_LENGTH - 1 : 0]_data_in
    );
        begin
            @(negedge clk)
            #1;
            tx_start = 1'b1;
            data_in = _data_in;
            @(negedge clk);
            tx_start = 1'b0;
        end
    endtask

    task automatic check_idle();
    begin
        // IDLE
        if (tx_busy != 1'b0 || tx_done != 1'b0 || tx_serial != 1'b1) begin
            $fatal(
                1, 
                "Case IDLE: Received: tx_busy=%0b tx_done=%0b tx_serial=%0b Expected: tx_busy=%0b tx_done=%0b tx_serial=%0b", 
                tx_busy, tx_done, tx_serial,
                1'b0, 1'b0, 1'b1
            );
        end
    end
    endtask

    task automatic check_serial(
        input logic [DATA_FRAME_LENGTH - 1 : 0]_data_in
    );
        begin
            @(posedge clk);
            #1;
            // wait an extra clock edge to enter START
            // START
            if (tx_busy != 1'b1 || tx_done != 1'b0 || tx_serial != 1'b0) begin
                $fatal(
                    1, 
                    "Case START: Received: tx_busy=%0b tx_done=%0b tx_serial=%0b Expected: tx_busy=%0b tx_done=%0b tx_serial=%0b", 
                    tx_busy, tx_done, tx_serial,
                    1'b1, 1'b0, 1'b0
                );
            end
            // DATA
            for (int i = 0; i < DATA_FRAME_LENGTH; i++) begin
                wait_one_uart_bit();
                @(posedge clk);
                #1;
                if (tx_busy != 1'b1 || tx_done != 1'b0 || tx_serial != _data_in[i]) begin
                    $fatal(
                        1, 
                        "Case DATA bit %0b: Received: tx_busy=%0b tx_done=%0b tx_serial=%0b Expected: tx_busy=%0b tx_done=%0b tx_serial=%0b", 
                        i, tx_busy, tx_done, tx_serial,
                        1'b1, 1'b0, _data_in[i]
                    );
                end 
            end
            wait_one_uart_bit();
            @(posedge clk);
            #1;
            // STOP
            if (tx_busy != 1'b1 || tx_done != 1'b0 || tx_serial != 1'b1) begin
                $fatal(
                    1, 
                    "Case STOP: Received: tx_busy=%0b tx_done=%0b tx_serial=%0b Expected: tx_busy=%0b tx_done=%0b tx_serial=%0b", 
                    tx_busy, tx_done, tx_serial,
                    1'b1, 1'b0, 1'b1
                );
            end
            wait_one_uart_bit();
            @(posedge clk);
            #1;
            // DONE
            if (tx_busy != 1'b0 || tx_done != 1'b1 || tx_serial != 1'b1) begin
                $fatal(
                    1, 
                    "Case DONE: Received: tx_busy=%0b tx_done=%0b tx_serial=%0b Expected: tx_busy=%0b tx_done=%0b tx_serial=%0b", 
                    tx_busy, tx_done, tx_serial,
                    1'b0, 1'b1, 1'b1
                );
            end
            @(posedge clk);
            #1;
            // IDLE after DONE
            if (tx_busy != 1'b0 || tx_done != 1'b0 || tx_serial != 1'b1) begin
                $fatal(
                    1, 
                    "Case IDLE: Received: tx_busy=%0b tx_done=%0b tx_serial=%0b Expected: tx_busy=%0b tx_done=%0b tx_serial=%0b", 
                    tx_busy, tx_done, tx_serial,
                    1'b0, 1'b0, 1'b1
                );
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
        $dumpfile("build/uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);

        clk       = 1'b0;
        n_rst     = 1'b1;
        tick      = 1'b0;
        tx_start  = 1'b0;
        data_in   = 'b0;

        _reset();

        for (int i = 0; i < 256; i++) begin
            check_idle();
            send_one_byte(i);
            check_serial(i);
        end

        $display("UART TX test passed.");
        $finish;
    end

endmodule

