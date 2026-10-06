module i2s_tx (
    input  wire        clk,       // 12.288MHz
    input  wire        rst_n,
    input  wire [15:0] sample_l,
    input  wire [15:0] sample_r,
    output reg         bclk,
    output reg         lrck,
    output reg         dout
);

    reg [3:0] bit_cnt;
    reg [1:0] bclk_div;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bclk_div <= 2'd0;
        else
            bclk_div <= bclk_div + 1'b1;
    end

    wire bclk_rise = (bclk_div == 2'd1);
    wire bclk_fall = (bclk_div == 2'd3);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bclk    <= 1'b0;
            lrck    <= 1'b0;
            dout    <= 1'b0;
            bit_cnt <= 4'd0;
        end else begin
            if (bclk_rise) bclk <= 1'b1;
            if (bclk_fall) bclk <= 1'b0;

            if (bclk_fall) begin
                if (bit_cnt == 4'd15) begin
                    bit_cnt <= 4'd0;
                    lrck    <= ~lrck;
                end else begin
                    bit_cnt <= bit_cnt + 1'b1;
                end
            end

            if (bclk_fall) begin
                if (lrck)
                    dout <= sample_r[15 - bit_cnt];
                else
                    dout <= sample_l[15 - bit_cnt];
            end
        end
    end

endmodule