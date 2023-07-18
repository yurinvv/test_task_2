module switch_rdram#(
	parameter DWIDTH = 16,
	parameter RAM_DEPTH = 3072
)(
	input  sel,
	input  [$clog2(RAM_DEPTH) - 1 : 0] i_client_addr0,
	output [DWIDTH - 1 : 0]            o_client_data0,
	input  [$clog2(RAM_DEPTH) - 1 : 0] i_client_addr1,
	output [DWIDTH - 1 : 0]            o_client_data1,
	input  [DWIDTH - 1 : 0]            i_data,
	output [$clog2(RAM_DEPTH) - 1 : 0] o_addr
);
	
	assign o_client_data0 = i_data; 
	assign o_client_data1 = i_data;
	assign o_addr         = sel? i_client_addr1 : i_client_addr0;
	
endmodule