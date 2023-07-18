`timescale 1ns/1ns

module llr_extr_calc_service_tb;

	localparam CLOCK_PERIOD = 10;
	parameter DWIDTH = 16;
	
	bit aclk;
	bit aresetn;
	
	// Arguments
	bit [DWIDTH - 1:0] alpha_0k;
	bit [DWIDTH - 1:0] alpha_1k;
	bit [DWIDTH - 1:0] alpha_2k;
	bit [DWIDTH - 1:0] alpha_3k;
	bit [DWIDTH - 1:0] alpha_4k;
	bit [DWIDTH - 1:0] alpha_5k;
	bit [DWIDTH - 1:0] alpha_6k;
	bit [DWIDTH - 1:0] alpha_7k;
	bit [DWIDTH - 1:0] beta_0k;
	bit [DWIDTH - 1:0] beta_1k;
	bit [DWIDTH - 1:0] beta_2k;
	bit [DWIDTH - 1:0] beta_3k;
	bit [DWIDTH - 1:0] beta_4k;
	bit [DWIDTH - 1:0] beta_5k;
	bit [DWIDTH - 1:0] beta_6k;
	bit [DWIDTH - 1:0] beta_7k;
	bit [DWIDTH - 1:0] branch1_k;
	bit [DWIDTH - 1:0] branch2_k;
	bit [DWIDTH - 1:0] sys_k;
	// Input control signals
	bit i_sof;
	bit i_eof;
	bit i_valid;
	
	// Output control signals 
	wire o_sof_llr;
	wire o_eof_llr;
	wire o_valid_llr;
	wire [DWIDTH - 1:0] o_data_llr;

	wire o_sof_extr;
	wire o_eof_extr;
	wire o_valid_extr;
	wire [DWIDTH - 1:0] o_data_extr;

	////////////////////////////////
	// DUT
	llr_extr_calc_service#(
		.DWIDTH(DWIDTH)
	) dut (
		.aclk   (aclk),
		.aresetn(aresetn),
		// Arguments
		.alpha_0k  (alpha_0k ),
		.alpha_1k  (alpha_1k ),
		.alpha_2k  (alpha_2k ),
		.alpha_3k  (alpha_3k ),
		.alpha_4k  (alpha_4k ),
		.alpha_5k  (alpha_5k ),
		.alpha_6k  (alpha_6k ),
		.alpha_7k  (alpha_7k ),
		.beta_0k   (beta_0k  ),
		.beta_1k   (beta_1k  ),
		.beta_2k   (beta_2k  ),
		.beta_3k   (beta_3k  ),
		.beta_4k   (beta_4k  ),
		.beta_5k   (beta_5k  ),
		.beta_6k   (beta_6k  ),
		.beta_7k   (beta_7k  ),
		.branch1_k (branch1_k),
		.branch2_k (branch2_k),
		.sys_k     (sys_k),
		// Input control signals
		.i_sof     (i_sof  ),
		.i_eof     (i_eof  ),
		.i_valid   (i_valid),
		
		// Output control signals 
		.o_sof_llr   (o_sof_llr  ),
		.o_eof_llr   (o_eof_llr  ),
		.o_valid_llr (o_valid_llr),
		.o_data_llr  (o_data_llr ),
		
		.o_sof_extr   (o_sof_extr  ),
		.o_eof_extr   (o_eof_extr  ),
		.o_valid_extr (o_valid_extr),
		.o_data_extr  (o_data_extr )
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
		#50 aresetn <= 1;
	end
	
	///////////////////////////////
	//  Driving
	
	// Main
	initial begin 
		init();
		wait(aresetn);
		repeat(3) begin
			@(posedge aclk);
			setPattern();
			@(posedge aclk);
			init();
		end
		
		#300 $finish;
	end
	
	/////////
	task init();
		alpha_0k  <= 0;
		alpha_1k  <= 0;
		alpha_2k  <= 0;
		alpha_3k  <= 0;
		alpha_4k  <= 0;
		alpha_5k  <= 0;
		alpha_6k  <= 0;
		alpha_7k  <= 0;
		beta_0k   <= 0;
		beta_1k   <= 0;
		beta_2k   <= 0;
		beta_3k   <= 0;
		beta_4k   <= 0;
		beta_5k   <= 0;
		beta_6k   <= 0;
		beta_7k   <= 0;
		branch1_k <= 0;
		branch2_k <= 0;
		sys_k     <=0;
		i_sof     <=0;
		i_eof     <=0;
		i_valid   <=0;
	endtask
	
	task setPattern();
		alpha_0k  <= 0;
		alpha_1k  <= 1;
		alpha_2k  <= 2;
		alpha_3k  <= 3;
		alpha_4k  <= 4;
		alpha_5k  <= 5;
		alpha_6k  <= 6;
		alpha_7k  <= 7;
		beta_0k   <= 10;
		beta_1k   <= 11;
		beta_2k   <= 12;
		beta_3k   <= 13;
		beta_4k   <= 14;
		beta_5k   <= 15;
		beta_6k   <= 16;
		beta_7k   <= 17;
		branch1_k <= -1;
		branch2_k <= -2;
		sys_k     <= 7;
		i_sof     <=1;
		i_eof     <=0;
		i_valid   <=1;
	endtask	
endmodule