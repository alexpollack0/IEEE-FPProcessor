`timescale 1ns / 1ps

module FPMultiplier(
    input clk,
    input [31:0] multiplier,
    input [31:0] multiplicand,
    output [31:0] result
    );
    
    reg [2:0] state;
    reg [2:0] next_state;
    reg [24:0] p0;
    reg [24:0] p1;
    reg [24:0] p2;
    reg [24:0] p3;
    reg [24:0] p4;
    reg [24:0] p5;
    reg [24:0] p6;
    reg [24:0] p7;
    reg [24:0] p8;
    reg [24:0] p9;
    reg [24:0] p10;
    reg [24:0] p11;
    reg [24:0] p12;
    reg [24:0] p13;
    reg [24:0] p14;
    reg [24:0] p15;   
    
    always @(posedge clk) begin
        case (state)
        3'b0: begin
            next_state = 3'b1;
        end
        3'b1: begin
            
        end
        default: begin
        end
        endcase
    end
    
    always @(negedge clk) begin
        state <= next_state;
    end
    
    assign result[31] = multiplier[31] ^ multiplicand[31];
    
    Radix4BoothPartialGenerator (multiplier[23:0],multiplicand[23:0],p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15);
    
endmodule
