`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2019 03:51:36 PM
// Design Name: 
// Module Name: FPAdder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FPAdder(a, b, op, res);

    input op; // 0 = addition, 1 = subtraction
    input [31:0] a, b;
    output [31:0] res;
    
    reg [2:0] state;
    
    localparam ADD = 1'b0, SUB = 1'b1;
    
    localparam INIT = 3'b000;
    
    always @(a or b or op) begin
    
        case(op)
        
            ADD: begin
                
                case(state)
                
                    INIT: begin
                    
                    end
                
                endcase
                
            end
            
            SUB: begin
            
            end
        
        endcase
    
    end
    
    
 
endmodule
