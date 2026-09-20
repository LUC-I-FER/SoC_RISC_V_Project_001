module uart_tx #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer BAUD_RATE = 115200
)(
    input wire       clk,
    input wire       reset_n,

    // control interface from the memory mapped registers
    input wire       tx_start,
    input wire [7:0] tx_data,

    // Status and physical pins
    output reg       tx_busy,
    output reg       tx
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // State machine states
    localparam s_IDLE  = 3'b000;
    localparam s_START = 3'b001;
    localparam s_DATA  = 3'b010;
    localparam s_STOP  = 3'b011;
    
    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  tx_data_reg;

    always @(posedge clk) begin
        if (!reset_n) begin
            state       <= s_IDLE;
            tx          <= 1'b1; // idle state of uart is HIGH
            tx_busy     <= 1'b0;
            clk_count   <= 0;
            bit_index   <= 0;
            tx_data_reg <= 0;
        end else begin
            case (state)

                s_IDLE:begin
                    tx        <= 1'b1;
                    clk_count <= 0;
                    bit_index <= 0;

                    if (tx_start) begin
                        tx_busy      <= 1'b1;
                        tx_data_reg  <= tx_data; // Latch data so CPU can change it safely
                        tx           <= 1'b0;
                        state        <= s_START;
                    end else begin
                        tx_busy <= 1'b0;
                    end
                end

                s_START: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        tx        <= tx_data_reg[0];
                        state     <= s_DATA;
                    end
                end

                s_DATA: begin
                   if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                   end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index  <= bit_index + 1;
                            tx         <= tx_data_reg[bit_index + 1];
                        end else begin
                            bit_index <= 0;
                            tx        <= 1'b1; // Drive the STOP bit that is HIGH
                            state     <= s_STOP;
                        end
                   end
                end

                s_STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        tx_busy   <= 1'b0; // Done, this tell the CPU it can send another
                        state     <= s_IDLE;
                    end
                end

                default: state <= s_IDLE;
            endcase
        end
    end

endmodule
