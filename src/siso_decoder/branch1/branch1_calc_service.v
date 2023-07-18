//Task: imlementation of a next formula: -(sys + parity)/2
module branch1_calc_service#(
	parameter DWIDTH = 16,
	parameter BRANCH_SIZE = 3072
)(
	input                                 aclk,
	//(* direct_reset = "yes" *)input         aresetn,
	input                                 aresetn,
	input signed [DWIDTH - 1 : 0]         i_sys_item,
	input signed [DWIDTH - 1 : 0]         i_parity_item,
	input [$clog2(BRANCH_SIZE) - 1 : 0]   i_addr,
	input                                 i_valid,
	output [$clog2(BRANCH_SIZE) - 1 : 0]  o_addr,
	output                                o_valid,
	output signed [DWIDTH - 1 : 0]        o_data
);
	
// Out: -1 * (sys + parity) >>> 1	. It is the same as -(sys + parity)/2
	
	reg signed [DWIDTH:0] sum_result;
	reg signed [DWIDTH:0] mult_result;
	reg [$clog2(BRANCH_SIZE) - 1 : 0] addr_stage0,  addr_stage_last; 
	reg                               valid_stage0, valid_stage_last; 
		
	// Data	
	assign o_data = mult_result[DWIDTH:1];// Shift
	
	always@(posedge aclk)
		if (!aresetn) begin
			sum_result  <= 0;
			mult_result <= 0;
		end else begin
			// Stage 0
			sum_result <= i_sys_item + i_parity_item;
			// Stage 1
			mult_result <= (-1 * sum_result);
		end	
	
	// Address
	assign o_addr = addr_stage_last;
	
	always@(posedge aclk)
		if (!aresetn) begin
			addr_stage0 <= 0;
			addr_stage_last <= 0;
		end else begin
			addr_stage0 <= i_addr;
			addr_stage_last <= addr_stage0;
		end
		
	// Valid
	assign o_valid = valid_stage_last;
	
	always@(posedge aclk)
		if (!aresetn) begin
			valid_stage0 <= 0;
			valid_stage_last <= 0;
		end else begin
			valid_stage0 <= i_valid;
			valid_stage_last <= valid_stage0;
		end

endmodule