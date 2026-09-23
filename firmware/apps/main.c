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
    SPI_CS = state;
}

unsigned char spi_transfer(unsigned char data) {
    SPI_DATA = data;
    while (SPI_STATUS & 0x01);
    return SPI_DATA;
}

// --- I2C Driver ---
#define I2C_BASE       0x50000000
#define I2C_DATA       (*((volatile unsigned int *)(I2C_BASE + 0x00)))
#define I2C_CMD        (*((volatile unsigned int *)(I2C_BASE + 0x04)))
#define I2C_STATUS     (*((volatile unsigned int *)(I2C_BASE + 0x08)))

void i2c_wait() {
    while (I2C_STATUS & 0x01); // Wait while Busy flag is set
}

void i2c_start() {
    I2C_CMD = 0x01;
    i2c_wait();
}

void i2c_stop() {
    I2C_CMD = 0x02;
    i2c_wait();
}

// Returns 0 if ACK received, 1 if NACK
unsigned char i2c_write(unsigned char data) {
    I2C_DATA = data;
    I2C_CMD = 0x03;
    i2c_wait();
    return (I2C_STATUS >> 1) & 0x01; 
}

// --- Main Application ---
int main(void) {
    uart_puts("SoC Booted!\n");

    // --- Test SPI ---
    spi_set_cs(1);
    spi_set_cs(0);
    unsigned char spi_res = spi_transfer(0xFF);
    spi_set_cs(1);
    
    if (spi_res == 0xA5) {
        uart_puts("SPI Master Test: PASSED\n");
    } else {
        uart_puts("SPI Master Test: FAILED\n");
    }

    // --- Test I2C ---
    uart_puts("Testing I2C Bus...\n");
    
    i2c_start();
    // Write to a hypothetical I2C device at address 0x3C (0x3C shifted left by 1 + 0 for write)
    unsigned char ack = i2c_write(0x3C << 1); 
    i2c_stop();

    if (ack == 0) {
        uart_puts("I2C Master Test: PASSED (ACK Received)\n");
    } else {
        uart_puts("I2C Master Test: FAILED (NACK)\n");
    }

    // Halt CPU
    uart_puts("All tests complete. CPU Halted.\n");
    while(1);
    return 0;
}