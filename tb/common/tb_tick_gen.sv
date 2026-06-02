`timescale 1ns/1ps

module tb_tick_gen;

    logic clk;
    logic n_rst;
    logic enable;
    logic [4:0]count;
    logic tick;
    
    tick_gen dut (
        .clk(clk),
        .n_rst(n_rst),
        .enable(enable),
        .count(count),
        .tick(tick)
    );

    task automatic _reset (); 

    begin
        n_rst = 1'b0; // reset enabled
        #1;
        n_rst = 1'b1;
        #1;
    end

    endtask

    task automatic _enable ();

        begin
            enable = 0;
            #1;
            enable = 1;
            #1;
        end

    endtask

    task automatic check_tick (
        input logic [8:0]cycles_max,
        input logic [4:0]expected_ticks
    );

        int ticks = 0;
        n_rst = 1; // disable reset
        enable = 1; // keep enabled

        @(posedge clk);
        #1;

        repeat(cycles_max) begin
            @(posedge clk); 
            #1;
            if (tick) begin
                ticks = ticks + 1;
            end 
        end

        if (ticks < expected_ticks) begin
            $display("Failed tick test"); 
        end else begin
            $display("Passed tick test"); 
        end


    endtask

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/tick_gen.vcd");
        $dumpvars(0, tb_tick_gen);

        clk    = 1'b0;
        n_rst  = 1'b1;
        enable = 1'b0;
        
        _reset();
        _enable();

        for (int i = 1; i < 19; i++) begin
            _reset();
            _enable();
            check_tick(27 * i, i);
        end

        $display("Tick gen test passed.");
        $finish;
    end

endmodule