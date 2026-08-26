# Define variables for paths
OUT_DIR = outputs/output_file
VCD_DIR = outputs/vcd_files
SIM_OUT = $(OUT_DIR)/sim.out

# The default target that runs when you just type 'make'
all: simulate

# Compile the Verilog code
compile:
	mkdir -p $(OUT_DIR) $(VCD_DIR)
	iverilog -o $(SIM_OUT) tb_main.v

# Run the simulation
simulate: compile
	vvp $(SIM_OUT)

# View the waveforms in GTKWave
waves:
	gtkwave $(VCD_DIR)/waveform.vcd &

# Clean up generated files
clean:
	rm -rf outputs/
