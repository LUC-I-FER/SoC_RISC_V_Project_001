module gpio_top (
    input  wire        clk,
    input  wire        resetn,

    // Bus Slave Interface
    input  wire        valid,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire [ 3:0] wstrb,
    output reg         ready,
    output reg  [31:0] rdata,

    // Physical External Pins (8-bit bidirectional port)
    inout  wire [7:0]  gpio
);

    // Register Map Offsets
    localparam REG_DIR = 8'h00;
    localparam REG_OUT = 8'h04;
    localparam REG_IN  = 8'h08;

    // Internal Hardware Registers
    reg [7:0] dir_reg;
    reg [7:0] out_reg;
    reg [7:0] in_sync; // Synchronizer for physical inputs

    // --- Tristate Buffer Logic ---
    // If dir_reg[i] is 1, drive the pin with out_reg[i]. 
    // If dir_reg[i] is 0, release the pin (1'bz) so external hardware can drive it.
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gpio_buffers
            assign gpio[i] = dir_reg[i] ? out_reg[i] : 1'bz;
        end
    endgenerate

    // --- Bus Transaction Logic ---
    always @(posedge clk) begin
        if (!resetn) begin
            ready   <= 1'b0;
            rdata   <= 32'b0;
            dir_reg <= 8'b0; // Default all pins to inputs (0) for safety
            out_reg <= 8'b0;
            in_sync <= 8'b0;
        end else begin
            // Continuously sample the physical pins into a flip-flop
            in_sync <= gpio; 

            if (valid && !ready) begin
                case (addr[7:0])
                    REG_DIR: begin
                        if (wstrb != 4'b0000) dir_reg <= wdata[7:0];
                        rdata <= {24'b0, dir_reg}; // Return current state on read
                    end

                    REG_OUT: begin
                        if (wstrb != 4'b0000) out_reg <= wdata[7:0];
                        rdata <= {24'b0, out_reg};
                    end

                    REG_IN: begin
                        // Read-only register: returns the actual pin voltages
                        rdata <= {24'b0, in_sync};
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