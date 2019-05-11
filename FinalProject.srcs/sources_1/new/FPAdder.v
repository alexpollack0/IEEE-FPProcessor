`timescale 1ns / 1ps

module FPAdder(reset, clk, a, b, op, outSign, outExp, outFract);

    input reset, clk;
    input op; // 0 = addition, 1 = subtraction
    input [31:0] a, b;
    output reg outSign;
    output reg [7:0] outExp;
    output reg [22:0] outFract;

    reg [2:0] state, next_state;

    // Values to extract in INIT
    reg aSign, bSign;
    reg [7:0] aExp, bExp;
    reg [23:0] aFract, bFract;
    wire [23:0] bFractComp;

    reg tempSign;
    reg [7:0] tempExp;
    reg [23:0] tempFract;

    reg swapped;
    reg setComp;
    reg [23:0] shiftRegB;
    wire signed [24:0] compShiftRegB;
    reg signed [47:0] shiftedOut; 
    wire [47:0] compShiftedOut;
    wire [31:0] regSTemp;
    reg [23:0] regS;
    wire [23:0] regSTwosComp;
    reg [23:0] regFiveS;
    wire [23:0] finalRes;
    wire [23:0] normalizedFiveS;
    wire [4:0] fiveBitShift;
    wire fiveCOut;
    wire roundCOut;
    wire [7:0] subOutExp;

    wire [7:0] d; 
    reg guard, round, sticky;
    reg fiveLeft;

    reg [3:0] eightCase;
    
    wire [31:0] roundedVal;
    
    wire [31:0] incOutExp;
    wire cTrash;
    wire [4:0] normTrash;

    localparam ADD = 1'b0, SUB = 1'b1;

    localparam INIT = 3'b000, SWAP = 3'b001, SHIFTB = 3'b010, NORM = 3'b011,
                ADD_SHIFT = 3'b100, ADJUST =3'b101, ROUND_COMP = 3'b110, DONE = 3'b111;

    TwosComplement #(.BIT_WIDTH(24)) twoB(.in(bFract), .out(bFractComp));
    TwosComplement #(.BIT_WIDTH(25)) compShift(.in({1'b0, bFract}), .out(compShiftRegB));
    TwosComplement #(.BIT_WIDTH(48)) compShiftOut(.in({22'b0, shiftedOut}), .out(compShiftedOut));    
    VariableCLA #(.SIZE(5)) fourS(.a({8'b0, shiftRegB}), .b({8'b0, aFract}), .c_in(1'b0), .s(regSTemp), .c_out(fiveCOut));    
    TwosComplement #(.BIT_WIDTH(24)) fourComp(.in(regSTemp[23:0]), .out(regSTwosComp));    
    NormalizeReg #(.BIT_WIDTH(24))fiveNormalize(.mantissa_in(regS), .mantissa_out(normalizedFiveS), .shiftNum(fiveBitShift));    
    VariableCLA #(.SIZE(5)) sevenRound(.a({8'b0, regFiveS}), .b({31'b0, 1'b1}), .c_in(1'b0), .s(roundedVal), .c_out(roundCOut));    
    VariableCLA #(.SIZE(5)) incOne(.a({24'b0, outExp}), .b({31'b0, 1'b1}), .c_in(1'b0), .s(incOutExp), .c_out(cTrash));
    VariableCLA #(.SIZE(3)) expDiff(.a(aExp), .b(~bExp), .c_in(1'b1), .s(d), .c_out(cTrash));
    VariableCLA #(.SIZE(3)) subExp(.a(outExp), .b(~{3'b0,fiveBitShift}), .c_in(1'b1), .s(subOutExp), .c_out(cTrash));    
    NormalizeReg #(.BIT_WIDTH(24))finalNorm(.mantissa_in(regFiveS), .mantissa_out(finalRes), .shiftNum(normTrash));
    
    assign fiveCOut = regSTemp[24];
    
    reg aPosInf, aNegInf, bPosInf, bNegInf;
    reg [4:0] inf;
    
    always @(negedge clk or negedge reset) begin

      if(!reset) begin
        state <= INIT;
      end
      else begin
        state <= next_state;
      end

    end


    integer i;
    always @(posedge clk) begin

        case(state)

            // Initialize the registers holding the sign, exponent, and fractional values
            INIT: begin

              // NaN
              if((a[30:23] == 8'hff && a[22:0] != 0) || (b[30:23] == 8'hff && b[22:0] != 0)) begin
                outExp = 8'hff;
                outFract = 23'b1;
                outSign = 1'b0;
                next_state = DONE;
              end
              // Inf
              else if((a[30:23] == 8'hff && a[22:0] == 23'b0)
                        || (b[30:23] == 8'hff && b[22:0] == 23'b0)) begin
                        
                if(a[30:23] == 8'hff && a[22:0] == 23'b0) begin
                    case(a[31])
                        // a is positive infinity
                        1'b0: begin
                            aPosInf = 1; 
                            aNegInf = 0;
                        end
                        // a is negative infinity
                        1'b1: begin
                            aNegInf = 1; 
                            aPosInf = 0;
                        end
                    endcase
                end
                else begin
                    aPosInf = 0;
                    aNegInf = 0;
                end
                if(b[30:23] == 8'hff && b[22:0] == 23'b0) begin
                    case(b[31])
                        // a is positive infinity
                        1'b0: begin
                            bPosInf = 1; 
                            bNegInf = 0;
                        end
                        // a is negative infinity
                        1'b1: begin
                            bNegInf = 1; 
                            bPosInf = 0;
                        end    
                    endcase
                end
                else begin
                    bPosInf = 0;
                    bNegInf = 0;
                end
                
                inf = {aPosInf, aNegInf, bPosInf, bNegInf, op};
                case(inf)
                    5'b00000: begin
                        // This should never happen
                    end
                    // a + negInf = negInf
                    5'b00010: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b1;
                    end
                    // a + posInf = posInf
                    5'b00100: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b0;
                    end
                    5'b00110: begin
                        // This should never hapen
                    end
                    // negInf + b = negInf
                    5'b01000: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b1;
                    end
                    // negInf + negInf = negInf
                    5'b01010: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b1;                
                    end
                    // nefInf + posInf = NaN
                    5'b01100: begin
                        outExp = 8'hff;
                        outFract = 23'b1;
                        outSign = 1'b0;                    
                    end
                    5'b01110: begin
                        // This should never happen
                    end
                    // posInf + b = posInf
                    5'b10000: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b0;
                    end
                    // posInf + negInf = NaN
                    5'b10010: begin
                        outExp = 8'hff;
                        outFract = 23'b1;
                        outSign = 1'b0;                    
                    end
                    // posInf + posInf = posInf
                    5'b10100: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b0;                    
                    end
                    5'b10110: begin
                        // This should never happen
                    end
                    5'b11000: begin
                        // This should never happen
                    end
                    5'b11010: begin
                        // This should never happen
                    end
                    5'b11100: begin
                        // This should never happen
                    end
                    5'b11110: begin
                       // This should never happen
                    end
                    5'b00001: begin
                        // This should never happen
                    end
                    // a - negInf = posInf
                    5'b00011: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b0;     
                    end
                    // a - posInf = negInf
                    5'b00101: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b1;
                    end
                    5'b00111: begin
                        // This should never happen
                    end
                    // negInf - b = negInf
                    5'b01001: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b1;
                    end
                    // negInf - negInf  = NaN
                    5'b01011: begin
                        outExp = 8'hff;
                        outFract = 23'b1;
                        outSign = 1'b0; 
                    end
                    // negInf - posInf = negInf
                    5'b01101: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b1;
                    end
                    5'b01111: begin
                        // This should never happen
                    end
                    // posInf - b = posInf
                    5'b10001: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b0;     
                    end
                    // posInf - negInf = posInf
                    5'b10011: begin
                        outExp = 8'hff;
                        outFract = 23'b0;
                        outSign = 1'b0;     
                    end
                    // posInf - posInf = NaN
                    5'b10101: begin
                        outExp = 8'hff;
                        outFract = 23'b1;
                        outSign = 1'b0; 
                    end
                    5'b10111: begin
                        // This should never happen
                    end
                    5'b11001: begin
                        // This should never happen                    
                    end
                    5'b11011: begin
                        // This should never happen                   
                    end
                    5'b11101: begin
                        // This should never happen                    
                    end
                    5'b11111: begin
                        // This should never happen                    
                    end                    
                endcase
                
                next_state = DONE;
              end
              else begin
                  aSign = a[31];
                  aExp = a[30:23];
                  bExp = b[30:23];
                  if(aExp > 0) begin
                    aFract = {1'b1, a[22:0]};
                  end
                  else begin
                     aFract = {1'b0, a[22:0]};
                  end
                  if(bExp > 0) begin
                     bFract = {1'b1, b[22:0]};
                  end
                  else begin
                    bFract = {1'b0, b[22:0]};
                  end
                  next_state = SWAP;
    
                  outExp = 0;
                  setComp = 0;
                  swapped = 0;
    
                  // TODO: Must take twos complement if subtraction
                  if(op) begin
                      bSign = ~b[31];
                  end
                  else begin
                      bSign = b[31];
                  end
                  next_state <= ADJUST;
              end

            end

            SWAP: begin
             
              if(aExp < bExp) begin

                // Swap signs
                tempSign = aSign;
                aSign = bSign;
                bSign = tempSign;

                // Swap exponents
                tempExp = aExp;
                aExp = bExp;
                bExp = tempExp;

                // Swap fractions
                tempFract = aFract;
                aFract = bFract;
                bFract = tempFract;

                swapped = 1;

              end

              // Tentatively set the exponent of the result to e1
              outExp = aExp;

              next_state <= SHIFTB;
            end

            SHIFTB: begin
            
              if(aSign != bSign) begin
                shiftRegB = compShiftRegB >>> d;
                shiftedOut = {compShiftRegB, 24'b0};
              end
              else begin
                shiftRegB = bFract >>> d;
                shiftedOut = {1'b0, bFract, 24'b0};
              end
              
              shiftedOut = shiftedOut >>> d;

              next_state = ADD_SHIFT;

            end

            ADD_SHIFT: begin

              next_state <= NORM;
              
              guard = shiftedOut[23];
              round = shiftedOut[22];
              sticky = |shiftedOut[21:0];

              // Add aFract to shiftRegB (call output register regS)
              regS = regSTemp[23:0];

              // This can only possibly be hit when totalShift = 0
              if(aSign != bSign && regS[22] && !regSTemp[24]) begin
                regS = regSTwosComp;
                bSign = aSign;
                setComp = 1;
              end

              

            end
            
            NORM: begin
            
              if(aSign == bSign && regSTemp[24]) begin
                regFiveS = {1'b1, regS[23:1]};
                fiveLeft = 0;
              end
              else begin
                if(d == 0) begin
                    regFiveS = regS;
                end
                else begin
                    regFiveS = normalizedFiveS;
                    regFiveS[fiveBitShift-1] = guard;
                    fiveLeft = 1;
                end
              end

              // Adjust the exponent of the result
              if(fiveLeft) begin
                outExp = subOutExp;
              end
              else if(aSign == bSign && regSTemp[24]) begin
                outExp = incOutExp[7:0];
              end
              
            
            end

            ADJUST: begin

              if(fiveLeft) begin
                if(fiveBitShift > 1) begin
                  round = 0;
                  sticky = 0;
                end
                else if(fiveBitShift == 0) begin
                  round = guard;
                  sticky = round | sticky;
                end
              end
              else begin
                round = regS[0];
                sticky = guard | round | sticky;
              end

              next_state <= ROUND_COMP;

            end

            ROUND_COMP: begin

              if((round && regFiveS[23]) || (round && sticky)) begin
                // Add 1
                regFiveS <= roundedVal[23:0];
              end

              if(aSign != bSign) begin
                eightCase = {swapped, setComp, aSign, bSign};

                case(eightCase)
                  4'b1001: outSign = 1;
                  4'b1101: outSign = 1;
                  4'b0001: outSign = 0;
                  4'b0010: outSign = 1;
                  4'b0101: outSign = 1;
                  4'b0110: outSign = 0;
                  default: outSign = 0;
                endcase

              end
              else begin
                outSign = aSign;
              end

              next_state <= DONE;

            end

            DONE: begin
              if(outExp != 0 && outExp != 8'hff) begin
                 outFract = finalRes[22:0];
              end
              else if (outExp != 8'hff) begin
                 outFract = regFiveS[22:0];
              end
            end

        endcase

    end



endmodule
