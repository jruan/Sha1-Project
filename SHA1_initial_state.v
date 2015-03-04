module SHA1_initial_state(
				 clk,
				 input_state,
				 message_size,
				 padding_length
);

input clk;
input [1:0] input_state;
input [31:0] message_size;

output [31:0] padding_length;

reg [31:0] full_length;
assign padding_length = full_length;

always @(posedge clk)begin
	//calculate the padding length
	if(input_state == 2'b01)begin
		if ( ((message_size + 1) % 64) <= 56 && ((message_size + 1) % 64) > 0) begin
        full_length <= (message_size/64)*64 + 64;
    end else begin
        full_length <= (message_size/64+1)*64 + 64;
    end
	end
	
	else begin
		//do nothing if not our state
	end
end
endmodule 