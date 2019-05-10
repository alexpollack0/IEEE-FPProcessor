`timescale 1ns / 1ps

module FPProcessor(
    input clk,
    input rst,
    input [1:0] SW,
    input UART_RX,
    output UART_TX
);
  
// UART Signals
wire        [15: 0] divisor;
wire        [ 7: 0] rx_data;
wire                rx_irq;
reg         [ 7: 0] tx_data;
reg                 tx_wr;
wire                tx_irq;
wire                tx_tcvr;

// Data collection
reg [71:0] recv_data;
reg [4:0] data_cnt;

// Adder/Multiplier
reg [1:0] selection;
reg [31:0] input_a;
reg [31:0] input_b;
wire [31:0] addsubResult;
wire [31:0] multResult;
  
/*************************************************************/
//                  RS-232 TRANCEIVER                        //
/*************************************************************/
parameter clk_freq = 100000000;
parameter baud = 115200;
assign UART_TX = (SW[0]) ? UART_RX : tx_tcvr;
assign divisor = clk_freq/baud/16;

uart_transceiver transceiver(
	.sys_clk(clk),
	.sys_rst(rst),
	.uart_rx(UART_RX),
	.uart_tx(tx_tcvr),
	.divisor(divisor),
	.rx_data(rx_data),
	.rx_done(rx_irq),
	.tx_data(tx_data),
	.tx_wr(tx_wr),
	.tx_done(tx_irq)
);

/*************************************************************/
//                  Data Collection                          //
/*************************************************************/
always @(posedge rx_irq) begin
    // Shift new data into recv_data register
    recv_data <= {rx_data, recv_data[135:0]};
    data_cnt <= data_cnt + 1; // TODO replace with CLA
end

always @(posedge clk) begin
    if (data_cnt == 18) begin
        case (recv_data[71:64])
        8'h01: begin // Subtraction
            selection <= 2'b01;
        end
        8'h10: begin // Multiplication
            selection <= 2'b10;
        end
        default: begin // Addition
            selection <= 2'b00;
        end
        endcase
        
        input_a = recv_data[63:32];
        input_a = recv_data[31:0];
    end
end

FPAdder addsub(.reset(rst),.clk(clk),.a(input_a),.b(input_b),.op(selection[0]),.outSign(addsubResult[31]),.outExp(addsubResult[30:23]),.outFract(addsubResult[22:0]));

FPMultipllier mult(.clk(clk),.reset(rst),.multiplier(input_a),.multiplicand(input_b),.result(multResult));

endmodule