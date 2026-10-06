module top_music (
    input  wire clk_50m,      // 板载 50MHz 时钟
    input  wire rst_n,        // 复位按键，低有效
    output wire HP_BCK,       // I2S 位时钟 (BCLK)
    output wire HP_WS,        // I2S 左右声道时钟 (LRCK/WS)
    output wire HP_DIN,       // I2S 串行数据 (DIN)
    output wire PA_EN         // 功放使能
);

    // PA_EN 拉高使能功放
    assign PA_EN = 1'b1;

    // ---------- PLL_ADV IP 实例化 ----------
    // 模块名需与你在 IP Core Generator 中生成的一致
    // 输入 50MHz，输出 12.288MHz
    wire clk_audio;
    wire pll_lock;

    my_audio_pll u_pll (
        .clkin   (clk_50m),
        .clkout0 (clk_audio),
        .lock    (pll_lock)
    );

    // ---------- 音符频率控制字 ----------
    // 中央 C (261.63Hz) 对应 Fword 约 91480000
    // Fword = Fout * 2^32 / 12288000
    reg [31:0] fword;
    reg [3:0]  wave_sel;

    always @(posedge clk_audio or negedge rst_n) begin
        if (!rst_n) begin
            fword    <= 32'd91480000;  // 默认中央 C
            wave_sel <= 4'd3;          // 默认钢琴音色
        end
    end

    // ---------- DDS 波形发生器 ----------
    wire [15:0] audio_sample;

    dds_wave_gen u_dds (
        .clk      (clk_audio),
        .rst_n    (rst_n),
        .fword    (fword),
        .wave_sel (wave_sel),
        .sample   (audio_sample)
    );

    // ---------- I2S 发送器 ----------
    i2s_tx u_i2s (
        .clk      (clk_audio),
        .rst_n    (rst_n),
        .sample_l (audio_sample),
        .sample_r (audio_sample),
        .bclk     (HP_BCK),
        .lrck     (HP_WS),
        .dout     (HP_DIN)
    );

endmodule