module CTR_adjust_phase_noise #(
    parameter SIZE_VALUE     = 7,
    parameter SIZE_SEG       = 7,
    parameter SIZE_PHASE     = 512
)(
    input logic                         i_clk   ,
    input logic                         i_rst_n ,
    input logic                         i_en,       // Mode= Wave/Noise
    input logic                         i_btn_0,    // Select adjust size
    input logic                         i_btn_1,    // Adjust frequency

    output logic [SIZE_PHASE-1:0]       o_phase_wave,
    output logic [SIZE_SEG-1:0]         o_hex_0 , // sign
    output logic [SIZE_SEG-1:0]         o_hex_1 , // Value0
    output logic [SIZE_SEG-1:0]         o_hex_2   // value1
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

logic signed [SIZE_VALUE:0] w_step;
CTR_step_phase #(
    .SIZE_VALUE (SIZE_VALUE),
    .SIZE_SEG   (SIZE_SEG  )
) CTR_step_phase_unit (
    .i_clk   (i_clk   ),
    .i_rst_n (i_rst_n ),
    .i_en    (i_en    ),
    .i_btn   (i_btn_0),
    .o_step  (w_step),
    .o_hex_0 (o_hex_0), // sign
    .o_hex_1 (o_hex_1), // Value0
    .o_hex_2 (o_hex_2)  // value1
);

logic signed [SIZE_PHASE:0] w_step_phase;
logic signed [SIZE_PHASE:0] w_next_step_phase;
logic signed [SIZE_PHASE:0] w_add_step_phase;
assign w_add_step_phase = {{(SIZE_PHASE-SIZE_VALUE){w_step[SIZE_VALUE-1]}}, w_step};

assign w_next_step_phase = w_step_phase + w_add_step_phase;
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n)
        w_step_phase    <= 'd0;
    else if(w_en)
        w_step_phase    <= w_next_step_phase;
end

logic [SIZE_PHASE-1:0] w_phase_wave;
always_comb begin 
    if(w_step_phase[SIZE_PHASE]) begin
        w_phase_wave = w_step_phase[SIZE_PHASE-1:0];
    end else begin
        w_phase_wave = (~w_step_phase[SIZE_PHASE-1:0]) + 1'b1;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n)
        o_phase_wave    <= 'd0;
    else if(w_en)
        o_phase_wave    <= w_phase_wave;
end
endmodule
