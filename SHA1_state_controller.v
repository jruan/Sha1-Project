module SHA1_state_controller(
						nreset,
						start_hash,
						//done,
						state
);

input nreset;
input start_hash;
//input done;

output [1:0] state;

reg [1:0] output_state;
reg initialized = 0;

assign state = output_state;

always @(*)
begin
	//reset state
	if(nreset == 0)begin
		output_state = 2'b00;
	end
	
	//transition into initialize state
	else if(nreset == 1 && start_hash == 1 && ~initialized)begin
		output_state = 2'b01;
		initialized = 1;
	end
	
	//transition into computation state
	else if(nreset == 1 && start_hash == 0 && initialized)begin
		output_state = 2'b10;
	end

	else begin
		//else nothing should happen
	end
end
endmodule 						
			