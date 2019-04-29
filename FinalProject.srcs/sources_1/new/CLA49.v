`timescale 1ns / 1ps

module CLA49(
    input [48:0] a,
    input [48:0] b,
    output [48:0] s
    );
    
    wire c_32_16, c_16_1;
    
    VariableCLA #(.SIZE(32)) thirtytwo(.a(a[31:0]), .b(b[31:0]), .c_in(1'b0), .s(s[31:0]), .c_out(c_32_16));
    
    VariableCLA #(.SIZE(32)) sixteen(.a(a[47:32]), .b(b[47:32]), .c_in(c_32_16), .s(s[47:32]), .c_out(c_16_1));
    
    VariableCLA #(.SIZE(32)) one(.a(a[48]), .b(b[48]), .c_in(c_16_1), .s(s[48]));
    
endmodule
