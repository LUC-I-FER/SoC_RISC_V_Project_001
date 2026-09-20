# Define variables for output paths
OUT_DIR = outputs/output_file
VCD_DIR = outputs/vcd_files
SIM_OUT = $(OUT_DIR)/sim.out

# Define variables for source paths
TB_SRC = dv/tb_top/tb_main.v
CPU_WRAPPER = rtl/cpu_wrapper/cpu_wrapper.v  # Uncomment this once created
CORE_SRC = third_party/picorv32/picorv32.v
MEMORY_SRC = rtl/memory/boot_rom.v

# The default target
all: simulate

# Compile the Verilog code
compile:
	mkdir -p $(OUT_DIR) $(VCD_DIR)
	iverilog -o $(SIM_OUT) $(TB_SRC) $(CPU_WRAPPER) $(MEMORY_SRC) $(CORE_SRC) 

# Run the simulation
simulate: compile
	vvp $(SIM_OUT)

# View the waveforms
waves:
	gtkwave $(VCD_DIR)/waveform.vcd &

# Clean up generated files
clean:
	rm -rf outputs/