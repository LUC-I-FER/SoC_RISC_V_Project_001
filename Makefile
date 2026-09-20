# --- Firmware Build Settings ---
RV_GCC = riscv64-unknown-elf-gcc
RV_OBJCOPY = riscv64-unknown-elf-objcopy

# -march=rv32i: 32-bit RISC-V integer instruction set
# -nostartfiles -nostdlib: No standard C library or default startup code
# -Ttext=0x00000000: Link the code to start at memory address 0x0
RV_CFLAGS  = -march=rv32i -mabi=ilp32 -O0 -nostartfiles -nostdlib -Ttext=0x00000000

FW_SRC = firmware/apps/main.c
FW_ELF = firmware/apps/main.elf
FW_HEX = firmware/hex/boot.hex

# --- Simulation Build Settings ---
OUT_DIR = outputs/output_file
VCD_DIR = outputs/vcd_files
SIM_OUT = $(OUT_DIR)/sim.out

TB_SRC = dv/tb_top/tb_main.v
CPU_WRAPPER = rtl/cpu_wrapper/cpu_wrapper.v
CORE_SRC = third_party/picorv32/picorv32.v
MEMORY_SRC = rtl/memory/boot_rom.v

# Group all sources for dependencies
ALL_SRCS = $(TB_SRC) $(CPU_WRAPPER) $(MEMORY_SRC) $(CORE_SRC)

# Tell Make these aren't real files
.PHONY: all compile simulate waves clean firmware

# The default target
all: simulate

# --- Simulation Targets ---
compile: $(SIM_OUT)

# Only recompile if a source file or the firmware hex has changed
$(SIM_OUT): $(ALL_SRCS) $(FW_HEX)
	mkdir -p $(OUT_DIR) $(VCD_DIR)
	iverilog -o $(SIM_OUT) $(ALL_SRCS)

simulate: compile
	vvp $(SIM_OUT)

waves:
	gtkwave $(VCD_DIR)/waveform.vcd &

clean:
	rm -rf outputs/ firmware/hex/ firmware/apps/*.elf

# --- Firmware Targets ---
firmware: $(FW_HEX)

$(FW_ELF): $(FW_SRC)
	$(RV_GCC) $(RV_CFLAGS) -o $(FW_ELF) $(FW_SRC)

$(FW_HEX): $(FW_ELF)
	mkdir -p firmware/hex
	$(RV_OBJCOPY) -O verilog --verilog-data-width=4 $(FW_ELF) $(FW_HEX)