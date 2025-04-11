`timescale 1ns/1ps

module fir_parallel_L2 #(
    parameter int TAPS = 102,            // Number of taps
    parameter int IO_WIDTH = 16,       // Bit width for I/O
    parameter int COEFF_WIDTH = 32    // Bit width for fixed-point coefficients
)(
    input logic clk,
    input logic rst,
    input logic signed [IO_WIDTH-1:0] din1, din2,
    output logic signed [COEFF_WIDTH*2-1:0] dout1, dout2
);
    // Buffers to store the most recent 102 samples (51 even, 51 odd)
    logic signed [IO_WIDTH-1:0] buffer1 [TAPS/2-1:0];
    logic signed [IO_WIDTH-1:0] buffer2 [TAPS/2-1:0];
    
    // Coefficients for the FIR filter
    logic signed [COEFF_WIDTH-1:0] coef [TAPS-1:0];
    
    initial begin
        $readmemb("fir_coeffs_bin.mem", coef); // Load fixed-point coefficients
    end
    // Filter sums
    logic signed [COEFF_WIDTH*2-1:0] sum_h0, sum_h1, sum_h01, sum_h1_reg;

    // Process inputs
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sum_h1_reg <= 0;
            for (int i = 0; i <= TAPS/2-1; i++) begin
                buffer1[i] <= 0;
                buffer2[i] <= 0;
            end
        end else begin
            // Shift buffer and insert new input sample
            for (int i = TAPS/2-1; i > 0; i--) begin
                buffer1[i] <= buffer1[i - 1];
                buffer2[i] <= buffer2[i - 1];
            end
            buffer1[0] <= din1;
            buffer2[0] <= din2;
            sum_h1_reg <= sum_h1;
        end
    end
    
    always_comb begin
        sum_h0 = 0;
        sum_h1 = 0;
        sum_h01 = 0;

        for (int i = 0; i <= TAPS/2-1; i++) begin
            sum_h0 += buffer1[i] * coef[2*i];
            sum_h1 += buffer2[i] * coef[2*i+1];
            sum_h01 += (buffer1[i] + buffer2[i])*(coef[2*i] + coef[2*i+1]);
        end
    end

    // Assign final outputs
    assign dout1 = (sum_h0 + sum_h1_reg) >>> 31;
    assign dout2 = (sum_h01 - sum_h0 - sum_h1) >>> 31;

endmodule