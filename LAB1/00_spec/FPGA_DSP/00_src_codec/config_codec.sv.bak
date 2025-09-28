module config_codec #(
    parameter DEPTH = 11
)(
    input  logic i_clk  , 
    input  logic i_rst_n,

    output logic o_done,
    
    output logic o_scl  ,
    inout  logic io_sda
);

    logic [3:0] reg_div, next_div;
    logic tick_div;

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(~i_rst_n) reg_div <= '0      ;
        else         reg_div <= next_div;
    end

    assign tick_div = (reg_div == 4'd8); // 1.5MHz (1:7 - 0:1) => i2c_sclk = 375kHz
    assign next_div = tick_div ? '0 : reg_div + 1'b1;

    logic [15:0] reg_setup [DEPTH:0]; 

    assign reg_setup[ 0] = 16'b0001_111__0_0000_0000; //15 reset all                                                   | addr: 0001_111  15| data: 0_0000_0000                              
    assign reg_setup[ 1] = 16'b0000_010__0_0001_0000; //6  PWU except OUTPD                                            | addr: 0000_110   6| data: 0_0001_0000  
    assign reg_setup[ 2] = 16'b0000_010__1_0111_1001; //2  LVOL - 0dB                                                  | addr: 0000_010   2| data: 1_0111_1001
    assign reg_setup[ 3] = 16'b0000_011__1_0111_1001; //3  RVOL - 0dB                                                  | addr: 0000_011   3| data: 1_0111_1001 
    assign reg_setup[ 4] = 16'b0000_000__0_0001_0111; //0  LIN  - 0dB - Not Mute                                       | addr: 0000_000   0| data: 0_0001_0111 
    assign reg_setup[ 5] = 16'b0000_001__0_0001_0111; //1  RIN  - 0dB - Not Mute                                       | addr: 0000_001   1| data: 0_0001_0111
    //assign reg_setup[ 4] = 16'b0000_000__0_1000_0000; //0  Mute Linein                                                 | addr: 0000_000   0| data: 0_1000_0000 
    //assign reg_setup[ 5] = 16'b0000_001__0_1000_0000; //1  Mute Linein                                                 | addr: 0000_001   1| data: 0_1000_0000
    assign reg_setup[ 6] = 16'b0000_100__0_0001_0000; //4  LINEIN selected to ADC, mute MICIN                          | addr: 0000_100   4| data: 0_0001_0000  
    assign reg_setup[ 7] = 16'b0000_101__0_0000_0000; //5  Disable: High-PF ADC, DAC filter and soft mute,clear offset | addr: 0000_101   5| data: 0_0000_0000   
    assign reg_setup[ 8] = 16'b0000_111__0_0000_0001; //7  left justified 24bit MSB first                              | addr: 0000_111   7| data: 0_0000_1001 
    assign reg_setup[ 9] = 16'b0001_000__0_0000_0001; //8  USB mode, MCLK = 12Mhz, Fs = 48Khz                          | addr: 0001_000   8| data: 0_0000_0001 
    assign reg_setup[10] = 16'b0001_001__0_0000_0001; //9  active                                                      | addr: 0001_001   9| data: 0_0000_0001   
    assign reg_setup[11] = 16'b0000_110__0_0000_0010; //6  PWU: LINEOUT, LINEIN, ADC, DAC... - PD: Mic in              | addr: 0000_110   6| data: 0_0000_0010

    typedef enum logic [1:0] {
        IDLE ,
        START,
        HOLD ,
        DONE
    } e_state;

    e_state reg_state, next_state;

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(~i_rst_n)      reg_state <= IDLE      ;
        else if(tick_div) reg_state <= next_state;
    end

    logic [3:0] reg_counter, next_counter;

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(~i_rst_n)      reg_counter <='0           ;
        else if(tick_div) reg_counter <= next_counter;
    end

    logic  done, start, ready;
    assign done = (reg_counter == DEPTH);

    logic [15:0] trans_data;

    always_comb begin
        case(reg_state)
            IDLE    : next_state = START;
            START   : next_state = HOLD ;
            HOLD    : next_state = ready ? (done ? DONE : START) : HOLD;
            DONE    : next_state = DONE ;
            default : next_state = IDLE ;
        endcase
    end

    always_comb begin
        case(reg_state)
            IDLE    : begin
                start        = 1'b0;
                next_counter = '0;
                trans_data   = reg_setup[reg_counter];
                o_done       = 1'b0;
            end
            START   : begin
                start        = 1'b1;
                next_counter = reg_counter;
                trans_data   = reg_setup[reg_counter];
                o_done       = 1'b0;
            end
            HOLD    : begin
                start        = 1'b0;
                next_counter = ready ? reg_counter + 1'b1 : reg_counter;
                trans_data   = reg_setup[reg_counter];
                o_done       = 1'b0;
            end
            DONE    : begin
                start        = 1'b0;
                next_counter = reg_counter;
                trans_data   = reg_setup[reg_counter];
                o_done       = 1'b1;
            end
            default : begin
                start        = 1'b0;
                next_counter = reg_counter;
                trans_data   = reg_setup[reg_counter];
                o_done       = 1'b0;
            end
        endcase
    end  

    i2c_trans i2c (
        .i_clk       (i_clk),       //  12MHz (50:50 - 0:1)
        .i_rst_n     (i_rst_n),
        .i_div_clk   (tick_div),    // 1.5MHz ( 1: 7 - 0:1)
        .i_start     (start),
        .i_addr      (7'b0011010),
        .i_mode      (1'b0),        // write
        .i_reg_data  (trans_data),
        .o_ready     (ready),
        .o_scl       (o_scl),
        .io_sda      (io_sda)
    );

endmodule
