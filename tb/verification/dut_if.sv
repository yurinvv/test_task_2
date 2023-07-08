interface dut_if#(
	parameter DATA_WIDTH = 16,
	parameter DEPTH_BUF  = 256
)(
	input aclk,
	input aresetn
);

	logic [DATA_WIDTH - 1 : 0] blklen;
	
	logic [DATA_WIDTH - 1 : 0] s_axis_in_tdata;
	logic                      s_axis_in_tvalid;
	logic                      s_axis_in_tready;
	logic                      s_axis_in_tlast;
	
	logic                       m_axis_llr_tready; 
	logic                       m_axis_llr_tvalid;
	logic  [DATA_WIDTH - 1 : 0] m_axis_llr_tdata;
	logic                       m_axis_llr_tuser;   // Start of frame 
	logic                       m_axis_llr_tlast;   // End of frame
	
	//input                       m_axis_extrinsic_tready, 
	logic                       m_axis_extrinsic_tvalid;
	logic  [DATA_WIDTH - 1 : 0] m_axis_extrinsic_tdata;
	logic                       m_axis_extrinsic_tuser;   // Start of frame 
	logic                       m_axis_extrinsic_tlast;    // End of frame
	
	task initSlaveSignals();
		blklen = 0;
		s_axis_in_tdata = 0;
		s_axis_in_tvalid = 0;
	endtask;
	
	////////////////////////////////////
	// Send method
	task sendData (input bit[DATA_WIDTH - 1 : 0] data);
		//@(posedge cb);
		@(posedge aclk);
		s_axis_in_tvalid <= 1;
		s_axis_in_tdata  <= data;
		wait(s_axis_in_tready);
		//@(posedge cb);
		@(posedge aclk);
		s_axis_in_tvalid <= 0;
	endtask
	
	///////////////////////////////////
	// Receive method
	task receiveData (
		output bit sof,
		output int llr_data,
		output int extr_data,
		output bit eof
		);
	//@(posedge cb);	
	@(posedge aclk);
	m_axis_llr_tready <= 1;
	wait(m_axis_llr_tvalid);
	//@(posedge cb);
	@(posedge aclk);
	llr_data          <= m_axis_llr_tdata;
	extr_data         <= m_axis_extrinsic_tdata;
	sof               <= m_axis_llr_tuser;
	eof               <= m_axis_llr_tlast;	
	m_axis_llr_tready <= 0;
	@(posedge aclk);
	endtask

endinterface