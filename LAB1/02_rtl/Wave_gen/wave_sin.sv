module wave_sin #(
    parameter WIDTH = 24 ,
    parameter DEPTH = 1024,
    parameter HEX_LINK = "./sin_wave.txt",
    parameter BEHAVIOR = 0
)(
    input  logic                       i_clk        ,
    //input  logic                       i_rst_n      ,
    input  logic [$clog2(DEPTH) - 1:0] i_phase_count,
    output logic [WIDTH         - 1:0] o_sine_wave
);

    localparam DEPTH_LOG = $clog2(DEPTH/4);
    localparam DEPTH_SUB = DEPTH_LOG - 1  ;
    localparam WIDTH_SUB = WIDTH - 1;

    logic [DEPTH_LOG - 1:0] phase_count, phase_down ;
    logic [WIDTH     - 1:0] sine_data  , sin_rom_xor;
    logic [WIDTH     - 1:0] two_compiment_for_sine;
    assign two_compiment_for_sine = {{WIDTH_SUB{1'b0}}, i_phase_count[$clog2(DEPTH) - 1]};

    assign phase_count = i_phase_count[$clog2(DEPTH) - 2] ? phase_down : i_phase_count[DEPTH_LOG - 1:0];
    assign sin_rom_xor = sine_data  ^ {WIDTH{i_phase_count[$clog2(DEPTH) - 1]}}; 

    generate
        if(BEHAVIOR) begin
            assign phase_down  = {DEPTH_LOG{1'b1}} - i_phase_count[DEPTH_LOG - 1:0];
            assign o_sine_wave = sin_rom_xor + {{DEPTH_SUB{1'b0}}, i_phase_count[$clog2(DEPTH) - 1]};
        end
        
        else begin

            adder_flex_no_carry #(
                .WIDTH(DEPTH_LOG)
            ) mirror_sine (
                .i_a   ('1),
                .i_b   (~i_phase_count[DEPTH_LOG - 1:0]),
                .i_cin (1'b1),
                .o_s   (phase_down)
            );

            adder_flex_no_carry #(
                .WIDTH(WIDTH)
            ) two_compiment (
                .i_a   (sin_rom_xor),
                .i_b   (two_compiment_for_sine),
                .i_cin (1'b0),
                .o_s   (o_sine_wave)
            );
        end
    endgenerate

    single_port_ram #(
        .DATA_WIDTH (WIDTH), 
        .ADDR_WIDTH (DEPTH_LOG),
    	.HEX_LINK	(HEX_LINK)
    ) sine_rom (
        .i_clk      (i_clk),
        .i_wren     (1'b0),
        .i_addr     (phase_count),
        .i_st_data  ({WIDTH{1'bx}}),
        .o_ld_data  (sine_data)
    );

endmodule