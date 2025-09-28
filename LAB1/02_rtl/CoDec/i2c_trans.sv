module i2c_trans (
    input  logic               i_clk       ,
    input  logic               i_rst_n     ,
    input  logic               i_div_clk   ,

    input  logic               i_start     ,
    input  logic [        6:0] i_addr      ,
    input  logic               i_mode      ,
    input  logic [       15:0] i_reg_data  ,
    output logic               o_ready     ,

    output logic               o_scl       ,
    inout  logic               io_sda
);

    typedef enum logic [3:0] { 
        IDLE    ,
        START_I ,
        START_II,
        HOLD_I  ,
        HOLD_II ,
        DATA_I  ,
        DATA_II ,
        DATA_III,
        DATA_IV ,
        STOP_I  ,
        STOP_II 
    } e_state;
    e_state reg_state, next_state;

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(~i_rst_n)       reg_state <= IDLE      ;
        else if(i_div_clk) reg_state <= next_state;
        //else               reg_state <= next_state;
    end

    logic [26:0] data;

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(~i_rst_n)     data <= '0;
        else if(i_start) data = {i_addr, i_mode, 1'b1, i_reg_data[15:8], 1'b1, i_reg_data[7:0], 1'b1};
    end

    logic [4:0] reg_counter, next_counter;
    
    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(~i_rst_n)       reg_counter <= '0          ;
        else if(i_div_clk) reg_counter <= next_counter;
        //else               reg_counter <= next_counter;
    end

    logic  count_end;
    assign count_end = reg_counter == 5'b0;

    logic scl, sda, ready, reg_scl, reg_sda;

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(~i_rst_n) {reg_scl, reg_sda} <= '1;
        else         {reg_scl, reg_sda} <= {scl, sda};
    end

    always_comb begin
        case(reg_state)
            IDLE    : next_state = i_start ? START_I : IDLE;

            START_I : next_state = START_II;

            START_II: next_state = HOLD_I  ;

            HOLD_I  : next_state = DATA_I  ;

            DATA_I  : next_state = DATA_II ;

            DATA_II : next_state = DATA_III;

            DATA_III: next_state = DATA_IV ;

            DATA_IV : next_state = count_end ? HOLD_II : DATA_I;

            HOLD_II : next_state = STOP_I ;

            STOP_I  : next_state = STOP_II;

            STOP_II : next_state = IDLE   ;

            default : next_state = IDLE   ;
        endcase
    end

    always_comb begin
        case(reg_state)
            IDLE    : begin
                next_counter = 5'd26;
                scl          = 1'b1;
                sda          = 1'b1;
                ready        = 1'b1;
            end

            START_I : begin
                next_counter = reg_counter;
                scl          = 1'b1;
                sda          = 1'b0;
                ready        = 1'b0;
            end

            START_II: begin
                next_counter = reg_counter;
                scl          = 1'b0;
                sda          = 1'b0;
                ready        = 1'b0;
            end

            HOLD_I  : begin
                next_counter = reg_counter;
                scl          = 1'b0;
                sda          = 1'b0;
                ready        = 1'b0;
            end

            DATA_I  : begin
                next_counter = reg_counter;
                scl          = 1'b0;
                sda          = data[reg_counter];
                ready        = 1'b0;
            end

            DATA_II : begin
                next_counter = reg_counter;
                scl          = 1'b1;
                sda          = data[reg_counter];
                ready        = 1'b0;
            end

            DATA_III: begin
                next_counter = reg_counter;
                scl          = 1'b1;
                sda          = data[reg_counter];
                ready        = 1'b0;
            end

            DATA_IV : begin
                next_counter = reg_counter - 1'b1;
                scl          = 1'b0;
                sda          = data[reg_counter];
                ready        = 1'b0;
            end

            HOLD_II : begin
                next_counter = reg_counter;
                scl          = 1'b0;
                sda          = 1'b0;
                ready        = 1'b0;
            end

            STOP_I  : begin
                next_counter = reg_counter;
                scl          = 1'b1;
                sda          = 1'b0;
                ready        = 1'b0;
            end

            STOP_II : begin
                next_counter = reg_counter;
                scl          = 1'b1;
                sda          = 1'b1;
                ready        = 1'b0;
            end

            default : begin
                next_counter = reg_counter;
                scl          = 1'b1;
                sda          = 1'b1;
                ready        = 1'b1;
            end
        endcase
    end

    assign o_scl   = reg_scl ? 1'bz : 1'b0;
    assign io_sda  = reg_sda ? 1'bz : 1'b0;
    assign o_ready = ready                ;

endmodule
