`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2025 04:08:24 AM
// Design Name: 
// Module Name: parity calc
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

module parity_calc(
    input clk, rst_n, par_type, par_en,
    input [7:0] P_DATA,
    input Data_Valid,
    input busy, // Added busy signal
    output reg par_bit
);
    
    reg [7:0] data_reg;   // data register
        
    // Data register with busy condition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            data_reg <= 8'b0;              
        else if (Data_Valid && !busy) // Added busy condition
            data_reg <= P_DATA;
    end
   
    // Parity calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            par_bit <= 0;
        else if(par_en) begin
            case(par_type)
                1'b1: par_bit <= ^data_reg;     // Even parity
                1'b0: par_bit <= ~^data_reg;    // Odd parity
            endcase
        end   
    end
endmodule