module compare_great_than #(
    parameter WIDTH = 3
)(
    input  logic [WIDTH - 1:0] i_a,
    input  logic [WIDTH - 1:0] i_b,
    output logic               o_gt
);

    logic [WIDTH - 1:0] compare, xnor_result, and_result;
    assign xnor_result = i_a ~^ i_b;
    assign and_result  = i_a & ~i_b;

    genvar i;
    generate 
        if(WIDTH > 1) begin
            for(i = 0; i < WIDTH - 1; i++) assign compare[i] =  (&xnor_result[WIDTH - 1:WIDTH - 1 - i]) & and_result[i];
        end

        assign compare[WIDTH - 1] = and_result[WIDTH - 1];
    endgenerate

    assign o_gt = |compare;

endmodule
