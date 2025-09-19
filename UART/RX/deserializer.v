module deserializer #(
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst_n,
    input sampled_bit,
    input enable,
    input [5:0] edge_count,
    input [5:0] prescale,
    output reg [DATA_WIDTH-1:0] p_data
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_data <= 0;
        end
        else if (enable && edge_count == (prescale - 6'b1)) begin
            p_data <= {sampled_bit, p_data[DATA_WIDTH-1:1]};
        end
    end

endmodule