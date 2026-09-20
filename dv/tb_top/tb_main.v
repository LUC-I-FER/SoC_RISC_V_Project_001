`timescale 1ns / 1ps

module tb_main;
    reg  clk;
    reg  resetn;
    wire tx;
    reg  rx;
    wire [7:0] gpio; // NEW: Wire to observe the bidirectional GPIO port

    soc_top u_soc (
        .clk    (clk),
        .resetn (resetn),
        .tx     (tx),
        .rx     (rx),
        .gpio   (gpio)   // NEW: Connect the GPIO port
    );

    // 1. Generate Clock (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    // 2. Task to simulate an external device sending a UART byte
    task send_uart_byte;
        input [7:0] char_data;
        integer i;
        begin
            rx = 0;       // Start bit
            #8680;
            for (i = 0; i < 8; i = i + 1) begin
                rx = char_data[i]; // Data bits (LSB first)
                #8680;
            end
            rx = 1;       // Stop bit
            #8680;
        end
    endtask

    // 3. Main Simulation Block
    initial begin
        $dumpfile("outputs/vcd_files/waveform.vcd");
        $dumpvars(0, tb_main);

        clk = 0;
        resetn = 0;
        rx = 1;

        $display("--- Powering On SoC ---");
        #20;
        resetn = 1;
        $display("--- Reset Released. CPU Running ---");

        // Give the CPU time to boot up and run initialization code
        #20000;

        $display("--- Injecting 'K' (0x4B) into RX pin ---");
        send_uart_byte(8'h4B);

        // Wait enough time for the CPU to process and output GPIO toggles
        #200000;

        $display("--- Simulation Complete ---");
        $finish;
    end
endmodule