module wave_gen_tb();

    parameter WIDTH = 24  ;
    parameter DEPTH = 1024;

    logic                              i_clk             ;
    logic                              i_rst_n           ;
    logic                              i_samp_tick       ;
    logic                              i_add_noise       ; // 0 - pure waveform, 1 - waveform + noise
    logic        [                2:0] i_sel_wave        ; // select output waveform type
    logic        [$clog2(DEPTH) - 1:0] i_wave_phase_step ; // phase step of NCO for waveform - frequency control
    logic        [                2:0] i_sel_duty_cycle  ; // select duty cycle for square wave
    logic signed [                3:0] i_gain_wave       ; // gain control for waveform amplitude
    logic                              i_lfsr_sin        ; // 0 - LFSR noise, 1 - high-order sine harmonic
    logic        [$clog2(DEPTH) - 1:0] i_wave_sine_step  ; // phase step of NCO for high-frequency sine noise
    logic signed [                3:0] i_gain_noise      ; // gain control for noise amplitude
    logic signed [WIDTH         - 1:0] o_wave_out        ;

    wave_gen #(
        .WIDTH(24  ),
        .DEPTH(1024)
    ) dut (
        .i_clk             (i_clk),
        .i_rst_n           (i_rst_n),
        .i_samp_tick       (i_samp_tick),
        .i_add_noise       (i_add_noise),       // 0 - pure waveform, 1 - waveform + noise
        .i_sel_wave        (i_sel_wave),        // select output waveform type
        .i_wave_phase_step (i_wave_phase_step), // phase step of NCO for waveform - frequency control
        .i_sel_duty_cycle  (i_sel_duty_cycle),  // select duty cycle for square wave
        .i_gain_wave       (i_gain_wave),       // gain control for waveform amplitude
        .i_lfsr_sin        (i_lfsr_sin),       // 0 - LFSR noise, 1 - high-order sine harmonic
        .i_wave_sine_step  (i_wave_sine_step),  // phase step of NCO for high-frequency sine noise
        .i_gain_noise      (i_gain_noise),      // gain control for noise amplitude
        .o_wave_out        (o_wave_out) 
    );

    // Clock generation: 50 MHz clock (period = 20 ns)
    always #10 i_clk = ~i_clk;

    initial begin 
        $shm_open("waves.shm")  ;
        $shm_probe("ASM")       ;
    end

    initial begin
        // Initialization
        i_clk             =  1'b0;
        i_rst_n           =  1'b0;
        i_samp_tick       =  1'b1;
        i_add_noise       =  1'b1;
        //i_add_noise       =  1'b0;
        //i_sel_wave        =  3'd4;
        i_sel_wave        =  3'd0;
        i_wave_phase_step = 10'd1;

        i_sel_duty_cycle  =  3'd4;

        i_gain_wave       =  4'd7;
        i_lfsr_sin        =  1'b1;
        i_wave_sine_step  = 10'd3;
        i_gain_noise      =  4'd1;

        // Release reset
        #40
        i_rst_n           =  1'b1;

        // Test sequence
        #50000
        i_wave_phase_step =  10'd4;
        i_gain_noise      =  4'd2;
        #50000
        i_wave_phase_step =  10'd2;

        #50000
        i_gain_wave       =  4'd7;

        #50000
        i_gain_wave       =  4'd3;

        #50000
        i_lfsr_sin        =  1'b1;
        i_sel_wave        =  3'd0;
        i_wave_phase_step =  10'd1;
        i_gain_noise      =  4'd1;

        #50000
        i_gain_noise      =  4'd2;
        i_wave_sine_step  =  10'd5;

        #50000
        i_lfsr_sin        =  1'b0;

        #50000
        
        $finish;
    end

endmodule
