`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2025 11:09:12 AM
// Design Name: 
// Module Name: top_tb
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


// Testbench
`timescale 1ns / 1ps

module uart_tb;
    reg clk;
    reg rst;
    reg start_tx;
    reg [7:0] tx_data_in;
    wire tx_done;
    wire rx_done;
    wire [7:0] rx_data_out;

    // Instantiate top
    uart_top uut (
        .clk(clk),
        .rst(rst),
        .start_tx(start_tx),
        .tx_data_in(tx_data_in),
        .tx_done(tx_done),
        .tx_busy(tx_busy),
        .rx_done(rx_done),
        .rx_data_out(rx_data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock
    end

    // Test Sequence
    initial begin
        rst = 1;
        start_tx = 0;
        tx_data_in = 8'b0;
        #100;

        rst = 0;
        #20;
        tx_data_in = 8'hA5;
        start_tx = 1;
        wait (start_tx & tx_busy);
        start_tx = 0;
        wait (tx_done);
        wait (rx_done);

        $display("\nSent = %h | Received = %h", tx_data_in, rx_data_out);
        if (rx_data_out == tx_data_in)
            $display("UART TX/RX Test Passed ✅\n");
        else
            $display("UART TX/RX Test Failed ❌\n");

       
    end

endmodule
