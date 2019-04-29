`timescale 1ns / 1ps

module FullAdder(
    input x,
    input y,
    input z,
    output ps,
    output sc
    );
    
    assign ps = x ^ y ^ z;
    assign sc = (x & y) | (x & z) | (y & z);
endmodule
