module Top_gen_wave #(
    parameter SIZE_BTN    = 4    ,
    parameter SIZE_SW     = 10   ,
    parameter SIZE_LEDR   = 10   ,
    parameter SIZE_LEDG   = 4    ,
    parameter SIZE_WIDTH  = 24   ,
    parameter SIZE_DEPTH  = 1024 ,
    parameter SIZE_SEG    = 7    ,
    parameter NUM_MODE_WAVE = 3  ,
    parameter NUM_DUTY_CYCLE = 3 ,
    parameter SIZE_GAIN_WAVE = 3
)(
    input logic                             i_clk,
    input logic [SIZE_BTN-1:0]              i_btn,
    input logic [SIZE_SW-1:0]               i_sw,

    output logic                            o_add_noise, // 0 - sóng thuần túy, 1 - sóng + nhiễu

    output logic [NUM_MODE_WAVE-1:0]        o_sel_wave, // chọn loại sóng xuất
    output logic [NUM_DUTY_CYCLE-1:0]       o_sel_duty_cycle, // chọn duty cycle cho sóng vuông
    output logic signed [SIZE_GAIN_WAVE:0]  o_gain_wave, // lựa chọn độ lợi áp khôi phục của sóng
    output logic [$clog2(SIZE_DEPTH)-1:0]   o_phase_step_wave, // chỉnh bước nhảy của NCO của sóng - chỉnh tẩn số

    output logic                            o_lfsr_sin, // 0 - lfsr, 1 - hài bậc cao sóng sine
    output logic [$clog2(SIZE_DEPTH)-1:0]   o_phase_step_noise, // chỉnh bước nhảy của NCO của nhiểu sin cao - chỉnh tẩn số
    output logic signed [SIZE_GAIN_WAVE:0]  o_gain_noise, // lựa chọn độ lợi áp khôi phục của nhiễu

    output logic [SIZE_LEDR-1:0]            o_ledr,
    output logic [SIZE_LEDG-1:0]            o_ledg,
    output logic [SIZE_SEG-1:0]             o_hex_0, // value0 |
    output logic [SIZE_SEG-1:0]             o_hex_1, // Value1 | Amplitude
    output logic [SIZE_SEG-1:0]             o_hex_2, // value2 |
    output logic [SIZE_SEG-1:0]             o_hex_3, // sign   |
    output logic [SIZE_SEG-1:0]             o_hex_4, // Value0 | Frequency
    output logic [SIZE_SEG-1:0]             o_hex_5  // value1 |
); 

//////////////////////////////////////////////////////////
// Internal Signal
//////////////////////////////////////////////////////////
//- MODE WAVE SELECT
// parameter SIN       = 3'b000;
// parameter SQUARE    = 3'b001;
// parameter TRIANGLE  = 3'b010;
// parameter SAWTOOTH  = 3'b011;
// parameter ECG       = 3'b100;
// parameter LFSR_NOISE= 3'b110;
// parameter SIN_NOISE = 3'b111;
//- Select duty cycle
// parameter DUTY_CYCLE_10 = 3'd0;
// parameter DUTY_CYCLE_20 = 3'd1;
// parameter DUTY_CYCLE_25 = 3'd2;
// parameter DUTY_CYCLE_33 = 3'd3;
// parameter DUTY_CYCLE_50 = 3'd4;
// parameter DUTY_CYCLE_75 = 3'd5;
// parameter DUTY_CYCLE_80 = 3'd6;
// parameter DUTY_CYCLE_90 = 3'd7;

logic i_rst_n;
assign i_rst_n = i_sw[9];
assign o_ledr[9] = i_sw[9];
logic signed [SIZE_GAIN_WAVE:0]  w_gain;

//////////////////////////////////////////////////////////
// Submodule
//////////////////////////////////////////////////////////
//--| Waveform
logic w_en_wave;
assign w_en_wave = (~i_sw[8]) & (~i_sw[7]);
logic signed [SIZE_GAIN_WAVE:0]   w_gain_wave;
logic [SIZE_SEG-1:0]              w_wave_hex_0;
logic [SIZE_SEG-1:0]              w_wave_hex_1;
logic [SIZE_SEG-1:0]              w_wave_hex_2;
//- Amplitude
CTR_adjust_amp_wave #(
    .NUM_GAIN_STEP (SIZE_GAIN_WAVE),
    .NUM_SEG       (SIZE_SEG)
) CTR_adjust_amp_wave_unit (
    .i_clk(i_clk), 
    .i_rst_n(i_rst_n),
    .i_btn_0(i_btn[0]),    // Select adjust size
    .i_btn_1(i_btn[2]),    // Adjust amplitude
    .i_en(w_en_wave),       // Mode= Wave/Noise
    .o_gain_wave(w_gain_wave),
    .o_hex_0(w_wave_hex_0), // sign
    .o_hex_1(w_wave_hex_1), // GiaTriTang
    .o_hex_2(w_wave_hex_2)  // Value
);
assign o_gain_wave = w_gain_wave;
//- Phase
logic [$clog2(SIZE_DEPTH)-1:0]      w_phase_wave;
logic [SIZE_SEG-1:0]                w_wave_hex_3;
logic [SIZE_SEG-1:0]                w_wave_hex_4;
logic [SIZE_SEG-1:0]                w_wave_hex_5;
CTR_adjust_phase_wave #(
    .SIZE_VALUE(7),
    .SIZE_SEG(SIZE_SEG),
    .SIZE_PHASE($clog2(SIZE_DEPTH)-1)
) CTR_adjust_phase_wave_unit (
    .i_clk(i_clk),
    .i_rst_n (i_rst_n),
    .i_en(w_en_wave),       // Mode= Wave/Noise
    .i_btn_0(i_btn[0]),    // Select adjust size
    .i_btn_1(i_btn[3]),    // Adjust frequency

    .o_phase_wave(w_phase_wave),
    .o_hex_0(w_wave_hex_3), // sign
    .o_hex_1(w_wave_hex_4), // Value0
    .o_hex_2(w_wave_hex_5)  // value1
);
assign o_phase_step_wave = w_phase_wave;

//--| Noise
logic w_en_noise;
assign w_en_noise = (~i_sw[8]) & (i_sw[7]);
logic signed [SIZE_GAIN_WAVE:0]   w_gain_noise;
logic [SIZE_SEG-1:0]              w_noise_hex_0;
logic [SIZE_SEG-1:0]              w_noise_hex_1;
logic [SIZE_SEG-1:0]              w_noise_hex_2;
//- Amplitude
CTR_adjust_amp_noise #(
    .NUM_GAIN_STEP (SIZE_GAIN_WAVE),
    .NUM_SEG       (SIZE_SEG)
) CTR_adjust_amp_noise_unit (
    .i_clk(i_clk), 
    .i_rst_n(i_rst_n),
    .i_btn_0(i_btn[0]),    // Select adjust size
    .i_btn_1(i_btn[2]),    // Adjust amplitude
    .i_en(w_en_noise),       // Mode= Wave/Noise
    .o_gain_wave(w_gain_noise),
    .o_hex_0(w_noise_hex_0), // sign
    .o_hex_1(w_noise_hex_1), // GiaTriTang
    .o_hex_2(w_noise_hex_2)  // Value
);
assign o_gain_noise = w_gain_noise;
//- Phase
logic [$clog2(SIZE_DEPTH)-1:0]      w_phase_noise;
logic [SIZE_SEG-1:0]                w_noise_hex_3;
logic [SIZE_SEG-1:0]                w_noise_hex_4;
logic [SIZE_SEG-1:0]                w_noise_hex_5;
CTR_adjust_phase_noise #(
    .SIZE_VALUE(7),
    .SIZE_SEG(SIZE_SEG),
    .SIZE_PHASE($clog2(SIZE_DEPTH)-1)
) CTR_adjust_phase_noise_unit (
    .i_clk(i_clk),
    .i_rst_n (i_rst_n),
    .i_en(w_en_noise),       // Mode= Wave/Noise
    .i_btn_0(i_btn[0]),    // Select adjust size
    .i_btn_1(i_btn[3]),    // Adjust frequency

    .o_phase_wave(w_phase_noise),
    .o_hex_0(w_noise_hex_3), // sign
    .o_hex_1(w_noise_hex_4), // Value0
    .o_hex_2(w_noise_hex_5)  // value1
);
assign o_phase_step_noise = w_phase_noise;

//- o_add_noise
logic w_btn_0;
BTN_detect_edge BTN_DE_unit_0 (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn[0]),
    .o_signal    (w_btn_0)
);
assign o_ledg[0] = w_btn_0;

logic w_btn_1;
BTN_detect_edge BTN_DE_unit (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn[1]),
    .o_signal    (w_btn_1)
);
assign o_ledg[1] = w_btn_1;

logic w_btn_2;
BTN_detect_edge BTN_DE_unit_2 (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn[2]),
    .o_signal    (w_btn_2)
);
assign o_ledg[2] = w_btn_2;

logic w_btn_3;
BTN_detect_edge BTN_DE_unit_3 (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn[3]),
    .o_signal    (w_btn_3)
);
assign o_ledg[3] = w_btn_3;

logic w_en_add_noise;
assign w_en_add_noise = (i_sw[8]) & (~i_sw[7]) & w_btn_1;
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_enable_add_nosie
    if(~i_rst_n)
        o_add_noise <= 1'b0;
    else if(w_en_add_noise)
        o_add_noise <= ~o_add_noise;
end
assign o_ledr[0] = o_add_noise;

//- Select type waveform
logic [NUM_MODE_WAVE-1:0]        w_sel_wave;
assign w_sel_wave = i_sw[6:4];
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        o_sel_wave <= '0;
    else 
        o_sel_wave <= w_sel_wave;
end
assign o_ledr[7:5] = o_sel_wave;

//- Duty Cycle
logic [NUM_DUTY_CYCLE-1:0] w_sel_duty_cycle;
assign w_sel_duty_cycle = i_sw[3:1];
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n)
        o_sel_duty_cycle <= 3'd4;
    else if(w_btn_1)
        o_sel_duty_cycle <= w_sel_duty_cycle;
end
assign o_ledr[4:2] = o_sel_duty_cycle;

//- o_lfsr_sin, // 0 - lfsr, 1 - hài bậc cao sóng sine
logic w_lfsr_sin;
always_comb begin
    if((w_sel_wave[2])&(w_sel_wave[1])&(~w_sel_wave[0]))
        w_lfsr_sin = 1'b0;
    else if ((w_sel_wave[2])&(w_sel_wave[1])&(w_sel_wave[0]))
        w_lfsr_sin = 1'b1;
    else 
        w_lfsr_sin = 1'b0;
end
always_ff @(posedge i_clk or negedge i_rst_n) begin 
    if(~i_rst_n)
        o_lfsr_sin <= 1'b0;
    else if(w_btn_1 & w_en_noise)
        o_lfsr_sin <= w_lfsr_sin;
end
assign o_ledr[1] = o_lfsr_sin;

//- 7 Segement
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_seg_led
    if(~i_rst_n) begin
        o_hex_0     <= 7'b1111111;
        o_hex_1     <= 7'b1111111;
        o_hex_2     <= 7'b1111111;
        o_hex_3     <= 7'b1111111;
        o_hex_4     <= 7'b1111111;
        o_hex_5     <= 7'b1111111;
    end else begin
        if(w_en_wave) begin
            o_hex_0     <= w_wave_hex_0;
            o_hex_1     <= w_wave_hex_1;
            o_hex_2     <= w_wave_hex_2;
            o_hex_3     <= w_wave_hex_3;
            o_hex_4     <= w_wave_hex_4;
            o_hex_5     <= w_wave_hex_5;
        end else if(w_en_noise) begin
            o_hex_0     <= w_noise_hex_0;
            o_hex_1     <= w_noise_hex_1;
            o_hex_2     <= w_noise_hex_2;
            o_hex_3     <= w_noise_hex_3;
            o_hex_4     <= w_noise_hex_4;
            o_hex_5     <= w_noise_hex_5;
        end else begin
            o_hex_0     <= o_hex_0;
            o_hex_1     <= o_hex_1;
            o_hex_2     <= o_hex_2;
            o_hex_3     <= o_hex_3;
            o_hex_4     <= o_hex_4;
            o_hex_5     <= o_hex_5;
        end
    end
end
endmodule
