module siso_decoder#(
	parameter DATA_WIDTH = 16,
	parameter DEPTH_BUF  = 256
)(
	input aclk,
	input aresetn,
	
	input [DATA_WIDTH - 1 : 0]  blklen,
	
	input [DATA_WIDTH - 1 : 0]  s_axis_in_tdata,
	input                       s_axis_in_tvalid,
	input                       s_axis_in_tlast,
	output reg                  s_axis_in_tready,	
	
	input                           m_axis_llr_tready, 
	output reg                      m_axis_llr_tvalid,
	output reg [DATA_WIDTH - 1 : 0] m_axis_llr_tdata,
	output reg                      m_axis_llr_tuser,   // Start of LLR frame 
	output reg                      m_axis_llr_tlast,    // End of LLR frame
	
	//input                           m_axis_extrinsic_tready, 
	output                          m_axis_extrinsic_tvalid,
	output     [DATA_WIDTH - 1 : 0] m_axis_extrinsic_tdata,
	output                          m_axis_extrinsic_tuser,   // Start of extrinsic frame 
	output                          m_axis_extrinsic_tlast    // End of extrinsic frame
);


	wire                         sys_array_we;
	wire [$clog2(DEPTH_BUF) - 1 : 0] sys_array_wr_addr;
	wire [$clog2(DEPTH_BUF) - 1 : 0] sys_array_rd_addr;
	wire [DATA_WIDTH - 1 : 0]        sys_array_data_in;
	wire [DATA_WIDTH - 1 : 0]        sys_array_data_out;
	
	wire                         parity_array_array_we;
	wire [$clog2(DEPTH_BUF) - 1 : 0] parity_array_wr_addr;
	wire [$clog2(DEPTH_BUF) - 1 : 0] parity_array_rd_addr;
	wire [DATA_WIDTH - 1 : 0]        parity_array_data_in;
	wire [DATA_WIDTH - 1 : 0]        parity_array_data_out;
	
	assign m_axis_extrinsic_tvalid = m_axis_llr_tvalid;
	assign m_axis_extrinsic_tuser  = m_axis_llr_tuser;
	assign m_axis_extrinsic_tlast  = m_axis_llr_tlast; 

/////////////////////////////////////////////////////
// Instances	
	
	custom_ram#(
		.DWIDTH(DATA_WIDTH),
		.DEPTH (DEPTH_BUF)
	) sys_array (
		.aclk         (aclk),
		.write_enable (sys_array_we),
		.wr_addr      (sys_array_wr_addr),
		.rd_addr      (sys_array_rd_addr),
		.data_in      (sys_array_data_in),
		.data_out     (sys_array_data_out)
	);
	
	custom_ram#(
		.DWIDTH(DATA_WIDTH),
		.DEPTH (DEPTH_BUF)
	) parity_array (
		.aclk         (aclk),
		.write_enable (sys_array_we),
		.wr_addr      (sys_array_wr_addr),
		.rd_addr      (sys_array_rd_addr),
		.data_in      (sys_array_data_in),
		.data_out     (sys_array_data_out)
	);
	

	
endmodule