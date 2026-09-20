module tb_main;
    reg clk;
    reg resetn;

    // CPU Interface signals
    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;   // Changed from reg to wire
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [ 3:0] mem_wstrb;
    wire [31:0] mem_rdata;   // Changed from reg to wire

    // Instantiate the CPU Wrapper
    cpu_wrapper u_cpu_wrapper (
        .clk       (clk),
        .resetn    (resetn),
        .mem_valid (mem_valid),
        .mem_instr (mem_instr),
        .mem_ready (mem_ready),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (mem_rdata)
    );

    // 1. Generate Clock
    always #5 clk = ~clk;

    // 2. Boot ROM Instantiation
    boot_rom u_rom (
        .clk   (clk),
        .valid (mem_valid),
        .addr  (mem_addr),
        .rdata (mem_rdata),
        .ready (mem_ready)
    );

    // 3. Main Simulation Block
    initial begin
        $dumpfile("outputs/vcd_files/waveform.vcd");
        $dumpvars(0, tb_main);

        // Initialize clock and reset
        clk = 0;
        resetn = 0;

        $display("--- Asserting Reset ---");
        #20;
        resetn = 1;
        $display("--- Reset Released. CPU Running ---");

        // Let the CPU fetch instructions from the ROM
        #200;

        $display("--- Simulation Complete ---");
        $finish;
    end
endmodule
