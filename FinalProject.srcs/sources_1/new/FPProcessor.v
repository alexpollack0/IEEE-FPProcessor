`timescale 1ns / 1ps

module FPProcessor(
    input clk,
    input rst,
    input UART_RX,
    output UART_TX,
    output [15:0] LEDS
);
  
// UART Signals
wire        [15: 0] divisor;
wire        [ 7: 0] rx_data;
wire                rx_irq;
wire         [ 7: 0] tx_data;
reg                 tx_wr;
wire                tx_irq;

// Data collection
reg [71:0] recv_data;
reg [3:0] data_cnt;

// Adder/Multiplier
reg [1:0] selection;
reg [31:0] input_a;
reg [31:0] input_b;
wire [31:0] addsubResult;
wire [31:0] multResult;

reg start_count;
reg [4:0] count;

reg [2:0] tx_pointer;
wire [7:0] out_buffer [3:0];
  
reg tst;
  
/*************************************************************/
//                  RS-232 TRANCEIVER                        //
/*************************************************************/
parameter clk_freq = 100000000;
parameter baud = 115200;
assign divisor = clk_freq/baud/16;

uart_transceiver transceiver(
	.sys_clk(clk),
	.sys_rst(rst),
	.uart_rx(UART_RX),
	.uart_tx(UART_TX),
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
always @(posedge clk) begin
    if (rst) begin
        data_cnt <= 0;
        selection <=0;
        tx_wr <=0;
        count <= 0;
        start_count <= 0;
        tx_pointer <= 0;
        tst <= 0;
    end else if (rx_irq) begin
        // Shift new data into recv_data register
        recv_data <= {recv_data[71:8], rx_data};
        data_cnt <= data_cnt + 1; // TODO replace with CLA    
    end else if (data_cnt == 9) begin
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
        input_b = recv_data[31:0];
        
        data_cnt <= 0;
        
        count <= 0;
        start_count <= 1;
    end else if (start_count) begin
        if (count < 10) count = count + 1;
        if (count == 10) start_count <= 0;
    end else if (count == 10) begin        
        count = 0;
        tx_pointer = 0;
        tx_wr = 1;
    end else if (tx_irq) begin
        tst = 1;
        if (tx_pointer == 2'd3) begin
            tx_pointer = 0;
        end else begin
            tx_pointer = tx_pointer + 1;
            tx_wr = 1;
        end
    end else if (tx_wr == 1) tx_wr = 0;
end

// TODO fix this when adding multiplier
assign out_buffer[0] = addsubResult[31:24];
assign out_buffer[1] = addsubResult[23:16];
assign out_buffer[2] = addsubResult[15:8];
assign out_buffer[3] = addsubResult[7:0];

assign tx_data = out_buffer[tx_pointer];

assign LEDS = addsubResult[31:16];

FPAdder addsub(.reset(rst),.clk(clk),.a(input_a),.b(input_b),.op(selection[0]),.outSign(addsubResult[31]),.outExp(addsubResult[30:23]),.outFract(addsubResult[22:0]));

//FPMultiplier mult(.clk(clk),.reset(rst),.multiplier(input_a),.multiplicand(input_b),.result(multResult));

endmodule