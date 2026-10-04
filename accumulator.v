`timescale 1ns / 1ps
// accumulator : 32 bit wrap-around accumulator, async active-high reset,
// synchronous clear, enable-gated accumulate.
module accumulator (
    input  wire               clk,
    input  wire               rst,
    input  wire               clear,
    input  wire               enable,
    input  wire signed [31:0] product,
    output reg  signed [31:0] Y
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            Y <= 32'sd0;
        else if (clear)
            Y <= 32'sd0;
        else if (enable)
            Y <= Y + product;      // wrap-around is intentional
    end
endmodule
