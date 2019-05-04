`timescale 1ns / 1ps

module LeadingZeroCount #(BIT_WIDTH=1) (
    input [BIT_WIDTH-1:0] in,
    output [$clog2(BIT_WIDTH)-1:0] out
    );
    
    wire [$clog2(BIT_WIDTH)-1:0] ldz;
    wire [2**$clog2(BIT_WIDTH)-1:0] temp [$clog2(BIT_WIDTH)-1:0];
    
    assign temp[$clog2(BIT_WIDTH)-1] = {in, {(2**$clog2(BIT_WIDTH))-BIT_WIDTH{1'b0}}};
    
    genvar i;
    for (i = $clog2(BIT_WIDTH)-1; i >= 0; i=i-1) begin
        assign ldz[i] = temp[i][2**i +: 2**i] == 0;
        if (i != 0) assign temp[i-1] = ldz[i] ? temp[i][0 +: 2**i] : temp[i][2**i +: 2**i];
    end
    
    assign out = (in != {BIT_WIDTH-1{1'b0}}) ? ldz : BIT_WIDTH;
    
endmodule
