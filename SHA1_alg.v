module SHA1_alg(
		 state,
		 clk,
		 input_data,
		 round,
		 compute_enable,
		 second_half,
		 output_round,
		 part2_enable
);

input clk;
input [31:0] input_data;
input [7:0] round;
input [1:0] state;
input compute_enable;

output [31:0] second_half;
output [7:0] output_round;
output part2_enable;

reg [31:0] w0;
reg [31:0] w1;
reg [31:0] w2;
reg [31:0] w3;
reg [31:0] w4;
reg [31:0] w5;
reg [31:0] w6;
reg [31:0] w7;
reg [31:0] w8;
reg [31:0] w9;
reg [31:0] w10;
reg [31:0] w11;
reg [31:0] w12;
reg [31:0] w13;
reg [31:0] w14;
reg [31:0] w15;

reg [7:0] r;
reg enable_p2;

assign second_half = w15;
assign output_round = r;
assign part2_enable = enable_p2;

always @(posedge clk)begin
	if(compute_enable)begin	
		w0 <= w1;
		w1 <= w2;
		w2 <= w3;
		w3 <= w4;
		w4 <= w5;
		w5 <= w6;
		w6 <= w7;
		w7 <= w8;
		w8 <= w9;
		w9 <= w10;
		w10 <= w11;
		w11 <= w12;
		w12 <= w13;
		w13 <= w14;
		w14 <= w15;
		r <= round + 1;
		enable_p2 <= 1;
	
		if(round >= 1 && round < 17)begin
			w15 <= input_data;
		end
		
		else if(round >= 17 && round <= 80)begin
			w15 <= (((w13 ^ w8 ^ w2 ^ w0) << 1) |((w13 ^ w8 ^ w2 ^ w0) >> 31));
		end
		
		
		//compute new h0 - h4	
		else if(round == 83)begin
			enable_p2 <= 0;
		end
	end
	
	else begin
		//do nothing
	end
end
endmodule 