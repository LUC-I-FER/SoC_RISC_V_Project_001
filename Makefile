# --- Firmware Build Settings ---
RV_GCC = riscv64-unknown-elf-gcc
RV_OBJCOPY = riscv64-unknown-elf-objcopy

RV_CFLAGS  = -march=rv32i -mabi=ilp32 -O0 -nostartfiles -nostdlib -T firmware/link.ld 

FW_SRC = firmware/apps/start.S firmware/apps/main.c
FW_ELF = firmware/apps/main.elf
FW_HEX = firmware/hex/boot.hex
FW_MEM = firmware/hex/boot.mem

# --- Simulation Build Settings ---
OUT_DIR = outputs/output_file
VCD_DIR = outputs/vcd_files
SIM_OUT = $(OUT_DIR)/sim.out

# Automatically find all Verilog files in the rtl/ directory
RTL_SRCS = $(shell find rtl -name '*.v')

# Other hardware source files
TB_SRC   = dv/tb_top/tb_main.v
CORE_SRC = third_party/picorv32/picorv32.v

# Group all sources for dependencies
ALL_SRCS = $(TB_SRC) $(RTL_SRCS) $(CORE_SRC)

.PHONY: all compile simulate waves clean firmware mem

all: simulate

# --- Simulation Targets ---
compile: $(SIM_OUT)

$(SIM_OUT): $(ALL_SRCS) $(FW_HEX)
	mkdir -p $(OUT_DIR) $(VCD_DIR)
	iverilog -g2012 -o $(SIM_OUT) $(ALL_SRCS)

simulate: compile
	vvp $(SIM_OUT)

waves:
	gtkwave $(VCD_DIR)/waveform.vcd &

clean:
	rm -rf outputs/ firmware/hex/ firmware/apps/*.elf vivado_workspace/ *.jou *.log

# --- Firmware Targets ---
firmware: $(FW_HEX) $(FW_MEM)

$(FW_ELF): $(FW_SRC)
	$(RV_GCC) $(RV_CFLAGS) -o $(FW_ELF) $(FW_SRC)

$(FW_HEX): $(FW_ELF)
	mkdir -p firmware/hex
	$(RV_OBJCOPY) -O verilog --verilog-data-width=4 $(FW_ELF) $(FW_HEX)
	riscv64-unknown-elf-objdump -d $(FW_ELF) > firmware/apps/main.dump

# Target for Vivado synthesis (.mem format)
$(FW_MEM): $(FW_HEX)
	cp $(FW_HEX) $(FW_MEM)