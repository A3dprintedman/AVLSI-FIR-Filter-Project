`timescale 1ns/1ps

module fir_parallel_L2_tb;

    // Parameters
    parameter int TAPS = 102;      // Number of taps
    parameter int IO_WIDTH = 16;   // Bit width for fixed-point coefficients
    parameter int COEFF_WIDTH = 32;   // Bit width for fixed-point coefficients
    parameter int INPUT_SIZE = 10000;
    // Testbench signals
    logic clk;
    logic rst;
    logic signed [IO_WIDTH-1:0] din1, din2;
    logic signed [COEFF_WIDTH*2-1:0] dout1, dout2;
    logic signed [IO_WIDTH-1:0] sin [INPUT_SIZE-1:0];
    int address;

    // Instantiate the DUT
    fir_parallel_L2 uut (
        .clk(clk),
        .rst(rst),
        .din1(din1),
        .din2(din2),
        .dout1(dout1),
        .dout2(dout2)
    );

    // Test signal generation
    initial begin
        // Load mem
        $readmemb("input.data", sin);

        // Initialize signals
        clk = 0;
        rst = 1;
        address = 0;
        #22676 rst = 0; // Deassert reset after 20ns
    end

    assign din1 = sin[address];
    assign din2 = sin[address+1];

    always @(posedge clk) begin
        if (address < INPUT_SIZE) begin
            address += 2;
        end
    end

    // Clock generation: 41.4 KHz clock (22676ns period)
    always #11338 clk = ~clk;

endmodule