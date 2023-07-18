/*
* Origin: -(sys - parity)/2
* Impl: (parity - sys) >>> 1
* Конвейер
*/
module branch2_calc_service#(
	parameter DWIDTH = 16,
	parameter BRANCH_SIZE = 3072
)(
	input                                 aclk,
	input                                 aresetn,
	input signed [DWIDTH - 1 : 0]         i_sys_item,
	input signed [DWIDTH - 1 : 0]         i_parity_item,
	input [$clog2(BRANCH_SIZE) - 1 : 0]   i_addr,
	input                                 i_valid,
	output [$clog2(BRANCH_SIZE) - 1 : 0]  o_addr,
	output                                o_valid,
	output signed [DWIDTH - 1 : 0]        o_data
);
	
// Out: (parity - sys) >>> 1. It is the same as -(sys - parity)/2
	
	reg signed [DWIDTH:0]             subtr_result;
	reg [$clog2(BRANCH_SIZE) - 1 : 0] addr_stage_last; 
	reg [$clog2(BRANCH_SIZE) - 1 : 0] valid_stage_last; 
		
	// Data	
	assign o_data = subtr_result[DWIDTH:1];// Shift
	
	always@(posedge aclk)
		if (!aresetn) begin
			subtr_result <= 0;
		end else begin
			// Stage 1
			subtr_result <= i_parity_item - i_sys_item;
		end	
	
	// Address
	assign o_addr = addr_stage_last;
	
	always@(posedge aclk)
		if (!aresetn) begin
			addr_stage_last <= 0;
		end else begin
			// Stage 1
			addr_stage_last <= i_addr;
		end
		
	// Valid
	assign o_valid = valid_stage_last;
	
	always@(posedge aclk)
		if (!aresetn) begin
			valid_stage_last <= 0;
		end else begin
			// Stage 1
			valid_stage_last <= i_valid;
		end

endmodule