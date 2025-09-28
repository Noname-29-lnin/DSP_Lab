module phase_accummulator #(
    parameter DEPTH    = 1024,
    parameter BEHAVIOR = 1
)(
    input  logic                       i_clk        ,
    input  logic                       i_rst_n      ,
    input  logic                       i_tick       ,
    input  logic [$clog2(DEPTH) - 1:0] i_count_value,
    output logic [$clog2(DEPTH) - 1:0] o_phase_count
);

    localparam DEPTH_LOG_SUB = $clog2(DEPTH) - 1;

    logic [$clog2(DEPTH) - 1:0] reg_count, count;

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(~i_rst_n)    reg_count <= '0    ;
        else if(i_tick) reg_count <= count ;
    end

    generate
        if(BEHAVIOR) assign count = reg_count + i_count_value;

        else begin
            adder_flex_no_carry #(
                .WIDTH($clog2(DEPTH))
            ) adder (
                .i_a   (reg_count),
                .i_b   (i_count_value),
                .i_cin (1'b0),
                .o_s   (count)
            );
        end
    endgenerate

    assign o_phase_count = reg_count;

endmodule