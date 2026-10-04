`timescale 1ns / 1ps
// sign_extender : sign-extends the selected 4 / 8 / 16 bit value to 16 bits
module sign_extender (
    input  wire signed [15:0] in,
    input  wire        [1:0]  mode,
    output reg  signed [15:0] out
);
    always @(*) begin
        case (mode)
            2'b00:   out = {{12{in[3]}}, in[3:0]};   // INT4
            2'b01:   out = {{8{in[7]}},  in[7:0]};   // INT8
            2'b10:   out = in;                       // INT16
            default: out = in;                       // 2'b11 -> INT16
        endcase
    end
endmodule
