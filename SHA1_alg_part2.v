module SHA1_alg_part2(
					clk,
					second_half,
					in_round,
					enable,
					out
);

input clk;
input [31:0] second_half;
input [7:0] in_round;
input enable;
output [159:0] out;

reg [31:0] a = 32'h67452301;
reg [31:0] b = 32'hEFCDAB89;
reg [31:0] c = 32'h98BADCFE;
reg [31:0] d = 32'h10325476;
reg [31:0] e = 32'hC3D2E1F0;

reg [159:0] hash = {32'h67452301, 32'hEFCDAB89, 32'h98BADCFE, 32'h10325476, 32'hC3D2E1F0};
reg [31:0] next_k = 32'h5A827999;
reg [31:0] next_f = 32'h98BADCFE;

assign out = hash;

always@(posedge clk)begin
	if(enable)begin
		if(in_round != 82 && in_round != 83)begin
			a <= (a << 5 | a >> 27) + next_f + second_half + next_k + e;
			b <= a;
			c <= (b << 30 | b >> 2);
			d <= c;
			e <= d;	
		end
		
		else if(in_round == 83)begin
			a <= hash[159:128];
			b <= hash[127:96];
			c <= hash[95:64];
			d <= hash[63:32];
			e <= hash[31:0];
			
			next_k <= 32'h5A827999;
			next_f <= (hash[127:96] & hash[95:64]) ^ (~(hash[127:96]) & hash[63:32]);
		end
		
		if(in_round >= 2 && in_round < 21)begin
			next_f <= (a & (b << 30 | b >> 2)) ^ ((~a) & c);
			next_k <= 32'h5A827999;
		end
		
		else if(in_round >= 21 && in_round < 41)begin
			next_f <= (a ^ (b << 30 | b >> 2) ^ c);
			next_k <= 32'h6ED9EBA1;
		end
		
		else if(in_round >= 41 && in_round < 61)begin
			next_f <= ((a & (b << 30 | b >> 2)) ^ (a & c) ^ ((b << 30 | b >> 2) & c));
			next_k <= 32'h8f1bbcdc;
		end
		
		else if(in_round >= 61 && in_round < 81)begin
			next_f <= (a ^ (b << 30 | b >> 2) ^ c);
			next_k <= 32'hca62c1d6;
		end
		
		else if(in_round == 82)begin
			hash <= {(hash[159:128] + a), (hash[127:96] + b), (hash[95:64] + c), (hash[63:32] + d), (hash[31:0] + e)};
		end
	end
	else begin
	
	end
end

endmodule 