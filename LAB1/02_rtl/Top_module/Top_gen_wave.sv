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
localparam VALUE_NON = 7'b1111111;
logic i_rst_n;
assign i_rst_n = i_sw[9];

logic w_btn_0, w_btn_1, w_btn_2, w_btn_3;
logic [NUM_MODE_WAVE-1:0] w_sel_wave;
logic w_en_amp, w_en_freq, w_en_wave, w_en_noise, w_en_duty, w_en_add_noise;

logic signed [SIZE_GAIN_WAVE:0] w_step_amp;
logic [SIZE_SEG-1:0] w_amp_hex_0, w_amp_hex_1;
logic [SIZE_SEG-1:0] w_amp_wave_hex_2;
logic [SIZE_SEG-1:0] w_amp_noise_hex_2;

logic [SIZE_SEG-1:0] w_freq_hex_0, w_freq_hex_1, w_freq_hex_2;
logic [7:0] w_step_freq;
//////////////////////////////////////////////////////////
// Submodule
//////////////////////////////////////////////////////////
//--- Button edge detect
BTN_detect_edge BTN_detect_edge_0_unit (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn[0]),
    .o_signal    (w_btn_0)    
);
BTN_detect_edge BTN_detect_edge_1_unit (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn[1]),
    .o_signal    (w_btn_1)    
);
BTN_detect_edge BTN_detect_edge_2_unit (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn[2]),
    .o_signal    (w_btn_2)    
);
BTN_detect_edge BTN_detect_edge_3_unit (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn[3]),
    .o_signal    (w_btn_3)    
);

//--- Save select wave
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        w_sel_wave <= 3'b000;
    end else if(w_btn_1) begin
        w_sel_wave <= i_sw[6:4];
    end
end
//--- Enable one hot
assign w_en_wave = (~i_sw[8]) & (~i_sw[7]) & ((~w_sel_wave[2]) | ((~w_sel_wave[1]) & (~w_sel_wave[0]))); // Mode = 00 and Select wave = 000,001,010,011,100
assign w_en_noise= (~i_sw[8]) & (~i_sw[7]) & ((w_sel_wave[2]) & (w_sel_wave[1])); // Mode = 00 and Select wave = 110,111
assign w_en_duty = (~i_sw[8]) & (~i_sw[7]) & ((~w_sel_wave[2]) & (~w_sel_wave[1]) & (w_sel_wave[0])); // Mode = 00 and Select wave = 001
assign w_en_add_noise = (~i_sw[8]) & (i_sw[7]); // Mode = 01
assign w_en_amp  = i_sw[8] & ~i_sw[7]; // Mode = 10
assign w_en_freq = i_sw[8] &  i_sw[7]; // Mode = 11

//--- o_gain_wave
CTR_step_amp #(
    .NUM_GAIN_STEP (SIZE_GAIN_WAVE),
    .NUM_SEG (SIZE_SEG)
) CTR_step_amp_unit (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_btn_0(i_btn[0]), // Change step
    .i_btn_1(i_btn[1]), // Save step
    .i_en(w_en_amp),
    .o_step(w_step_amp),
    .o_hex_0(w_amp_hex_0),   // Value
    .o_hex_1(w_amp_hex_1)    // Sign
);
CTR_adjust_amp_wave #(
    .NUM_GAIN_STEP (SIZE_GAIN_WAVE),
    .NUM_SEG       (SIZE_SEG)
) CTR_adjust_amp_wave_unit (
    .i_clk          (i_clk), 
    .i_rst_n        (i_rst_n),
    .i_btn          (i_btn[2]), // Adjust amplitude
    .i_en           (w_en_wave | w_en_amp),       // Mode= Wave/Noise
    .i_step         (w_step_amp),
    .o_gain_wave    (o_gain_wave),
    .o_hex_2        (w_amp_wave_hex_2)// Value
);
CTR_adjust_amp_noise #(
    .NUM_GAIN_STEP (SIZE_GAIN_WAVE),
    .NUM_SEG       (SIZE_SEG)
) CTR_adjust_amp_noise_unit (
    .i_clk          (i_clk), 
    .i_rst_n        (i_rst_n),
    .i_btn          (i_btn[2]), // Adjust amplitude
    .i_en           (w_en_noise | w_en_amp),       // Mode= Wave/Noise
    .i_step         (w_step_amp),
    .o_gain_wave    (o_gain_noise),
    .o_hex_2        (w_amp_noise_hex_2)// Value
);
//--- o_phase_step_wave
CTR_step_phase #(
    .SIZE_VALUE     (7),
    .SIZE_SEG       (SIZE_SEG)
) CTR_step_phase_unit (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_en           (w_en_freq),
    .i_btn_0        (i_btn[0]),
    .i_btn_1        (i_btn[1]),
    .o_step         (w_step_freq),
    .o_hex_0        (w_freq_hex_0),  // sign
    .o_hex_1        (w_freq_hex_1),  // Value0
    .o_hex_2        (w_freq_hex_2)   // value1
);
CTR_adjust_phase_wave #(
    .SIZE_VALUE (7),
    .SIZE_SEG   (SIZE_SEG),
    .SIZE_PHASE ($clog2(SIZE_DEPTH))
) CTR_adjust_phase_wave_unit (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_en           (w_en_wave | w_en_freq),     // Mode= Wave/Noise
    .i_btn          (i_btn[3]),    // Adjust frequency
    .i_step         (w_step_freq),
    .o_phase_wave   (o_phase_step_wave)
);
CTR_adjust_phase_noise #(
    .SIZE_VALUE (7),
    .SIZE_SEG   (SIZE_SEG),
    .SIZE_PHASE ($clog2(SIZE_DEPTH))
) CTR_adjust_phase_noise_unit (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_en           (w_en_noise | w_en_freq),     // Mode= Wave/Noise
    .i_btn          (i_btn[3]),    // Adjust frequency
    .i_step         (w_step_freq),
    .o_phase_wave   (o_phase_step_noise)
);

//////////////////////////////////////////////////////////
// Output
//////////////////////////////////////////////////////////
//-- Add_noise
always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_add_noise
    if (!i_rst_n) begin
        o_add_noise <= 1'b0;
    end else if(w_btn_1 & w_en_add_noise) begin
        o_add_noise <= ~o_add_noise;
    end 
end
assign o_ledr[8] = o_add_noise;
//-- LFSR/Sin noise
always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_lfsr_sin
    if (!i_rst_n) begin
        o_lfsr_sin <= 1'b0;
    end else if(w_btn_1 & w_en_noise) begin
        o_lfsr_sin <= w_sel_wave[0];
    end
end
assign o_ledr[7] = o_lfsr_sin;
//-- Select waveform
assign o_sel_wave = w_sel_wave;
assign o_ledr[6:4] = o_sel_wave;
//-- Duty cycle for square wave
always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_duty_cycle
    if (!i_rst_n) begin
        o_sel_duty_cycle <= '0;
    end else if(w_btn_1 & w_en_duty) begin
        o_sel_duty_cycle <= i_sw[3:1];
    end
end
assign o_ledr[3:1] = o_sel_duty_cycle;

//-- Output HEX
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_out_hex
    if(~i_rst_n) begin
        o_hex_0 <= VALUE_NON;
        o_hex_1 <= VALUE_NON;
        o_hex_2 <= VALUE_NON;
        o_hex_3 <= VALUE_NON;
        o_hex_4 <= VALUE_NON;
        o_hex_5 <= VALUE_NON; 
    end else begin
        o_hex_0 <= w_amp_hex_0;
        o_hex_1 <= w_amp_hex_1;
        o_hex_2 <= (w_btn_2 & (w_en_wave | w_en_amp)) ? w_amp_wave_hex_2 : (w_btn_2 & (w_en_noise | w_en_amp)) ? w_amp_noise_hex_2 : o_hex_2;
        o_hex_3 <= w_freq_hex_0;
        o_hex_4 <= w_freq_hex_1;
        o_hex_5 <= w_freq_hex_2;
    end
end

endmodule
