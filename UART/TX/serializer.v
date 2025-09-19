`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2025 04:08:24 AM
// Design Name: 
// Module Name: serializer
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

module serializer (
    input        clk,
    input        rst_n,
    input  [7:0] P_DATA,
    input        ser_en,
    input        Data_Valid, // Added Data_Valid signal
    input        busy,       // Added busy signal
    output reg   ser_data,
    output       ser_done
);

    reg [7:0] shift_reg;   // shift register to hold P_DATA
    reg [2:0] counter;     // 3-bit counter (0-7)

    // Shift register with busy condition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 8'b0;
            ser_data  <= 1'b0;
        end 
        else if (Data_Valid && !busy) begin // Load data when valid and not busy
            shift_reg <= P_DATA;
            counter <= 3'b0;
        end
        else if (ser_en) begin
            shift_reg <= shift_reg >> 1; // shift right each cycle
            ser_data <= shift_reg[0];    // output LSB
        end
    end

    // Counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 3'b0;
        end
        else if (ser_en) begin
            if (counter == 3'b111)
                counter <= 3'b0;          // wrap after 8 bits
            else
                counter <= counter + 1'b1;
        end
    end

    // Done flag when last bit is sent
    assign ser_done = (counter == 3'b111) ? 1'b1 : 1'b0;

endmodule