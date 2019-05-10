`timescale 1ns / 1ps

module MultRound(
    input [7:0] exponent_in,
    input [47:0] mantissa_in,
    output [7:0] exponent_out,
    output [22:0] mantissa_out
    );
    
    wire round;
    wire sticky;
    
    wire [8:0] exponent_tmp;
    wire [24:0] mantissa_tmp;
    
    assign round = mantissa_in[23];
    assign sticky = | mantissa_in[25:0];
    
    VariableCLA #(.SIZE(5)) manTmp(.a({8'b0, mantissa_in[47 -: 24]}), .b(32'b0), .c_in(round && sticky), .s(mantissa_tmp));
    VariableCLA #(.SIZE(3)) expTmp(.a(exponent_in), .b(-8'd1), .c_in(1'b0), .s(exponent_tmp));
    
    assign mantissa_out = mantissa_tmp[24] ? mantissa_tmp[23:1] : mantissa_tmp[22:0];
    assign exponent_out = (round && sticky && mantissa_tmp[24]) ? exponent_tmp : exponent_in;
    
endmodule
