module top_fir_pipe_L3 (
    input logic clk,               // Clock signal
    input logic rst,               // Reset signal
    input logic signed [15:0] din0, // Input sample
    input logic signed [15:0] din1, // Input sample
    input logic signed [15:0] din2, // Input sample
    output logic signed [63:0] dout0, // Filtered output
    output logic signed [63:0] dout1, // Filtered output
    output logic signed [63:0] dout2 // Filtered output
);
    fir_pipelined_L3 F0 (
        .clk(clk),
        .rst(rst),
        .din(din0),
        .dout(dout0)
    );

    fir_pipelined_L3 F1 (
        .clk(clk),
        .rst(rst),
        .din(din1),
        .dout(dout1)
    );

    fir_pipelined_L3 F2 (
        .clk(clk),
        .rst(rst),
        .din(din2),
        .dout(dout2)
    );

endmodule
