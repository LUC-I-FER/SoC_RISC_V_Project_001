module cpu_wrapper(
    input  wire clk,
    input  wire resetn,

    output wire mem_valid,
    output wire mem_instr,
    input  wire mem_ready,
    output wire [31:0] mem_addr,
    output wire [31:0] mem_wdata,
    output wire [ 3:0] mem_wstrb,
    input  wire [31:0] mem_rdata
);

    picorv32 #(
        .ENABLE_COUNTERS(1),
        .ENABLE_REGS_16_31(1),
        .ENABLE_REGS_DUALPORT(1),
        .BARREL_SHIFTER(1),
        .TWO_STAGE_SHIFT(0),
        .CATCH_MISALIGN(1),
        .CATCH_ILLINSN(1)
    ) cpu(
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

endmodule
