OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 4K /* Increased from previous size */
    RAM (rwx) : ORIGIN = 0x10000000, LENGTH = 4K
}

SECTIONS
{
    /* Code and read-only constants go into ROM */
    .text : {
        *(.text.start) /* Force boot assembly to be at address 0x0 */
        *(.text*)
        *(.rodata*)
    } > ROM

    /* Uninitialized variables go into RAM */
    .bss : {
        *(.bss*)
        *(COMMON)
    } > RAM

    /* Initialized variables go into RAM */
    .data : {
        *(.data*)
    } > RAM AT > ROM 
    
    /* Define the top of the stack at the very end of the 4KB RAM */
    PROVIDE(_stack_top = ORIGIN(RAM) + LENGTH(RAM));
}