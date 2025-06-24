`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2025 09:25:43 AM
// Design Name: 
// Module Name: UART_TX
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


 module Uart_tr(
    input clk,
    input rst,
    input new_data,
    input [7:0] data_in,
    output reg tx_done,
    output reg tx_busy,
    output reg tx
);

    // FSM states
    parameter idle = 2'b00;
    parameter start = 2'b01;
    parameter transfer = 2'b10;
    parameter trx_done = 2'b11;

    reg [1:0] state;

    parameter system_clk = 1000000;  // 1 MHz
    parameter baudrate   = 9600;

    parameter clk_cycles = system_clk / baudrate;

    reg [15:0] count = 0;  // Counter for baud clock generation
    reg u_clk = 0;         // UART bit clock (9600 Hz)

    reg [7:0] tx_data = 0;
    reg [3:0] bit_count = 0;

    // UART bit clock generation
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

    // Main FSM for UART transmission
    always @(posedge u_clk or posedge rst) begin
        if (rst) begin
            state <= idle;
            tx <= 1;
            tx_busy = 0;
            tx_done <= 0;
            bit_count <= 0;
        end else begin
            case (state)
                idle: begin
                    tx <= 1;
                    if (new_data) begin
                        tx_data <= data_in;
                        bit_count <= 0;
                        state <= start;
                        tx_done <= 0;
                        tx_busy = 1;
                    end
                    else begin
                        tx_data <=0;
                        bit_count <= 0;
                        state <= idle;
                        tx_done <= 1;
                        tx_busy = 0;
                    end
                    
                end

                start: begin
                    tx <= 0;         // Start bit
                    state <= transfer;
                end

                transfer: begin
                    tx <= tx_data[bit_count];
                    if (bit_count == 7) begin
                        state <= trx_done;
                    end else begin
                        bit_count <= bit_count + 1;
                    end
                end

                trx_done: begin
                    tx <= 1;         // Stop bit
                    tx_done <= 1;
                    state <= idle;
                end
            endcase
        end
    end
endmodule

