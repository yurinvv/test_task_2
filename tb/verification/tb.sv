`timescale 1ns/1ns

module tb;

	import tb_pckg::*;
	
	/////////////////////////////////////
	//  Select the Test
	/////////////////////////////////////
	//Test512 test;

	Test6144 test;
	
	////////////////////////////////////
	
	localparam CLOCK_PERIOD = 10;

	bit aclk;
	bit aresetn;
	
	// DUT Interface
	dut_if _if(aclk, aresetn);
	
	// DUT
	siso_decoder dut (
		.aclk                    (aclk),
		.aresetn                 (aresetn),
		
		.blklen                  (_if.blklen                 ),
		                              
		.s_axis_in_tdata         (_if.s_axis_in_tdata        ),
		.s_axis_in_tvalid        (_if.s_axis_in_tvalid       ),
		.s_axis_in_tlast         (_if.s_axis_in_tlast        ),
		.s_axis_in_tready        (_if.s_axis_in_tready       ),	
		                              
		.m_axis_llr_tready       (_if.m_axis_llr_tready      ), 
		.m_axis_llr_tvalid       (_if.m_axis_llr_tvalid      ),
		.m_axis_llr_tdata        (_if.m_axis_llr_tdata       ),
		.m_axis_llr_tuser        (_if.m_axis_llr_tuser       ),   // Start of LLR frame 
		.m_axis_llr_tlast        (_if.m_axis_llr_tlast       ),    // End of LLR frame
		                              
		.m_axis_extrinsic_tvalid (_if.m_axis_extrinsic_tvalid),
		.m_axis_extrinsic_tdata  (_if.m_axis_extrinsic_tdata ),
		.m_axis_extrinsic_tuser  (_if.m_axis_extrinsic_tuser ),   // Start of extrinsic frame 
		.m_axis_extrinsic_tlast  (_if.m_axis_extrinsic_tlast )    // End of extrinsic frame
	);

	/////////////////////////////////
	// Clock generation

	initial begin
		aclk = 0;
		forever #(CLOCK_PERIOD/2) aclk = !aclk;
	end
	
	/////////////////////////////////
	// Reset

	initial begin
		aresetn <= 0;
		#1000 aresetn <= 1;
	end

	////////////////////////////////
	// Main thread
	initial begin
		test = new; 
		test.environment0._if = _if;
		wait(aresetn);
		#1000;
		test.run();
		
		#100 $finish;
	end

endmodule