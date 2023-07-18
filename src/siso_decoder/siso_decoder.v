module siso_decoder#(
	parameter DWIDTH = 16,
	parameter BLKLEN_MAX = 6144
)(
	input aclk,
	input aresetn,
	//////////////////////////////////////////////
	// IN and BLKLEN
	
	input [DATA_WIDTH - 1 : 0]  blklen,
	
	input [DATA_WIDTH - 1 : 0]  s_axis_in_tdata,
	input                       s_axis_in_tvalid,
	output reg                  s_axis_in_tready,	
	
	//////////////////////////////////////////////
	// LLR
	//input                           m_axis_llr_tready, 
	output reg                      m_axis_llr_tvalid,
	output reg [DATA_WIDTH - 1 : 0] m_axis_llr_tdata,
	output reg                      m_axis_llr_tuser,   // Start of vector 
	output reg                      m_axis_llr_tlast,    // End of vector
	
	//////////////////////////////////////////////
	// Extrinsic
	//input                           m_axis_extrinsic_tready, 
	output                          m_axis_extrinsic_tvalid,
	output     [DATA_WIDTH - 1 : 0] m_axis_extrinsic_tdata,
	output                          m_axis_extrinsic_tuser,   // Start of vector 
	output                          m_axis_extrinsic_tlast    // End of vector
);

	//////////////////////////////////////////////
	// BRANCH 1 BLOCK
	//

	localparam BRANCH_SIZE = BLKLEN_MAX/2;
	//Writing
	wire [DWIDTH - 1 : 0]              branch1_block_sys;
	wire [DWIDTH - 1 : 0]              branch1_block_parity;
	wire                               branch1_block_wrvalid;
	wire [$clog2(BRANCH_SIZE) - 1 : 0] branch1_block_wraddr;
	//Reading
	wire [$clog2(BRANCH_SIZE) - 1 : 0] branch1_block_rdaddr;
	wire [DWIDTH - 1 : 0]              branch1_block_rddata;

	branch1_block#(
		.DWIDTH(DWIDTH), .BRANCH_SIZE(BRANCH_SIZE)
	) branch1_block0 (
		.aclk          (aclk                  ),
		.aresetn       (aresetn               ),
		.i_sys_item    (branch1_sys_bus       ),
		.i_parity_item (branch1_block_parity  ),
		.i_addr        (branch1_block_wraddr  ),
		.i_valid       (branch1_block_wrvalid ),
		.o_addr        (branch1_block_rdaddr  ),
		.o_data        (branch1_block_rddata  )
	);
	
	//////////////////////////////////////////////
	// BRANCH 2 BLOCK
	//
	
	//Writing
	wire [DWIDTH - 1 : 0]              branch2_block_sys;
	wire [DWIDTH - 1 : 0]              branch2_block_parity;
	wire                               branch2_block_wrvalid;
	wire [$clog2(BRANCH_SIZE) - 1 : 0] branch2_block_wraddr;
	//Reading
	wire [$clog2(BRANCH_SIZE) - 1 : 0] branch2_block_rdaddr;
	wire [DWIDTH - 1 : 0]              branch2_block_rddata;

	branch2_block#(
		.DWIDTH(DWIDTH), .BRANCH_SIZE(BRANCH_SIZE)
	) branch2_block0 (
		.aclk          (aclk                  ),
		.aresetn       (aresetn               ),
		.i_sys_item    (branch2_sys_bus       ),
		.i_parity_item (branch2_block_parity  ),
		.i_addr        (branch2_block_wraddr  ),
		.i_valid       (branch2_block_wrvalid ),
		.o_addr        (branch2_block_rdaddr  ),
		.o_data        (branch2_block_rddata  )
	);
	
	
	//////////////////////////////////////////////
	// ALPHA RAM
	//
	
	localparam ALPHA_RAM_DEPTH = 8 * BLKLEN_MAX / 2;
	
	//Writing
	wire [DWIDTH - 1 : 0]                  alpha_ram_wrdata;
	wire                                   alpha_ram_wrvalid;
	wire [$clog2(ALPHA_RAM_DEPTH) - 1 : 0] alpha_ram_wraddr;
	//Reading
	wire [$clog2(ALPHA_RAM_DEPTH) - 1 : 0] alpha_ram_rdaddr;
	wire [DWIDTH - 1 : 0]                  alpha_ram_rddata;
	
	custom_ram#(
		.DWIDTH(DWIDTH), .DEPTH (ALPHA_RAM_DEPTH)
	) alpha_ram (
		.aclk         ( aclk              ),
		.write_enable ( alpha_ram_wrvalid ),
		.wr_addr      ( alpha_ram_wraddr  ),
		.rd_addr      ( alpha_ram_rdaddr  ),
		.data_in      ( alpha_ram_wrdata  ),
		.data_out     ( alpha_ram_rddata  )
	);
	
	
	//////////////////////////////////////////////
	// BETA RAM
	//
	
	localparam BETA_RAM_DEPTH = ALPHA_RAM_DEPTH;
	
	//Writing
	wire [DWIDTH - 1 : 0]                 beta_ram_wrdata;
	wire                                  beta_ram_wrvalid;
	wire [$clog2(BETA_RAM_DEPTH) - 1 : 0] beta_ram_wraddr;
	//Reading
	wire [$clog2(BETA_RAM_DEPTH) - 1 : 0] beta_ram_rdaddr;
	wire [DWIDTH - 1 : 0]                 beta_ram_rddata;
	
	custom_ram#(
		.DWIDTH(DWIDTH), .DEPTH (BETA_RAM_DEPTH)
	) beta_ram (
		.aclk         ( aclk             ),
		.write_enable ( beta_ram_wrvalid ),
		.wr_addr      ( beta_ram_wraddr  ),
		.rd_addr      ( beta_ram_rdaddr  ),
		.data_in      ( beta_ram_wrdata  ),
		.data_out     ( beta_ram_rddata  )
	);
	
	//////////////////////////////////////////////
	// SYS RAM
	//
	
	localparam SYS_RAM_DEPTH = BLKLEN_MAX / 2;
	
	//Writing
	wire [DWIDTH - 1 : 0]                 sys_ram_wrdata ;
	wire                                  sys_ram_wrvalid;
	wire [$clog2(BETA_RAM_DEPTH) - 1 : 0] sys_ram_wraddr ;
	//Reading
	wire [$clog2(BETA_RAM_DEPTH) - 1 : 0] sys_ram_rdaddr;
	wire [DWIDTH - 1 : 0]                 sys_ram_rddata;
	
	custom_ram#(
		.DWIDTH(DWIDTH), .DEPTH (SYS_RAM_DEPTH)
	) beta_ram (
		.aclk         ( aclk            ),
		.write_enable ( sys_ram_wrvalid ),
		.wr_addr      ( sys_ram_wraddr  ),
		.rd_addr      ( sys_ram_rdaddr  ),
		.data_in      ( sys_ram_wrdata  ),
		.data_out     ( sys_ram_rddata  )
	);
	
	//////////////////////////////////////////////
	// PARITY RAM is redundant.
	//
	
	//////////////////////////////////////////////
	// Alpha Calculating Service
	//
	
	
endmodule