`timescale 1ns / 1ps

module LeadingZeroCount_tb(

    );
    
    reg [24:0] in;
    wire [4:0] out;
    
    LeadingZeroCount #(.BIT_WIDTH(24)) UUT(.in(in), .out(out));
    
    reg [4:0] expected;
    
    integer i;
    initial begin
        for (in = 1; in <= (2**24-1); in=in<<1) begin
            expected = 24;
            
            for (i = 23; i >= 0; i=i-1) begin
                if (in[i] == 1'b1) begin
                    if (expected == 24) expected = 23-i;
                end
            end
            
            #10 $display("in = %b, # zeros = %d", in, out);
            if (out != expected) $display("Error, out should be %d, is %d", expected, out);
        end
        
        for (in = 0; in <= (2**24-1); in=in+1) begin
            expected = 24;
            
            for (i = 23; i >= 0; i=i-1) begin
                if (in[i] == 1'b1) begin
                    if (expected == 24) expected = 23-i;
                end
            end
            
            #10 $display("in = %b, # zeros = %d", in, out);
            if (out != expected) $display("Error, out should be %d, is %d", expected, out);
        end
    end
    
endmodule
