`timescale 1ns / 1ps

module Radix4BoothPartialGenerator(
    input [23:0] multiplier,
    input [23:0] multiplicand,
    output [25:0] p0, 
    output [25:0] p1,
    output [25:0] p2,
    output [25:0] p3,
    output [25:0] p4,
    output [25:0] p5,
    output [25:0] p6,
    output [25:0] p7,
    output [25:0] p8,
    output [25:0] p9,
    output [25:0] p10,
    output [25:0] p11,
    output [25:0] p12
    );
    
    wire [26:0] multiplier_extended;
    wire [24:0] multiplicand_complement;
    
    assign multiplier_extended = {2'b0, multiplier, 1'b0};
    TwosComplement #(.BIT_WIDTH(26)) neg(.in({2'b0, multiplicand}), .out(multiplicand_complement));
    
    reg [25:0] partials [12:0]; 
    
    for (genvar i = 0; i < 13; i=i+1) begin
        always @(*) begin
            case (multiplier_extended[2*i +: 3])
            3'b000: partials[i] <= 25'b0;
            3'b001: partials[i] <= {2'b0, multiplicand};
            3'b010: partials[i] <= {2'b0, multiplicand};
            3'b011: partials[i] <= {1'b0, multiplicand, 1'b0};
            3'b100: partials[i] <= {multiplicand_complement, 1'b0};
            3'b101: partials[i] <= {multiplicand_complement[24], multiplicand_complement};
            3'b110: partials[i] <= {multiplicand_complement[24], multiplicand_complement};
            3'b111: partials[i] <= 25'b0;
            endcase
        end
    end

    assign p0  = partials[0];
    assign p1  = partials[1];
    assign p2  = partials[2];
    assign p3  = partials[3];
    assign p4  = partials[4];
    assign p5  = partials[5];
    assign p6  = partials[6];
    assign p7  = partials[7];
    assign p8  = partials[8];
    assign p9  = partials[9];
    assign p10 = partials[10];
    assign p11 = partials[11];  
    assign p12 = partials[12];  
endmodule
