module uart_top(
    input  wire         clk,
    input  wire         reset_n,

    // Bus slave interface 
    input  wire         valid,
    input  wire [31:0]  addr,
    input  wire [31:0]  wdata,
    input  wire [ 3:0]  wstrb,
    output reg          ready,
    output reg  [31:0]  rdata,

    // Physical External Pins
    output wire         tx
);

    // Internal wires connecting to the TX engine
    reg        tx_start;
    reg  [7:0] tx_data_reg;
    wire       tx_busy;

    uart_tx #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115200)
    ) u_tx (
        .clk      (clk),
        .resetn   (resetn),
        .tx_start (tx_start),
        .tx_data  (tx_data_reg),
        .tx_busy  (tx_busy),
        .tx       (tx)
    );

    localparam REG_TX_DATA = 8'h00; // Offset 0x00: Write character here to transmit
    localparam REG_STATUS  = 8'h04; // Offset 0x04: Read bit 0 to check if busy

    always @(posedge clk) begin
        if (!reset_n) begin
            ready       <= 1'b0;
            rdata       <= 32'b0;
            tx_start    <= 1'b0;
            tx_data_reg <= 8'b0;
        end else begin
            tx_data_reg <= 8'b0; // Default behavior: Do not trigger a transmission unless commanded
            if (valid && !ready) begin
                case (addr[7:0])

                    REG_TX_DATA: begin
                        if (wstrb != 4'b0000) begin
                            tx_data_reg <= wdata[7:0];
                            tx_start    <= 1'b1;
                        end
                        rdata <= 32'b0;
                    end

                    REG_STATUS: begin
                        rdata <= {31'b0, tx_busy};
                    end
                    
                    default : begin
                        rdata <= 32'b0;
                    end

                endcase
                ready <= 1'b1; // ACK BIT
            end else begin
                ready <= 1'b0;
            end
        end
    end

endmodule