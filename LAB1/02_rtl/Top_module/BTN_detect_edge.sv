// i_pos_edge = 0 -> detect negedge edge
// i_pos_edge = 1 -> detect posedge edge
module BTN_detect_edge(
    input logic                 i_clk       ,
    input logic                 i_rst_n     ,
    input logic                 i_pos_edge  ,
    input logic                 i_signal    ,
    output logic                o_signal    
);

logic w_p_signal;

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_detect_edge
    if(~i_rst_n) begin
        w_p_signal <= 1'b0;
        o_signal   <= 1'b0;
    end else begin
        w_p_signal <= i_signal;
        if(i_pos_edge) 
            o_signal <= (i_signal & (~w_p_signal));
        else
            o_signal <= (~i_signal & (w_p_signal));
            
    end
end


endmodule
