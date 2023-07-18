/**
* a - b = subt
*/
module subtraction#(
	parameter DWIDTH = 16
)(
	input [DWIDTH - 1:0] a,
	input [DWIDTH - 1:0] b,
	output [DWIDTH:0]    subt
);
	assign subt = a - b;
endmodule