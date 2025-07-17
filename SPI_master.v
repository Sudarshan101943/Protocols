`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2025 03:31:58 PM
// Design Name: 
// Module Name: SPI_master
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


module SPI_Master (
    input clk,
    input rst,
    input new_d,
    input [10:0] d_in,
    output reg cs,
    output reg mosi,
    output reg sclk
);

    parameter idle     = 2'b00;
    parameter start    = 2'b01;
    parameter transfer = 2'b10;
    parameter stop     = 2'b11;

    reg [1:0] state = idle;

    reg [10:0] temp;
    reg [3:0] bit_count = 0;
    integer bit_counter = 0;

    parameter SYS_CLK = 10000000; // 10 MHz system clock
    parameter SPI_CLK = 1000000;  // 1 MHz SPI clock
    parameter DIVISOR = SYS_CLK / (2 * SPI_CLK); // divide by 5 for 1MHz toggle

    // Clock divider for generating SPI clock (sclk)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bit_counter <= 0;
            sclk <= 0;
        end else begin
            if (bit_counter == DIVISOR - 1) begin
                sclk <= ~sclk;
                bit_counter <= 0;
            end else begin
                bit_counter <= bit_counter + 1;
            end
        end
    end

    // SPI transaction FSM on positive edge of SPI clock
    always @(posedge sclk or posedge rst) begin
        if (rst) begin
            state <= idle;
            cs <= 1;
            mosi <= 1;
            bit_count <= 0;
            temp <= 0;
        end else begin
            case (state)
                idle: begin
                    cs <= 1;
                    mosi <= 1;
                    if (new_d) begin
                        temp <= d_in;
                        bit_count <= 0;
                        state <= start;
                    end
                end

                start: begin
                    cs <= 0; // Activate chip select
                    state <= transfer;
                end





                transfer: begin
                    mosi <= temp[bit_count];
                    if (bit_count == 10)
                        state <= stop;
                    else
                        bit_count <= bit_count + 1;
                end

                stop: begin
                    cs <= 1;
                    state <= idle;
                end

                default: begin
                    state <= idle;
                end
            endcase
        end
    end

endmodule
