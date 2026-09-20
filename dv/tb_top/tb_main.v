`timescale 1ns / 1ps

module tb_main;
    reg clk;
    reg resetn;

    // Instantiate the entire System-on-Chip
    soc_top u_soc (
        .clk    (clk),
        .resetn (resetn)
    );

    // 1. Generate Clock (100 MHz)
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

        // Give the CPU more time to execute C code that uses the RAM
        #5000;

        $display("--- Simulation Complete ---");
        $finish;
    end
endmodule
