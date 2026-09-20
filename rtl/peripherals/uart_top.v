module uart_top (
    input  wire        clk,
    input  wire        resetn,

    // Bus Slave Interface
    input  wire        valid,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire [ 3:0] wstrb,
    output reg         ready,
    output reg  [31:0] rdata,

    // Physical External Pins
    output wire        tx,
    input  wire        rx
);

    // --- TX Engine Signals ---
    reg        tx_start;
    reg  [7:0] tx_data_reg;
    wire       tx_busy;

    uart_tx #(
        .CLK_FREQ(100_000_000), .BAUD_RATE(115200)
    ) u_tx (
        .clk(clk), .resetn(resetn), .tx_start(tx_start), 
        .tx_data(tx_data_reg), .tx_busy(tx_busy), .tx(tx)
    );

    // --- RX Engine Signals ---
    wire       rx_valid_pulse;
    wire [7:0] rx_incoming_data;
    reg        rx_data_ready; // Stays 1 until CPU reads it
    reg  [7:0] rx_latched_data;

    uart_rx #(
        .CLK_FREQ(100_000_000), .BAUD_RATE(115200)
    ) u_rx (
        .clk(clk), .resetn(resetn), .rx(rx), 
        .rx_valid(rx_valid_pulse), .rx_data(rx_incoming_data)
    );

    // --- Register Map ---
    localparam REG_TX_DATA = 8'h00; // Write to send
    localparam REG_STATUS  = 8'h04; // Read: Bit 0 = TX Busy, Bit 1 = RX Ready
    localparam REG_RX_DATA = 8'h08; // Read to get received byte

    always @(posedge clk) begin
        if (!resetn) begin
            ready <= 1'b0;
            rdata <= 32'b0;
            tx_start <= 1'b0;
            tx_data_reg <= 8'b0;
            rx_data_ready <= 1'b0;
            rx_latched_data <= 8'b0;
        end else begin
            tx_start <= 1'b0; // Default

            // Latch incoming RX data asynchronously to bus transactions
            if (rx_valid_pulse) begin
                rx_latched_data <= rx_incoming_data;
                rx_data_ready   <= 1'b1;
            end

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
                        // Return both TX and RX status flags
                        rdata <= {30'b0, rx_data_ready, tx_busy};
                    end

                    REG_RX_DATA: begin
                        rdata <= {24'b0, rx_latched_data};
                        // Auto-clear the ready flag when the CPU reads the data
                        if (wstrb == 4'b0000) begin
                            rx_data_ready <= 1'b0; 
                        end
                    end

                    default: rdata <= 32'b0;
                endcase
                ready <= 1'b1;
            end else begin
                ready <= 1'b0;
            end
        end
    end

endmodule