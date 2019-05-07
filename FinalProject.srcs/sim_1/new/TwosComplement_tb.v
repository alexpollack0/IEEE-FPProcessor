`timescale 1ns / 1ps

module TwosComplement_tb(

    );
    
    reg signed [9:0] a;
    wire signed [9:0] b;
    
    TwosComplement #(.BIT_WIDTH(10)) tbb(.in(a), .out(b));
    
    initial begin        
        for (a = -127; a < 128; a=a+1) begin
            #10 $display("a = %d, -a = %d", a, b);
            if (b != -a) $display("Error, b should be %d, is %d", -a, b);
        end
    end
    
endmodule
