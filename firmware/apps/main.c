// --- UART Driver ---
#define UART_BASE      0x20000000
#define UART_TX_DATA   (*((volatile unsigned int *)(UART_BASE + 0x00)))
#define UART_STATUS    (*((volatile unsigned int *)(UART_BASE + 0x04)))
#define UART_RX_DATA   (*((volatile unsigned int *)(UART_BASE + 0x08)))

void uart_putc(char c) {
    while (UART_STATUS & 0x01);
    UART_TX_DATA = c;
}

void uart_puts(const char *str) {
    while (*str) uart_putc(*str++);
}

// Helper to print hexadecimal numbers over UART
void uart_print_hex(unsigned char val) {
    const char hex_chars[] = "0123456789ABCDEF";
    uart_putc('0');
    uart_putc('x');
    uart_putc(hex_chars[(val >> 4) & 0x0F]);
    uart_putc(hex_chars[val & 0x0F]);
}

// --- SPI Driver ---
#define SPI_BASE       0x40000000
#define SPI_DATA       (*((volatile unsigned int *)(SPI_BASE + 0x00)))
#define SPI_CS         (*((volatile unsigned int *)(SPI_BASE + 0x04)))
#define SPI_STATUS     (*((volatile unsigned int *)(SPI_BASE + 0x08)))

void spi_set_cs(unsigned char state) {
    SPI_CS = state; // 0 = Active (Low), 1 = Inactive (High)
}

unsigned char spi_transfer(unsigned char data) {
    // 1. Write data to the TX register to start the hardware shift engine
    SPI_DATA = data;
    
    // 2. Wait until the hardware clears the busy flag (Bit 0)
    while (SPI_STATUS & 0x01);
    
    // 3. The transaction is complete. Return the byte captured from MISO
    return SPI_DATA;
}

// --- Main Application ---
int main(void) {
    uart_puts("SoC Booted! Testing SPI...\n");

    // 1. Initialize SPI bus (CS High / Sensor asleep)
    spi_set_cs(1);

    // 2. Wake up the sensor by pulling CS Low
    spi_set_cs(0);

    // 3. Send a dummy byte (0xFF) to clock the data out of the sensor
    unsigned char response = spi_transfer(0xFF);

    // 4. Release the sensor by pulling CS High
    spi_set_cs(1);

    // 5. Print the result
    uart_puts("SPI Sensor Response: ");
    uart_print_hex(response);
    uart_puts("\n");

    if (response == 0xA5) {
        uart_puts("SPI Master Test: PASSED\n");
    } else {
        uart_puts("SPI Master Test: FAILED\n");
    }

    // Halt CPU
    while(1);
    return 0;
}