module soc_top (
    input  wire        clk,
    input  wire        resetn,
    output wire        tx,
    input  wire        rx,
    inout  wire [7:0]  gpio,
    output wire        sck,
    output wire        mosi,
    input  wire        miso,
    output wire        cs,
    // NEW: I2C External Pins
    inout  wire        sda,
    inout  wire        scl
);

    // --- Internal Wires ---
    wire        cpu_valid, cpu_ready;
    wire [31:0] cpu_addr, cpu_wdata, cpu_rdata;
    wire [ 3:0] cpu_wstrb;

    wire        rom_valid, rom_ready;
    wire [31:0] rom_rdata;

    wire        ram_valid, ram_ready;
    wire [31:0] ram_rdata;

    wire        uart_valid, uart_ready;
    wire [31:0] uart_rdata;

    wire        gpio_valid, gpio_ready;
    wire [31:0] gpio_rdata;

    wire        spi_valid, spi_ready;
    wire [31:0] spi_rdata;

    // NEW: I2C Slave Signals
    wire        i2c_valid, i2c_ready;
    wire [31:0] i2c_rdata;

    // --- Module Instantiations ---
    cpu_wrapper u_cpu (
        .clk(clk), .resetn(resetn), .mem_valid(cpu_valid), .mem_instr(),
        .mem_ready(cpu_ready), .mem_addr(cpu_addr), .mem_wdata(cpu_wdata),
        .mem_wstrb(cpu_wstrb), .mem_rdata(cpu_rdata)
    );

    bus u_bus (
        .cpu_valid(cpu_valid), .cpu_addr(cpu_addr), .cpu_wdata(cpu_wdata),
        .cpu_wstrb(cpu_wstrb), .cpu_ready(cpu_ready), .cpu_rdata(cpu_rdata),
        .rom_valid(rom_valid), .rom_ready(rom_ready), .rom_rdata(rom_rdata),
        .ram_valid(ram_valid), .ram_ready(ram_ready), .ram_rdata(ram_rdata),
        .uart_valid(uart_valid), .uart_ready(uart_ready), .uart_rdata(uart_rdata),
        .gpio_valid(gpio_valid), .gpio_ready(gpio_ready), .gpio_rdata(gpio_rdata),
        .spi_valid(spi_valid), .spi_ready(spi_ready), .spi_rdata(spi_rdata),
        .i2c_valid(i2c_valid), .i2c_ready(i2c_ready), .i2c_rdata(i2c_rdata) // NEW
    );

    boot_rom u_rom (
        .clk(clk), .valid(rom_valid), .addr(cpu_addr),
        .rdata(rom_rdata), .ready(rom_ready)
    );

    ram u_ram (
        .clk(clk), .valid(ram_valid), .addr(cpu_addr),
        .wdata(cpu_wdata), .wstrb(cpu_wstrb), .ready(ram_ready), .rdata(ram_rdata)
    );

    uart_top u_uart (
        .clk(clk), .resetn(resetn), .valid(uart_valid), .addr(cpu_addr),
        .wdata(cpu_wdata), .wstrb(cpu_wstrb), .ready(uart_ready),
        .rdata(uart_rdata), .tx(tx), .rx(rx)
    );

    gpio_top u_gpio (
        .clk(clk), .resetn(resetn), .valid(gpio_valid), .addr(cpu_addr),
        .wdata(cpu_wdata), .wstrb(cpu_wstrb), .ready(gpio_ready),
        .rdata(gpio_rdata), .gpio(gpio)
    );

    spi_top u_spi (
        .clk(clk), .resetn(resetn), .valid(spi_valid), .addr(cpu_addr),
        .wdata(cpu_wdata), .wstrb(cpu_wstrb), .ready(spi_ready),
        .rdata(spi_rdata), .sck(sck), .mosi(mosi), .miso(miso), .cs(cs)
    );

    // 8. I2C Peripheral
    i2c_top u_i2c (
        .clk    (clk),
        .resetn (resetn),
        .valid  (i2c_valid),
        .addr   (cpu_addr),
        .wdata  (cpu_wdata),
        .wstrb  (cpu_wstrb),
        .ready  (i2c_ready),
        .rdata  (i2c_rdata),
        .sda    (sda),
        .scl    (scl)
    );

endmodule