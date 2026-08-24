`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.05.2026 14:27:02
// Design Name: 
// Module Name: TOP
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


module TOP(
    input clk,
    input reset,
    input rx,
    input wr_en,
    input ready_clr,
    input [7:0] data_in,
    output tx,
    output [7:0] data_out,
    output ready,
    output busy
);

    // Internal wires connecting the baud rate generator to TX and RX
    wire tx_en;
    wire rx_en;

    // Instantiate Baud Rate Generator
    BAUD_RATE_GENERATOR baud_gen_inst (
        .clk(clk),
        .reset(reset),
        .tx_en(tx_en),
        .rx_en(rx_en)
    );

    // Instantiate UART Transmitter
    TX tx_inst (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .en(tx_en),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );

    // Instantiate UART Receiver
    RX rx_inst (
        .clk(clk),
        .reset(reset),
        .ready_clr(ready_clr),
        .clk_en(rx_en),
        .rx(rx),
        .data_out(data_out),
        .ready(ready)
    );

endmodule

