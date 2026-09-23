`timescale 1ns / 1ps

module tb_main;
    reg  clk;
    reg  resetn;
    
    // UART Pins
    wire tx;
    reg  rx;
    
    // GPIO Pin
    wire [7:0] gpio;
    
    // SPI External Pins
    wire sck;
    wire mosi;
    wire cs;
    wire miso;

    // I2C External Pins
    wire sda;
    wire scl;

    soc_top u_soc (
        .clk    (clk),
        .resetn (resetn),
        .tx     (tx),
        .rx     (rx),
        .gpio   (gpio),
        .sck    (sck),
        .mosi   (mosi),
        .miso   (miso),
        .cs     (cs),
        .sda    (sda),
        .scl    (scl)
    );

    // 1. Generate Clock (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    // --- NEW: Independent GPIO Input Stimulus ---
    reg [3:0] ext_gpio_in;
    
    // Drive the upper 4 bits of the GPIO bus (simulating external buttons).
    // The lower 4 bits are left as high-Z (z) so the SoC can drive them (LEDs).
    assign gpio = {ext_gpio_in, 4'bzzzz};

    // 2. Task to simulate an external device sending a UART byte
    task send_uart_byte;
        input [7:0] char_data;
        integer i;
        begin
            rx = 0;
            #8680; // Wait 1 baud period (115200 bps)
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

    always @(negedge cs) begin
        sensor_shift_reg = 8'hA5; 
        sensor_miso = sensor_shift_reg[7]; 
    end

    always @(negedge sck) begin
        if (!cs) begin
            sensor_shift_reg = {sensor_shift_reg[6:0], 1'b0};
            sensor_miso = sensor_shift_reg[7];
        end
    end
    // ------------------------------------------------

    // --- Simulated I2C Sensor (Always ACKs) ---
    pullup(sda);
    pullup(scl);

    reg i2c_sda_drv = 1;
    integer i2c_bit_cnt = 0;
    
    assign sda = (i2c_sda_drv == 0) ? 1'b0 : 1'bz;

    always @(negedge sda) begin
        if (scl === 1'b1) i2c_bit_cnt <= 0;
    end

    always @(negedge scl) begin
        if (i2c_bit_cnt == 9) begin
            i2c_sda_drv <= 1; 
            i2c_bit_cnt <= 0; 
        end else if (i2c_bit_cnt == 8) begin
            i2c_sda_drv <= 0; 
            i2c_bit_cnt <= 9;
        end else begin
            i2c_bit_cnt <= i2c_bit_cnt + 1;
        end
    end
    // ------------------------------------------------

    // --- UART Monitor (Prints SoC TX to Terminal) ---
    reg [7:0] rx_char;
    integer rx_bit;
    
    always @(negedge tx) begin
        #4340;
        if (tx == 0) begin
            for (rx_bit = 0; rx_bit < 8; rx_bit = rx_bit + 1) begin
                #8680;
                rx_char[rx_bit] = tx;
            end
            #8680;
            $write("%c", rx_char); 
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
        ext_gpio_in = 4'b0000;

        $display("--- Powering On SoC ---");
        #20;
        resetn = 1;
        $display("--- Reset Released. CPU Running ---");

        // =========================================================
        // INDEPENDENT HARDWARE STIMULUS
        // These events happen at fixed simulation times, ignoring
        // whatever the C code inside the CPU is currently doing.
        // =========================================================

        #500000; // Wait 500us for boot

        // 1. Simulate an external user pressing buttons on GPIO [7:4]
        ext_gpio_in = 4'b1010; 
        #100000;               // Hold for 100us
        ext_gpio_in = 4'b0101; 
        
        // 2. Simulate an external device blasting UART data into the SoC's RX pin
        send_uart_byte(8'h58); // Send 'X'
        send_uart_byte(8'h59); // Send 'Y'
        send_uart_byte(8'h5A); // Send 'Z'

        // 3. Wait out the remainder of the 20ms test period
        // (The SPI and I2C sensors are reactive and test themselves whenever the CPU reaches that code)
        #19000000; 

        $display("\n--- Simulation Complete ---");
        $finish;
    end
endmodule