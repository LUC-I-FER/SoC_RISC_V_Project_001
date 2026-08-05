# FPGA-Based RISC-V System-on-Chip (SoC)

> A modular FPGA-based RISC-V System-on-Chip designed from the ground up using Verilog, featuring custom communication peripherals, a memory-mapped architecture, and bare-metal firmware support.

---

# Project Goal

The primary objective of this project is to design and implement a complete RISC-V based System-on-Chip (SoC) on a Xilinx Spartan-7 FPGA.

Unlike projects that only instantiate an existing processor, this project focuses on understanding and implementing the complete embedded system architecture around the processor.

The final system will be capable of running bare-metal C programs while communicating with external devices through industry-standard communication protocols.

---

# Long-Term Vision

The project aims to provide practical experience in

- Computer Architecture
- Digital System Design
- FPGA Design
- Embedded Systems
- Hardware/Software Co-design
- RTL Development
- Verification
- Memory-Mapped Architectures

This project is intended to simulate the development workflow used in semiconductor companies such as Qualcomm, AMD, Intel, NXP, Texas Instruments, Synopsys, and Cadence.

---

# Current Hardware Platform

## FPGA

- Xilinx Spartan-7
- Device: XC7S50CSGA324-2

## Development Software

- Vivado 2024.1

## HDL

- Verilog

---

# System Architecture

```
                    +----------------------+
                    |      RISC-V CPU      |
                    +----------+-----------+
                               |
                     Memory-Mapped Bus
                               |
        +-----------+----------+-----------+-----------+
        |           |          |           |           |
      Boot ROM     RAM       UART        SPI         I²C
        |                                   |
      GPIO                               Timer
                               |
                     Interrupt Controller
```

---

# CPU Strategy

Instead of immediately developing a custom RISC-V processor, the first version of the SoC will use the open-source PicoRV32 processor.

This allows development to focus on:

- System integration
- Peripheral design
- Memory architecture
- Bus design
- Firmware development

After completing the SoC, the PicoRV32 core can be replaced with a custom RISC-V implementation without changing the rest of the architecture.

This incremental approach enables continuous progress while keeping the project achievable.

---

# Why PicoRV32?

The following open-source RISC-V processors were evaluated:

| CPU | Language | Notes |
|------|----------|------|
| PicoRV32 | Verilog | Selected |
| Ibex | SystemVerilog | Industrial CPU |
| CV32E40P | SystemVerilog | OpenHW Core |
| VexRiscv | Scala | Highly configurable |

PicoRV32 was selected because:

- Pure Verilog
- Small resource utilization
- Excellent documentation
- Easy FPGA integration
- Large community support

Repository:

https://github.com/YosysHQ/picorv32

---

# Planned Features

## Processor

- RV32I Instruction Set
- Open-source PicoRV32 (Phase 1)
- Custom CPU (Phase 2)

---

## Memory

- Boot ROM
- Data RAM
- Memory-Mapped IO

---

## Communication Peripherals

### UART

- Configurable baud rate
- Interrupt support
- TX/RX FIFOs

### SPI

- Master mode
- Multiple SPI modes
- Configurable clock

### I²C

- Master mode
- ACK/NACK support
- START/STOP generation

---

## General Peripherals

- GPIO
- Timer
- PWM
- Interrupt Controller

---

# Memory Map (Planned)

| Address | Device |
|----------|--------|
| 0x00000000 | Boot ROM |
| 0x10000000 | RAM |
| 0x20000000 | UART |
| 0x20001000 | SPI |
| 0x20002000 | I²C |
| 0x20003000 | GPIO |
| 0x20004000 | Timer |

---

# Software

The SoC will execute bare-metal RISC-V applications written in C.

Example:

```c
#define UART_TX (*(volatile unsigned int*)0x20000000)

int main()
{
    UART_TX = 'H';
    UART_TX = 'i';

    while(1);
}
```

---

# Repository Structure

```
SoC_Project/
│
├── rtl/
│   ├── cpu/
│   ├── bus/
│   ├── memory/
│   ├── peripherals/
│   │     ├── uart/
│   │     ├── spi/
│   │     ├── i2c/
│   │     ├── gpio/
│   │     └── timer/
│   └── common/
│
├── constraints/
│
├── firmware/
│
├── simulation/
│
├── docs/
│
└── README.md
```

---

# Development Roadmap

## Phase 1

- Project setup
- Vivado configuration
- FPGA verification

---

## Phase 2

- Integrate PicoRV32
- Instruction ROM
- Data RAM

---

## Phase 3

Develop custom peripherals

- UART
- SPI
- I²C
- GPIO
- Timer

---

## Phase 4

Develop memory-mapped interconnect

- Address decoder
- Peripheral selection
- Bus arbitration (if required)

---

## Phase 5

Firmware

- Toolchain setup
- Hello World
- Peripheral drivers
- Bare-metal applications

---

## Phase 6

Custom RISC-V Processor

Replace PicoRV32 with a self-designed RV32I processor while maintaining compatibility with the existing SoC architecture.

---

# Research Summary

## Why not immediately build a CPU?

Developing a processor from scratch significantly increases project complexity.

A complete processor requires:

- Instruction Fetch
- Decoder
- Register File
- ALU
- Branch Logic
- Memory Interface
- Exception Handling
- Verification

This can take several months before any external hardware can be controlled.

Using PicoRV32 allows early development of the complete SoC while still leaving the processor as a future enhancement.

---

## Engineering Philosophy

This project emphasizes modular hardware design.

Each hardware block is designed as an independent reusable IP core.

Examples:

- UART IP
- SPI IP
- I²C IP
- Timer IP
- GPIO IP

These modules communicate through a common memory-mapped interface, enabling future processor replacement without redesigning the peripherals.

---

# Future Enhancements

- Five-stage pipeline CPU
- Interrupt pipeline
- Cache memory
- DMA Controller
- AXI/APB Bus
- RTOS Support
- External Flash
- SDRAM Controller
- Ethernet MAC
- USB Controller
- JTAG Debug
- Hardware Debug Unit

---

# Learning Outcomes

This project aims to strengthen knowledge in:

- Verilog RTL Design
- FPGA Development
- Computer Architecture
- Digital Logic Design
- Embedded Systems
- Memory-Mapped Architectures
- Hardware Verification
- Communication Protocols
- Bare-Metal Firmware Development
- Hardware/Software Co-design

---

# Disclaimer

The first version of this project uses the open-source PicoRV32 processor to accelerate SoC development.

The long-term objective is to replace the processor with a custom-designed RISC-V implementation while preserving the surrounding system architecture.
