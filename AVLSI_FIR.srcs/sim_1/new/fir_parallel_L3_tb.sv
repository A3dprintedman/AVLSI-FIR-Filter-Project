
`timescale 1ns/1ps

module fir_parallel_L3_tb;

    // Parameters
    parameter int TAPS = 102;      // Number of taps
    parameter int IO_WIDTH = 16;   // Bit width for fixed-point coefficients
    parameter int COEFF_WIDTH = 32;   // Bit width for fixed-point coefficients
    parameter int INPUT_SIZE = 10000;
    // Testbench signals
    logic clk;
    logic rst;
    logic signed [IO_WIDTH-1:0] din1, din2, din3;
    logic signed [COEFF_WIDTH*2-1:0] dout1, dout2, dout3;
    logic signed [IO_WIDTH-1:0] sin [INPUT_SIZE-1:0];
    int address;

    // Instantiate the DUT
    fir_parallel_L3 uut (
        .clk(clk),
        .rst(rst),
        .din1(din1),
        .din2(din2),
        .din3(din3),
        .dout1(dout1),
        .dout2(dout2),
        .dout3(dout3)
    );

    // Test signal generation
    initial begin
        // Load mem
        $readmemb("input.data", sin);

        // Initialize signals
        clk = 0;
        rst = 1;
        address = 0;
        #22676 rst = 0;
    end

    assign din1 = sin[address];
    assign din2 = sin[address+1];
    assign din3 = sin[address+2];

    always @(posedge clk) begin
        if (address < INPUT_SIZE) begin
            address += 3;
        end
    end

    // Clock generation: 47 KHz clock (21276ns period)
    always #11338 clk = ~clk;

endmodule
