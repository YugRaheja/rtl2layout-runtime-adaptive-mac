`timescale 1ns / 1ps
// multiplier : 16x16 signed -> 32 bit
module multiplier (
    input  wire signed [15:0] A,
    input  wire signed [15:0] B,
    output wire signed [31:0] product
);
    assign product = A * B;
endmodule
