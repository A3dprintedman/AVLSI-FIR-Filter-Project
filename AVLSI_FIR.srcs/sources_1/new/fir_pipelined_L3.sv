`timescale 1ns/1ps

module fir_pipelined_L3 #(
    parameter int TAPS = 102,            // Number of taps
    parameter int IO_WIDTH = 16,       // Bit width for I/O
    parameter int COEFF_WIDTH = 32    // Bit width for fixed-point coefficients
)(
    input logic clk,               // Clock signal
    input logic rst,               // Reset signal
    input logic signed [IO_WIDTH-1:0] din, // Input sample
    output logic signed [COEFF_WIDTH*2-1:0] dout // Filtered output
);

    logic signed [COEFF_WIDTH-1:0] coef [TAPS-1:0];
    
    initial begin 
        $readmemb("fir_coeffs_bin.mem" ,coef);
    end

    logic signed [IO_WIDTH-1:0] delay_line [(TAPS-1)*2-1:0]; // Delay line for input samples
    logic signed [COEFF_WIDTH*2-1:0] acc_pipe [TAPS-1:0]; // Pipeline registers for accumulation

    // Shift Register (Delay Line)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i <= (TAPS-1)*2-1; i = i + 1) begin
                delay_line[i] <= 16'sd0;
            end
        end else begin
            // Shift buffer and insert new input sample
            for (int i = (TAPS-1)*2-1; i > 0; i--) begin
                delay_line[i] <= delay_line[i - 1];
            end
            delay_line[0] <= din; 
        end
    end

    // Multiply input samples with coefficients
    always_ff @(posedge clk) begin
        acc_pipe[0] <= (din * coef[0]);
        for (int i = 1; i < TAPS; i = i + 1) begin
            acc_pipe[i] <= (acc_pipe[i-1] + delay_line[2*(i-1)+1] * coef[i]);
        end
    end

   assign dout = acc_pipe[TAPS-1] >>> 31;

endmodule