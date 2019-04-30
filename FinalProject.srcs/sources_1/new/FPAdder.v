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
    output [31:0] res;

    reg [2:0] state, next_state;

    // Values to extract in INIT
    reg aSign, bSign;
    reg [7:0] aExp, bExp;
    reg [22:0] aFract, bFract, bFractComp;

    reg tempSign;
    reg [7:0] tempExp;
    reg [22:0] tempFract;

    reg swapped;
    reg setComp;
    reg [22:0] shiftRegB; // TODO: This needs to be a p-bit register, is 23 bits correct?
    reg [22:0] shiftedOut; // TODO: Determine width
    reg [22:0] regS;
    reg [22:0] regFiveS;
    reg cOut;

    reg d, totalShift; // TODO: Determine width
    reg guard, round, sticky;
    reg fiveLeft;

    localparam ADD = 1'b0, SUB = 1'b1;

    localparam INIT = 3'b000, SWAP_COMP = 3'b001, SHIFTB = 3'b010, SHIFT_DIRECT = 3'b011,
                ADD_SHIFT = 3'b100, ADJUST =3'b101, ROUND_COMP = 3'b110;

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

              if(aSign != bSign) begin
                bFract = bFractComp;
                setComp = 1;
              end

              next_state <= SHIFTB
            end

            // Step 3
            SHIFTB: begin
              d = aExp - bExp; // TODO: Implement this in a proper manner (with a subtractor)
              totalShift = d;
              shiftRegB = bFract;
              if(d > 0) begin
                next_state = SHIFT_DIRECT;
              end
              else begin
                next_state = ADD_SHIFT;
              end

            end

            // Step 3 (continued)
            SHIFT_DIRECT: begin

              shiftedOut = {shiftedOut[21:0], shiftRegB[0]};

              if(setComp) begin
                shiftRegB = {1'b1, shiftRegB[22:1]};
              end
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
              for(i = 0; i < totalShift; i = i + 1) begin // TODO: Can we use 'for' loops (curious because of addition)
                if(i == (totalShift - 1)) begin
                  guard = shiftedOut[i];
                end
                else if(i == (totalShift - 2)) begin
                  round = shiftedOut[i];
                end
                else begin
                  if(shiftedOut[i]) begin
                    sticky = 1;
                  end
                end
              end

              // Step 4
              // TODO: Add aFract to shiftRegB (call output reg regS)

              // This can only possibly be hit when totalShift = 0
              if(aSign != bSign && regS[22] && !cOut) begin
                regS = regSTwosComp;
              end

              // Step 5
              if(aSign == bSign && !cOut) begin
                regFiveS = {1'b1, S[21:0]};
                fiveLeft = 0;
              end
              // TODO: Shift S left until it is normalized
              else begin

                fiveLeft = 1;
              end

              // TODO: Adjust the exponent of the result

            end

            // Step 6
            ADJUST: begin

              if(fiveLeft) begin

              end
              else begin
                round = regS[0];
                sticky = guard | round | sticky;
              end

            end

            // Steps 7, 8
            ROUND_COMPUTE: begin

              if(aSign != bSign) begin
                if(swapped) begin

                end
              end

            end

        endcase

    end



endmodule
