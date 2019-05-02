`timescale 1ns / 1ps

module TwosComplement (
    input [2**SIZE-1:0] in,
    output [2**SIZE-1:0] out
    );

    parameter SIZE = 0;

    wire [2**SIZE - 1:0] in_inv;
    wire [2**SIZE - 1:0] bVal;
    assign bVal = 1'b1;

    genvar i;
    for (i = 0; i < 2**SIZE; i = i+1) begin
        assign in_inv[i] = !in[i];
    end

    VariableCLA #(.SIZE(SIZE)) adder (.a(in_inv), .b(bVal), .c_in(1'b0), .s(out));

endmodule
