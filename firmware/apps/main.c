// --- UART Driver (0x20000000) ---
#define UART_BASE      0x20000000
#define UART_TX_DATA   (*((volatile unsigned int *)(UART_BASE + 0x00)))
#define UART_STATUS    (*((volatile unsigned int *)(UART_BASE + 0x04)))
#define UART_RX_DATA   (*((volatile unsigned int *)(UART_BASE + 0x08)))

void uart_putc(char c) {
    while (UART_STATUS & 0x01); // Wait while TX is busy (Bit 0)
    UART_TX_DATA = c;
}

char uart_getc() {
    // Wait until RX Valid flag goes high (Assuming Bit 1)
    while (!(UART_STATUS & 0x02)); 
    return UART_RX_DATA;
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

// --- GPIO Driver (0x30000000) ---
#define GPIO_BASE      0x30000000
#define GPIO_DIR       (*((volatile unsigned int *)(GPIO_BASE + 0x00)))
#define GPIO_OUT       (*((volatile unsigned int *)(GPIO_BASE + 0x04)))
#define GPIO_IN        (*((volatile unsigned int *)(GPIO_BASE + 0x08)))

void gpio_set_dir(unsigned char dir) {
    GPIO_DIR = dir; // 1 = Output, 0 = Input
}

void gpio_write(unsigned char val) {
    GPIO_OUT = val;
}

unsigned char gpio_read() {
    return GPIO_IN;
}

// --- SPI Driver (0x40000000) ---
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

// --- I2C Driver (0x50000000) ---
#define I2C_BASE       0x50000000
#define I2C_DATA       (*((volatile unsigned int *)(I2C_BASE + 0x00)))
#define I2C_CMD        (*((volatile unsigned int *)(I2C_BASE + 0x04)))
#define I2C_STATUS     (*((volatile unsigned int *)(I2C_BASE + 0x08)))

void i2c_wait() {
    while (I2C_STATUS & 0x01); 
}

void i2c_start() {
    I2C_CMD = 0x01;
    i2c_wait();
}

void i2c_stop() {
    I2C_CMD = 0x02;
    i2c_wait();
}

unsigned char i2c_write(unsigned char data) {
    I2C_DATA = data;
    I2C_CMD = 0x03;
    i2c_wait();
    return (I2C_STATUS >> 1) & 0x01; 
}

// --- Main Application ---
int main(void) {
    uart_puts("\n===========================\n");
    uart_puts("   SoC System Diagnostic   \n");
    uart_puts("===========================\n");

    // 1. Initial GPIO State
    uart_puts("1. Initializing GPIO...\n");
    gpio_set_dir(0x0F); 
    gpio_write(0x05);   
    uart_puts("   Initial GPIO State: ");
    uart_print_hex(gpio_read());
    uart_puts("\n");

    // 2. Test SPI
    uart_puts("2. Testing SPI Bus...\n");
    spi_set_cs(1); 
    spi_set_cs(0); 
    unsigned char spi_res = spi_transfer(0xFF); 
    spi_set_cs(1); 
    
    if (spi_res == 0xA5) {
        uart_puts("   SPI Master Test: PASSED\n");
    } else {
        uart_puts("   SPI Master Test: FAILED\n");
    }

    // 3. Test I2C
    uart_puts("3. Testing I2C Bus...\n");
    i2c_start();
    unsigned char ack = i2c_write(0x3C << 1); 
    i2c_stop();

    if (ack == 0) {
        uart_puts("   I2C Master Test: PASSED (ACK Received)\n");
    } else {
        uart_puts("   I2C Master Test: FAILED (NACK)\n");
    }

    // 4. Test Asynchronous Hardware Stimulus
    uart_puts("4. Waiting for Testbench Stimulus (500us)...\n");
    
    // The CPU will freeze here until the testbench sends the UART bytes
    char rx1 = uart_getc();
    char rx2 = uart_getc();
    char rx3 = uart_getc();

    uart_puts("   UART Received: ");
    uart_putc(rx1);
    uart_putc(rx2);
    uart_putc(rx3);
    uart_puts("\n");

    // Read the GPIO again to see the external button presses (4'b0101 injected)
    uart_puts("   New External GPIO State: ");
    uart_print_hex(gpio_read());
    uart_puts("\n");

    // Halt CPU
    uart_puts("===========================\n");
    uart_puts("All diagnostics complete. CPU Halted.\n");
    while(1);
    return 0;
}