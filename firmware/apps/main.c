// Define memory-mapped peripheral addresses
#define UART_BASE      0x20000000
#define UART_TX_DATA   (*((volatile unsigned int *)(UART_BASE + 0x00)))
#define UART_STATUS    (*((volatile unsigned int *)(UART_BASE + 0x04)))
#define UART_RX_DATA   (*((volatile unsigned int *)(UART_BASE + 0x08)))

// Function to transmit a single character
void uart_putc(char c) {
    // Wait until TX is NOT busy (Bit 0)
    while (UART_STATUS & 0x01);
    UART_TX_DATA = c;
}

// Function to transmit a string
void uart_puts(const char *str) {
    while (*str) {
        uart_putc(*str++);
    }
}

// Function to receive a single character (Blocking)
char uart_getc(void) {
    // Wait until RX Data is READY (Bit 1 is 1)
    while (!(UART_STATUS & 0x02));
    
    // Reading the RX_DATA register automatically clears the ready flag in hardware
    return UART_RX_DATA;
}

int main(void) {
    // 1. Announce that the CPU is alive
    uart_puts("SoC Booted! Waiting for input...\n");

    // 2. Enter an infinite echo loop
    while(1) {
        char c = uart_getc(); // CPU halts here until the testbench sends a character
        uart_putc(c);         // Immediately send it back out to the TX pin
    }
    
    return 0;
}