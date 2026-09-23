module i2c_top (
    input  wire        clk,
    input  wire        resetn,

    // Bus Slave Interface
    input  wire        valid,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire [ 3:0] wstrb,
    output reg         ready,
    output reg  [31:0] rdata,

    // Physical External Pins (Open-Drain)
    inout  wire        sda,
    inout  wire        scl
);

    localparam REG_DATA   = 8'h00; // Read/Write Data
    localparam REG_CMD    = 8'h04; // Write command to execute
    localparam REG_STATUS = 8'h08; // Read BUSY and ACK flags

    // Clock divider for 100kHz I2C on a 100MHz System Clock
    // 1000 cycles per bit -> 250 cycles per quarter-bit phase
    localparam DIV_TARGET = 250;

    reg [7:0] clk_div;
    reg [1:0] phase;
    reg [3:0] bit_count;
    
    // Internal tracking for the open-drain pins
    reg sda_out, scl_out;
    wire sda_in = (sda !== 1'b0); // Safely read the physical pin

    reg [7:0] tx_data;
    reg [7:0] rx_data;
    reg       ack_rx;
    reg       send_ack;
    reg       is_read;
    
    reg       busy;
    reg [2:0] state;
    
    localparam s_IDLE  = 3'd0;
    localparam s_START = 3'd1;
    localparam s_STOP  = 3'd2;
    localparam s_DATA  = 3'd3;
    localparam s_ACK   = 3'd4;

    // Open-Drain Pin Drivers (Drive 0, or release to Z)
    assign sda = sda_out ? 1'bz : 1'b0;
    assign scl = scl_out ? 1'bz : 1'b0;

    always @(posedge clk) begin
        if (!resetn) begin
            ready   <= 0;
            rdata   <= 0;
            sda_out <= 1; // Release bus
            scl_out <= 1; // Release bus
            busy    <= 0;
            state   <= s_IDLE;
            clk_div <= 0;
            phase   <= 0;
        end else begin
            // --- I2C State Machine (Hardware Layer) ---
            if (busy) begin
                if (clk_div == DIV_TARGET - 1) begin
                    clk_div <= 0;
                    phase <= phase + 1;
                    
                    case (state)
                        s_START: begin
                            if (phase == 0) begin sda_out <= 1; scl_out <= 1; end
                            if (phase == 1) begin sda_out <= 0; scl_out <= 1; end // Drop SDA first
                            if (phase == 2) begin sda_out <= 0; scl_out <= 1; end
                            if (phase == 3) begin sda_out <= 0; scl_out <= 0; busy <= 0; state <= s_IDLE; end
                        end
                        
                        s_STOP: begin
                            if (phase == 0) begin sda_out <= 0; scl_out <= 0; end
                            if (phase == 1) begin sda_out <= 0; scl_out <= 1; end // Raise SCL first
                            if (phase == 2) begin sda_out <= 1; scl_out <= 1; end // Then raise SDA
                            if (phase == 3) begin busy <= 0; state <= s_IDLE; end
                        end
                        
                        s_DATA: begin
                            if (phase == 0) begin 
                                scl_out <= 0; 
                                sda_out <= is_read ? 1'b1 : tx_data[7]; // Setup data or release for read
                            end
                            if (phase == 1) scl_out <= 1;
                            if (phase == 2) begin 
                                scl_out <= 1;
                                if (is_read) rx_data <= {rx_data[6:0], sda_in}; // Sample slave data
                            end
                            if (phase == 3) begin
                                scl_out <= 0;
                                if (!is_read) tx_data <= {tx_data[6:0], 1'b0};
                                if (bit_count == 7) begin
                                    state <= s_ACK;
                                    bit_count <= 0;
                                end else begin
                                    bit_count <= bit_count + 1;
                                end
                            end
                        end
                        
                        s_ACK: begin
                            if (phase == 0) begin
                                scl_out <= 0;
                                sda_out <= is_read ? send_ack : 1'b1; // Master sends ACK, or releases to hear Slave ACK
                            end
                            if (phase == 1) scl_out <= 1;
                            if (phase == 2) begin
                                scl_out <= 1;
                                if (!is_read) ack_rx <= sda_in; // Sample slave's ACK response
                            end
                            if (phase == 3) begin
                                scl_out <= 0;
                                sda_out <= 1'b1; // Release SDA
                                busy <= 0;
                                state <= s_IDLE;
                            end
                        end
                    endcase
                end else begin
                    clk_div <= clk_div + 1;
                end
            end

            // --- Bus Interface (Software Layer) ---
            if (valid && !ready) begin
                case (addr[7:0])
                    REG_DATA: begin
                        if (wstrb != 4'b0000) tx_data <= wdata[7:0];
                        rdata <= {24'b0, rx_data};
                    end
                    REG_CMD: begin
                        if (wstrb != 4'b0000) begin
                            busy <= 1;
                            clk_div <= 0;
                            phase <= 0;
                            bit_count <= 0;
                            if (wdata[7:0] == 8'h01) state <= s_START;
                            if (wdata[7:0] == 8'h02) state <= s_STOP;
                            if (wdata[7:0] == 8'h03) begin state <= s_DATA; is_read <= 0; end
                            if (wdata[7:0] == 8'h04) begin state <= s_DATA; is_read <= 1; send_ack <= 0; end // Send ACK
                            if (wdata[7:0] == 8'h05) begin state <= s_DATA; is_read <= 1; send_ack <= 1; end // Send NACK
                        end
                        rdata <= 0;
                    end
                    REG_STATUS: begin
                        // Bit 0 = Busy, Bit 1 = ACK received (0 means ACK, 1 means NACK)
                        rdata <= {30'b0, ack_rx, busy};
                    end
                    default: rdata <= 0;
                endcase
                ready <= 1;
            end else begin
                ready <= 0;
            end
        end
    end

endmodule