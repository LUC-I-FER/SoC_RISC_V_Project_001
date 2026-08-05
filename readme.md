# FPGA-Based RISC-V System-on-Chip (SoC)

> A modular FPGA-based RISC-V System-on-Chip implemented on a Xilinx Spartan-7 FPGA using Verilog. The project focuses on designing a complete embedded platform around a RISC-V processor, including memory, custom peripherals, a memory-mapped interconnect, and bare-metal firmware.

---

# Project Goal

The objective of this project is to design and implement a modular RISC-V based System-on-Chip (SoC) capable of executing bare-metal applications while interfacing with external hardware through industry-standard communication peripherals.

Rather than focusing only on processor implementation, this project emphasizes complete SoC design, including:

- Processor integration
- Memory subsystem
- Bus architecture
- Peripheral design
- Hardware/software co-design
- Verification
- FPGA implementation

---

# Long-Term Vision

This project is intended to simulate the workflow used by semiconductor companies such as Qualcomm, AMD, Intel, NXP, Texas Instruments, Synopsys, and Cadence.

The project aims to strengthen practical experience in:

- RTL Design
- FPGA Design
- Computer Architecture
- Embedded Systems
- SoC Integration
- Memory-Mapped Architectures
- Verification
- Bare-Metal Firmware Development

---

# Development Platform

## FPGA

- Xilinx Spartan-7
- Device: XC7S50CSGA324-2

## Development Environment

- Vivado 2024.1

## HDL

- Verilog

---

# System Architecture

```
                     +----------------------+
                     |     RISC-V CPU       |
                     |     (PicoRV32)       |
                     +----------+-----------+
                                |
                          CPU Wrapper
                                |
                    Memory-Mapped Interconnect
                                |
      +-----------+-------------+-------------+-------------+
      |           |             |             |             |
   Boot ROM      RAM          UART          SPI           I²C
      |                                          |
     GPIO                                      Timer
                                |
                     Interrupt Controller
```

---

# Development Strategy

The project is divided into two major phases.

## Phase 1

Develop a complete working SoC using the open-source PicoRV32 processor.

The focus is on:

- Memory subsystem
- Address decoder
- Bus architecture
- Peripheral development
- Firmware
- FPGA implementation

## Phase 2

Replace PicoRV32 with a custom-designed RV32I processor while preserving the surrounding SoC architecture.

This allows the custom processor to immediately reuse all existing peripherals without redesigning the entire system.

---

# Why PicoRV32?

Several open-source RISC-V processors were evaluated.

| Processor | HDL | Purpose |
|------------|-----|---------|
| PicoRV32 | Verilog | Selected |
| Ibex | SystemVerilog | Industrial Core |
| CV32E40P | SystemVerilog | OpenHW Core |
| VexRiscv | Scala | FPGA Optimized |

PicoRV32 was selected because:

- Pure Verilog implementation
- Lightweight design
- Excellent documentation
- Easy FPGA integration
- Well-tested open-source project
- Allows focusing on SoC development before CPU development

Repository:

https://github.com/YosysHQ/picorv32

---

# Third-Party Components

The project separates external IP from custom RTL.

```
third_party/
    picorv32/
```

The PicoRV32 source code will remain unmodified.

A custom CPU wrapper will interface the processor with the rest of the SoC.

This separation allows future replacement of PicoRV32 with a custom processor without modifying the remaining architecture.

---

# Planned Features

## Processor

- RV32I ISA
- PicoRV32 Integration (Phase 1)
- Custom RV32I Processor (Phase 2)

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

- Master Mode
- Multiple SPI Modes
- Configurable Clock Divider

### I²C

- Master Mode
- START / STOP generation
- ACK / NACK support

---

## General Peripherals

- GPIO
- Timer
- PWM
- Interrupt Controller

---

# Planned Memory Map

| Address | Peripheral |
|----------|------------|
| 0x00000000 | Boot ROM |
| 0x10000000 | RAM |
| 0x20000000 | UART |
| 0x20001000 | SPI |
| 0x20002000 | I²C |
| 0x20003000 | GPIO |
| 0x20004000 | Timer |

---

# Repository Structure

```
SoC_Project_001/

├── rtl/
│   ├── top/
│   ├── cpu/
│   ├── bus/
│   ├── memory/
│   ├── peripherals/
│   ├── interrupt/
│   └── common/
│
├── third_party/
│   └── picorv32/
│
├── constraints/
│
├── firmware/
│
├── simulation/
│
├── docs/
│
├── scripts/
│
├── README.md
│
└── .gitignore
```

---

# Development Roadmap

## Milestone 1

Project Setup

- Repository structure
- Vivado project
- Documentation
- PicoRV32 integration

---

## Milestone 2

Memory Subsystem

- Boot ROM
- RAM
- Memory Controller

---

## Milestone 3

Bus Architecture

- Address Decoder
- Memory-Mapped Interconnect
- Peripheral Selection

---

## Milestone 4

Peripheral Development

- UART
- SPI
- I²C
- GPIO
- Timer

---

## Milestone 5

Firmware

- RISC-V GCC Toolchain
- Bare-Metal Runtime
- Peripheral Drivers
- Hello World
- Peripheral Demonstrations

---

## Milestone 6

Custom RV32I Processor

Replace PicoRV32 while maintaining compatibility with the existing SoC.

---

# Verification Strategy

Every RTL module will include dedicated simulations before integration.

Examples:

- UART Testbench
- SPI Testbench
- I²C Testbench
- RAM Testbench
- ROM Testbench
- Complete SoC Testbench

Simulation will be performed before FPGA implementation.

---

# Engineering Philosophy

The project follows a modular IP-based design methodology.

Each subsystem is developed independently.

Examples:

- UART IP
- SPI IP
- I²C IP
- Timer IP
- GPIO IP

Each IP communicates using a common memory-mapped interface, making the architecture reusable and scalable.

---

# Future Enhancements

- Custom 5-stage RV32I Pipeline
- Hazard Detection
- Forwarding Unit
- CSR Support
- Interrupt Pipeline
- Cache Memory
- DMA Controller
- AXI/APB Bus
- RTOS Support
- External Flash
- SDRAM Controller
- Ethernet MAC
- USB Controller
- JTAG Debug Interface
- Performance Counters

---

# Learning Objectives

Through this project, the following topics will be explored:

- Verilog RTL Design
- FPGA Development
- Computer Architecture
- SoC Design
- Memory-Mapped Architectures
- Communication Protocols
- Hardware Verification
- Embedded Firmware Development
- Hardware/Software Co-design

---

# Project Status

Current Stage:

- Repository initialized
- Project architecture defined
- Vivado environment configured
- Folder hierarchy established
- Evaluation of RISC-V cores completed
- PicoRV32 selected as Phase 1 processor

Next Milestone:

- Integrate PicoRV32 using a custom CPU wrapper
- Design Boot ROM
- Implement the memory subsystem

---

# License

The custom RTL, documentation, and firmware in this repository are developed as part of this project.

The PicoRV32 processor remains the property of its original authors and is included under its respective open-source license.
