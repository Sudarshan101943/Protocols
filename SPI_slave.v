`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2025 03:45:09 PM
// Design Name: 
// Module Name: SPI_slave
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

module slave (
    input clk,
    input rst,
    input cs,
    input mosi,
    input s_clk,
    output reg [10:0] data_out,
    output reg done
);

    reg [10:0] temp;
    integer counter = 0;
    reg [1:0] state;

    parameter idle     = 2'b00;
    parameter start    = 2'b01;
    parameter transfer = 2'b10;
    parameter stop     = 2'b11;

    always @(posedge s_clk or posedge rst) begin
        if (rst) begin
            state     <= start;
            data_out  <= 0;
            temp      <= 0;
            counter   <= 0;
             done     <= 0;
        end else begin
            case (state)
              

                start: begin
                    if (cs == 0) begin
                        state <= transfer;
                        counter <=0;
                    end else begin
                        state <= start;
                        
                    end
                end

                transfer: begin
                    temp[counter] <= mosi;
                    if (counter == 10)
                       state <= stop;
                    else
                        
                         counter <= counter + 1;
                end

                stop: begin
                    if (cs == 1) begin
                        data_out <= temp;
                        done<=1;
                        state <= start;
                    end
                end

                default: state <= start;
            endcase
        end
    end

endmodule
