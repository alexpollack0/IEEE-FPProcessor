`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2019 02:02:15 PM
// Design Name: 
// Module Name: cell_b
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


module cell_b(
    input g_jk,
    input p_jk,
    input g_ij,
    input p_ij,
    input c_ii,
    output c_j,
    output c_io,
    output p_ik,
    output g_ik
    );
    
    assign p_ik = p_ij & p_jk;
    assign g_ik = g_jk | (p_jk & g_ij);
    assign c_io = c_ii;
    assign c_j = g_ij | (p_ij & c_ii);
endmodule
