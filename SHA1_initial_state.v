module SHA1_initial_state(
				 clk,
				 input_state,
				 input_pad,  // <-------------------- testing purposes, remove later ------------------------->
				 message_size,
				 padding_length
);

input clk;
input [1:0] input_state;
input [31:0] message_size;
input [31:0] input_pad;

output [31:0] padding_length;

reg [31:0] output_pad_len;
assign padding_length = output_pad_len;

always @(posedge clk)begin
	//calculate the padding length
	if(input_state == 2'b01)begin
		output_pad_len <= 64;
	end
	
	else begin
		//do nothing if not our state
	end
end
endmodule 