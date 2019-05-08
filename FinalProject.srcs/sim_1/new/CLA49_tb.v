`timescale 1ns / 1ps

module CLA43_tb(

    );
    
    reg [43:0] a;
    reg [43:0] b;
    wire [42:0] s;
    reg [42:0] exp;
    
    CLA43 UUT(.a(a), .b(b), .s(s));

    initial begin        
        for (a = 1; a < 2**42-1; a=a<<1) begin
            for (b = 1; b < 2**42-1; b=b<<1) begin
                exp = a+b;
                #1 if (s != exp) $display("Error, a = %d, b = %d, s should be %d, is %d", a, b, exp, s);
            end
        end
    end
    
endmodule

