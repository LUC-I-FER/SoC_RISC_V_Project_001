module spi_top (
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
    output reg         sck,
    output reg         mosi,
    input  wire        miso,
    output reg         cs
);

    localparam REG_DATA   = 8'h00;
    localparam REG_CS     = 8'h04;
    localparam REG_STATUS = 8'h08;

    // Clock divider for 1MHz SPI on a 100MHz System Clock
    // 100MHz / 1MHz = 100 cycles per SPI bit. (50 cycles HIGH, 50 cycles LOW)
    localparam DIV_TARGET = 50;

    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg [7:0] clk_div;
    reg       busy;
    reg       cpha; // Phase tracker (0 = Leading Edge, 1 = Trailing Edge)

    always @(posedge clk) begin
        if (!resetn) begin
            ready     <= 1'b0;
            rdata     <= 32'b0;
            sck       <= 1'b0; // Mode 0: Clock idles LOW
            mosi      <= 1'b0;
            cs        <= 1'b1; // CS is active LOW, so idle is HIGH
            busy      <= 1'b0;
            bit_count <= 4'b0;
            cpha      <= 1'b0;
            clk_div   <= 8'b0;
            shift_reg <= 8'b0;
        end else begin
            // --- SPI Shift Engine (Hardware Layer) ---
            if (busy) begin
                if (clk_div == DIV_TARGET - 1) begin
                    clk_div <= 0;
                    if (cpha == 0) begin
                        // Leading Edge (Rising): SCK goes HIGH, Sample MISO
                        sck <= 1'b1;
                        shift_reg <= {shift_reg[6:0], miso}; // Shift left, pull in MISO
                        cpha <= 1'b1;
                    end else begin
                        // Trailing Edge (Falling): SCK goes LOW, Setup next MOSI
                        sck <= 1'b0;
                        cpha <= 1'b0;
                        if (bit_count == 1) begin
                            busy <= 1'b0; // Transfer complete
                        end else begin
                            bit_count <= bit_count - 1;
                            mosi <= shift_reg[7]; // Expose next MSB
                        end
                    end
                end else begin
                    clk_div <= clk_div + 1;
                end
            end

            // --- Bus Interface (Software Layer) ---
            if (valid && !ready) begin
                case (addr[7:0])
                    REG_DATA: begin
                        if (wstrb != 4'b0000) begin
                            // CPU is writing: Start the hardware engine
                            shift_reg <= wdata[7:0];
                            mosi      <= wdata[7]; // Setup first bit immediately
                            bit_count <= 8;
                            busy      <= 1'b1;
                            sck       <= 1'b0;
                            cpha      <= 1'b0;
                            clk_div   <= 8'b0;
                        end
                        // CPU is reading: Return the last received byte
                        rdata <= {24'b0, shift_reg};
                    end

                    REG_CS: begin
                        if (wstrb != 4'b0000) cs <= wdata[0];
                        rdata <= {31'b0, cs};
                    end

                    REG_STATUS: begin
                        // Return busy flag so CPU knows when to send next byte
                        rdata <= {31'b0, busy};
                    end

                    default: rdata <= 32'b0;
                endcase
                ready <= 1'b1; // Acknowledge the bus transaction
            end else begin
                ready <= 1'b0;
            end
        end
    end

endmodule