`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2019 02:02:15 PM
// Design Name: 
// Module Name: cell_a
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


module cell_a(
    input a,
    input b,
    input c,
    output g,
    output p,
    output s
    );
    
    assign s = a ^ b ^ c;
    assign p = a | b;
    assign g = a & b;
endmodule
