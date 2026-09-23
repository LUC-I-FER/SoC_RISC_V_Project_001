# FPGA-Based RISC-V System-on-Chip (SoC)

> A modular FPGA-based RISC-V System-on-Chip implemented on a Xilinx Spartan-7 FPGA using Verilog. The project focuses on designing a complete embedded platform around a RISC-V processor, including memory, custom peripherals, a memory-mapped interconnect, and bare-metal firmware.

---

## Project Goal

The objective of this project is to design and implement a modular RISC-V based System-on-Chip (SoC) capable of executing bare-metal applications while interfacing with external hardware through industry-standard communication peripherals.

Rather than focusing only on processor implementation, this project emphasizes complete SoC design, including:

* Processor integration
* Memory subsystem
* Bus architecture
* Peripheral design
* Hardware/software co-design
* Verification
* FPGA implementation

---

## Long-Term Vision

This project is intended to simulate the workflow used by semiconductor companies such as Qualcomm, AMD, Intel, NXP, Texas Instruments, Synopsys, and Cadence.

The project aims to strengthen practical experience in:

* RTL Design
* FPGA Design
* Computer Architecture
* Embedded Systems
* SoC Integration
* Memory-Mapped Architectures
* Verification
* Bare-Metal Firmware Development

---

## Development Platform

**FPGA**

* Xilinx Spartan-7
* Device: XC7S50CSGA324-2

**Development Environment**

* Vivado 2024.1
* Icarus Verilog & GTKWave (Simulation/Verification)
* RISC-V GCC Toolchain (Bare-Metal Firmware)

**HDL**

* Verilog-2012

---

## System Architecture

```text
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
    (4KB)         |             |             |             |
                 GPIO         Timer*         PWM*      Interrupt*
                                |                       Controller*

```

*(Items marked with * are currently in active development or planned for immediate next steps)*

---

## Development Strategy

The project is divided into two major phases.

### Phase 1 (Current)

Develop a complete working SoC using the open-source PicoRV32 processor.
The focus is on:

* Memory subsystem
* Address decoder
* Bus architecture
* Peripheral development
* Firmware
* FPGA implementation

### Phase 2 (Future)

Replace PicoRV32 with a custom-designed RV32I processor while preserving the surrounding SoC architecture. This allows the custom processor to immediately reuse all existing peripherals without redesigning the entire system.

---

## Why PicoRV32?

Several open-source RISC-V processors were evaluated. PicoRV32 was selected because it is a lightweight, pure Verilog implementation with excellent documentation. It allows for rapid SoC and bus architecture development before shifting focus to custom CPU pipelining.

Repository: [https://github.com/YosysHQ/picorv32](https://github.com/YosysHQ/picorv32?utm_source=gemini)

---

## Third-Party Components

The project separates external IP from custom RTL.

```text
third_party/
    picorv32/

```

The PicoRV32 source code remains unmodified. A custom CPU wrapper interfaces the processor with the rest of the SoC memory-mapped interconnect.

---

## Features & Implementation Status

### Processor

* [x] RV32I ISA (via PicoRV32 Integration)
* [ ] Custom RV32I Processor (Phase 2)

### Memory

* [x] Boot ROM (Recently expanded to 4KB)
* [x] Data RAM
* [x] Memory-Mapped IO via custom interconnect

### Communication Peripherals

* [x] **UART:** Configurable baud rate, TX/RX verification complete.
* [x] **SPI:** Full-duplex Master Mode, Mode 0 implemented and verified with dummy sensors.
* [x] **I²C:** Open-drain Master Mode, 4-phase state machine, START/STOP/ACK generation verified.

### General Peripherals

* [x] GPIO (Input/Output directional control)
* [ ] Hardware Timer (SysTick)
* [ ] PWM Controller
* [ ] Interrupt Controller

---

## Active Memory Map

| Base Address | Peripheral | Status |
| --- | --- | --- |
| `0x00000000` | Boot ROM (4KB) | Active |
| `0x10000000` | RAM | Active |
| `0x20000000` | UART | Active |
| `0x30000000` | GPIO | Active |
| `0x40000000` | SPI Master | Active |
| `0x50000000` | I²C Master | Active |

---

## Repository Structure

```text
SoC_Project_001/
├── rtl/
│   ├── top/         (soc_top.v)
│   ├── cpu_wrapper/
│   ├── bus/         (Memory-mapped interconnect)
│   ├── memory/      (4KB ROM, RAM)
│   └── peripherals/ (gpio, uart, spi, i2c)
├── third_party/
│   └── picorv32/
├── dv/
│   └── tb_top/      (Simulation environment, dummy sensors, UART monitor)
├── firmware/
│   ├── apps/        (main.c, start.S)
│   ├── hex/         (Compiled boot.hex)
│   └── link.ld      (Custom linker script)
├── outputs/
│   └── vcd_files/   (GTKWave waveforms)
├── constraints/
├── scripts/
├── Makefile         (Automated firmware compilation and RTL simulation)
└── README.md

```

---

## Development Roadmap

### [x] Milestone 1: Project Setup

* Repository structure, Vivado project, PicoRV32 integration.

### [x] Milestone 2: Memory Subsystem

* Boot ROM, RAM, Memory Controller. *(Note: ROM expanded to 4KB to support growing bare-metal drivers).*

### [x] Milestone 3: Bus Architecture

* Coarse-grained Address Decoder, Memory-Mapped Interconnect, Peripheral Selection.

### [ ] Milestone 4: Peripheral Development

* [x] UART
* [x] GPIO
* [x] SPI Master
* [x] I²C Master
* [ ] Hardware Timer (SysTick) - *Next Target*
* [ ] PWM Controller - *Next Target*

### [ ] Milestone 5: Firmware & Drivers

* [x] RISC-V GCC Toolchain Integration
* [x] Bare-Metal Runtime (`start.S` & `link.ld`)
* [x] C Drivers (UART, GPIO, SPI, I²C)
* [ ] Hardware Interrupt Handling

### [ ] Milestone 6: Custom RV32I Processor

* Replace PicoRV32 while maintaining compatibility with the existing SoC.

---

## Verification Strategy

Verification is handled via `iverilog` and `vvp`, with waveform analysis in GTKWave. The central testbench (`tb_main.v`) currently features:

* A UART monitor that decodes the `tx` wire and prints bare-metal execution logs directly to the host terminal.
* Simulated external sensors providing realistic hardware feedback (e.g., virtual pull-up resistors for I²C, `0xA5` response generation for SPI Mode 0).

---

## Project Status

**Current Stage:**
The core SoC foundation is complete and thoroughly verified. The custom memory-mapped bus successfully routes instructions and data between the PicoRV32 core, the newly expanded 4KB Boot ROM, and multiple peripherals. Custom bare-metal C drivers have been written and simulated for GPIO, UART, SPI, and I²C. The testbench environment successfully simulates physical bus constraints (like I²C open-drain pull-ups) to validate hardware-level protocol adherence.

**Immediate Next Steps:**

1. Design and integrate a Hardware Timer (SysTick) peripheral to eliminate the need for software-blocking `while` loops during precise delays.
2. Develop a hardware PWM controller for motor and servo actuation.
3. Introduce interrupt generation and routing from peripherals to the CPU.