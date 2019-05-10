`timescale 1ns / 1ps

module FPMultiplier(
    input clk,
    input reset,
    input [31:0] multiplier,
    input [31:0] multiplicand,
    output reg [31:0] result
    );
    
    wire [23:0] multiplier_mantissa;
    wire [23:0] multiplicand_mantissa;
    
    reg  sign [3:0];
    reg  [25:0] partials [12:0];
    reg  [51:0] mult_mantissa;
    
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
    wire [25:0] p12;
    wire [51:0] s;
    
    wire [8:0] exp_tmp_w [2:0];
    reg  [8:0] exp_tmp_r [3:0];
    
    wire [47:0] norm_mantissa_w;
    reg  [47:0] norm_mantissa_r [1:0];
    
    wire [5:0] shift_w;
    reg  [5:0] shift_r;
    
    wire [7:0] final_exponent;
    wire [22:0] final_mantissa;
    
    always @(posedge clk) begin
        /*
         *  Stage 1
         */
        // Calculate sign
        sign[0] = multiplier[31] ^ multiplicand[31];
        // Store partials
        partials[0] <= p0;
        partials[1] <= p1;
        partials[2] <= p2;
        partials[3] <= p3;
        partials[4] <= p4;
        partials[5] <= p5;
        partials[6] <= p6;
        partials[7] <= p7;
        partials[8] <= p8;
        partials[9] <= p9;
        partials[10] <= p10;
        partials[11] <= p11;
        partials[12] <= p12;
        // Store exponent addition
        exp_tmp_r[0] <= exp_tmp_w[0];
        
        /*
         *  Stage 2
         */
        // Propogate sign
        sign[1] <= sign[0];
        // Store mantissa multiplication
        mult_mantissa <= s;
        // Store exponent addition minus 127
        exp_tmp_r[1] <= exp_tmp_w[1];
        
        /*
         *  Stage 3
         */
         // Propogate sign
         sign[2] <= sign[1];
         // Store normalized mantissa
         norm_mantissa_r[0] = norm_mantissa_w;
         // Store shift amount
         shift_r = shift_w;
         // Store exponent
         exp_tmp_r[2] <= exp_tmp_r[1];
         
         /*
          * Stage 4
          */
         // Propogate sign
         sign[3] <= sign[2];
         // Propogate normalized mantissa
         norm_mantissa_r[1] <= norm_mantissa_r[0];
         // Store exponent minus shift
         exp_tmp_r[3] <= exp_tmp_w[2];
         
         /*
          * Stage 5
          */
         // Set result sign
         result[31] <= sign[3];
         // Set result exponent
         result[30:23] <= final_exponent;
         // Set result mantissa
         result[22:0] <= final_mantissa; 
    end
    
    // Set the first bit of the mantissa to be 1 or 0 depending on if it is a denormal or not
    assign multiplier_mantissa = {multiplier[30:23] != 8'b0, multiplier[22:0]}; 
    assign multiplicand_mantissa = {multiplicand[30:23] != 8'b0, multiplicand[22:0]}; 
    
    // Calculate partials for WallaceTree
    Radix4BoothPartialGenerator partialGen(multiplier_mantissa,multiplicand_mantissa,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12);
    
    // Add partials together to get the multiplication of the mantissas
    WallaceTree wallaceTree(partials[0],partials[1],partials[2],partials[3],partials[4],partials[5],partials[6],partials[7],partials[8],partials[9],partials[10],partials[11],partials[12],s);
    
    // Add exponents and then subtract 127
    VariableCLA #(.SIZE(3)) exp_adder(.a(multiplier[30:23]), .b(multiplicand[30:23]), .c_in(1'b0), .s(exp_tmp_w[0][7:0]), .c_out(exp_tmp_w[0][8]));
    VariableCLA #(.SIZE(4)) exp_sub(.a(exp_tmp_r[0][8:0]), .b(-8'd127), .c_in(1'b0), .s(exp_tmp_w[1][7:0]));
    
    // Normalize mantissa
    wire [5:0] temp;
    NormalizeReg #(.BIT_WIDTH(48)) normReg(.mantissa_in(mult_mantissa), .mantissa_out(norm_mantissa_w), .shiftNum(temp));
    VariableCLA #(.SIZE(3)) tmp(.a(temp), .b(-6'b1), .c_in(1'b0), .s(shift_w));
    
    // Subract shift from exponent
    VariableCLA #(.SIZE(3)) expShift(.a(exp_tmp_r[2]), .b(~{{2{shift_r[5]}},shift_r}), .c_in(1'b1), .s(exp_tmp_w[2]));
    
    // Round mantissa and adjust exponent
    MultRound round(.exponent_in(exp_tmp_r[3]), .mantissa_in(norm_mantissa_r[1]), .exponent_out(final_exponent), .mantissa_out(final_mantissa));
    
endmodule
