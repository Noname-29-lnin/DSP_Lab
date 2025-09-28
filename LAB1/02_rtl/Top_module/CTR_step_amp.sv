module CTR_step_amp #(
    parameter NUM_GAIN_STEP = 3     ,
    parameter NUM_SEG = 7
)(
    input logic                             i_clk,
    input logic                             i_rst_n,
    input logic                             i_btn_0, // Change step
    input logic                             i_btn_1, // Save step
    input logic                             i_en,
    output logic signed [NUM_GAIN_STEP:0]   o_step,
    output logic [NUM_SEG-1:0]              o_hex_0,   // Value
    output logic [NUM_SEG-1:0]              o_hex_1    // Sign
);

localparam SIGN_POS  = 7'b1111111;
localparam SIGN_NEG  = 7'b0111111;
localparam VALUE_ONE = 7'b1111001;
localparam VALUE_NON = 7'b1111111;

logic w_btn, w_btn_1;
BTN_detect_edge BTN_DE_unit (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn_0),
    .o_signal    (w_btn) 
);
BTN_detect_edge BTN_DE_unit_1 (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn_1),
    .o_signal    (w_btn_1) 
);
logic w_en;
assign w_en = i_en & w_btn;

logic w_mode;
logic w_next_mode;
assign w_next_mode = ~w_mode;
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        w_mode <= '0;
    else if (w_en)
        w_mode <= w_next_mode;
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_hex_value
    if(~i_rst_n)
        o_hex_0 <= VALUE_NON; // NONE
    else if(w_en)
        o_hex_0 <= VALUE_ONE; // 1
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_hex_sign
    if(~i_rst_n)
        o_hex_1 <= SIGN_POS; // NONE
    else if(w_en) begin
        if(w_mode) // step=1
            o_hex_1 <= SIGN_POS; // NONE
        else 
            o_hex_1 <= SIGN_NEG; // -
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n)
        o_step <= 4'b0001;
    else if(w_en & w_btn_1) begin
        if(w_mode) 
            o_step <= 4'b1111; 
        else
            o_step <= 4'b0001;
    end
end
endmodule
