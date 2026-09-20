module uart_rx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       resetn,
    input  wire       rx,           // Physical RX pin
    
    output reg        rx_valid,     // Pulses high for 1 clock when byte is received
    output reg  [7:0] rx_data       // The received byte
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    
    // Wait half a bit period to sample in the middle of the "eye"
    localparam CLKS_PER_HALF_BIT = CLKS_PER_BIT / 2;

    localparam s_IDLE  = 3'b000;
    localparam s_START = 3'b001;
    localparam s_DATA  = 3'b010;
    localparam s_STOP  = 3'b011;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  shift_reg;

    always @(posedge clk) begin
        if (!resetn) begin
            state     <= s_IDLE;
            rx_valid  <= 1'b0;
            rx_data   <= 8'b0;
            clk_count <= 0;
            bit_index <= 0;
            shift_reg <= 8'b0;
        end else begin
            // Default: valid is a 1-cycle pulse
            rx_valid <= 1'b0;

            case (state)
                s_IDLE: begin
                    clk_count <= 0;
                    bit_index <= 0;
                    // Start bit is detected when RX drops to 0
                    if (rx == 1'b0) begin
                        state <= s_START;
                    end
                end

                s_START: begin
                    // Wait until the middle of the start bit
                    if (clk_count == CLKS_PER_HALF_BIT) begin
                        clk_count <= 0;
                        // Verify it's still 0 (ignore noise glitches)
                        if (rx == 1'b0) begin
                            state <= s_DATA;
                        end else begin
                            state <= s_IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                s_DATA: begin
                    // Wait a full bit period to sample the middle of the next bit
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        shift_reg[bit_index] <= rx; // Sample the data bit
                        
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            state <= s_STOP;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                s_STOP: begin
                    // Wait a full bit period for the middle of the stop bit
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        rx_data  <= shift_reg;
                        rx_valid <= 1'b1; // Tell the wrapper a byte is ready
                        state    <= s_IDLE;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                default: state <= s_IDLE;
            endcase
        end
    end

endmodule