module branch2_block#(
	parameter DWIDTH = 16,
	parameter BRANCH_SIZE = 3072
)(
	input                                 aclk,
	input                                 aresetn,
	input signed [DWIDTH - 1 : 0]         i_sys_item,
	input signed [DWIDTH - 1 : 0]         i_parity_item,
	input [$clog2(BRANCH_SIZE) - 1 : 0]   i_addr,
	input                                 i_valid,
	input [$clog2(BRANCH_SIZE) - 1 : 0]   o_addr,
	output signed [DWIDTH - 1 : 0]        o_data
);

	wire [$clog2(BRANCH_SIZE) - 1 : 0]  bcs_addr;
	wire                                bcs_valid;
	wire signed [DWIDTH - 1 : 0]        bcs_data;
	
	
	branch2_calc_service#( 
		.DWIDTH(DWIDTH), .BRANCH_SIZE(BRANCH_SIZE) ) 
	calc_service (
		.aclk           (aclk         ),
		.aresetn        (aresetn      ),
		.i_sys_item     (i_sys_item   ),
		.i_parity_item  (i_parity_item),
		.i_addr         (i_addr       ),
		.i_valid        (i_valid      ),
		.o_addr         (bcs_addr     ),
		.o_valid        (bcs_valid    ),
		.o_data         (bcs_data     )
	);
	
	
	custom_ram#(
		.DWIDTH(DWIDTH), .DEPTH (BRANCH_SIZE)
	) array_1D (
		.aclk         (aclk      ),
		.write_enable (bcs_valid ),
		.wr_addr      (bcs_addr  ),
		.rd_addr      (o_addr    ),
		.data_in      (bcs_data  ),
		.data_out     (o_data    )
	);

endmodule