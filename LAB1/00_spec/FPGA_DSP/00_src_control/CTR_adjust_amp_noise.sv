module CTR_adjust_amp_noise #(
    parameter NUM_GAIN_STEP = 3     ,
    parameter NUM_SEG       = 7 
)(
    input logic                         i_clk, 
    input logic                         i_rst_n,
    input logic                         i_btn_0,    // Select adjust size
    input logic                         i_btn_1,    // Adjust amplitude
    input logic                         i_en,       // Mode= Wave/Noise


    output logic signed [NUM_GAIN_STEP:0]   o_gain_wave ,
    output logic [NUM_SEG-1:0]              o_hex_0 , // sign
    output logic [NUM_SEG-1:0]              o_hex_1 , // GiaTriTang
    output logic [NUM_SEG-1:0]              o_hex_2   // Value
);

logic w_btn;
BTN_detect_edge BTN_DE_unit (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn_1),
    .o_signal    (w_btn)
);
logic w_en;
assign w_en = w_btn & i_en;

logic signed [NUM_GAIN_STEP:0] w_step;
CTR_step_amp #(
    .NUM_GAIN_STEP(NUM_GAIN_STEP),
    .NUM_SEG (NUM_SEG)
) CTR_step_amp_unit (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_btn(i_btn_0),
    .i_en(i_en),
    .o_step(w_step), // 1:-1
    .o_hex_0(o_hex_0),   // GiaTriTang
    .o_hex_1(o_hex_1)    // sign
);

logic signed [NUM_GAIN_STEP:0] w_next_gain;
assign w_next_gain = o_gain_wave + w_step;
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n) 
        o_gain_wave <= 4'b0001;
    else if(w_en)
        o_gain_wave <= w_next_gain;
end

logic [6:0] w_hex_2;
seven_seg_anode_common SEVEN_SEG_Unit (
    .bin (o_gain_wave[NUM_GAIN_STEP-1:0]),
    .seg (w_hex_2)
);
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n) 
        o_hex_2 <= 7'b1111111; // NONE
    else 
        o_hex_2 <= w_hex_2;
end

endmodule
