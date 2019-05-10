`timescale 1ns / 1ps

module Xmit(clock, reset, switches, tx_wr, rx_done, UART_TX, LED);
  input clock; // millisecond clock
  input reset; // input reset signal from button 0
  input [7:0] switches; // input 8 switches for use to input data to send
  input tx_wr; // input write signal to begin serial transmission
  input rx_done; // input acknowledge that the receiver has acknowledged the data

  output reg UART_TX; // TODO: Determine bit width for serial data output
  output reg [1:0] LED;
  wire parity;

  reg [4:0] rx_pointer;
  reg [4:0] tx_pointer;

  integer i;
  reg [7:0] fifo [15:0];
  
  reg [1:0] transmitting;
  reg [3:0] counter;
  
  wire [10:0] to_transmit;
  
  reg [3:0] waiting;

  GenParity par(.data(fifo[tx_pointer]), .parity(parity));
  
  always @(posedge clock or posedge reset) begin
    // Reset pulled high, reset pointers and clear fifo
    if (reset) begin
        rx_pointer <= 0;
        tx_pointer <= 0;
        for(i = 0; i < 16; i = i + 1) begin
          fifo[i] <= 0;
        end
        UART_TX = 1;
        LED = 0;
        transmitting = 2'b00;
    end 
    // Request to send data made
    else if (tx_wr == 1) begin
        LED[0] = 1;
        // Store switch data in fifo
        fifo[rx_pointer] = switches;
        rx_pointer = rx_pointer + 1;
        // Ensure we have data to send
        if(rx_pointer != tx_pointer) begin
            LED[1] = 1;
            // send data out UART_TX
            transmitting <= 2'b1;
            counter <= 10;
        end
    end
    else if (rx_done == 1) begin
      tx_pointer = tx_pointer + 1; // Next time, send next value
      transmitting = 2'b0;
    end
    else begin
        case (transmitting)
        // Transmitting data
        2'b01:  begin
                    UART_TX = to_transmit[counter];
                    counter = counter - 1;
                    if (counter == 4'b1111) begin
                        transmitting = 2'b10;
                        waiting = 0;
                        counter = 10;
                    end
                end
        // Waiting for achknoledgement
        2'b10:  begin
                    waiting = waiting + 1;
                    if (waiting > 5) transmitting = 2'b01;
                end
        endcase
    end
  end
  
assign to_transmit = {1'b0, fifo[tx_pointer], parity, 1'b1};

endmodule
