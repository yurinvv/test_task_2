/**
* Task: max(arg0  +/-  arg1, arg2  +/-  arg3)
*                opp01            opp23
*/
module max_calc_service#(
	parameter DWIDTH = 16,
	parameter OPP01 = 0, // 0 - addition; 1 - subtraction
	parameter OPP23 = 0 // 0 - addition; 1 - subtraction
)(
	input aclk,
	input aresetn,
	input signed [DWIDTH - 1 : 0]         i_arg0,
	input signed [DWIDTH - 1 : 0]         i_arg1,
	input signed [DWIDTH - 1 : 0]         i_arg2,
	input signed [DWIDTH - 1 : 0]         i_arg3,
	output reg signed [DWIDTH - 1 : 0]    o_max_result
);
	
	wire signed [DWIDTH:0]	opp01_result_comb;
	wire signed [DWIDTH:0]	opp23_result_comb;
	reg signed [DWIDTH:0]  opp01_result;
	reg signed [DWIDTH:0]  opp23_result;
	
		
	generate
		if (OPP01)
			subtraction#(.DWIDTH(DWIDTH)) sub0 (.a(i_arg0), .b(i_arg1), .subt(opp01_result_comb));
		else
			addition#(.DWIDTH(DWIDTH)) add0 (.a(i_arg0), .b(i_arg1), .sum(opp01_result_comb));
	endgenerate
	
	generate
		if (OPP23)
			subtraction#(.DWIDTH(DWIDTH)) sub1 (.a(i_arg2), .b(i_arg3), .subt(opp23_result_comb));
		else
			addition#(.DWIDTH(DWIDTH)) add1 (.a(i_arg2), .b(i_arg3), .sum(opp23_result_comb));
	endgenerate
				
	// Stage 1
	/**
	* opp01 = arg0  +/-  arg1
	*/
	always@(posedge aclk)
		if (!aresetn) opp01_result <= 0;
		else          opp01_result <= opp01_result_comb;
			
	/**
	* opp23 = arg2  +/-  arg3
	*/
	always@(posedge aclk)
		if (!aresetn) opp23_result <= 0;
		else          opp23_result <= opp23_result_comb;
			
	// Stage 2	
	/**
	* max
	*/
	always@(posedge aclk)
		if (!aresetn) 
			o_max_result <= 0;
		else if (opp01_result > opp23_result)
			o_max_result <= opp01_result;
		else
			o_max_result <= opp23_result;

endmodule