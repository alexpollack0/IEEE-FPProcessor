`timescale 1ns / 1ps

module VariableCLA #(parameter SIZE=2)(
    input [2**SIZE-1:0] a,
    input [2**SIZE-1:0] b,
    input c_in,
    output [2**SIZE-1:0] s,
    output c_out
    );
    
    wire carry [2**SIZE-1:0][SIZE:0];
    wire gen [2**SIZE-1:0][SIZE:0];
    wire prop [2**SIZE-1:0][SIZE:0];
    
    assign carry[0][SIZE] = c_in;
    
    for (genvar i = 0; i < (2**SIZE); i = i + 1) begin: as
        cell_a a (.a(a[i]), .b(b[i]), .c(carry[(2**SIZE-1)-i][0]), .p(prop[(2**SIZE-1)-i][0]), .g(gen[(2**SIZE-1)-i][0]), .s(s[i]));
    end
    
    for (genvar i = 0; i < SIZE; i = i + 1) begin: row
        for (genvar j = 0; j < 2**(SIZE-i-1); j = j + 1) begin: col
            cell_b b (.g_jk(gen[2*j][i]), 
                    .p_jk(prop[2*j][i]), 
                    .g_ij(gen[2*j+1][i]), 
                    .p_ij(prop[2*j+1][i]), 
                    .c_ii(carry[j][i+1]), 
                    .c_j(carry[2*j][i]), 
                    .c_io(carry[2*j+1][i]), 
                    .p_ik(prop[j][i+1]), 
                    .g_ik(gen[j][i+1]));
        end 
    end
    
    assign c_out = gen[0][0] | (prop[0][0] & carry[0][0]);
    
endmodule