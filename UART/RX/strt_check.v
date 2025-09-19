module strt_check(
    input clk,
    input rst_n,
    input strt_chk_en,
    input sampled_bit,
    output reg strt_glitch
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            strt_glitch <= 1'b0;
        end
        else if (strt_chk_en) begin
            strt_glitch <= sampled_bit;
        end
    end

endmodule