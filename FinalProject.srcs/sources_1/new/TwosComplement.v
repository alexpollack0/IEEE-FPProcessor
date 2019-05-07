`timescale 1ns / 1ps

module TwosComplement #(BIT_WIDTH=1) (
    input [BIT_WIDTH-1:0] in,
    output [BIT_WIDTH-1:0] out
    );

    wire [2**($clog2(BIT_WIDTH))-1:0] in_inv;

    for (genvar i = 0; i < BIT_WIDTH; i = i+1) begin
        assign in_inv[i] = !in[i];
    end
    
    for (genvar i = BIT_WIDTH; i < 2**($clog2(BIT_WIDTH)); i=i+1) begin
        assign in_inv[i] = in_inv[BIT_WIDTH-1];
    end

    VariableCLA #(.SIZE($clog2(BIT_WIDTH))) adder(.a(in_inv), .b(0), .c_in(1'b1), .s(out));

endmodule
