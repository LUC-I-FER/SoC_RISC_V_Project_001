`timescale 1ns / 1ps

module tb_main;
    reg  clk;
    reg  resetn;
    
    wire tx;
    reg  rx;
    wire [7:0] gpio;
    
    wire sck;
    wire mosi;
    wire cs;
    wire miso;

    // NEW: I2C External Pins
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
        .sda    (sda),   // NEW
        .scl    (scl)    // NEW
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

    // --- NEW: Simulated I2C Sensor (Always ACKs) ---
    // Virtual Pull-up Resistors
    pullup(sda);
    pullup(scl);

    reg i2c_sda_drv = 1;
    integer i2c_bit_cnt = 0;
    
    // Drive the physical SDA wire (Open-Drain)
    assign sda = (i2c_sda_drv == 0) ? 1'b0 : 1'bz;

    // Detect START condition: SDA goes LOW while SCL is HIGH
    always @(negedge sda) begin
        if (scl === 1'b1) i2c_bit_cnt <= 0;
    end

    // Count 8 bits, then pull SDA low to send an ACK
    always @(negedge scl) begin
        if (i2c_bit_cnt == 8) begin
            i2c_sda_drv <= 1; // Release bus after ACK cycle
            i2c_bit_cnt <= 0; // Reset for next byte
        end else if (i2c_bit_cnt == 7) begin
            i2c_sda_drv <= 0; // Drive SDA LOW to send ACK
            i2c_bit_cnt <= 8;
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

        $display("--- Powering On SoC ---");
        #20;
        resetn = 1;
        $display("--- Reset Released. CPU Running ---");

        // Give the CPU 10 milliseconds to boot, run tests, and print UART
        #10000000; 

        $display("\n--- Simulation Complete ---");
        $finish;
    end
endmodule