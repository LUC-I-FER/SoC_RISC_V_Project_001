# --- build_vivado.tcl ---

# 1. Define Project Variables
set project_name "SoC_RISC_V_Project"
set project_dir "./vivado_workspace"
set target_part "xc7s50csga324-2"

# 2. Create Project (Overwrite if it already exists)
create_project -force $project_name $project_dir -part $target_part

# 3. Add Design Sources (Verilog Files)
puts "Importing RTL sources..."
add_files ./third_party/picorv32/picorv32.v
add_files [glob -nocomplain ./rtl/bus/*.v]
add_files [glob -nocomplain ./rtl/cpu_wrapper/*.v]
add_files [glob -nocomplain ./rtl/memory/*.v]
add_files [glob -nocomplain ./rtl/peripherals/*.v]
add_files [glob -nocomplain ./rtl/top/*.v]

# 4. Add Firmware Data
# This allows Vivado to bake the C code directly into the Boot ROM during synthesis
puts "Importing firmware hex file..."
add_files ./firmware/hex/boot.hex

# 5. Add Constraints File
puts "Importing constraints..."
add_files -fileset constrs_1 ./constraints/constraints.xdc

# 6. Set Top-Level Module
set_property top soc_top [current_fileset]
update_compile_order -fileset sources_1

# 7. Automate Build Pipeline (Optional)
# Uncomment the following lines to automatically synthesize and generate the bitstream
# puts "Launching Synthesis..."
# launch_runs synth_1 -jobs 4
# wait_on_run synth_1
# 
# puts "Launching Implementation and Bitstream Generation..."
# launch_runs impl_1 -to_step write_bitstream -jobs 4
# wait_on_run impl_1
# 
# puts "Build Complete. Bitstream generated."