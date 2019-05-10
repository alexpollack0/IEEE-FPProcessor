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

    localparam ADD = 1'b0, SUB = 1'b1;

    localparam INIT = 3'b000, SWAP_COMP = 3'b001, SHIFTB = 3'b010, NORM = 3'b011,
                ADD_SHIFT = 3'b100, ADJUST =3'b101, ROUND_COMP = 3'b110, DONE = 3'b111;

    TwosComplement #(.BIT_WIDTH(24)) twoB(.in(bFract), .out(bFractComp));
    TwosComplement #(.BIT_WIDTH(25)) compShift(.in({1'b0, bFract}), .out(compShiftRegB));
    TwosComplement #(.BIT_WIDTH(48)) compShiftOut(.in({22'b0, shiftedOut}), .out(compShiftedOut));
    
    VariableCLA #(.SIZE(5)) fourS(.a({8'b0, shiftRegB}), .b({8'b0, aFract}), .c_in(1'b0), .s(regSTemp), .c_out(fiveCOut));
    assign fiveCOut = regSTemp[24];
    
    
    TwosComplement #(.BIT_WIDTH(24)) fourComp(.in(regSTemp[23:0]), .out(regSTwosComp));
    
    NormalizeReg #(.BIT_WIDTH(24))fiveNormalize(.mantissa_in(regS), .mantissa_out(normalizedFiveS), .shiftNum(fiveBitShift));
    
    VariableCLA #(.SIZE(5)) sevenRound(.a({8'b0, regFiveS}), .b({31'b0, 1'b1}), .c_in(1'b0), .s(roundedVal), .c_out(roundCOut));
    
    VariableCLA #(.SIZE(5)) incOne(.a({24'b0, outExp}), .b({31'b0, 1'b1}), .c_in(1'b0), .s(incOutExp), .c_out(cTrash));
    VariableCLA #(.SIZE(3)) expDiff(.a(aExp), .b(~bExp), .c_in(1'b1), .s(d), .c_out(cTrash));
    VariableCLA #(.SIZE(3)) subExp(.a(outExp), .b(~{3'b0,fiveBitShift}), .c_in(1'b1), .s(subOutExp), .c_out(cTrash));
    
    always @(negedge clk or negedge reset) begin

      if(!reset) begin
        state <= INIT;
      end
      else begin
        state <= next_state;
        #1 $display("SETTING STATE: %d", state);
      end

    end


    integer i;
    always @(posedge clk) begin

        case(state)

            // Initialize the registers holding the sign, exponent, and fractional values
            // Step 0
            INIT: begin

              aSign <= a[31];
              aExp <= a[30:23];
              bExp <= b[30:23];
              aFract <= {1'b1, a[22:0]};
              bFract <= {1'b1, b[22:0]};
              next_state <= SWAP_COMP;

              outExp <= 0;
              setComp <= 0;
              swapped <= 0;

              // TODO: Must take twos complement if subtraction
              if(op) begin
                  bSign = ~b[31];
              end
              else begin
                  bSign = b[31];
              end

            end

            // If aExp < bExp, swap the operands
            // If the signs of the two exponents differ, replace b's fraction by its twos complement
            // Steps 1, 2
            SWAP_COMP: begin
             
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

            // Step 3
            SHIFTB: begin
              
              
              $display("Shifting b by %d", d);
              
              if(aSign != bSign) begin
                $display("compShiftRegB before shifting: %b", compShiftRegB);
                shiftRegB = compShiftRegB >>> d;
                shiftedOut = {compShiftRegB, 24'b0};
                
                $display("shiftRegB: %b", shiftRegB);
                $display("shiftedOut: %b", shiftedOut);
              end
              else begin
                shiftRegB = bFract >>> d;
                shiftedOut = {1'b0, bFract, 24'b0};
              end
              
              shiftedOut = shiftedOut >>> d;
              $display("After shifting shiftedOut: %b", shiftedOut);

              next_state = ADD_SHIFT;

            end

            // Steps 4, 5
            ADD_SHIFT: begin

              $display("Inside ADD_SHIFT");
              // Finish initialization from Step 3
              next_state <= NORM;
              
              guard = shiftedOut[23];
              round = shiftedOut[22];
              sticky = |shiftedOut[21:0];

              // Step 4

                
              $display("regSTemp: %b", regSTemp);

              // Add aFract to shiftRegB (call output register regS)
              regS = regSTemp[23:0];

              $display("regS: %b", regS);

              // This can only possibly be hit when totalShift = 0
              if(aSign != bSign && regS[22] && !regSTemp[24]) begin
                regS = regSTwosComp;
                $display("Replaced regS with regSTwosComp");
                bSign = aSign;
                setComp = 1;
              end

              $display("Carry out: %b", fiveCOut);
              

            end
            
            NORM: begin
            
              // Step 5
              if(aSign == bSign && regSTemp[24]) begin
                $display("Carry out, shifting in 1");
                regFiveS = {1'b1, regS[23:1]};
                $display("regFiveS: %b", regFiveS);
                fiveLeft = 0;
              end
              else begin
                $display("No carry out, using normalized version - %b", normalizedFiveS);
                $display("Guard: %b", guard);
                $display("Shifted left by %d", fiveBitShift);
                regFiveS = normalizedFiveS;
                regFiveS[fiveBitShift-1] = guard;
                fiveLeft = 1;
              end

              // Adjust the exponent of the result
              if(fiveLeft) begin
                outExp = subOutExp;
              end
              else begin
                outExp = incOutExp[7:0];
                $display("outExp incrementing by 1 - %b", outExp);
              end

              $display("Next state set to ADJUST");
              next_state <= ADJUST;
            
            end

            // Step 6
            ADJUST: begin

              $display("Inside ADJUST");
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

            // Steps 7, 8
            ROUND_COMP: begin

              $display("Inside ROUND_COMP");
              $display("Output fract value pre round: %b", regFiveS);
              // Step 7: Round to nearest even
              if((round && regFiveS[23]) || (round && sticky)) begin
                $display("Rounding baby!");
                // Add 1
                regFiveS <= roundedVal[23:0];
              end

              // Step 8
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
              $display("Inside DONE");
              outFract <= regFiveS[22:0];
            end

        endcase

    end



endmodule
