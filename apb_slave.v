`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2025 06:10:09 PM
// Design Name: 
// Module Name: apb_slave
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


module apb_slave (
  input        clk,
  input        rst_n,
  input      [7:0]apb_slave_write_data,
  output reg [7:0]apb_slave_read_data_out,      
  // APB bus interface
  input        psel,
  input        penable,
  input        pwrite,      // 1=write, 0=read
  input  [7:0] paddr,
  input  [7:0] pwdata,
  output reg   pready,
  output reg [7:0] prdata
);

  

  // State machine for APB phases

 parameter SETUP = 1;
 parameter ENABLE = 0;
 
 reg state;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state  <= SETUP;
      pready <= 1'b0;
      prdata <= 8'h00;
      apb_slave_read_data_out <=0;
    end else begin
      case (state)
        SETUP: begin
          // whenever master asserts psel, move to ENABLE
          pready <= 1'b0;
          if (psel)
            state <= ENABLE;
        end

        ENABLE:
        
         begin
         
          if (psel && penable) begin
            pready <= 1'b1;         
            if (pwrite) begin
            
             apb_slave_read_data_out <=pwdata;
                    
            end else begin
             
            prdata <= apb_slave_write_data;  
            
            end
          end else begin
          
            state <= SETUP;
            pready <= 1'b0;
          end
        end

        default: state <= SETUP;
      endcase
    end
  end

endmodule