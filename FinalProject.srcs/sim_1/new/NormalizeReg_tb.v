`timescale 1ns / 1ps

module NormalizeReg_tb(

    );
    
    reg [23:0] in;
    wire [23:0] out;
    wire [4:0] shift;
    
    NormalizeReg #(.BIT_WIDTH(24)) UUT(.mantissa_in(in), .mantissa_out(out), .shiftNum(shift));
    
    reg [23:0] expected_out;
    reg [4:0] expected_shift;
    
    reg [47:0] tmp;
    
    integer i;
    initial begin
        for (in = 1; in <= (2**24-1); in=in+1) begin
            expected_shift = 24;
            
            for (i = 23; i >= 0; i=i-1) begin
                if (in[i] == 1'b1) begin
                    if (expected_shift == 24) expected_shift = 23-i;
                end
            end
            
            tmp = {in,24'b0};
            
            expected_out = tmp[(47-expected_shift) -: 24];
            
            #10 $display("in = %b, out = %b, shifted = %d", in, out, shift);
            if (out != expected_out) $display("Error, out should be %b, is %b", expected_out, out);
            if (shift != expected_shift) $display("Error, shift should be %d, is %d", expected_shift, shift);
        end
    end
endmodule
