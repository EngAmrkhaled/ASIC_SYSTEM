`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2025 06:38:03 PM
// Design Name: 
// Module Name: FSM
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

module FSM(
    input clk,
    input rst_n,
    input RX_IN,
    input [3:0] bit_cnt,
    input [5:0] edge_cnt,
    input par_en,
    input [5:0] pre_scale,
    input stp_err,
    input strt_glitch,
    input par_err,
    output reg strt_chk_en,
    output reg edge_bit_en,
    output reg deser_en,
    output reg par_chk_en,
    output reg stp_chk_en,
    output reg dat_samp_en,
    output reg data_valid
);

    parameter IDLE = 3'b000,
              START_STATE = 3'b001,
              DATA_STATE = 3'b011,
              PARITY_STATE = 3'b010,
              STOP_STATE = 3'b110,
              ERROR_CHK_STATE = 3'b111;

    reg [2:0] cs, ns;
    wire [5:0] check_edge, error_check_edge;

    assign check_edge = pre_scale - 6'd1;
    assign error_check_edge = pre_scale - 6'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cs <= IDLE;
        else
            cs <= ns;
    end

    always @(*) begin
        case (cs)
            IDLE: begin
                if (!RX_IN)
                    ns = START_STATE;
                else
                    ns = IDLE;
            end

            START_STATE: begin
                if (bit_cnt == 4'd0 && edge_cnt == check_edge) begin
                    if (!strt_glitch)
                        ns = DATA_STATE;
                    else
                        ns = IDLE;
                end
                else
                    ns = START_STATE;
            end

            DATA_STATE: begin
                if (bit_cnt == 4'd8 && edge_cnt == check_edge) begin
                    if (par_en)
                        ns = PARITY_STATE;
                    else
                        ns = STOP_STATE;
                end
                else
                    ns = DATA_STATE;
            end

            PARITY_STATE: begin
                if (bit_cnt == 4'd9 && edge_cnt == check_edge)
                    ns = STOP_STATE;
                else
                    ns = PARITY_STATE;
            end

            STOP_STATE: begin
                if (par_en) begin
                    if (bit_cnt == 4'd10 && edge_cnt == error_check_edge)
                        ns = ERROR_CHK_STATE;
                    else
                        ns = STOP_STATE;
                end
                else begin
                    if (bit_cnt == 4'd9 && edge_cnt == error_check_edge)
                        ns = ERROR_CHK_STATE;
                    else
                        ns = STOP_STATE;
                end
            end

            ERROR_CHK_STATE: begin
                if (!RX_IN)
                    ns = START_STATE;
                else
                    ns = IDLE;
            end

            default: ns = IDLE;
        endcase
    end

    always @(*) begin
        strt_chk_en = 1'b0;
        edge_bit_en = 1'b0;
        deser_en = 1'b0;
        par_chk_en = 1'b0;
        stp_chk_en = 1'b0;
        dat_samp_en = 1'b0;
        data_valid = 1'b0;

        case (cs)
            IDLE: begin
                if (!RX_IN) begin
                    edge_bit_en = 1'b1;
                    strt_chk_en = 1'b1;
                    dat_samp_en = 1'b1;
                end
            end

            START_STATE: begin
                edge_bit_en = 1'b1;
                dat_samp_en = 1'b1;
                strt_chk_en = 1'b1;
            end

            DATA_STATE: begin
                edge_bit_en = 1'b1;
                dat_samp_en = 1'b1;
                deser_en = 1'b1;
            end

            PARITY_STATE: begin
                edge_bit_en = 1'b1;
                dat_samp_en = 1'b1;
                par_chk_en = 1'b1;
            end

            STOP_STATE: begin
                edge_bit_en = 1'b1;
                dat_samp_en = 1'b1;
                stp_chk_en = 1'b1;
            end

            ERROR_CHK_STATE: begin
                dat_samp_en = 1'b1;
                if (!(par_err | stp_err))
                    data_valid = 1'b1;
            end
        endcase
    end

endmodule