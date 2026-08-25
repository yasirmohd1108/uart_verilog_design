`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Mohammad Yasir 
// Create Date: 04.05.2026
// Design Name: UART Controller
// Module Name: RX
// Project Name: UART TX+RX
// Description: UART Receiver module utilizing a 16x oversampling scheme.
//              Detects start bits, samples incoming serial data (rx) at 
//              the mid-bit point (sample 7), and latches 8-bit output data.
//////////////////////////////////////////////////////////////////////////////////

module RX(
    input clk,reset,ready_clr,clk_en,rx,
    output reg[7:0] data_out,
    output reg ready
    );
parameter start_state = 2'b00;
parameter data_state = 2'b01;
parameter stop_state = 2'b10;

reg [3:0]index = 4'd0;
reg [1:0]state = start_state;
reg [3:0]sample = 4'd0;
reg [7:0]temp_data = 8'd0;

always @(posedge clk) begin
    if (reset) begin
        ready <= 1'b0;
        data_out <= 8'd0;
        state <= start_state;
        sample <= 4'd0;
        index <= 4'd0;
        temp_data <= 8'd0;
    end else begin
        if (ready_clr) begin
            ready <= 1'b0;
        end
        if (clk_en) begin
            case(state)
                start_state: begin
                    if (rx == 1'b0 || sample != 4'd0) begin
                        if (sample == 4'd15) begin
                            sample <= 4'd0;
                            state <= data_state;
                            index <= 4'd0;
                            temp_data <= 8'd0;
                        end else begin
                            sample <= sample + 1'b1;
                        end
                    end
                end
                
                data_state: begin
                    if (sample == 4'd7) begin
                        temp_data[index] <= rx;
                    end
                    
                    if (sample == 4'd15) begin
                        sample <= 4'd0;
                        if (index == 4'd7) begin
                            state <= stop_state;
                        end else begin
                            index <= index + 1'b1;
                        end
                    end else begin
                        sample <= sample + 1'b1;
                    end
                end
                
                stop_state: begin
                    if (sample == 4'd15) begin
                        state <= start_state;
                        data_out <= temp_data;
                        ready <= 1'b1;
                        sample <= 4'd0;
                    end else begin
                        sample <= sample + 1'b1;
                    end
                end
                
                default: begin
                    state <= start_state;
                end
            endcase
        end
    end
end

endmodule
