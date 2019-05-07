`timescale 1ns / 1ps

module WallaceTree(
    input [24:0] p0, 
    input [24:0] p1,
    input [24:0] p2,
    input [24:0] p3,
    input [24:0] p4,
    input [24:0] p5,
    input [24:0] p6,
    input [24:0] p7,
    input [24:0] p8,
    input [24:0] p9,
    input [24:0] p10,
    input [24:0] p11,
    output [49:0] s
    );
    
    assign s[1:0] = p0[1:0];
    
    wire [25:0] s00;
    wire [26:0] c00;
    
    CSA #(.SIZE(27)) csa00(.X({{4{p0[24]}},p0[24:2]}), .Y({{2{p1[24]}},p1}), .Z({p2,2'b0}), .PS({s00,s[2]}), .SC(c00));
    
    wire [28:0] s01;
    wire [26:0] c01;
    
    assign s01[1:0] = p3[1:0];
    
    CSA #(.SIZE(27)) csa01(.X({{4{p3[24]}},p3[24:2]}), .Y({{2{p4[24]}},p4}), .Z({p5,2'b0}), .PS(s01[28:2]), .SC(c01));
    
    wire [28:0] s02;
    wire [26:0] c02;
    
    assign s02[1:0] = p6[1:0];
    
    CSA #(.SIZE(27)) csa02(.X({{4{p6[24]}},p6[24:2]}), .Y({{2{p7[24]}},p7}), .Z({p8,2'b0}), .PS(s02[28:2]), .SC(c02));
    
    wire [28:0] s03;
    wire [26:0] c03;
    
    assign s03[1:0] = p9[1:0];
    
    CSA #(.SIZE(27)) csa03(.X({{4{p9[24]}},p9[24:2]}), .Y({{2{p10[24]}},p10}), .Z({p11,2'b0}), .PS(s03[28:2]), .SC(c03));
    
    wire [30:0] s10;
    wire [31:0] c10;
    
    CSA #(.SIZE(32)) csa10(.X({{6{s00[25]}},s00}), .Y({{5{c00[25]}},c00}), .Z({s01,3'b0}), .PS({s10,s[3]}), .SC(c10));
    
    wire [32:0] s11;
    wire [29:0] c11;
    
    assign s11[2:0] = c01[2:0];
    
    CSA #(.SIZE(30)) csa11(.X({{6{c01[26]}},c01}), .Y({s02[28],s02}), .Z({c02,3'b0}), .PS(s11[32:3]), .SC(c11));
    
    wire [36:0] s20;
    wire [37:0] c20;
        
    CSA #(.SIZE(38)) csa20(.X({{7{s10[30]}},s10}), .Y({{6{c10[31]}},c10}), .Z({s11,5'b0}), .PS({s20,s[4]}), .SC(c20));
    
    wire [35:0] s21;
    wire [29:0] c21;
    
    assign s21[5:0] = c11[5:0];
    
    CSA #(.SIZE(30)) csa21(.X({{5{c11[29]}},c11[29:6]}), .Y({s03[34],s03}), .Z({c03,3'b0}), .PS(s21[35:6]), .SC(c21));
    
    wire [41:0] s30;
    wire [42:0] c30;
    
    CSA #(.SIZE(43)) csa30(.X({{6{s20[26]}},s20}), .Y({{5{c20[37]}},c20}), .Z({s21,7'b0}), .PS({s30,s[5]}), .SC(c30));
    
    wire [41:0] s40;
    wire [42:0] c40;
    
    CSA #(.SIZE(43)) csa40(.X({s30[41],s30}), .Y(c30), .Z({c21,13'b0}), .PS({s40,s[6]}), .SC(c40));
    
    CLA43 cla (.a({s40[41],s40}), .b(c40), .s(s[49:7]));
    
endmodule
