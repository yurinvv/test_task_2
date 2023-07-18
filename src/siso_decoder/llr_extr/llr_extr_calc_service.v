module llr_extr_calc_service#(
	parameter DWIDTH = 16
)(
	input aclk,
	input aresetn,
	// Arguments
	input [DWIDTH - 1:0] alpha_0k,
	input [DWIDTH - 1:0] alpha_1k,
	input [DWIDTH - 1:0] alpha_2k,
	input [DWIDTH - 1:0] alpha_3k,
	input [DWIDTH - 1:0] alpha_4k,
	input [DWIDTH - 1:0] alpha_5k,
	input [DWIDTH - 1:0] alpha_6k,
	input [DWIDTH - 1:0] alpha_7k,
	input [DWIDTH - 1:0] beta_0k,
	input [DWIDTH - 1:0] beta_1k,
	input [DWIDTH - 1:0] beta_2k,
	input [DWIDTH - 1:0] beta_3k,
	input [DWIDTH - 1:0] beta_4k,
	input [DWIDTH - 1:0] beta_5k,
	input [DWIDTH - 1:0] beta_6k,
	input [DWIDTH - 1:0] beta_7k,
	input [DWIDTH - 1:0] branch1_k,
	input [DWIDTH - 1:0] branch2_k,
	input [DWIDTH - 1:0] sys_k,
	// Input control signals
	input i_sof,
	input i_eof,
	input i_valid,
	
	// Output control signals 
	output o_sof_llr,
	output o_eof_llr,
	output o_valid_llr,
	output [DWIDTH - 1:0] o_data_llr,
	
	output o_sof_extr,
	output o_eof_extr,
	output o_valid_extr,
	output [DWIDTH - 1:0] o_data_extr
);
	localparam EXPR_NUMBER = 8;
	localparam LLR_PIPE_LENGTH = 4;
	localparam VALID_PIPE_LENGTH = 9;
	localparam SYS_PIPE_LENGTH = 6;
	
	
	reg [VALID_PIPE_LENGTH - 1:0] valid_pp;
	reg [VALID_PIPE_LENGTH - 1:0] sof_pp;
	reg [VALID_PIPE_LENGTH - 1:0] eof_pp;
	
	reg [DWIDTH - 1:0] sys_pp [SYS_PIPE_LENGTH-1:0];
	
	reg [DWIDTH - 1:0] expr_result   [EXPR_NUMBER-1:0];
	reg [DWIDTH - 1:0] sub_expr0     [EXPR_NUMBER-1:0];
	reg [DWIDTH - 1:0] sub_expr1     [EXPR_NUMBER-1:0];
	reg [DWIDTH - 1:0] sub_expr0_part0 [EXPR_NUMBER-1:0];
	reg [DWIDTH - 1:0] sub_expr0_part1 [EXPR_NUMBER-1:0];
	reg [DWIDTH - 1:0] sub_expr1_part0 [EXPR_NUMBER-1:0];
	reg [DWIDTH - 1:0] sub_expr1_part1 [EXPR_NUMBER-1:0];
	
	reg [DWIDTH - 1:0] max01;  // max(expr0, expr1)
	reg [DWIDTH - 1:0] max23;  // max(expr2, expr3)
	reg [DWIDTH - 1:0] max45;  // max(expr4, expr5)
	reg [DWIDTH - 1:0] max67;  // max(expr6, expr7)
	
	reg [DWIDTH - 1:0] max0123;  //max( max(expr0, expr1), max(expr2, expr3) )
	reg [DWIDTH - 1:0] max4567;  //max( max(expr4, expr5), max(expr6, expr7) )
	reg [DWIDTH - 1:0] llr_result_pp [LLR_PIPE_LENGTH-1:0];
	
	reg [DWIDTH - 1:0]        extr_sub;    // (LLR - sys)
	reg signed [DWIDTH - 1:0] extr_mult;   // 3 * extr_sub
	reg [DWIDTH - 1:0]        extr_shift;  // extr_mult >> 2
	
	wire [DWIDTH - 1:0] llr_result = max0123 - max4567;
	
	assign o_data_llr  = llr_result_pp[LLR_PIPE_LENGTH-1];
	assign o_data_extr = extr_shift;
	
	assign o_sof_llr   = sof_pp[VALID_PIPE_LENGTH - 1];
	assign o_eof_llr   = eof_pp[VALID_PIPE_LENGTH - 1];
	assign o_valid_llr = valid_pp[VALID_PIPE_LENGTH - 1];
	
	assign o_sof_extr   = o_sof_llr;
	assign o_eof_extr   = o_eof_llr;
	assign o_valid_extr = o_valid_llr;
	
	//////////////////////////////////
	// Control signals
	/////////////////////////////////
	
	integer j;
		always@(posedge aclk)
			if (!aresetn) begin
				valid_pp <= 0;
				sof_pp   <= 0;
				eof_pp   <= 0;
			end else begin
				valid_pp[0] <= i_valid;
				sof_pp[0]   <= i_sof;
				eof_pp[0]   <= i_eof;
				for (j = 1; j < VALID_PIPE_LENGTH; j = j + 1) begin
					valid_pp[j] <= valid_pp[j-1];
					sof_pp[j]   <= sof_pp[j-1];
					eof_pp[j]   <= eof_pp[j-1];
				end
			end
	
	//////////////////////////////////
	// LLR
	//////////////////////////////////
	
	/**
	* LLR(k) = max( max(expr0, expr1), max(expr2, expr3) ) -
    *          max( max(expr4, expr5), max(expr6, expr7) );
	*
	*/	
	
	integer i;
	
	always@(posedge aclk)
		if (!aresetn) begin
			for (i=0; i < LLR_PIPE_LENGTH; i = i + 1) begin
				llr_result_pp[i] <= 0;
			end
		end else begin
			llr_result_pp[0] <= llr_result;
			for (i=1; i < LLR_PIPE_LENGTH; i = i + 1) begin
				llr_result_pp[i] <= llr_result_pp[i-1];
			end
		end
		
	//////////////////////////////////
	// EXTRINSIC
	//////////////////////////////////
	/**
	* 3 * (LLR - sys) >>> 2
	*/
	always@(posedge aclk)
		if (!aresetn) begin
			extr_sub <= 0;
			extr_mult <= 0;
			extr_shift <= 0;
		end else begin
			extr_sub <= llr_result_pp[0] - sys_pp[SYS_PIPE_LENGTH - 1];
			extr_mult <= 3 * extr_sub;
			extr_shift <= extr_mult >>> 2;
		end	
		
	integer n;
	
	always@(posedge aclk)
		if (!aresetn) begin
			for (n=0; n < SYS_PIPE_LENGTH; n = n + 1) begin
				sys_pp[n] <= 0;
			end
		end else begin
			sys_pp[0] <= sys_k;
			for (n=1; n < SYS_PIPE_LENGTH; n = n + 1) begin
				sys_pp[n] <= sys_pp[n-1];
			end
		end
	
	//////////////////////////////////
	// MAX 0123
	//////////////////////////////////
	/**
	* max( max(expr0, expr1), max(expr2, expr3) )
	*/
	always@(posedge aclk)
		if (!aresetn) begin
			max0123 <= 0;
		end else begin
			max0123 <= max01 > max23 ? max01 : max23;
		end
		
	//////////////////////////////////
	// MAX 4567
	//////////////////////////////////
	/**
	* max( max(expr4, expr5), max(expr6, expr7)
	*/
	always@(posedge aclk)
		if (!aresetn) begin
			max4567 <= 0;
		end else begin
			max4567 <= max45 > max67 ? max45 : max67;
		end

	//////////////////////////////////
	// MAX 01 - 67
	//////////////////////////////////
	/**
	* max01 = max(expr0, expr1)
	*
	*/
	always@(posedge aclk)
		if (!aresetn) begin
			max01 <= 0;
		end else begin
			max01 <= expr_result[0] > expr_result[1] ? expr_result[0] : expr_result[1];
		end

	/**
	* max23 = max(expr2, expr3)
	*
	*/
	always@(posedge aclk)
		if (!aresetn) begin
			max23 <= 0;
		end else begin
			max23 <= expr_result[2] > expr_result[3] ? expr_result[2] : expr_result[3];
		end
		
	/**
	* max45 = max(expr4, expr5)
	*
	*/
	always@(posedge aclk)
		if (!aresetn) begin
			max45 <= 0;
		end else begin
			max45 <= expr_result[4] > expr_result[5] ? expr_result[4] : expr_result[5];
		end		
		
	/**
	* max67 = max(expr6, expr7)
	*
	*/
	always@(posedge aclk)
		if (!aresetn) begin
			max67 <= 0;
		end else begin
			max67 <= expr_result[6] > expr_result[7] ? expr_result[6] : expr_result[7];
		end	
	
	//////////////////////////////////
	// EXPRESSIONS 0 - 7
	//////////////////////////////////
	/**
	* expr0 = max( alpha(0,k) - branch1(k) + beta(4,k+1),     //sub_expr0
    *              alpha(1,k) - branch1(k) + beta(0, k+1) );  //sub_expr1
	*
	*/
	
	// max()
	always@(posedge aclk)
		if (!aresetn) begin
			expr_result[0] <= 0;
		end else begin
			expr_result[0] <= sub_expr0[0] > sub_expr1[0]? sub_expr0[0] : sub_expr1[0];
		end
	
	// sub_expr0 = alpha(0,k) - branch1(k) + beta(4,k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr0[0] <= 0;
			sub_expr0_part0[0] <= 0;
			sub_expr0_part1[0] <= 0;
		end else begin
			sub_expr0_part0[0] <= alpha_0k - branch1_k;
			sub_expr0_part1[0] <= beta_4k;
			sub_expr0[0] <= sub_expr0_part0[0] + sub_expr0_part1[0];
		end
	
	// sub_expr1 = alpha(1,k) - branch1(k) + beta(0, k+1) 
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr1[0] <= 0;
			sub_expr1_part0[0] <= 0;
			sub_expr1_part1[0] <= 0;
		end else begin
			sub_expr1_part0[0] <= alpha_1k - branch1_k;
			sub_expr1_part1[0] <= beta_0k;
			sub_expr1[0] <= sub_expr1_part0[0] + sub_expr1_part1[0];
		end
		
		
	/**
	* expr1 = max( alpha(2,k) - branch2(k) + beta(1,k+1),
    *              alpha(3,k) - branch2(k) + beta(5, k+1) );
	*
	*/

	// max()
	always@(posedge aclk)
		if (!aresetn) begin
			expr_result[1] <= 0;
		end else begin
			expr_result[1] <= sub_expr0[1] > sub_expr1[1]? sub_expr0[1] : sub_expr1[1];
		end

	// sub_expr0 = alpha(2,k) - branch2(k) + beta(1,k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr0[1] <= 0;
			sub_expr0_part0[1] <= 0;
			sub_expr0_part1[1] <= 0;
		end else begin
			sub_expr0_part0[1] <= alpha_2k - branch2_k;
			sub_expr0_part1[1] <= beta_1k;
			sub_expr0[1] <= sub_expr0_part0[1] + sub_expr0_part1[1];
		end
	
	// sub_expr1 = alpha(3,k) - branch2(k) + beta(5, k+1) 
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr1[1] <= 0;
			sub_expr1_part0[1] <= 0;
			sub_expr1_part1[1] <= 0;
		end else begin
			sub_expr1_part0[1] <= alpha_3k - branch2_k;
			sub_expr1_part1[1] <= beta_5k;
			sub_expr1[1] <= sub_expr1_part0[1] + sub_expr1_part1[1];
		end
	
	
	/**
	* expr2 = max( alpha(4,k) - branch2(k) + beta(6,k+1),
    *              alpha(5,k) - branch2(k) + beta(2, k+1) );
	*
	*/
	
	// max()
	always@(posedge aclk)
		if (!aresetn) begin
			expr_result[2] <= 0;
		end else begin
			expr_result[2] <= sub_expr0[2] > sub_expr1[2]? sub_expr0[2] : sub_expr1[2];
		end

	// sub_expr0 = alpha(4,k) - branch2(k) + beta(6,k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr0[2] <= 0;
			sub_expr0_part0[2] <= 0;
			sub_expr0_part1[2] <= 0;
		end else begin
			sub_expr0_part0[2] <= alpha_4k - branch2_k;
			sub_expr0_part1[2] <= beta_6k;
			sub_expr0[2] <= sub_expr0_part0[2] + sub_expr0_part1[2];
		end
	
	// sub_expr1 = alpha(5,k) - branch2(k) + beta(2, k+1) 
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr1[2] <= 0;
			sub_expr1_part0[2] <= 0;
			sub_expr1_part1[2] <= 0;
		end else begin
			sub_expr1_part0[2] <= alpha_5k - branch2_k;
			sub_expr1_part1[2] <= beta_2k;
			sub_expr1[2] <= sub_expr1_part0[2] + sub_expr1_part1[2];
		end
		
		
	/**
	* expr3 = max( alpha(6,k) - branch1(k) + beta(3,k+1),
    *              alpha(7,k) - branch1(k) + beta(7, k+1) );
	*
	*/
	
	// max()
	always@(posedge aclk)
		if (!aresetn) begin
			expr_result[3] <= 0;
		end else begin
			expr_result[3] <= sub_expr0[3] > sub_expr1[3]? sub_expr0[3] : sub_expr1[3];
		end

	// sub_expr0 = alpha(6,k) - branch1(k) + beta(3,k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr0[3] <= 0;
			sub_expr0_part0[3] <= 0;
			sub_expr0_part1[3] <= 0;
		end else begin
			sub_expr0_part0[3] <= alpha_6k - branch1_k;
			sub_expr0_part1[3] <= beta_3k;
			sub_expr0[3] <= sub_expr0_part0[3] + sub_expr0_part1[3];
		end
	
	// sub_expr1 = alpha(7,k) - branch1(k) + beta(7, k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr1[3] <= 0;
			sub_expr1_part0[3] <= 0;
			sub_expr1_part1[3] <= 0;
		end else begin
			sub_expr1_part0[3] <= alpha_7k - branch1_k;
			sub_expr1_part1[3] <= beta_7k;
			sub_expr1[3] <= sub_expr1_part0[3] + sub_expr1_part1[3];
		end	
	
	
	/**
	* expr4 = max( alpha(0,k) + branch1(k) + beta(0,k+1),
    *              alpha(1,k) + branch1(k) + beta(4, k+1) );
	*
	*/
	
	// max()
	always@(posedge aclk)
		if (!aresetn) begin
			expr_result[4] <= 0;
		end else begin
			expr_result[4] <= sub_expr0[4] > sub_expr1[4]? sub_expr0[4] : sub_expr1[4];
		end

	// sub_expr0 = alpha(0,k) + branch1(k) + beta(0,k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr0[4] <= 0;
			sub_expr0_part0[4] <= 0;
			sub_expr0_part1[4] <= 0;
		end else begin
			sub_expr0_part0[4] <= alpha_0k + branch1_k;
			sub_expr0_part1[4] <= beta_0k;
			sub_expr0[4] <= sub_expr0_part0[4] + sub_expr0_part1[4];
		end
	
	// sub_expr1 = alpha(1,k) + branch1(k) + beta(4, k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr1[4] <= 0;
			sub_expr1_part0[4] <= 0;
			sub_expr1_part1[4] <= 0;
		end else begin
			sub_expr1_part0[4] <= alpha_1k + branch1_k;
			sub_expr1_part1[4] <= beta_4k;
			sub_expr1[4] <= sub_expr1_part0[4] + sub_expr1_part1[4];
		end	


	/**
	* expr5 = max( alpha(2,k) + branch2(k) + beta(5,k+1),
    *              alpha(3,k) + branch2(k) + beta(1, k+1) );
	*
	*/

	// max()
	always@(posedge aclk)
		if (!aresetn) begin
			expr_result[5] <= 0;
		end else begin
			expr_result[5] <= sub_expr0[5] > sub_expr1[5]? sub_expr0[5] : sub_expr1[5];
		end

	// sub_expr0 = alpha(2,k) + branch2(k) + beta(5,k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr0[5] <= 0;
			sub_expr0_part0[5] <= 0;
			sub_expr0_part1[5] <= 0;
		end else begin
			sub_expr0_part0[5] <= alpha_2k + branch2_k;
			sub_expr0_part1[5] <= beta_5k;
			sub_expr0[5] <= sub_expr0_part0[5] + sub_expr0_part1[5];
		end
	
	// sub_expr1 = alpha(3,k) + branch2(k) + beta(1, k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr1[5] <= 0;
			sub_expr1_part0[5] <= 0;
			sub_expr1_part1[5] <= 0;
		end else begin
			sub_expr1_part0[5] <= alpha_3k + branch2_k;
			sub_expr1_part1[5] <= beta_1k;
			sub_expr1[5] <= sub_expr1_part0[5] + sub_expr1_part1[5];
		end	
		
		
	/**
	* expr6 = max( alpha(4,k) + branch2(k) + beta(2,k+1),
    *              alpha(5,k) + branch2(k) + beta(6, k+1) );
	*
	*/	

	// max()
	always@(posedge aclk)
		if (!aresetn) begin
			expr_result[6] <= 0;
		end else begin
			expr_result[6] <= sub_expr0[6] > sub_expr1[6]? sub_expr0[6] : sub_expr1[6];
		end

	// sub_expr0 = alpha(4,k) + branch2(k) + beta(2,k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr0[6] <= 0;
			sub_expr0_part0[6] <= 0;
			sub_expr0_part1[6] <= 0;
		end else begin
			sub_expr0_part0[6] <= alpha_4k + branch2_k;
			sub_expr0_part1[6] <= beta_2k;
			sub_expr0[6] <= sub_expr0_part0[6] + sub_expr0_part1[6];
		end
	
	// sub_expr1 = alpha(5,k) + branch2(k) + beta(6, k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr1[6] <= 0;
			sub_expr1_part0[6] <= 0;
			sub_expr1_part1[6] <= 0;
		end else begin
			sub_expr1_part0[6] <= alpha_5k + branch2_k;
			sub_expr1_part1[6] <= beta_6k;
			sub_expr1[6] <= sub_expr1_part0[6] + sub_expr1_part1[6];
		end	


	/**
	* expr7 = max( alpha(6,k) + branch1(k) + beta(7,k+1),
    *              alpha(7,k) + branch1(k) + beta(3, k+1) );
	*
	*/
	
	always@(posedge aclk)
		if (!aresetn) begin
			expr_result[7] <= 0;
		end else begin
			expr_result[7] <= sub_expr0[7] > sub_expr1[7]? sub_expr0[7] : sub_expr1[7];
		end

	// sub_expr0 = alpha(6,k) + branch1(k) + beta(7,k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr0[7] <= 0;
			sub_expr0_part0[7] <= 0;
			sub_expr0_part1[7] <= 0;
		end else begin
			sub_expr0_part0[7] <= alpha_6k + branch1_k;
			sub_expr0_part1[7] <= beta_7k;
			sub_expr0[7] <= sub_expr0_part0[7] + sub_expr0_part1[7];
		end
	
	// sub_expr1 = alpha(7,k) + branch1(k) + beta(3, k+1)
	always@(posedge aclk)
		if (!aresetn) begin
			sub_expr1[7] <= 0;
			sub_expr1_part0[7] <= 0;
			sub_expr1_part1[7] <= 0;
		end else begin
			sub_expr1_part0[7] <= alpha_7k + branch1_k;
			sub_expr1_part1[7] <= beta_3k;
			sub_expr1[7] <= sub_expr1_part0[7] + sub_expr1_part1[7];
		end	
	
endmodule