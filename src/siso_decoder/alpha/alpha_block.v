module alpha_block#(
	parameter DWIDTH = 16,
	parameter ROW_SIZE = 3072
)(
	input aclk,
	input aresetn,
);
	localparam ROW_NUMBER = 8;
	
	localparam OPP01_ROW1 = 0;
	localparam OPP23_ROW1 = 0;
	
	localparam OPP01_ROW2 = 0;
	localparam OPP23_ROW2 = 0;
	
	localparam OPP01_ROW3 = 0;
	localparam OPP23_ROW3 = 0;
	
	localparam OPP01_ROW4 = 0;
	localparam OPP23_ROW4 = 0;
	
	localparam OPP01_ROW5 = 0;
	localparam OPP23_ROW5 = 0;
	
	localparam OPP01_ROW6 = 0;
	localparam OPP23_ROW6 = 0;
	
	localparam OPP01_ROW7 = 0;
	localparam OPP23_ROW7 = 0;
	
	wire [DWIDTH - 1:0] norm_value; //alpha(0, k)
	wire [DWIDTH - 1:0] alpha_0k; //alpha(0, k-1)
	wire [DWIDTH - 1:0] alpha_1k; //alpha(1, k-1)
	wire [DWIDTH - 1:0] alpha_2k; //alpha(2, k-1)
	wire [DWIDTH - 1:0] alpha_3k; //alpha(3, k-1)
	wire [DWIDTH - 1:0] alpha_4k; //alpha(4, k-1)
	wire [DWIDTH - 1:0] alpha_5k; //alpha(5, k-1)
	wire [DWIDTH - 1:0] alpha_6k; //alpha(6, k-1)
	wire [DWIDTH - 1:0] alpha_7k; //alpha(7, k-1)
	wire [DWIDTH - 1:0] branch1_k; //branch1(k-1)
	wire [DWIDTH - 1:0] branch2_k; //branch2(k-1)
	
	wire [$clog2(DEPTH_RAM) - 1 : 0] i_addr  [ROW_NUMBER - 1:0];
	wire                             i_valid [ROW_NUMBER - 1:0];
	wire [$clog2(DEPTH_RAM) - 1 : 0] o_addr  [ROW_NUMBER - 1:0];
	wire                             o_valid [ROW_NUMBER - 1:0];
	wire [DWIDTH - 1 : 0]            o_data  [ROW_NUMBER - 1:0];
	
	
	/////////////////////////////////////////////
	// ROW 0
	/**
	* alpha(0,k) = max(alpha(0, k-1) + branch1(k-1), alpha(1, k-1) - branch1(k-1));
	*/
	localparam OPP01_ROW0 = 0;  // 0 - addition; 1 - subtraction
	localparam OPP23_ROW0 = 1;  // 0 - addition; 1 - subtraction
	
	row_calc_service#(
		.DWIDTH    (DWIDTH),
		.DEPTH_RAM (DEPTH_RAM),
		.OPP01     (OPP01_ROW0),
		.OPP23     (OPP23_ROW0) 
	) row0 (
		.aclk           (aclk),
		.aresetn        (aresetn),
		
		.i_row_item0    (alpha_0k),
		.i_row_item1    (alpha_1k),
		.i_branch_item0 (branch1_k),
		.i_branch_item1 (branch1_k),
		.i_norm_item    (norm_value),
		
		.i_addr         (i_addr[0]),
		.i_valid        (i_valid[0]),
				        
		.o_addr         (o_addr[0]),
		.o_valid        (o_valid[0]),
		.o_data         (o_data[0])
	);
	
	/////////////////////////////////////////////
	// ROW 1
	/**
	* alpha(1,k) = max(alpha(2, k-1) - branch2(k-1), alpha(3, k-1) + branch2(k-1));
	*/
	localparam OPP01_ROW1 = 1; // 0 - addition; 1 - subtraction
	localparam OPP23_ROW1 = 0; // 0 - addition; 1 - subtraction
	
	row_calc_service#(
		.DWIDTH    (DWIDTH),
		.DEPTH_RAM (DEPTH_RAM),
		.OPP01     (OPP01_ROW1),
		.OPP23     (OPP23_ROW1) 
	) row1 (
		.aclk           (aclk),
		.aresetn        (aresetn),
		
		.i_row_item0    (alpha_2k),
		.i_row_item1    (alpha_3k),
		.i_branch_item0 (branch2_k),
		.i_branch_item1 (branch2_k),
		.i_norm_item    (norm_value),
		
		.i_addr         (i_addr[1]),
		.i_valid        (i_valid[1]),
				        
		.o_addr         (o_addr[1]),
		.o_valid        (o_valid[1]),
		.o_data         (o_data[1])
	);


	/////////////////////////////////////////////
	// ROW 2
	/**
	* alpha(2,k) = max(alpha(4, k-1) + branch2(k-1), alpha(5, k-1) - branch2(k-1));
	*/
	localparam OPP01_ROW2 = 0; // 0 - addition; 1 - subtraction
	localparam OPP23_ROW2 = 1; // 0 - addition; 1 - subtraction
	
	row_calc_service#(
		.DWIDTH    (DWIDTH),
		.DEPTH_RAM (DEPTH_RAM),
		.OPP01     (OPP01_ROW2),
		.OPP23     (OPP23_ROW2) 
	) row2 (
		.aclk           (aclk),
		.aresetn        (aresetn),
		
		.i_row_item0    (alpha_4k),
		.i_row_item1    (alpha_5k),
		.i_branch_item0 (branch2_k),
		.i_branch_item1 (branch2_k),
		.i_norm_item    (norm_value),
		
		.i_addr         (i_addr[2]),
		.i_valid        (i_valid[2]),
				        
		.o_addr         (o_addr[2]),
		.o_valid        (o_valid[2]),
		.o_data         (o_data[2])
	);


	/////////////////////////////////////////////
	// ROW 3
	/**
	* alpha(3,k) = max(alpha(6, k-1) - branch1(k-1), alpha(7, k-1) + branch1(k-1));
	*/
	localparam OPP01_ROW3 = 1; // 0 - addition; 1 - subtraction
	localparam OPP23_ROW3 = 0; // 0 - addition; 1 - subtraction
	
	row_calc_service#(
		.DWIDTH    (DWIDTH),
		.DEPTH_RAM (DEPTH_RAM),
		.OPP01     (OPP01_ROW3),
		.OPP23     (OPP23_ROW3) 
	) row3 (
		.aclk           (aclk),
		.aresetn        (aresetn),
		
		.i_row_item0    (alpha_6k),
		.i_row_item1    (alpha_7k),
		.i_branch_item0 (branch1_k),
		.i_branch_item1 (branch1_k),
		.i_norm_item    (norm_value),
		
		.i_addr         (i_addr[3]),
		.i_valid        (i_valid[3]),
				        
		.o_addr         (o_addr[3]),
		.o_valid        (o_valid[3]),
		.o_data         (o_data[3])
	);	
	
	/////////////////////////////////////////////
	// ROW 4
	/**
	* alpha(4,k) = max(alpha(0, k-1) - branch1(k-1), alpha(1, k-1) + branch1(k-1));
	*;
	*/
	localparam OPP01_ROW4 = 1; // 0 - addition; 1 - subtraction
	localparam OPP23_ROW4 = 0; // 0 - addition; 1 - subtraction
	
	row_calc_service#(
		.DWIDTH    (DWIDTH),
		.DEPTH_RAM (DEPTH_RAM),
		.OPP01     (OPP01_ROW4),
		.OPP23     (OPP23_ROW4) 
	) row4 (
		.aclk           (aclk),
		.aresetn        (aresetn),
		
		.i_row_item0    (alpha_0k),
		.i_row_item1    (alpha_1k),
		.i_branch_item0 (branch1_k),
		.i_branch_item1 (branch1_k),
		.i_norm_item    (norm_value),
		
		.i_addr         (i_addr[4]),
		.i_valid        (i_valid[4]),
				        
		.o_addr         (o_addr[4]),
		.o_valid        (o_valid[4]),
		.o_data         (o_data[4])
	);	


	/////////////////////////////////////////////
	// ROW 5
	/**
	* alpha(5,k) = max(alpha(2, k-1) + branch2(k-1), alpha(3, k-1) - branch2(k-1));
	*
	*/
	localparam OPP01_ROW5 = 0; // 0 - addition; 1 - subtraction
	localparam OPP23_ROW5 = 1; // 0 - addition; 1 - subtraction
	
	row_calc_service#(
		.DWIDTH    (DWIDTH),
		.DEPTH_RAM (DEPTH_RAM),
		.OPP01     (OPP01_ROW5),
		.OPP23     (OPP23_ROW5) 
	) row5 (
		.aclk           (aclk),
		.aresetn        (aresetn),
		
		.i_row_item0    (alpha_2k),
		.i_row_item1    (alpha_3k),
		.i_branch_item0 (branch2_k),
		.i_branch_item1 (branch2_k),
		.i_norm_item    (norm_value),
		
		.i_addr         (i_addr[5]),
		.i_valid        (i_valid[5]),
				        
		.o_addr         (o_addr[5]),
		.o_valid        (o_valid[5]),
		.o_data         (o_data[5])
	);	


	/////////////////////////////////////////////
	// ROW 6
	/**
	* alpha(6,k) = max(alpha(4, k-1) - branch2(k-1), alpha(5, k-1) + branch2(k-1));
	*
	*/
	localparam OPP01_ROW6 = 1; // 0 - addition; 1 - subtraction
	localparam OPP23_ROW6 = 0; // 0 - addition; 1 - subtraction
	
	row_calc_service#(
		.DWIDTH    (DWIDTH),
		.DEPTH_RAM (DEPTH_RAM),
		.OPP01     (OPP01_ROW6),
		.OPP23     (OPP23_ROW6) 
	) row6 (
		.aclk           (aclk),
		.aresetn        (aresetn),
		
		.i_row_item0    (alpha_4k),
		.i_row_item1    (alpha_5k),
		.i_branch_item0 (branch2_k),
		.i_branch_item1 (branch2_k),
		.i_norm_item    (norm_value),
		
		.i_addr         (i_addr[6]),
		.i_valid        (i_valid[6]),
				        
		.o_addr         (o_addr[6]),
		.o_valid        (o_valid[6]),
		.o_data         (o_data[6])
	);	
	

	/////////////////////////////////////////////
	// ROW 7
	/**
	* alpha(7,k) = max(alpha(6, k-1) + branch1(k-1), alpha(7, k-1) - branch1(k-1));
	*
	alpha.get(7).set(k, Math.max(alpha.get(6).get(k-1) + branch1.get(k-1), alpha.get(7).get(k-1) - branch1.get(k-1)));
	*
	*/
	localparam OPP01_ROW7 = 1; // 0 - addition; 1 - subtraction
	localparam OPP23_ROW7 = 0; // 0 - addition; 1 - subtraction
	
	row_calc_service#(
		.DWIDTH    (DWIDTH),
		.DEPTH_RAM (DEPTH_RAM),
		.OPP01     (OPP01_ROW7),
		.OPP23     (OPP23_ROW7) 
	) row7 (
		.aclk           (aclk),
		.aresetn        (aresetn),
		
		.i_row_item0    (alpha_4k),
		.i_row_item1    (alpha_5k),
		.i_branch_item0 (branch2_k),
		.i_branch_item1 (branch2_k),
		.i_norm_item    (norm_value),
		
		.i_addr         (i_addr[6]),
		.i_valid        (i_valid[6]),
				        
		.o_addr         (o_addr[6]),
		.o_valid        (o_valid[6]),
		.o_data         (o_data[6])
	);	
endmodule