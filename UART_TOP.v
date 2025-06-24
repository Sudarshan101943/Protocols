module uart_top(
    input clk,
    input rst,
    input start_tx,
    input [7:0] tx_data_in,
    output tx_done,
    output tx_busy,
    output rx_done,
    output [7:0] rx_data_out
);

    wire tx_line;

    Uart_tr tx_inst (
        .clk(clk),
        .rst(rst),
        .new_data(start_tx),
        .data_in(tx_data_in),
        .tx_done(tx_done),
        .tx_busy(tx_busy),
        .tx(tx_line)
    );

    Uart_rx rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(tx_line),
        .rx_done(rx_done),
        .data_out(rx_data_out)
    );

endmodule
