
/**
* Task: max(row(x,k)  +/-  branchx(k), row(x,k)  +/-  branchx(k)) - row(0,k)
*                    opp01                      opp23
*/
module row_calc_service#(
	parameter DWIDTH = 16,
	parameter DEPTH_RAM = 3072,
	parameter OPP01 = 0, // 0 - addition; 1 - subtraction
	parameter OPP23 = 0 // 0 - addition; 1 - subtraction
)(
	input aclk,
	input aresetn,
	input [DWIDTH - 1 : 0]         i_row_item0,
	input [DWIDTH - 1 : 0]         i_row_item1,
	input [DWIDTH - 1 : 0]         i_branch_item0,
	input [DWIDTH - 1 : 0]         i_branch_item1,
	input [DWIDTH - 1 : 0]         i_norm_item,
	
	input [$clog2(DEPTH_RAM) - 1 : 0]     i_addr,
	input                                 i_valid,
	
	output [$clog2(DEPTH_RAM) - 1 : 0]    o_addr,
	output                                o_valid,
	output reg signed [DWIDTH - 1 : 0]    o_data
);

	///////////////////////
	/**
	* ADDR & VALID & NORM conveyor
	*/
	localparam PIPE_LENGTH = 3;

	reg [DWIDTH - 1 : 0]            norm_item_pp[PIPE_LENGTH - 1:0];
	reg [$clog2(DEPTH_RAM) - 1 : 0] addr_pp [PIPE_LENGTH - 1:0];
	reg                             valid_pp [PIPE_LENGTH - 1:0];

	integer i;

	always@(posedge aclk)
		if (!aresetn) begin
			for(i=0; i < PIPE_LENGTH; i = i + 1) begin
				addr_pp[i]  <= 0;
				valid_pp[i] <= 0;
				norm_item_pp[i]  <= 0;
			end
		end else begin
			addr_pp[0]  <= i_addr;
			valid_pp[0] <= i_valid;
			norm_item_pp[0] <= i_norm_item;
			for(i = 1; i < PIPE_LENGTH; i = i + 1) begin
				addr_pp[i]  <= addr_pp[i-1];
				valid_pp[i] <= valid_pp[i-1];
				norm_item_pp[i]  <= norm_item_pp[i-1];
			end
		end

/*
	always@(posedge aclk)
		if (!aresetn) begin
			addr_pp[0]      <= 0;
			valid_pp[0]     <= 0;
			norm_item_pp[0] <= 0;
			addr_pp[1]      <= 0;
			valid_pp[1]     <= 0;
			norm_item_pp[1] <= 0;
			addr_pp[2]      <= 0;
			valid_pp[2]     <= 0;
			norm_item_pp[2] <= 0;
			addr_pp[3]      <= 0;
			valid_pp[3]     <= 0;
			norm_item_pp[3] <= 0;
		end else begin
			addr_pp[0]  <= i_addr;
			valid_pp[0] <= i_valid;
			norm_item_pp[0] <= i_norm_item;
			addr_pp[1]      <= addr_pp[0];
			valid_pp[1]     <= valid_pp[0];
			norm_item_pp[1] <= norm_item_pp[0];
			addr_pp[2]      <= addr_pp[1] ;
			valid_pp[2]     <= valid_pp[1];
			norm_item_pp[2] <= norm_item_pp[1];
			addr_pp[3]      <= addr_pp[2];   
			valid_pp[3]     <= valid_pp[2] ;   
			norm_item_pp[3] <= norm_item_pp[2];
		end*/
	
	assign o_addr  = addr_pp[PIPE_LENGTH - 1];
	assign o_valid = valid_pp[PIPE_LENGTH - 1];
	
	
	///// MAX Calculating
	/**
	* Task: max(arg0  +/-  arg1, arg2  +/-  arg3)
	*                opp01            opp23
	*
	* Latency: 2 periods of aclk
	*/
	wire [DWIDTH - 1 : 0] max_result;
	
	
	max_calc_service#(
		.DWIDTH (DWIDTH),
		.OPP01  (OPP01) , // 0 - addition; 1 - subtraction
		.OPP23  (OPP23)   // 0 - addition; 1 - subtraction
	) max0 (
		.aclk   (aclk   ),
		.aresetn(aresetn),
		.i_arg0       (i_row_item0),
		.i_arg1       (i_branch_item0),
		.i_arg2       (i_row_item1), 
		.i_arg3       (i_branch_item1),
		.o_max_result (max_result)
	);
	
	///// Norm Calculating
		
	always@(posedge aclk)
		if (!aresetn) begin
			o_data <= 0;
		end else begin
			o_data <= max_result - norm_item_pp[PIPE_LENGTH - 2];
		end
endmodule