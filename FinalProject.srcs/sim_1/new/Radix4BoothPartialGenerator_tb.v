`timescale 1ns / 1ps

module Radix4BoothPartialGenerator_tb(

    );
    
    reg [24:0] multiplier;
    reg [24:0] multiplicand;
    wire [24:0] p0;
    wire [24:0] p1;
    wire [24:0] p2;
    wire [24:0] p3;
    wire [24:0] p4;
    wire [24:0] p5;
    wire [24:0] p6;
    wire [24:0] p7;
    wire [24:0] p8;
    wire [24:0] p9;
    wire [24:0] p10;
    wire [24:0] p11;
    
    Radix4BoothPartialGenerator UUT(.multiplier(multiplier),.multiplicand(multiplicand),.p0(p0),.p1(p1),.p2(p2),.p3(p3),.p4(p4),.p5(p5),.p6(p6),.p7(p7),.p8(p8),.p9(p9),.p10(p10),.p11(p11));
    
    initial begin
        multiplier = 0;
        multiplicand = 0;
        
        for (multiplier = 1; multiplier < 2**24-1;multiplier=multiplier<<1) begin
            for (multiplicand = 1; multiplicand < 2**24-1;multiplicand=multiplicand<<1) begin
                #10 $display("multiplier = %b, multiplicand = %b", multiplier, multiplicand);
                $display("p0 = %b", p0);
                $display("p1 = %b", p1);
                $display("p2 = %b", p2);
                $display("p3 = %b", p3);
                $display("p4 = %b", p4);
                $display("p5 = %b", p5);
                $display("p6 = %b", p6);
                $display("p7 = %b", p7);
                $display("p8 = %b", p8);
                $display("p9 = %b", p9);
                $display("p10 = %b", p10);
                $display("p11 = %b", p11);
            end
        end
    end
    
endmodule
