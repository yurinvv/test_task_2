/**
* a + b = sum
*/
module addition#(
	parameter DWIDTH = 16
)(
	input [DWIDTH - 1:0] a,
	input [DWIDTH - 1:0] b,
	output [DWIDTH:0]    sum
);
	assign sum = a + b;
endmodule