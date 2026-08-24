`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.05.2026 14:31:44
// Design Name: 
// Module Name: BAUD_RATE_GENERATOR
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


module BAUD_RATE_GENERATOR #(
    parameter CLK_FREQ = 100_000_000, // Default 100 MHz clock
    parameter BAUD_RATE = 9600        // Default 9600 baud
)(
    input clk,
    input reset,
    output reg tx_en,
    output reg rx_en
);

    // Calculate maximum counter values
    localparam RX_MAX = CLK_FREQ / (BAUD_RATE * 16);
    localparam TX_MAX = CLK_FREQ / BAUD_RATE;
    
    reg [31:0] rx_counter;
    reg [31:0] tx_counter;

    // RX Enable Generator (16x Oversampling)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_counter <= 0;
            rx_en <= 0;
        end else begin
            if (rx_counter == RX_MAX - 1) begin
                rx_counter <= 0;
                rx_en <= 1'b1;
            end else begin
                rx_counter <= rx_counter + 1;
                rx_en <= 1'b0;
            end
        end
    end

    // TX Enable Generator (1x Baud Rate)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_counter <= 0;
            tx_en <= 0;
        end else begin
            if (tx_counter == TX_MAX - 1) begin
                tx_counter <= 0;
                tx_en <= 1'b1;
            end else begin
                tx_counter <= tx_counter + 1;
                tx_en <= 1'b0;
            end
        end
    end

endmodule
