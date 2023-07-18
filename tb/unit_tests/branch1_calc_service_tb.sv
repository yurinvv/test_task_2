`timescale 1ns/1ns

module branch1_calc_service_tb;

	localparam CLOCK_PERIOD = 10;
	localparam DWIDTH = 16;
	localparam BRANCH_SIZE = 3072;

	bit aclk;
	bit aresetn;
	
	bit signed [DWIDTH - 1 : 0]        i_sys_item;
	bit signed [DWIDTH - 1 : 0]        i_parity_item;
	bit [$clog2(BRANCH_SIZE) - 1 : 0]  i_addr;
	bit                                i_valid;
	bit [$clog2(BRANCH_SIZE) - 1 : 0]  o_addr;
	bit                                o_valid;
	bit signed [DWIDTH - 1 : 0]        o_data;
	
	////////////////////////////////
	// DUT
	branch1_calc_service#( DWIDTH, BRANCH_SIZE ) dut (
		.aclk           (aclk         ),
		.aresetn        (aresetn      ),
		.i_sys_item     (i_sys_item   ),
		.i_parity_item  (i_parity_item),
		.i_addr         (i_addr       ),
		.i_valid        (i_valid      ),
		.o_addr         (o_addr       ),
		.o_valid        (o_valid      ),
		.o_data         (o_data       )
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
		i_sys_item    <=0;
	    i_parity_item <=0;
	    i_addr        <=0;
	    i_valid       <=0;
		
		aresetn       <=0;
		#1000 aresetn <=1;
		
		repeat(3) begin
			@(posedge aclk);
			i_sys_item <= i_sys_item + 7;
			i_parity_item <= i_parity_item * (-1) - 5;
			i_addr <= i_addr + 4;
			i_valid <= 1;
		end
		
		@(posedge aclk);
		i_valid <= 0;
		
		repeat(1) begin
			@(posedge aclk);
			i_sys_item <= i_sys_item + 14;
			i_parity_item <= -5;
			i_addr <= i_addr + 4;
			i_valid <= 1;
		end
		
		#100 $finish;
		
	end
endmodule