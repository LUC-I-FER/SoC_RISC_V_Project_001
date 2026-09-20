module bus (
    // CPU Master Interface
    input  wire        cpu_valid,
    input  wire [31:0] cpu_addr,
    input  wire [31:0] cpu_wdata,
    input  wire [ 3:0] cpu_wstrb,
    output wire        cpu_ready,
    output wire [31:0] cpu_rdata,

    // ROM Slave Interface (Address: 0x0000_0000 to 0x0FFF_FFFF)
    output wire        rom_valid,
    input  wire        rom_ready,
    input  wire [31:0] rom_rdata,

    // RAM Slave Interface (Address: 0x1000_0000 to 0x1FFF_FFFF)
    output wire        ram_valid,
    input  wire        ram_ready,
    input  wire [31:0] ram_rdata,

    // UART Slave Interface (Address: 0x2000_0000 to 0x2FFF_FFFF)
    output wire        uart_valid,
    input  wire        uart_ready,
    input  wire [31:0] uart_rdata,

    // GPIO Slave Interface (Address: 0x3000_0000 to 0x3FFF_FFFF)
    output wire        gpio_valid,
    input  wire        gpio_ready,
    input  wire [31:0] gpio_rdata
);

    // 1. Address Decoder (Identify target based on top 4 bits)
    wire sel_rom  = (cpu_addr[31:28] == 4'h0);
    wire sel_ram  = (cpu_addr[31:28] == 4'h1);
    wire sel_uart = (cpu_addr[31:28] == 4'h2);
    wire sel_gpio = (cpu_addr[31:28] == 4'h3);

    // 2. Demultiplexing: Route valid signal to the selected slave
    assign rom_valid  = cpu_valid & sel_rom;
    assign ram_valid  = cpu_valid & sel_ram;
    assign uart_valid = cpu_valid & sel_uart;
    assign gpio_valid = cpu_valid & sel_gpio;

    // 3. Multiplexing: Route ready signal from the active slave back to CPU
    assign cpu_ready = (sel_rom  & rom_ready) | 
                       (sel_ram  & ram_ready) |
                       (sel_uart & uart_ready)|
                       (sel_gpio & gpio_ready);

    // 4. Multiplexing: Route read data from the active slave back to CPU
    assign cpu_rdata = sel_rom  ? rom_rdata :
                       sel_ram  ? ram_rdata :
                       sel_uart ? uart_rdata :
                       sel_gpio ? gpio_rdata :
                       32'h0000_0000; // Default to 0 for unmapped addresses

endmodule