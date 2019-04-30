`timescale 1ns / 1ps

module FPMultiplier(
    input clk,
    input [31:0] multiplier,
    input [31:0] multiplicand,
    output [31:0] result
    );
    
    reg state;
    
    always @(posedge clk) begin
        
        case (state)
        1'b0: begin
        end
        default: begin
        end
        endcase
        
    end
    
endmodule
