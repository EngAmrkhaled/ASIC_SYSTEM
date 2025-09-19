module parity_check #(
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst_n,
    input par_type,
    input par_chk_en,
    input sampled_bit,
    input [DATA_WIDTH-1:0] P_Data,
    output reg par_err
);

    reg parity;

    always @(*) begin
        if (par_type)
            parity = ~^P_Data;   // Odd parity
        else
            parity = ^P_Data;    // Even parity
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            par_err <= 1'b0;
        else if (par_chk_en)
            par_err <= parity ^ sampled_bit;
    end

endmodule