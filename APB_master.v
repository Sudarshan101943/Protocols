`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2025 10:57:22 AM
// Design Name: 
// Module Name: APB_master
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
module apb_master (
    input         clk,
    input         rst,
    input         new_d,
    input  [7:0]  apb_write_addr,
    input  [7:0]  apb_read_addr,
    input  [7:0]  apb_write_data,          
    output reg [7:0]  apb_read_data_out,
    output reg      Busy,
    input         read,
    
    ////apb signals              
    input            pready,            
    output reg         pwrite,  
    output reg [7:0] paddr,
    output reg [7:0] pwdata,
    input      [7:0] prdata,
    output reg       psel,
    output reg       penable
);

   
   parameter   IDLE   = 2'b00;
   parameter   W_SETUP  = 2'b01;
   parameter   R_SETUP  = 2'b10;
   parameter   ENABLE = 2'b11;
   

  reg [1:0]state;

   
   
    always @(posedge clk , negedge rst)
     begin
          if (rst) begin
        psel   <= 0;
        penable <= 0;
        paddr  <= 0;
        pwdata <= 0;
        apb_read_data_out <= 0;
        state <= IDLE;
        Busy  <= 0;
        pwrite <=0;
    end 
    else
    begin
        case (state)

            IDLE: begin
                if (new_d) begin
                    state <= read?R_SETUP:W_SETUP;
                    Busy <=1;
                end
                else
                begin
                state<= IDLE;
                Busy <=0;
                end
            end
           //////////////////// ////////////////////
           /* if(read)
            begin
                psel <= 1;
                penable <= 0;
                pwrite <= 0;
                paddr <= apb_write_addr;
                pwdata <= apb_write_data;
                state <= ENABLE;
                end
            else 
            begin
              psel <= 1;
              penable <= 0;
              pwrite <= 1;
              paddr <= apb_read_addr;
              state <= ENABLE;
             end  */
        ///////////////////////////////// /////////////   

            W_SETUP: begin
                psel <= 1;
                penable <= 0;
                pwrite <= 0;
                paddr <= apb_write_addr;
                pwdata <= apb_write_data;
                state <= ENABLE;
            end

           R_SETUP: begin
                psel <= 1;
                penable <= 0;
                pwrite <= 0;
                paddr <= apb_read_addr;
                state <= ENABLE;
            end

            ENABLE: begin
                psel <= 1;
                penable <= 1;
                paddr <= pwrite ? apb_write_addr : apb_read_addr;
                pwdata <= apb_write_data;

                if (pready) begin
                    if (!pwrite)
                        apb_read_data_out <= prdata;

                    if (new_d)
                    begin
                      state <= read?R_SETUP:W_SETUP;
                      Busy <=1;
                      end
                    else
                    begin
                        state = IDLE;
                        Busy <=0;
                    end
                end
                else begin
                    state <= ENABLE; // Wait state
                end
            end

        endcase
       end
    end

endmodule

