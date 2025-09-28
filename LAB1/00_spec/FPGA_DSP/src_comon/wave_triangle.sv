module wave_triangle #(
    parameter WIDTH = 24  ,
    parameter DEPTH = 1024
)(
    input  logic [$clog2(DEPTH) - 1:0] i_phase_count,
    output logic [WIDTH         - 1:0] o_triangle_wave
);

    localparam DEPTH_LOG    = $clog2(DEPTH/2);
    localparam WIDTH_REMAIN = WIDTH - 4 - DEPTH_LOG;

    logic [DEPTH_LOG - 1:0] triangle_up, triangle_down, triangle_val;
    assign triangle_up = i_phase_count[$clog2(DEPTH) - 2:0];

    adder_flex_no_carry #(
        .WIDTH(DEPTH_LOG)
    ) mirror_sawtooth (
        .i_a   ('1),
        .i_b   (~i_phase_count[DEPTH_LOG - 2:0]),
        .i_cin (1'b1),
        .o_s   (triangle_down)
    );

    assign triangle_val    = i_phase_count[$clog2(DEPTH) - 1] ? triangle_down : triangle_up;
    assign o_triangle_wave = {4'b0, triangle_val, {WIDTH_REMAIN{1'b0}}};

endmodule