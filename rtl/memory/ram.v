module ram #(
    parameter integer ADDR_WIDTH = 10
) (
    input  wire        clk,
    input  wire        valid,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire [ 3:0] wstrb,
    output reg         ready,
    output reg  [31:0] rdata
);

  reg [31:0] memory[0:(1<<ADDR_WIDTH)-1];

  // Convert byte address to word address
  // We drop the bottom 2 bits (addr[1:0]) because memory is 32-bit aligned
  wire [ADDR_WIDTH-1:0] word_addr = addr[ADDR_WIDTH+1:2];

  always @(posedge clk) begin
    if (valid && !ready) begin
      rdata <= memory[word_addr];

      if (wstrb[0]) memory[word_addr][ 7: 0] <= wdata[ 7: 0];
      if (wstrb[1]) memory[word_addr][15: 8] <= wdata[15: 8];
      if (wstrb[2]) memory[word_addr][23:16] <= wdata[23:16];
      if (wstrb[3]) memory[word_addr][31:24] <= wdata[31:24];

      ready <= 1'b1;
    end else begin
      ready <= 1'b0;
    end
  end

endmodule
