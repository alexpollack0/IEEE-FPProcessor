`timescale 1ns / 1ps

module Rcvr(clock, reset, UART_RX, tx_done, LED);
  input clock; // millisecond clock
  input reset; // input reset signal from button 0
  input UART_RX; // serial data input

  output reg tx_done; // output acknowledge that the data received is correct
  output reg [7:0] LED; // output to LEDs of the data received

  wire parity;
  
  GenParity par(.data(data[9:2]), .parity(parity));
  
  reg [10:0] data;
  reg state;
  reg [3:0] counter;

  always @(posedge clock, posedge reset) begin
    if (reset) begin
        state = 2'b00;
    end
    else
    begin
        if (tx_done == 1) tx_done = 0;
        case (state)
        // Waiting for start bit
        1'b0:  if (UART_RX == 0) begin
                    state = 1'b1;
                    data[10] = 1'b0;
                    counter = 9;
                end
        // Storing received data
        1'b1:  begin
                    data[counter] = UART_RX;
                    counter = counter - 1;
                    if (counter == 4'b1111) begin
                        if (parity == data[1]) begin
                            tx_done = 1;
                            LED = data[9:2];
                            state = 1'b0;
                        end else begin
                            state = 1'b0;
                        end
                    end
                end
        endcase
    end
  end

endmodule
