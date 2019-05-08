`timescale 1ns / 1ps

module CLA44(
    input [43:0] a,
    input [43:0] b,
    output [43:0] s
    );
    
    wire c_32_8, c_8_4;
    
    VariableCLA #(.SIZE(5)) thirtytwo(.a(a[31:0]), .b(b[31:0]), .c_in(1'b0), .s(s[31:0]), .c_out(c_32_8));
    
    VariableCLA #(.SIZE(3)) eight(.a(a[32 +: 8]), .b(b[32 +: 8]), .c_in(c_32_8), .s(s[32 +: 8]), .c_out(c_8_4));
    
    VariableCLA #(.SIZE(2)) two(.a(a[43:40]), .b(b[43:40]), .c_in(c_8_4), .s(s[43:40]));
    
endmodule
