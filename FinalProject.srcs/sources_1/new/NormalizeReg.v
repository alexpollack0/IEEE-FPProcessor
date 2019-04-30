`timescale 1ns / 1ps

module NormalizeReg #(SIZE=1) (
    input [2**SIZE:0] mantissa_in,
    output [2**SIZE:0] mantissa_out,
    output [SIZE-1:0] shiftNum
    );
    
    reg [SIZE-1:0] i;
    reg [SIZE-1:0] to_shift;
    reg [SIZE-1:0] temp;
    wire [2*SIZE-1:0] extended_mantissa;
    
    always @(mantissa_in) begin
        to_shift = 0;
        for (i = SIZE; i >=0; i=i-1) begin
            if (mantissa_in[i] == 1) begin
                if (to_shift == 0) to_shift <= i;
            end
        end
    end
    
    assign extended_mantissa = {mantissa_in,{SIZE{1'b0}}};
    
    assign mantissa_out = extended_mantissa[to_shift -: 2**SIZE];
    
    TwosComplement #(.SIZE(SIZE)) comp(.in(to_shift), .out(temp));
    
    VariableCLA #(.SIZE(SIZE)) cla(.a(2**SIZE), .b(temp), .c_in(1'b0), .s(shiftNum));
    
endmodule
