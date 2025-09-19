`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2025 09:46:50 PM
// Design Name: 
// Module Name: UART_TX_TOP
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

module UART_TX #(parameter DATA_WIDTH = 8)
(
 input   wire                         clk,
 input   wire                         rst_n,
 input   wire    [DATA_WIDTH-1:0]     P_DATA,
 input   wire                         Data_Valid,
 input   wire                         parity_enable,
 input   wire                         parity_type, 
 output  wire                         TX_OUT,
 output  wire                         busy
);

wire          ser_en, 
              ser_done,
              ser_data,
              parity_bit;
            
wire  [1:0]   mux_sel;
 
FSM U0_fsm (
    .clk(clk),
    .rst_n(rst_n),
    .Data_Valid(Data_Valid), 
    .par_en(parity_enable),
    .ser_done(ser_done), 
    .ser_en(ser_en),
    .mux_sel(mux_sel), 
    .busy(busy)
);

serializer U0_Serializer (
    .clk(clk),
    .rst_n(rst_n),
    .P_DATA(P_DATA),
    .ser_en(ser_en),
    .Data_Valid(Data_Valid), // Added
    .busy(busy),             // Added
    .ser_data(ser_data),
    .ser_done(ser_done)
);

MUX U0_mux (
    .clk(clk),
    .rst_n(rst_n),
    .IN_0(1'b0),    // start_bit
    .IN_1(ser_data),
    .IN_2(parity_bit),
    .IN_3(1'b1),    // stop_bit
    .mux_sel(mux_sel),
    .TX_OUT(TX_OUT) 
);

parity_calc U0_parity_calc (
    .clk(clk),
    .rst_n(rst_n),
    .par_en(parity_enable),
    .par_type(parity_type),
    .P_DATA(P_DATA),
    .Data_Valid(Data_Valid),
    .busy(busy),     // Added
    .par_bit(parity_bit)
); 

endmodule

