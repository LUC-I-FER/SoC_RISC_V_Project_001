`timescale 1ns / 1ps

module tb_main;
    reg  clk;
    reg  resetn;
    
    wire tx;
    reg  rx;
    wire [7:0] gpio;
    
    // NEW: SPI External Pins
    wire sck;
    wire mosi;
    wire cs;
    wire miso;

    soc_top u_soc (
        .clk    (clk),
        .resetn (resetn),
        .tx     (tx),
        .rx     (rx),
        .gpio   (gpio),
        .sck    (sck),   // NEW
        .mosi   (mosi),  // NEW
        .miso   (miso),  // NEW
        .cs     (cs)     // NEW
    );

    // 1. Generate Clock (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    // 2. Task to simulate an external device sending a UART byte
    task send_uart_byte;
        input [7:0] char_data;
        integer i;
        begin
            rx = 0;
            #8680;
            for (i = 0; i < 8; i = i + 1) begin
                rx = char_data[i];
                #8680;
            end
            rx = 1;
            #8680;
        end
    endtask

    // --- Simulated SPI Sensor (Mode 0 Slave) ---
    reg [7:0] sensor_shift_reg;
    reg sensor_miso;
    
    // Drive the physical MISO wire with our simulated sensor's output pin
    assign miso = (!cs) ? sensor_miso : 1'bz;

    // When CS goes LOW, the sensor wakes up and prepares its first bit
    always @(negedge cs) begin
        sensor_shift_reg = 8'hA5; // The sensor always replies with 0xA5
        sensor_miso = sensor_shift_reg[7]; // Put MSB on the MISO line immediately
    end

    // On the falling edge of SCK, shift out the next bit
    always @(negedge sck) begin
        if (!cs) begin
            sensor_shift_reg = {sensor_shift_reg[6:0], 1'b0};
            sensor_miso = sensor_shift_reg[7];
        end
    end
    // ------------------------------------------------

    // --- NEW: UART Monitor (Prints SoC TX to Terminal) ---
    reg [7:0] rx_char;
    integer rx_bit;
    
    always @(negedge tx) begin
        // Wait half a bit period (4340ns) to center on the start bit
        #4340;
        if (tx == 0) begin
            // Sample the 8 data bits
            for (rx_bit = 0; rx_bit < 8; rx_bit = rx_bit + 1) begin
                #8680;
                rx_char[rx_bit] = tx;
            end
            // Wait for the stop bit
            #8680;
            $write("%c", rx_char); // Print the received ASCII character
        end
    end
    // ------------------------------------------------------

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

        // INCREASE THIS: Give the CPU 2 milliseconds to boot and run SPI tests
        #10000000; 

        $display("\n--- Simulation Complete ---");
        $finish;
    end
endmodule