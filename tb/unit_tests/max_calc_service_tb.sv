`timescale 1ns/1ns

module max_calc_service_tb;

	localparam CLOCK_PERIOD = 10;
	parameter DWIDTH = 16;
	parameter DEPTH_RAM = 3072;
	parameter OPP01 = 0; // 0 - addition; 1 - subtraction
	parameter OPP23 = 0; // 0 - addition; 1 - subtraction

	bit aclk;
	bit aresetn;
	
	bit [DWIDTH - 1 : 0]      arg0;
	bit [DWIDTH - 1 : 0]      arg1;
	bit [DWIDTH - 1 : 0]      arg2;
	bit [DWIDTH - 1 : 0]      arg3;
	bit [DWIDTH - 1 : 0]      out;
	
	////////////////////////////////
	// DUT
	max_calc_service#(
		.DWIDTH    (DWIDTH   ),
		.DEPTH_RAM (DEPTH_RAM),
		.OPP01     (OPP01    ),
		.OPP23     (OPP23    )
	) dut (
		.aclk   (aclk    ),
		.aresetn(aresetn ),
		.i_arg0 (arg0    ),
		.i_arg1 (arg1    ),
		.i_arg2 (arg2    ),
		.i_arg3 (arg3    ),
		.o_max_result (out)
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
		arg0          <=0;
		arg1          <=0;
		arg2          <=0;
		arg3          <=0;
		wait(aresetn);
		//1
		arg0          <=20;
		arg1          <=10;
		arg2          <=10;
		arg3          <=5;
		
		@(posedge aclk);

		//2
		arg0          <=10;
		arg1          <=5;
		arg2          <=20;
		arg3          <=10;
		
		@(posedge aclk);
		#100;
		
		
		#100 $finish;
		
	end
endmodule