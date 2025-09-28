module lfsr #(
    parameter LFSR_WIDTH = 24
)(
    input  logic                    i_clk   ,
    input  logic                    i_rst_n ,
    input  logic                    i_en    ,                  
    output logic [LFSR_WIDTH - 1:0] o_noise
);

    logic [LFSR_WIDTH - 1:0] p_noise, n_noise;
    logic feedback;

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(~i_rst_n) p_noise <= {'0, 1'b1};
        else         p_noise <= n_noise; 
    end

    assign feedback = p_noise[LFSR_WIDTH - 1] ^ p_noise[LFSR_WIDTH/2] ^ p_noise[LFSR_WIDTH/3] ^ p_noise[0];
    assign n_noise  = i_en ? {p_noise[LFSR_WIDTH - 2:0], feedback} : p_noise;
    assign o_noise  = p_noise;

endmodule