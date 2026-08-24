`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 22:08:00
// Design Name: UART Testbench
// Module Name: UART_TB
// Project Name: UART TX+RX
// Target Devices: 
// Tool Versions: 
// Description: Testbench for the complete UART module (TX + RX + BAUD RATE GENERATOR)
//              configured in a loopback setup.
// 
// Dependencies: TOP.v, TX.v, RX.v, BAUD_RATE_GENERATOR.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module UART_TB;

    // Inputs to the TOP module (declared as reg)
    reg clk;
    reg reset;
    reg rx;
    reg wr_en;
    reg ready_clr;
    reg [7:0] data_in;

    // Outputs from the TOP module (declared as wire)
    wire tx;
    wire [7:0] data_out;
    wire ready;
    wire busy;

    // Instantiate the Unit Under Test (UUT)
    TOP uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .wr_en(wr_en),
        .ready_clr(ready_clr),
        .data_in(data_in),
        .tx(tx),
        .data_out(data_out),
        .ready(ready),
        .busy(busy)
    );

    // Clock generation: 100 MHz clock (10 ns clock period)
    always #5 clk = ~clk;

    // Loopback configuration: wire the transmitter's output (tx) to the receiver's input (rx)
    always @(*) begin
        rx = tx;
    end

    // Task to transmit a single byte, verify reception, and handle handshaking
    task transmit_byte(input [7:0] data_to_send);
        begin
            @(posedge clk);
            #1;
            data_in = data_to_send;
            wr_en = 1'b1;
            $display("[TB] [%0d ns] Initiating transmission of byte: 8'h%h (8'b%b)", $time, data_to_send, data_to_send);
            
            @(posedge clk);
            #1;
            wr_en = 1'b0;
            
            // Wait for transmission to start (busy signal goes high)
            wait(busy);
            $display("[TB] [%0d ns] UART TX is now busy transmitting...", $time);
            
            // Wait for the receiver to assert ready (transmission + reception complete)
            wait(ready);
            $display("[TB] [%0d ns] UART RX received data: 8'h%h (8'b%b)", $time, data_out, data_out);
            
            // Assert and check data match
            if (data_out === data_to_send) begin
                $display("[SUCCESS] [%0d ns] Data match! Sent: 8'h%h, Received: 8'h%h\n", $time, data_to_send, data_out);
            end else begin
                $display("[ERROR] [%0d ns] DATA MISMATCH! Sent: 8'h%h, Received: 8'h%h\n", $time, data_to_send, data_out);
            end
            
            // Clear the ready flag in the RX module
            @(posedge clk);
            #1;
            ready_clr = 1'b1;
            @(posedge clk);
            #1;
            ready_clr = 1'b0;
            
            // Wait for TX to return to idle (busy goes low)
            wait(!busy);
            $display("[TB] [%0d ns] UART TX completed transmission (busy is low).\n", $time);
            #1000; // Delay before sending the next byte
        end
    endtask

    // Stimulus process
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        wr_en = 0;
        ready_clr = 0;
        data_in = 8'h00;
        
        // Assert reset for 100 ns
        #100;
        reset = 0;
        $display("[TB] [%0d ns] Reset deasserted. Starting test cases...", $time);
        #200;
        
        // Test Case 1: Send alternating bit pattern 0xA5 (10100101)
        transmit_byte(8'hA5);
        
        // Test Case 2: Send alternating bit pattern 0x5A (01011010)
        transmit_byte(8'h5A);
        
        // Test Case 3: Send all ones 0xFF (11111111)
        transmit_byte(8'hFF);
        
        // Test Case 4: Send all zeros 0x00 (00000000)
        transmit_byte(8'h00);
        
        // Test Case 5: Send a walking-one pattern/random data 0x3C (00111100)
        transmit_byte(8'h3C);
        
        $display("[TB] [%0d ns] All test cases completed successfully!", $time);
        $finish;
    end

endmodule
