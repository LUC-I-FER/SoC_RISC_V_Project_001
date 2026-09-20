`timescale 1ns / 1ps

module tb_main;
    reg  clk;
    reg  resetn;
    wire tx;
    reg  rx; // NEW: Register to drive the RX input

    soc_top u_soc (
        .clk    (clk),
        .resetn (resetn),
        .tx     (tx),
        .rx     (rx)     // Connect the RX pin
    );

    // 1. Generate Clock (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    // 2. Task to simulate an external device sending a UART byte
    // 115200 baud on a 100MHz clock = 868 clock cycles per bit.
    // 868 cycles * 10ns per cycle = 8680ns per bit.
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
        rx = 1; // UART idles HIGH

        $display("--- Powering On SoC ---");
        #20;
        resetn = 1;
        $display("--- Reset Released. CPU Running ---");

        // Give the CPU time to boot up and run initialization code
        #20000;

        $display("--- Injecting 'K' (0x4B) into RX pin ---");
        send_uart_byte(8'h4B); // Send the letter 'K'

        // Wait enough time for the CPU to process the received byte and echo it
        #200000;

        $display("--- Simulation Complete ---");
        $finish;
    end
endmodule