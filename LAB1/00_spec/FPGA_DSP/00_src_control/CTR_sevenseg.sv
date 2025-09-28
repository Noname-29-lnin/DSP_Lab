module CTR_sevenseg #(
    parameter NUM_VALUE  = 3   ,
    parameter NUM_SEG    = 7    
)(
    input logic                         i_clk   ,
    input logic                         i_rst_n ,
    input logic                         i_start ,
    input logic [NUM_VALUE-1:0]         i_mode  ,
    output logic [NUM_SEG-1:0]          o_hex_0 , // sign
    output logic [NUM_SEG-1:0]          o_hex_1 , // Value0
    output logic [NUM_SEG-1:0]          o_hex_2   // value1
);

localparam SIGN_POS = 7'b1111111;
localparam SIGN_NEG = 7'b1111101;

logic [3:0] bin_1, bin_2;
logic [NUM_SEG-1:0] seg_0, seg_1, seg_2;

seven_seg_anode_common HEX_1_unit (
    .bin    (bin_1),
    .seg    (seg_1)
);
seven_seg_anode_common HEX_2_unit (
    .bin    (bin_2),
    .seg    (seg_2)
);
// 1 Seg display sign
// 2 Seg display value
// i_mode:
// - 000: -1
// - 001:  1
// - 010: -4
// - 011:  4
// - 100:-16
// - 101: 16
// - 110:-64
// - 111: 64
always_comb begin : process_mode
    case(i_mode)
        3'b000: begin
            seg_0 = SIGN_NEG;
            bin_1 = 4'b0001;
            bin_2 = 4'b1111;
        end
        3'b001: begin
            seg_0 = SIGN_POS;
            bin_1 = 4'b0001;
            bin_2 = 4'b1111;
        end
        3'b010: begin
            seg_0 = SIGN_NEG;
            bin_1 = 4'b0100;
            bin_2 = 4'b1111;
        end
        3'b011: begin
            seg_0 = SIGN_POS;
            bin_1 = 4'b0100;
            bin_2 = 4'b1111;
        end
        3'b100: begin
            seg_0 = SIGN_NEG;
            bin_1 = 4'b0100;
            bin_2 = 4'b0000;
        end
        3'b101: begin
            seg_0 = SIGN_POS;
            bin_1 = 4'b0110;
            bin_2 = 4'b0001;
        end
        3'b110: begin
            seg_0 = SIGN_NEG;
            bin_1 = 4'b0100;
            bin_2 = 4'b0110;
        end
        3'b111: begin
            seg_0 = SIGN_POS;
            bin_1 = 4'b0100;
            bin_2 = 4'b0110;
        end
        default: begin
            seg_0 = SIGN_POS;
            bin_1 = 4'b1111;
            bin_2 = 4'b1111;
        end
    endcase
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_out_logic
    if(~i_rst_n) begin
        o_hex_0  <= 7'b0000001;
        o_hex_1  <= 7'b0000001;
        o_hex_2  <= 7'b0000001;
    end else if(i_start) begin
        o_hex_0  <= seg_0;
        o_hex_1  <= seg_1;
        o_hex_2  <= seg_2;
    end
end

endmodule
