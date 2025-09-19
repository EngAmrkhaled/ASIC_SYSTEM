`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2025 04:08:24 AM
// Design Name: 
// Module Name: MUX
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

`timescale 1ns / 1ps

module MUX(
    input clk, rst_n,
    input [1:0] mux_sel, // Changed from [2:0] to [1:0]
    input IN_0, IN_1, IN_2, IN_3,
    output reg TX_OUT
);
    
    reg mux_out;
    
    always @(*) begin
        case(mux_sel)
            2'b00: mux_out <= IN_0;
            2'b01: mux_out <= IN_1;
            2'b10: mux_out <= IN_2;
            2'b11: mux_out <= IN_3;
        endcase
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            TX_OUT <= 1;
        else 
            TX_OUT <= mux_out;
    end
    
endmodule
