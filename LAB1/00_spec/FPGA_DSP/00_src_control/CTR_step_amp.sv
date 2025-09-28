module CTR_step_amp #(
    parameter NUM_GAIN_STEP = 3     ,
    parameter NUM_SEG = 7
)(
    input logic                             i_clk,
    input logic                             i_rst_n,
    input logic                             i_btn,
    input logic                             i_en,
    output logic signed [NUM_GAIN_STEP:0]   o_step,
    output logic [NUM_SEG-1:0]              o_hex_0,   // GiaTriTang
    output logic [NUM_SEG-1:0]              o_hex_1    // sign
);

logic w_btn;
BTN_detect_edge BTN_DE_unit (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b0),
    .i_signal    (i_btn),
    .o_signal    (w_btn) 
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

always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n)
        o_hex_0 <= 7'b1111111; // NONE
    else if(w_en)
        o_hex_0 <= 7'b1001111; // 1
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n)
        o_hex_1 <= 7'b1111111; // NONE
    else if(w_en) begin
        if(w_mode) // step=1
            o_hex_1 <= 7'b1111111; // NONE
        else 
            o_hex_1 <= 7'b1111101; // -
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n)
        o_step <= 4'b0001;
    else if(w_en) begin
        if(w_mode) 
            o_step <= 4'b1111; 
        else
            o_step <= 4'b0001;
    end
end
endmodule
