`timescale 1ns / 1ps

module CSA #(SIZE=2) (
    input [SIZE-1:0] X,
    input [SIZE-1:0] Y,
    input [SIZE-1:0] Z,
    output [SIZE-1:0] PS,
    output [SIZE-1:0] SC
    );
    
    for (genvar i = 0; i < SIZE; i=i+1) begin: fa
        FullAdder add(.x(X[i]), .y(Y[i]), .z(Z[i]), .ps(PS[i]), .sc(SC[i]));
    end
    
endmodule