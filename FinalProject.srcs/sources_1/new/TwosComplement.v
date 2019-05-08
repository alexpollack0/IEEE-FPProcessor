`timescale 1ns / 1ps

module TwosComplement #(BIT_WIDTH=1) (
    input [BIT_WIDTH-1:0] in,
    output [BIT_WIDTH:0] out
    );

    wire [2**($clog2(BIT_WIDTH))-1:0] in_ext;
    wire [2**($clog2(BIT_WIDTH))-1:0] in_inv;
    wire carry;
    
    assign in_ext = {{2**($clog2(BIT_WIDTH))-BIT_WIDTH{in[BIT_WIDTH-1]}}, in};

    for (genvar i = 0; i < 2**($clog2(BIT_WIDTH)); i = i+1) begin
        assign in_inv[i] = !in_ext[i];
    end

    VariableCLA #(.SIZE($clog2(BIT_WIDTH))) adder(.a(in_inv), .b(0), .c_in(1'b1), .s(out), .c_out(carry));

    if (2**($clog2(BIT_WIDTH)) == BIT_WIDTH) assign out[BIT_WIDTH] = carry;

endmodule
