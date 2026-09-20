#define UART_BASE 0x20000000
#define UART_TX_DATA   (*((volatile unsigned int *)(UART_BASE + 0x00)))
#define UART_STATUS    (*((volatile unsigned int *)(UART_BASE + 0x04)))

void uart_putc(char c) {
    while (UART_STATUS & 0x01); // Wait until UART is ready to transmit
    UART_TX_DATA = c;           // Send character
}

void uart_puts(const char *s) {
    while (*s) {
        uart_putc(*s++);
    }
}

void main() {
    uart_puts("Hello, UART!\n");
    while(1);
}