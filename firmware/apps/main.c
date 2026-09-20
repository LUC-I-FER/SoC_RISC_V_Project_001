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

char uart_getc(void) {
    while (!(UART_STATUS & 0x02));
    return UART_RX_DATA;
}

// --- GPIO Driver ---
#define GPIO_BASE 0x30000000
#define GPIO_DIR  (*((volatile unsigned int *)(GPIO_BASE + 0x00)))
#define GPIO_OUT  (*((volatile unsigned int *)(GPIO_BASE + 0x04)))
#define GPIO_IN   (*((volatile unsigned int *)(GPIO_BASE + 0x08)))

void gpio_set_dir(unsigned char dir) {
    GPIO_DIR = dir;
}

void gpio_write(unsigned char data) {
    GPIO_OUT = data;
}

unsigned char gpio_read(void) {
    return GPIO_IN;
}

// --- Main Application ---
int main(void) {
    uart_puts("SoC Booted! Testing GPIO...\n");

    // 1. Set pins 0-3 as Outputs, and pins 4-7 as Inputs
    // Binary: 0000_1111 = 0x0F
    gpio_set_dir(0x0F); 
    
    // 2. Drive pins 0 and 2 HIGH (Binary: 0000_0101 = 0x05)
    gpio_write(0x05);
    uart_puts("GPIO LEDs set to 0x05. Waiting for UART input...\n");

    while(1) {
        // 3. Halt the CPU until the testbench sends a character
        char c = uart_getc(); 
        
        // 4. Echo the character back over TX
        uart_putc(c);         
        
        // 5. Change the GPIO pattern to prove we received it
        // Drive pins 1 and 3 HIGH (Binary: 0000_1010 = 0x0A)
        gpio_write(0x0A);
    }
    
    return 0;
}