`timescale 1ns / 1ps

module TwosComplement #(BIT_WIDTH=1) (
    input [BIT_WIDTH-1:0] in,
    output [BIT_WIDTH-1:0] out
    );

    wire [BIT_WIDTH-1:0] in_inv;

    for (genvar i = 0; i < BIT_WIDTH; i = i+1) begin
        assign in_inv[i] = !in[i];
    end

    VariableCLA #(.SIZE($clog2(BIT_WIDTH))) adder(.a({2**($clog2(BIT_WIDTH)), in_inv}), .b({{2**($clog2(BIT_WIDTH))-1{1'b0}}, 1'b1}), .c_in(1'b0), .s(out));

endmodule
