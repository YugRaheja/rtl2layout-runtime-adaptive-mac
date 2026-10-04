`timescale 1ns / 1ps
// bit_selector : picks the low 4 / 8 / 16 bits of the operand (mode 00/01/10)
// Output is zero-padded here; sign_extender fixes the sign afterwards.
module bit_selector (
    input  wire signed [15:0] in,
    input  wire        [1:0]  mode,
    output reg  signed [15:0] out
);
    always @(*) begin
        case (mode)
            2'b00:   out = {12'b0, in[3:0]};   // INT4
            2'b01:   out = {8'b0,  in[7:0]};   // INT8
            2'b10:   out = in;                 // INT16
            default: out = in;                 // 2'b11 -> INT16
        endcase
    end
endmodule
