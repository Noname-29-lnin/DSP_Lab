module CTR_step_phase #(
    parameter SIZE_VALUE     = 7  ,
    parameter SIZE_SEG       = 7 
)(
    input logic                         i_clk   ,
    input logic                         i_rst_n ,
    input logic                         i_en    ,
    input logic                         i_btn   ,
    output logic signed [SIZE_VALUE:0]  o_step  ,
    output logic [SIZE_SEG-1:0]          o_hex_0 , // sign
    output logic [SIZE_SEG-1:0]          o_hex_1 , // Value0
    output logic [SIZE_SEG-1:0]          o_hex_2   // value1
);

logic w_btn;
BTN_detect_edge BTN_DE_unit (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn),
    .o_signal    (w_btn) 
);

localparam NUM_STEP      = 3;
logic [NUM_STEP-1:0] w_mode;
logic [NUM_STEP-1:0] w_next_mode;
logic w_en;
assign w_en = w_btn & i_en;
// i_mode:
// - 000: -1
// - 001:  1
// - 010: -4
// - 011:  4
// - 100:-16
// - 101: 16
// - 110:-64
// - 111: 64
assign w_next_mode = w_mode + 1'b1;
always_ff @( posedge i_clk or negedge i_rst_n ) begin : increase_mode
    if(~i_rst_n) 
        w_mode <= 3'b001;
    else if (w_en)
        w_mode <= w_next_mode;
end
always_comb begin : process_o_step
    case(w_mode)
        3'b000:  o_step = -7'sd1;
        3'b001:  o_step =  7'sd1;
        3'b010:  o_step = -7'sd4;
        3'b011:  o_step =  7'sd4;
        3'b100:  o_step = -7'sd16;
        3'b101:  o_step =  7'sd16;
        3'b110:  o_step = -7'sd64;
        3'b111:  o_step =  7'sd64;
        default: o_step = 7'sd1;
    endcase
end

CTR_sevenseg #(
    .NUM_VALUE  (NUM_STEP),
    .NUM_SEG    (SIZE_SEG) 
) SEG_UNIT (
    .i_clk   (i_clk),
    .i_rst_n (i_rst_n),
    .i_start (w_en),
    .i_mode  (w_mode),
    .o_hex_0 (o_hex_0), // sign
    .o_hex_1 (o_hex_1), // Value0
    .o_hex_2 (o_hex_2)// value1
);
endmodule
