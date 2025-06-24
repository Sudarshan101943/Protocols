`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2025 10:05:52 AM
// Design Name: 
// Module Name: Uart_rx
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


module Uart_rx(
    input clk,
    input rst,
    input rx,                // serial input
    output reg rx_done,      // asserted for 1 u_clk cycle when reception is complete
    output reg [7:0] data_out
);

    // UART configuration
    parameter system_clk = 1000000;   // 1 MHz
    parameter baudrate   = 9600;
    localparam clk_cycles = system_clk / baudrate;

    // FSM states
 
     parameter   idle = 2'b00;
     parameter start = 2'b01;
     parameter transfer = 2'b10;
     parameter   stop_bit = 2'b11;
  

    reg [1:0] state;

    // Internal signals
    reg [15:0] count = 0;          // clock divider
    reg [3:0] bit_count = 0;
    reg [7:0] rx_shift = 0;
    reg u_clk = 0;

    // UART bit clock generation (same as transmitter)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            u_clk <= 0;
        end else if (count == clk_cycles/2) begin
            u_clk <= ~u_clk;
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end

    // UART Receiver FSM
    always @(posedge u_clk or posedge rst) begin
        if (rst) begin
            state <= start;
            rx_done <= 0;
            data_out <= 8'd0;
            bit_count <= 0;
            rx_shift <= 8'd0;
        end else begin
            case (state)
                idle: begin
                    rx_done <= 0;
                    state <= start;
                end

                start: begin
                    // Ideally, sample in the middle of start bit (already delayed half cycle)
                    if (rx == 0) begin
                        state <= transfer;
                        bit_count <= 0;
                    end else begin
                        state <= start; // False start bit
                    end
                end

                transfer: begin
                    rx_shift[bit_count] <= rx;  // Sample 1 data bit per u_clk
                    if (bit_count == 7) begin
                        state <= stop_bit;
                    end else begin
                        bit_count <= bit_count + 1;
                    end
                end

                stop_bit: begin
                    if (rx == 1) begin // Check for valid stop bit
                        data_out <= rx_shift;
                        rx_done <= 1;
                    end
                    state <= idle;
                end
            endcase
        end
    end

endmodule
