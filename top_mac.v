`timescale 1ns / 1ps
// top_mac : mode-selectable (INT4/INT8/INT16) multiply-accumulate
//   mode 00 = INT4, 01 = INT8, 10 = INT16, 11 = INT16 (alias)
module top_mac (
    input  wire               clk,
    input  wire               rst,
    input  wire               clear,
    input  wire               enable,
    input  wire signed [15:0] A,
    input  wire signed [15:0] B,
    input  wire        [1:0]  mode,
    output wire signed [31:0] Y
);
    wire signed [15:0] A_sel, B_sel, A_ext, B_ext;
    wire signed [31:0] product;

    bit_selector  u1 (.in(A),     .mode(mode), .out(A_sel));
    bit_selector  u2 (.in(B),     .mode(mode), .out(B_sel));
    sign_extender u3 (.in(A_sel), .mode(mode), .out(A_ext));
    sign_extender u4 (.in(B_sel), .mode(mode), .out(B_ext));
    multiplier    u5 (.A(A_ext),  .B(B_ext),   .product(product));
    accumulator   u6 (.clk(clk), .rst(rst), .clear(clear), .enable(enable),
                      .product(product), .Y(Y));
endmodule
