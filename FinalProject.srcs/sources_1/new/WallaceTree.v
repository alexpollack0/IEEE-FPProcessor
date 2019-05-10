`timescale 1ns / 1ps

module WallaceTree(
    input [25:0] p0, 
    input [25:0] p1,
    input [25:0] p2,
    input [25:0] p3,
    input [25:0] p4,
    input [25:0] p5,
    input [25:0] p6,
    input [25:0] p7,
    input [25:0] p8,
    input [25:0] p9,
    input [25:0] p10,
    input [25:0] p11,
    input [25:0] p12,
    output [51:0] s
    );
    
    assign s[1:0] = p0[1:0];
    
    wire [26:0] s00;
    wire [27:0] c00;
    
    CSA #(.SIZE(28)) csa00(.X({{4{p0[25]}},p0[25:2]}), .Y({{2{p1[25]}},p1}), .Z({p2,2'b0}), .PS({s00,s[2]}), .SC(c00));
    
    wire [29:0] s01;
    wire [27:0] c01;
    
    assign s01[1:0] = p3[1:0];
    
    CSA #(.SIZE(28)) csa01(.X({{4{p3[25]}},p3[25:2]}), .Y({{2{p4[25]}},p4}), .Z({p5,2'b0}), .PS(s01[29:2]), .SC(c01));
    
    wire [29:0] s02;
    wire [27:0] c02;
    
    assign s02[1:0] = p6[1:0];
    
    CSA #(.SIZE(28)) csa02(.X({{4{p6[25]}},p6[25:2]}), .Y({{2{p7[25]}},p7}), .Z({p8,2'b0}), .PS(s02[29:2]), .SC(c02));
    
    wire [29:0] s03;
    wire [27:0] c03;
    
    assign s03[1:0] = p9[1:0];
    
    CSA #(.SIZE(28)) csa03(.X({{4{p9[25]}},p9[25:2]}), .Y({{2{p10[25]}},p10}), .Z({p11,2'b0}), .PS(s03[29:2]), .SC(c03));
    
    wire [31:0] s10;
    wire [32:0] c10;
    
    CSA #(.SIZE(33)) csa10(.X({{6{s00[26]}},s00}), .Y({{5{c00[27]}},c00}), .Z({s01,3'b0}), .PS({s10,s[3]}), .SC(c10));
    
    wire [33:0] s11;
    wire [30:0] c11;
    
    assign s11[2:0] = c01[2:0];
    
    CSA #(.SIZE(31)) csa11(.X({{6{c01[27]}},c01[27:3]}), .Y({s02[29],s02}), .Z({c02,3'b0}), .PS(s11[33:3]), .SC(c11));
    
    wire [37:0] s20;
    wire [38:0] c20;
        
    CSA #(.SIZE(39)) csa20(.X({{7{s10[31]}},s10}), .Y({{6{c10[32]}},c10}), .Z({s11,5'b0}), .PS({s20,s[4]}), .SC(c20));
    
    wire [35:0] s21;
    wire [30:0] c21;
    
    assign s21[4:0] = c11[4:0];
    
    CSA #(.SIZE(31)) csa21(.X({{5{c11[30]}},c11[30:5]}), .Y({s03[29],s03}), .Z({c03,3'b0}), .PS(s21[35:5]), .SC(c21));
    
    wire [42:0] s30;
    wire [43:0] c30;
    
    CSA #(.SIZE(44)) csa30(.X({{6{s20[37]}},s20}), .Y({{5{c20[38]}},c20}), .Z({s21,8'b0}), .PS({s30,s[5]}), .SC(c30));
    
    wire [42:0] s40;
    wire [43:0] c40;
    
    CSA #(.SIZE(44)) csa40(.X({s30[42],s30}), .Y(c30), .Z({c21,13'b0}), .PS({s40,s[6]}), .SC(c40));
    
    wire [42:0] s50;
    wire [43:0] c50;
    
    CSA #(.SIZE(44)) csa50(.X({s40[42],s40}), .Y(c40), .Z({p12[25],p12,17'b0}), .PS({s50,s[7]}), .SC(c50));
    
    CLA44 cla (.a({s50[42],s50}), .b(c50), .s(s[51:8]));
    
endmodule
