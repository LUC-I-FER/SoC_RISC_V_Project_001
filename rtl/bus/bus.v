module bus (
    // CPU Master Interface
    input wire         cpu_valid,
    input wire [31:0]  cpu_addr,
    input wire [31:0]  cpu_wdata,
    input wire [ 3:0]  cpu_wstrb,
    output wire        cpu_ready,
    output wire [31:0] cpu_rdata,

    // ROM Slave Interface (Adress: 0x0000_0000 - 0x0FFF_FFFF)
    output wire        rom_valid,
    input wire         rom_ready,
    input wire [31:0]  rom_rdata,

    // RAM Slave Interface (Adress: 0x1000_0000 - 0x1FFF_FFFF)
    output wire        ram_valid,
    input wire         ram_ready,
    input wire [31:0]  ram_rdata

    // UART Slave Interface (Address: 0x2000_0000 to 0x2FFF_FFFF)
    output wire        uart_valid,
    input  wire        uart_ready,
    input  wire [31:0] uart_rdata
);

    // Address decoding | 4'h0 = 0x0... (ROM) | 4'h1 = 0x1... (RAM)
    wire sel_rom = (cpu_addr[31:28] == 4'h0);
    wire sel_ram = (cpu_addr[31:28] == 4'h1);
    wire sel_uart = (cpu_addr[31:28] == 4'h2);

    // Demultiplexing : Route the valid signal to the selected slave only
    assign rom_valid = cpu_valid & sel_rom;
    assign ram_valid = cpu_valid & sel_ram;
    assign uart_valid = cpu_valid & sel_uart;

    // Multiplexing : Route the ready and rdata signals from the selected slave to the CPU
    assign cpu_ready = (sel_rom & rom_ready) | (sel_ram & ram_ready) | (sel_uart & uart_ready);
    // Default to 0 for unmapped addresses
    assign cpu_rdata = sel_rom ? rom_rdata : sel_ram ? ram_rdata : sel_uart ? uart_rdata :32'h0000_0000;

endmodule
