`timescale 1ns / 1ps

module NormalizeReg #(BIT_WIDTH=1) (
    input [BIT_WIDTH-1:0] mantissa_in,
    output [BIT_WIDTH-1:0] mantissa_out,
    output [$clog2(BIT_WIDTH)-1:0] shiftNum
    );

    wire [2*BIT_WIDTH-1:0] extended_mantissa;

    assign extended_mantissa[2*BIT_WIDTH-1 -: BIT_WIDTH] = {BIT_WIDTH{1'b0}};

    genvar i;
    for (i = 0; i < BIT_WIDTH; i=i+1) begin
        assign extended_mantissa[i] = mantissa_in[(BIT_WIDTH-1)-i];
    end
    
    genvar j;
    for (j = 0; j < BIT_WIDTH; j=j+1) begin
        assign mantissa_out[(BIT_WIDTH-1)-j] = extended_mantissa[shiftNum+j];
    end
    //assign mantissa_out = extended_mantissa[shiftNum -: BIT_WIDTH];
    
    LeadingZeroCount #(.BIT_WIDTH(BIT_WIDTH)) ldz(.in(mantissa_in), .out(shiftNum));

endmodule
