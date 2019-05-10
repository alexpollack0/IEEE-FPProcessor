`timescale 1ns / 1ps

module FPMultiplier_tb(

    );
    
    reg clk;
    reg reset;
    
    reg [31:0] in1;
    reg [31:0] in2;
    
    wire [31:0] result;
    
    FPMultiplier UUT(.clk(clk), .reset(reset), .multiplier(in1), .multiplicand(in2), .result(result));
    
    initial begin
        in1 = 32'h42c7fae1;
        in2 = 32'h3e24dd2f;
        
        clk = 0;
        reset = 1;
        #2 reset = 0;
    end
    
    always begin
        #1 clk <= ~clk;
    end
endmodule
