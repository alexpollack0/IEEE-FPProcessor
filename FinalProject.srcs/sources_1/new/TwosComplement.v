`timescale 1ns / 1ps

module TwosComplement(
    input [23:0] in,
    output [23:0] out
    );
    
    wire [31:0] in_inv;
    
    for (genvar i = 0; i < 24; i=i+1) begin
        assign in_inv[i] = !in[i];
    end
    
    for (genvar i = 24; i < 32; i=i+1) begin
        assign in_inv[i] = in_inv[23];
    end
    
    VariableCLA #(.SIZE(5)) adder (.a(in_inv), .b(31'd1), .c_in(0), .s({8'b0, out}));
    
endmodule
