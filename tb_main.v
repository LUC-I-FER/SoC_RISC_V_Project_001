module tb_main;
    reg clk;
    reg [3:0] counter;

    // 1. Generate a clock (toggles every 5 time units)
    always #5 clk = ~clk;

    // 2. Simple counter logic
    always @(posedge clk) begin
        counter <= counter + 1;
        $display("Time: %0t | Counter: %d", $time, counter);
    end

    // 3. Main simulation block
    initial begin
        // Tell simulator to create a waveform file
        $dumpfile("outputs/vcd_files/waveform.vcd");
        $dumpvars(0, tb_main);

        // Initialize signals
        clk = 0;
        counter = 0;

        $display("--- Simulation Started ---");

        // Let the simulation run for 50 time units
        #50;

        $display("--- Simulation Complete ---");
        $finish; // End simulation
    end
endmodule
