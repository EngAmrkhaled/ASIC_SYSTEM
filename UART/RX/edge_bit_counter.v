module edge_bit_counter(
    input clk,
    input rst_n,
    input enable,
    input [5:0] prescale,
    output reg [5:0] edge_cnt,
    output reg [3:0] bit_cnt
);

    wire edge_count_done;

    assign edge_count_done = (edge_cnt == (prescale - 6'b1));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            edge_cnt <= 6'b0;
        end
        else if (enable) begin
            if (edge_count_done)
                edge_cnt <= 6'b0;
            else
                edge_cnt <= edge_cnt + 6'b1;
        end
        else begin
            edge_cnt <= 6'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= 4'b0;
        end
        else if (enable) begin
            if (edge_count_done)
                bit_cnt <= bit_cnt + 4'b1;
        end
        else begin
            bit_cnt <= 4'b0;
        end
    end

endmodule