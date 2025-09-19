module stop_check(
    input clk,
    input rst_n,
    input stp_chk_en,
    input sampled_bit,
    output reg stp_err
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stp_err <= 1'b0;
        end
        else if (stp_chk_en) begin
            stp_err <= 1'b1 ^ sampled_bit;
        end
    end

endmodule

