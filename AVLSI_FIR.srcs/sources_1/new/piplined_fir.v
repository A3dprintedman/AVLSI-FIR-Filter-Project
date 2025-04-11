`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2025 05:09:59 PM
// Design Name: 
// Module Name: fir_filter_pipelined
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fir_filter_pipelined
#(
    parameter TAP_COUNT = 100,
    parameter DATA_WIDTH = 16,
    parameter COEFF_WIDTH = 16
)
(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    input  wire                         data_valid,
    output reg  signed [DATA_WIDTH+COEFF_WIDTH:0] data_out,
    output reg                          data_out_valid
);

    // Coefficient memory
    reg signed [COEFF_WIDTH-1:0] coeffs [0:TAP_COUNT-1];
    
    // Delay line for input data
    reg signed [DATA_WIDTH-1:0] delay_line [0:TAP_COUNT-1];
    
    // Pipeline registers for multiply results
    reg signed [DATA_WIDTH+COEFF_WIDTH-1:0] mult_results [0:TAP_COUNT-1];
    
    // Pipeline registers for partial sums
    reg signed [DATA_WIDTH+COEFF_WIDTH:0] partial_sums [0:TAP_COUNT-1];
    
    // Pipeline valid signal
    reg data_valid_pipe [0:TAP_COUNT];
    
    // Initialize coefficients (for simulation)
    integer i;
    initial begin
        for (i = 0; i < TAP_COUNT; i = i + 1) begin
            coeffs[i] = 0;
        end
        // Actual coefficients would be loaded here
    end
    
    integer i;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            for (i = 0; i < TAP_COUNT; i = i + 1) begin
                delay_line[i] <= 0;
                mult_results[i] <= 0;
                partial_sums[i] <= 0;
                data_valid_pipe[i] <= 0;
            end
            data_valid_pipe[TAP_COUNT] <= 0;
            data_out <= 0;
            data_out_valid <= 0;
        end
        else begin
            // Input shift register stage
            if (data_valid) begin
                for (i = TAP_COUNT-1; i > 0; i = i - 1) begin
                    delay_line[i] <= delay_line[i-1];
                end
                delay_line[0] <= data_in;
                data_valid_pipe[0] <= 1;
            end
            else begin
                data_valid_pipe[0] <= 0;
            end
            
            // Multiply stage
            for (i = 0; i < TAP_COUNT; i = i + 1) begin
                mult_results[i] <= delay_line[i] * coeffs[i];
                data_valid_pipe[i+1] <= data_valid_pipe[i];
            end
            
            // Accumulation pipeline
            partial_sums[0] <= mult_results[0];
            for (i = 1; i < TAP_COUNT; i = i + 1) begin
                partial_sums[i] <= partial_sums[i-1] + mult_results[i];
            end
            
            // Output stage
            data_out <= partial_sums[TAP_COUNT-1];
            data_out_valid <= data_valid_pipe[TAP_COUNT];
        end
    end
endmodule
