module seven_seg_anode_common (
    input  logic [3:0] bin,
    output logic [6:0] seg
);
    always_comb begin
        case (bin)
            4'd0: seg = 7'b1000000; // 0 (đảo từ 0000001)
            4'd1: seg = 7'b1111001; // 1 (đảo từ 1001111)
            4'd2: seg = 7'b0100100; // 2 (đảo từ 0010010)
            4'd3: seg = 7'b0110000; // 3 (đảo từ 0000110)
            4'd4: seg = 7'b0011001; // 4 (đảo từ 1001100)
            4'd5: seg = 7'b0010010; // 5 (đảo từ 0100100)
            4'd6: seg = 7'b0000010; // 6 (đảo từ 0100000)
            4'd7: seg = 7'b1111000; // 7 (đảo từ 0001111)
            4'd8: seg = 7'b0000000; // 8 (đảo từ 0000000)
            4'd9: seg = 7'b0010000; // 9 (đảo từ 0000100)
            default: seg = 7'b1111111;
        endcase
    end
endmodule
