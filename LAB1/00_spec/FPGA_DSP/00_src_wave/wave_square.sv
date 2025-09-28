module wave_square #(
    parameter WIDTH    = 24  ,
    parameter DEPTH    = 1024,
    parameter BEHAVIOR = 0
)(
    input  logic [$clog2(DEPTH) - 1:0] i_phase_count,
    input  logic [                2:0] i_sel_duty_cycle,
    output logic [WIDTH         - 1:0] o_square_wave
);

    logic high_low;
    logic duty_90, duty_80, duty_75, duty_66, duty_50, duty_33, duty_25, duty_20, duty_10;

    assign duty_50 = i_phase_count[$clog2(DEPTH) - 1];
    assign duty_75 = |i_phase_count[$clog2(DEPTH) - 1:$clog2(DEPTH) - 2];

    assign duty_10 = ~duty_90;
    assign duty_20 = ~duty_80;
    assign duty_25 = ~duty_75;
    assign duty_33 = ~duty_66;

    always_comb begin
        case(i_sel_duty_cycle)
            3'd0   : high_low = duty_10; // 10%
            3'd1   : high_low = duty_20; // 20%
            3'd2   : high_low = duty_25; // 25%
            3'd3   : high_low = duty_33; // 33%
            3'd4   : high_low = duty_50; // 50%
            3'd5   : high_low = duty_75; // 75%
            3'd6   : high_low = duty_80; // 80%
            3'd7   : high_low = duty_90; // 90%
        endcase
    end

    assign o_square_wave = high_low ? 24'h0FFF00 : 24'h0;

    
            compare_great_than #(
                .WIDTH($clog2(DEPTH))
            ) duty_90_t (
                .i_a (i_phase_count),
                .i_b (10'h065),
                .o_gt(duty_90)
            );

            compare_great_than #(
                .WIDTH($clog2(DEPTH))
            ) duty_80_t (
                .i_a (i_phase_count),
                .i_b (10'h0CB),
                .o_gt(duty_80)
            );

            compare_great_than #(
                .WIDTH($clog2(DEPTH))
            ) duty_66_t (
                .i_a (i_phase_count),
                .i_b (10'h154),
                .o_gt(duty_66)
            );

endmodule