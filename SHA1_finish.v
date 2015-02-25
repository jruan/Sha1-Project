module SHA1_finish(
				clk,
				state, 
				/*in_h0,
				in_h1,
				in_h2,
				in_h3,
				in_h4,*/
				complete
				//result
);

input clk;
input [1:0] state;
/*input [31:0] in_h0;
input [31:0] in_h1;
input [31:0] in_h2;
input [31:0] in_h3;
input [31:0] in_h4;*/

output complete;
//output [159:0] result;

reg done;
//reg [159:0] hash = 0;

assign complete = done;
//assign result = hash;

always @(posedge clk)begin
	if(state == 2'b11)begin
		done <= 1;
	end
	
	else begin
	
	end
end
endmodule 