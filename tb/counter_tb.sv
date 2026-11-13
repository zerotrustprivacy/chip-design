// counter_tb.sv
// A "self-checking" testbench for counter.sv.
//
// A testbench is test code for hardware. It is never built into the chip --
// it only exists in simulation. It drives the inputs (clock, reset, enable),
// watches the outputs, and compares them to what we expect.
//
// It prints ALL TESTS PASSED and exits normally if everything matches.
// On any mismatch it exits with an error, which makes the CI pipeline turn red.

`timescale 1ns/1ps

module counter_tb;

    localparam int WIDTH = 8;

    logic             clk = 0;
    logic             rst;
    logic             en;
    logic [WIDTH-1:0] count;
    logic             wrap;

    int errors = 0;

    // The design under test ("DUT")
    counter #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst(rst), .en(en), .count(count), .wrap(wrap)
    );

    // Make a clock: flip every 5 ns -> a 10 ns period (100 MHz)
    always #5 clk = ~clk;

    // Watchdog: if the test is still running after 100 microseconds of
    // simulated time, something is stuck (e.g. waiting for a value that never
    // comes). Fail loudly instead of hanging the pipeline forever.
    initial begin
        #100us;
        $fatal(1, "TIMEOUT: simulation ran too long -- the design may be stuck");
    end

    // Helper: wait for one clock edge, then a moment for outputs to settle
    task automatic tick();
        @(posedge clk);
        #1;
    endtask

    // Helper: compare one value against what we expected
    task automatic check(input string what, input int got, input int expected);
        if (got !== expected) begin
            $display("  FAIL: %s -- got %0d, expected %0d", what, got, expected);
            errors++;
        end
    endtask

    initial begin
        // Save a waveform file so you can see every signal over time
        // (open it with GTKWave or Surfer -- see the README)
        $dumpfile("build/counter_tb.vcd");
        $dumpvars(0, counter_tb);

        // ---- Test 1: reset puts the counter at 0 ----
        $display("Test 1: reset");
        rst = 1; en = 0;
        tick();
        check("count after reset", count, 0);
        check("wrap after reset",  wrap,  0);

        // ---- Test 2: counts up by 1 each clock while enabled ----
        $display("Test 2: counting");
        rst = 0; en = 1;
        for (int i = 1; i <= 10; i++) begin
            tick();
            check($sformatf("count on cycle %0d", i), count, i);
        end

        // ---- Test 3: holds its value when enable is off ----
        $display("Test 3: hold when disabled");
        en = 0;
        repeat (5) tick();
        check("count while disabled", count, 10);

        // ---- Test 4: wraps from 255 back to 0 and raises `wrap` ----
        $display("Test 4: wrap-around");
        en = 1;
        while (count != 255) tick();
        check("wrap before rollover", wrap, 0);
        tick();
        check("count after rollover", count, 0);
        check("wrap on rollover",     wrap,  1);
        tick();
        check("wrap one cycle later", wrap,  0);

        // ---- Results ----
        if (errors == 0) begin
            $display("ALL TESTS PASSED");
            $finish;
        end else begin
            $fatal(1, "%0d TEST(S) FAILED", errors);
        end
    end

endmodule
