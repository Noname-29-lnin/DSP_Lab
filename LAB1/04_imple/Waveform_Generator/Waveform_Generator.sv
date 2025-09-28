module Waveform_Generator(
    input  logic        CLOCK_50        ,
    input  logic  [9:0] SW              ,
    input  logic  [3:0] KEY             ,

    inout  wire         FPGA_I2C_SDAT   ,
    output logic        FPGA_I2C_SCLK   ,

    output logic  [9:0] LEDR            ,
    output logic  [6:0] HEX0            ,
    output logic  [6:0] HEX1            ,
    output logic  [6:0] HEX2            ,
    output logic  [6:0] HEX3            ,
    output logic  [6:0] HEX4            ,
    output logic  [6:0] HEX5            ,

    output logic        AUD_XCK         ,
    output logic        AUD_BCLK        ,
    input  logic        AUD_ADCDAT      ,
    output logic        AUD_ADCLRCK     ,
    output logic        AUD_DACDAT      ,
    output logic        AUD_DACLRCK 
);

endmodule
