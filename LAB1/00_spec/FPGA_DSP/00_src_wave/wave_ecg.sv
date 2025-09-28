module wave_ecg #(
    parameter WIDTH    = 24  ,
    parameter DEPTH    = 1024,
    parameter HEX_LINK = "../04_fir_cof/ecg_wave_0.1.txt"
)(
    input  logic                       i_clk        ,
    //input  logic                       i_rst_n      ,
    input  logic [$clog2(DEPTH) - 1:0] i_phase_count,
    output logic [WIDTH         - 1:0] o_ecg_wave
);

    single_port_ram #(
        .DATA_WIDTH (WIDTH), 
        .ADDR_WIDTH ($clog2(DEPTH)),
    	.HEX_LINK	(HEX_LINK)
    ) ecg_rom (
        .i_clk      (i_clk),
        .i_wren     (1'b0),
        .i_addr     (i_phase_count),
        .i_st_data  ({WIDTH{1'bx}}),
        .o_ld_data  (o_ecg_wave)
    );

endmodule