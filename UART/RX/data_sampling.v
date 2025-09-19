module data_sampling(
    input clk,
    input rst_n,
    input RX_IN,
    input [5:0] pre_scale,
    input data_samp_en,
    input [5:0] edge_cnt,
    output reg sampled_bit
);

    reg [2:0] samples;
    wire [4:0] half_edges, half_edges_p1, half_edges_n1;

    assign half_edges = (pre_scale >> 1) - 1'b1;
    assign half_edges_p1 = half_edges + 1'b1;
    assign half_edges_n1 = half_edges - 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            samples <= 3'b0;
        end
        else if (data_samp_en) begin
            if (edge_cnt == half_edges_n1)
                samples[0] <= RX_IN;
            else if (edge_cnt == half_edges)
                samples[1] <= RX_IN;
            else if (edge_cnt == half_edges_p1)
                samples[2] <= RX_IN;
        end
        else begin
            samples <= 3'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sampled_bit <= 1'b0;
        end
        else if (data_samp_en) begin
            case (samples)
                3'b000, 3'b001, 3'b010, 3'b100: sampled_bit <= 1'b0;
                3'b011, 3'b101, 3'b110, 3'b111: sampled_bit <= 1'b1;
                default: sampled_bit <= 1'b0;
            endcase
        end
        else begin
            sampled_bit <= 1'b0;
        end
    end

endmodule