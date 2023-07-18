module custom_ram#(
	parameter DWIDTH = 16,
	parameter DEPTH = 256
)(
	input aclk,
	input write_enable,
	input [$clog2(DEPTH) - 1 : 0] wr_addr,
	input [$clog2(DEPTH) - 1 : 0] rd_addr,
	input [DWIDTH - 1 : 0] data_in,
	output reg [DWIDTH - 1 : 0] data_out
);
	
	reg [DWIDTH - 1 : 0] ram [DEPTH - 1 : 0];
	integer i;
		
	initial for (i=0; i<DEPTH; i=i+i) ram[i] = 0;
	
	always @(posedge aclk)
		begin
		data_out <= ram[rd_addr];
			if(write_enable)
				ram[wr_addr] <= data_in;
		end

endmodule