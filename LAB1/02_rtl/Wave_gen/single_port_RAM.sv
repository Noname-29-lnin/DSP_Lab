module single_port_ram #(
    parameter DATA_WIDTH = 8, 
    parameter ADDR_WIDTH = 11,
	parameter HEX_LINK	 = "../04_fir_cof/sine_wave.txt"
)(
    input  logic                      i_clk,
    input  logic                      i_wren,
    input  logic [(ADDR_WIDTH - 1):0] i_addr,
	input  logic [(DATA_WIDTH - 1):0] i_st_data,

	output logic [(DATA_WIDTH - 1):0] o_ld_data
);
	
	reg [DATA_WIDTH - 1:0] ram [2**ADDR_WIDTH - 1:0];

    initial $readmemh(HEX_LINK, ram);

	reg [ADDR_WIDTH - 1:0] addr_reg;

	always @ (posedge i_clk) begin : proc_ram
		if (i_wren) ram[i_addr] <= i_st_data;

		addr_reg <= i_addr;
	end
	  
	assign o_ld_data = ram[addr_reg];

endmodule
