`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2025 03:56:10 PM
// Design Name: 
// Module Name: UART_RX_TOP
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
module UART_RX_TOP #(
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst_n,
    input RX_IN,
    input [5:0] pre_scale,
    input par_en,
    input par_type,
    output [DATA_WIDTH-1:0] P_DATA,
    output data_valid,
    output parity_error,
    output framing_error
);

    wire strt_chk_en, edge_bit_en, deser_en, par_chk_en, stp_chk_en, dat_samp_en;
    wire [5:0] edge_cnt;
    wire [3:0] bit_cnt;
    wire sampled_bit;
    wire stp_err, strt_glitch, par_err;

    FSM fsm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .RX_IN(RX_IN),
        .bit_cnt(bit_cnt),
        .edge_cnt(edge_cnt),
        .par_en(par_en),
        .pre_scale(pre_scale),
        .stp_err(stp_err),
        .strt_glitch(strt_glitch),
        .par_err(par_err),
        .strt_chk_en(strt_chk_en),
        .edge_bit_en(edge_bit_en),
        .deser_en(deser_en),
        .par_chk_en(par_chk_en),
        .stp_chk_en(stp_chk_en),
        .dat_samp_en(dat_samp_en),
        .data_valid(data_valid)
    );

    edge_bit_counter counter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .enable(edge_bit_en),
        .prescale(pre_scale),
        .edge_cnt(edge_cnt),
        .bit_cnt(bit_cnt)
    );

    data_sampling sampler_inst (
        .clk(clk),
        .rst_n(rst_n),
        .RX_IN(RX_IN),
        .pre_scale(pre_scale),
        .data_samp_en(dat_samp_en),
        .edge_cnt(edge_cnt),
        .sampled_bit(sampled_bit)
    );

    deserializer #(
        .DATA_WIDTH(DATA_WIDTH)
    ) deserializer_inst (
        .clk(clk),
        .rst_n(rst_n),
        .sampled_bit(sampled_bit),
        .enable(deser_en),
        .edge_count(edge_cnt),
        .prescale(pre_scale),
        .p_data(P_DATA)
    );

    parity_check #(
        .DATA_WIDTH(DATA_WIDTH)
    ) parity_check_inst (
        .clk(clk),
        .rst_n(rst_n),
        .par_type(par_type),
        .par_chk_en(par_chk_en),
        .sampled_bit(sampled_bit),
        .P_Data(P_DATA),
        .par_err(par_err)
    );

    stop_check stop_check_inst (
        .clk(clk),
        .rst_n(rst_n),
        .stp_chk_en(stp_chk_en),
        .sampled_bit(sampled_bit),
        .stp_err(stp_err)
    );

    strt_check strt_check_inst (
        .clk(clk),
        .rst_n(rst_n),
        .strt_chk_en(strt_chk_en),
        .sampled_bit(sampled_bit),
        .strt_glitch(strt_glitch)
    );

    assign parity_error = par_err;
    assign framing_error = stp_err;

endmodule