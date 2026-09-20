`timescale 1ns / 1ps

module tb_main;
    reg clk;
    reg resetn;
    wire tx; // NEW: Wire to capture the UART TX output

    // Instantiate the entire System-on-Chip
    soc_top u_soc (
        .clk    (clk),
        .resetn (resetn),
        .tx     (tx)     // NEW: Connect the TX pin
    );

    // 1. Generate Clock (100 MHz)
    // 10ns period -> 100 MHz
    always #5 clk = ~clk;

    // 2. Main Simulation Block
    initial begin
        $dumpfile("outputs/vcd_files/waveform.vcd");
        $dumpvars(0, tb_main);

        // Initialize clock and reset
        clk = 0;
        resetn = 0;

        $display("--- Powering On SoC ---");
        #20;
        resetn = 1;
        $display("--- Reset Released. CPU Running ---");

        // INCREASED TIME: UART is slow compared to the CPU.
        // Sending 1 character at 115200 baud takes ~86,800 ns.
        // 1,000,000 ns gives enough time to send about 11 characters.
        #1000000;

        $display("--- Simulation Complete ---");
        $finish;
    end
endmodule