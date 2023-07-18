`timescale 1ns/1ns

module row_calc_service_tb;

	localparam CLOCK_PERIOD = 10;
	parameter DWIDTH = 16;
	parameter DEPTH_RAM = 3072;
	parameter OPP01 = 0; // 0 - addition; 1 - subtraction
	parameter OPP23 = 0; // 0 - addition; 1 - subtraction

	bit aclk;
	bit aresetn;
	
	bit [DWIDTH - 1 : 0]      row_item0;
	bit [DWIDTH - 1 : 0]      row_item1;
	bit [DWIDTH - 1 : 0]      branch_item0;
	bit [DWIDTH - 1 : 0]      branch_item1;
	bit [DWIDTH - 1 : 0]      norm_item;
	bit [$clog2(DEPTH_RAM) - 1 : 0]  i_addr;
	bit                              i_valid;
	wire [$clog2(DEPTH_RAM) - 1 : 0]  o_addr;
	wire                              o_valid;
	wire [DWIDTH - 1 : 0]             o_data;
	
	////////////////////////////////
	// DUT
	row_calc_service#(
		.DWIDTH    (DWIDTH),
		.DEPTH_RAM (DEPTH_RAM),
		.OPP01     (OPP01), // 0 - addition; 1 - subtraction
		.OPP23     (OPP23) // 0 - addition; 1 - subtraction
	)dut(
		.aclk           (aclk),
		.aresetn        (aresetn),
		.i_row_item0    (row_item0),
		.i_row_item1    (row_item1),
		.i_branch_item0 (branch_item0),
		.i_branch_item1 (branch_item1),
		.i_norm_item    (norm_item),
		
		.i_addr         (i_addr),
		.i_valid        (i_valid),
				        
		.o_addr         (o_addr),
		.o_valid        (o_valid),
		.o_data         (o_data)
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
		row_item0 <=0;
		row_item1 <=0;
		branch_item0 <=0;
		branch_item1 <=0;
		norm_item <=0;
	    i_addr        <=0;
	    i_valid       <=0;
		
		wait(aresetn);
		//1
		@(posedge aclk);
		row_item0 <=20;
		row_item1 <=-10;
		branch_item0 <=10;
		branch_item1 <=30;
		norm_item <=5;
	    i_addr        <=4;
	    i_valid       <=1;
		
		@(posedge aclk);
		i_valid <= 0;
		//2
		row_item0 <=0;
		row_item1 <=0;
		branch_item0 <=0;
		branch_item1 <=0;
		norm_item <=0;
	    i_addr        <=0;
	    i_valid       <=0;
		
		
		#100 $finish;
		
	end
endmodule