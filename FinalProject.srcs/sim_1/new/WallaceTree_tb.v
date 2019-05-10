`timescale 1ns / 1ps

module WallaceTree_tb(

    );
    
    reg signed [23:0] multiplier;
    reg signed [23:0] multiplicand;
    wire [25:0] p0;
    wire [25:0] p1;
    wire [25:0] p2;
    wire [25:0] p3;
    wire [25:0] p4;
    wire [25:0] p5;
    wire [25:0] p6;
    wire [25:0] p7;
    wire [25:0] p8;
    wire [25:0] p9;
    wire [25:0] p10;
    wire [25:0] p11;
    wire [50:0] s;
    
    reg [50:0] exp;
    
    Radix4BoothPartialGenerator UUT1(.multiplier(multiplier), .multiplicand(multiplicand), .p0(p0), .p1(p1), .p2(p2), .p3(p3), .p4(p4), .p5(p5), .p6(p6), .p7(p7), .p8(p8), .p9(p9), .p10(p10), .p11(p11));
    
    WallaceTree UUT2(.p0(p0),.p1(p1),.p2(p2),.p3(p3),.p4(p4),.p5(p5),.p6(p6),.p7(p7),.p8(p8),.p9(p9),.p10(p10),.p11(p11),.s(s));
    
    reg [24:0] i;
    reg [24:0] j;
    initial begin
        for (i = 1; i < 2**24-1;i=i<<1) begin
            for (j = 1; j < 2**24-1;j=j<<1) begin
                multiplier = i;
                multiplicand = j;
                exp = multiplier * multiplicand;
                #10 $display("multiplier = %b, multiplicand = %b, s = %b", multiplier, multiplicand, s);
                if (s != exp) $display("Error: s should be %b, is %b", exp, s);
            end
        end
    end
    
endmodule
