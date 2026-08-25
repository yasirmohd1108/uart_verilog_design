`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Mohammad Yasir 
// Create Date: 04.05.2026
// Design Name: UART Controller
// Module Name: TX
// Project Name: UART TX+RX
// Description: UART Transmitter state machine. Converts 8-bit parallel input 
//              data (data_in) into serial output frames (tx) with start, 
//              data, and stop bits driven by the tx_en clock enable.
//////////////////////////////////////////////////////////////////////////////////


module TX(
    input clk,reset,wr_en,en,
    input [7:0]data_in,
    output reg tx,
    output busy
        );
parameter idle_state = 2'b00;
parameter start_state = 2'b01;
parameter data_state = 2'b10;
parameter stop_state = 2'b11;

reg [7:0]data;
reg [2:0]index;
reg [1:0]state = idle_state;

always @(posedge clk) begin
        if (reset) begin
            state <= idle_state;
            tx <= 1'b1;
            data <= 8'd0;
            index <= 3'b000;
        end else begin
            case(state)
                idle_state:
                begin
                    if (wr_en)
                        begin
                            state <= start_state;
                            data <= data_in;  
                            index <= 3'b000; 
                        end 
                    else
                        state <= idle_state;
                end  
                 
                start_state:
                begin
                    if (en)
                        begin
                            tx <= 1'b0;
                            state <= data_state;
                        end 
                    else
                        state <= start_state;

                end 
                data_state:
                begin
                    if (en)
                        begin
                            tx <= data[index];
                            if (index == 3'b111)
                                begin
                                    state <= stop_state;
                                end
                            else
                                begin
                                    index <= index + 1;
                                    state <= data_state;
                                end
                        end
                end
                stop_state:
                begin       
                    if (en)
                        begin
                            tx <= 1'b1;
                            state <= idle_state;
                        end 
                    else
                        state <= stop_state;
                end
                default:
                begin
                    state <= idle_state;
                    tx <= 1'b1;   
                end 
            endcase
        end
    end
assign busy = (state != idle_state) ? 1'b1 : 1'b0;
endmodule
