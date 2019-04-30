`timescale 1ns / 1ps

module TwosComplement #(SIZE=0)(
    input [2^SIZE:0] in,
    output [2^SIZE:0] out
    );
    
    wire [2^SIZE:0] in_inv;
    
    for (genvar i = 0; i < 2^SIZE; i=i+1) begin
        assign in_inv[i] = !in[i];
    end
    
    VariableCLA #(.SIZE(SIZE)) adder (.a(in_inv), .b(31'd1), .c_in(0), .s(out));
    
endmodule
