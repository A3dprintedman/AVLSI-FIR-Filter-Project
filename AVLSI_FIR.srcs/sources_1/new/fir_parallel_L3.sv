`timescale 1ns/1ps

module fir_parallel_L3 #(
    parameter int TAPS = 102,            // Number of taps
    parameter int IO_WIDTH = 16,       // Bit width for I/O
    parameter int COEFF_WIDTH = 32    // Bit width for fixed-point coefficients
)(
    input logic clk,
    input logic rst,
    input logic signed [IO_WIDTH-1:0] din1 ,din2, din3,
    output logic signed [COEFF_WIDTH*2-1:0] dout1, dout2, dout3
);

    // Buffers to store the most recent 102 samples
    logic signed [IO_WIDTH-1:0] buffer0 [TAPS/3-1:0];
    logic signed [IO_WIDTH-1:0] buffer1 [TAPS/3-1:0];
    logic signed [IO_WIDTH-1:0] buffer2 [TAPS/3-1:0];
    
    // Coefficients for the FIR filter
    logic signed [COEFF_WIDTH-1:0] H0 [TAPS/3-1:0];
    logic signed [COEFF_WIDTH-1:0] H1 [TAPS/3-1:0];
    logic signed [COEFF_WIDTH-1:0] H2 [TAPS/3-1:0];

    logic signed [COEFF_WIDTH-1:0] coef [TAPS-1:0];
    
    initial begin
        $readmemb("fir_coeffs_bin.mem" ,coef);
    end

    // Filter sums
    logic signed [COEFF_WIDTH*2-1:0] sum_h0, sum_h1, sum_h2, sum_h01, sum_h12, sum_h012, sum_h2_reg, add_h1h2_min_h1_reg;
    logic signed [COEFF_WIDTH*2-1:0] add_h01_min_h1, add_h12_min_h1, add_h012_min_add_h01_min_h1, add_h0_min_sum_h2_reg;

    // Assign adder outputs (excluding those attached to an output)
    assign add_h01_min_h1 = sum_h01 - sum_h1;
    assign add_h12_min_h1 = sum_h12 - sum_h1;
    assign add_h012_min_add_h01_min_h1 = sum_h012 - add_h01_min_h1;
    assign add_h0_min_sum_h2_reg = sum_h0 - sum_h2_reg;

    // Process inputs
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sum_h2_reg <= 0;
            add_h1h2_min_h1_reg <= 0;
            for (int i = 0; i <= TAPS/3-1; i++) begin
                buffer0[i] <= 0;
                buffer1[i] <= 0;
                buffer2[i] <= 0;
            end
        end
        else begin
            // Shift buffer and insert new input sample
            for (int i = TAPS/3-1; i > 0; i--) begin
                buffer0[i] <= buffer0[i - 1];
                buffer1[i] <= buffer1[i - 1];
                buffer2[i] <= buffer2[i - 1];
            end
            buffer0[0] <= din1;
            buffer1[0] <= din2;
            buffer2[0] <= din3;

            sum_h2_reg <= sum_h2;
            add_h1h2_min_h1_reg <= add_h12_min_h1;
        end
    end

    always_comb begin
        sum_h0 = 0;
        sum_h1 = 0;
        sum_h2 = 0;
        sum_h01 = 0;
        sum_h12 = 0;
        sum_h012 = 0;

        for (int i = 0; i <= TAPS/3-1; i++) begin
            sum_h0 += buffer0[i] * coef[3*i];
            sum_h1 += buffer1[i] * coef[3*i+1];
            sum_h2 += buffer2[i] * coef[3*i+2];

            sum_h01  += (buffer0[i] + buffer1[i])*(coef[3*i] + coef[3*i+1]);
            sum_h12  += (buffer1[i] + buffer2[i])*(coef[3*i+1] + coef[3*i+2]);
            sum_h012 += (buffer0[i] + buffer1[i] + buffer2[i])*(coef[3*i] + coef[3*i+1] + coef[3*i+2]);
        end
    end

    // Assign final outputs
    assign dout1 = (add_h0_min_sum_h2_reg + add_h1h2_min_h1_reg) >>> 31;
    assign dout2 = (add_h01_min_h1 - add_h0_min_sum_h2_reg) >>> 31;
    assign dout3 = (add_h012_min_add_h01_min_h1 - add_h12_min_h1) >>> 31;

endmodule
