`timescale 1ns / 1ps

module SPI_TOP (
    input clk,
    input rst,
    input new_d,
    input [10:0] data_in,
    output [10:0] data_out,
    output done
);

    // Internal SPI lines
    wire chip_select;
    wire mosi_line;
    wire spi_clk;

    // Instantiate SPI Master
    SPI_Master master_inst (
        .clk(clk),
        .rst(rst),
        .new_d(new_d),
        .d_in(data_in),
        .cs(chip_select),
        .mosi(mosi_line),
        .sclk(spi_clk)
    );

    // Instantiate SPI Slave
    slave slave_inst (
        .clk(clk),         // System clock (not used internally)
        .rst(rst),
        .cs(chip_select),
        .mosi(mosi_line),
        .s_clk(spi_clk),   // SPI clock from master
        .data_out(data_out),
        .done(done)
    );

endmodule
