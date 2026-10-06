module dds_wave_gen (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] fword,
    input  wire [3:0]  wave_sel,
    output reg  [15:0] sample
);

    reg [31:0] phase_acc;
    wire [11:0] phase;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            phase_acc <= 32'd0;
        else
            phase_acc <= phase_acc + fword;
    end

    assign phase = phase_acc[31:20];

    reg [15:0] sample_next;

    always @(*) begin
        case (wave_sel)
            4'd0: sample_next = phase[11] ? 16'h7FFF : 16'h8000;  // 方波
            4'd1: sample_next = {phase[10:0], 5'b0} + 16'h8000;   // 三角波
            4'd2: sample_next = {phase, 4'b0} + 16'h8000;         // 锯齿波
            4'd3: sample_next = ({phase[10:0], 5'b0} + {phase[9:0], 6'b0}) + 16'h8000;  // 钢琴近似
            default: sample_next = 16'h8000;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sample <= 16'h8000;
        else
            sample <= sample_next;
    end

endmodule