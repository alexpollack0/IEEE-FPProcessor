`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/25/2019 03:51:36 PM
// Design Name:
// Module Name: FPAdder
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module FPAdder(reset, clk, a, b, op, res);

    input reset, clk;
    input op; // 0 = addition, 1 = subtraction
    input [31:0] a, b;
    output outSign;
    output [31:0] res;

    reg [2:0] state, next_state;

    // Values to extract in INIT
    reg aSign, bSign;
    reg [7:0] aExp, bExp;
    reg [22:0] aFract, bFract;
    reg [31:0] bFractComp;

    reg tempSign;
    reg [7:0] tempExp;
    reg [22:0] tempFract;

    reg swapped;
    reg setComp;
    reg [22:0] shiftRegB; // TODO: This needs to be a p-bit register, is 23 bits correct?
    reg [22:0] shiftedOut; // TODO: Determine width
    reg [31:0] regSTemp;
    reg [22:0] regS;
    reg [22:0] regSTwosComp;
    reg [22:0] regFiveS;
    reg fiveCOut;

    reg d, totalShift; // TODO: Determine width
    reg guard, round, sticky;
    reg fiveLeft;

    reg [3:0] eightCase;

    localparam ADD = 1'b0, SUB = 1'b1;

    localparam INIT = 3'b000, SWAP_COMP = 3'b001, SHIFTB = 3'b010, SHIFT_DIRECT = 3'b011,
                ADD_SHIFT = 3'b100, ADJUST =3'b101, ROUND_COMP = 3'b110, DONE = 3'b111;

    TwosComplement #(.SIZE(5))twoB(.in({9'b0, bFract}), .out(bFractComp));

    VariableCLA #(.SIZE(5)) fourS(.a({9'b0, aFract}), .b({9'b0, aFract}), .c_in(1'b0), .s(regSTemp), .c_out(fiveCOut));

    TwosComplement #(.SIZE(5))twoB(.in({9'b0, regS}), .out({9'b0, regSTwosComp}));

    always @(clk) begin

        case(state)

            // Initialize the registers holding the sign, exponent, and fractional values
            // Step 0
            INIT: begin
              aSign <= a[31];
              bSign <= b[31];
              aExp <= a[30:23];
              bExp <= b[30:23];
              aFract <= a[22:0];
              bFract <= b[22:0];
              next_state <= SWAP_COMP;
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
              outSign = aExp;

              if(aSign != bSign) begin
                bFract = bFractComp[22:0];
                setComp = 1;
              end

              next_state <= SHIFTB
            end

            // Step 3
            SHIFTB: begin

              // Place b mantissa in a p-bit register
              shiftRegB = bFract;

              // Calculate d (how many bits to shift shiftRegB)
              d = aExp - bExp; // TODO: Implement this in a proper manner (with a subtractor)

              // Important to store for later
              totalShift = d;

              if(d > 0) begin
                next_state = SHIFT_DIRECT;
              end
              else begin
                next_state = ADD_SHIFT;
              end

            end

            // Step 3 (continued)
            SHIFT_DIRECT: begin

              shiftedOut = {shiftRegB[0], shiftedOut[21:0]};

              // Shift in 1's if b fraction was completed in Step 2
              if(setComp) begin
                shiftRegB = {1'b1, shiftRegB[22:1]};
              end
              // Otherwise, shift in 0's
              else begin
                shiftRegB = {1'b0, shiftRegB[22:1]};
              end

              d = d - 1; // TODO: Implement this in a proper manner (with a subtractor)
              if(d == 0) begin
                next_state = ADD_SHIFT;
              end
              else begin
                next_state = SHIFT_DIRECT;
              end

            end

            // Steps 4, 5
            ADD_SHIFT: begin

              // Finish initialization from Step 3
              sticky = 0;

              integer i;
              for(i = 22; i > totalShift; i = i - 1) begin
                if(i == 22) begin
                  guard = shiftedOut[i];
                end
                else if(i == 21) begin
                  round = shiftedOut[i];
                end
                else begin
                  if(shiftedOut[i]) begin
                    sticky = 1;
                  end
                end
              end

              // Step 4

              // Add aFract to shiftRegB (call output register regS)
              regS = regSTemp[22:0];

              // This can only possibly be hit when totalShift = 0
              if(aSign != bSign && regS[22] && !cOut) begin
                regS = regSTwosComp;
              end

              // Step 5
              if(aSign == bSign && !cOut) begin
                regFiveS = {1'b1, regS[22:1]};
                fiveLeft = 0;
              end
              else begin
                // On first left shift, fill in low-order position with the guard bit
                regFiveS = {S[21:0], guard};

                // TODO: Shift S left until it is normalized
                // Shifted value will be placed in regFiveS
                // Number of bits shifted will be in fiveBitShift

                fiveLeft = 1;
              end

              // TODO: Adjust the exponent of the result

            end

            // Step 6
            ADJUST: begin

              if(fiveLeft) begin
                if(fiveBitShift > 0) begin
                  round = 0;
                  shift = 0;
                end
              end
              else begin
                round = regS[0];
                sticky = guard | round | sticky;
              end

            end

            // Steps 7, 8
            ROUND_COMPUTE: begin

              // Step 7: Round to nearest even

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

            end

            DONE: begin

            end

        endcase

    end



endmodule
