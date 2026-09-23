module boot_rom(
    input  wire        clk,
    input  wire        valid,
    input  wire [31:0] addr,
    output reg  [31:0] rdata,
    output reg         ready
);

    reg [31:0] memory [1024];
    initial begin
        $readmemh("firmware/hex/boot.hex", memory);
    end

    always @(posedge clk) begin
        if (valid) begin
            // Change this from addr[9:2] to addr[11:2]
            rdata <= memory[addr[11:2]]; 
            ready <= 1'b1;
        end else begin
            ready <= 1'b0;
        end
    end

endmodule
