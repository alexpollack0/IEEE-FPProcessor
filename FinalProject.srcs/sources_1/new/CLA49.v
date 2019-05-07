`timescale 1ns / 1ps

module CLA43(
    input [42:0] a,
    input [42:0] b,
    output [42:0] s
    );
    
    wire c_32_8, c_8_2, c_2_1;
    
    VariableCLA #(.SIZE(32)) thirtytwo(.a(a[31:0]), .b(b[31:0]), .c_in(1'b0), .s(s[31:0]), .c_out(c_32_8));
    
    VariableCLA #(.SIZE(8)) eight(.a(a[32 +: 8]), .b(b[32 +: 8]), .c_in(c_32_8), .s(s[32 +: 8]), .c_out(c_8_2));
    
    VariableCLA #(.SIZE(1)) two(.a(a[41:40]), .b(b[41:40]), .c_in(c_8_2), .s(s[41:40]), .c_out(c_2_1));
    
    VariableCLA #(.SIZE(1)) one(.a(a[42]), .b(b[42]), .c_in(c_2_1), .s(s[42]));
    
endmodule
