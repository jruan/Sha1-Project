module SHA1_alg(
		 state,
		 clk,
		 input_data,
		 round,
		 compute_enable,
		/* out_h0,
		 out_h1,
		 out_h2,
		 out_h3,
		 out_h4,*/
		 out
);

input clk;
input [31:0] input_data;
input [7:0] round;
input [1:0] state;
input compute_enable;

/*output [31:0] out_h0;
output [31:0] out_h1;
output [31:0] out_h2;
output [31:0] out_h3;
output [31:0] out_h4;*/

output [159:0] out;

reg [31:0] a;
reg [31:0] b;
reg [31:0] c;
reg [31:0] d;
reg [31:0] e;

reg [31:0] w[15:0];

/*reg [31:0] new_h0;
reg [31:0] new_h1;
reg [31:0] new_h2;
reg [31:0] new_h3;
reg [31:0] new_h4;*/

reg [31:0] h0 = 32'h67452301;
reg [31:0] h1 = 32'hEFCDAB89;
reg [31:0] h2 = 32'h98BADCFE;
reg [31:0] h3 = 32'h10325476;
reg [31:0] h4 = 32'hC3D2E1F0;

reg [159:0] hash;

/*assign out_h0 = new_h0;
assign out_h1 = new_h1;
assign out_h2 = new_h2;
assign out_h3 = new_h3;
assign out_h4 = new_h4;*/
assign out = hash;

function compute_a;
	input [31:0] a;
	input [31:0] b;
	input [31:0] c;
	input [31:0] d;
	input [31:0] e;
	input [7:0] t;
	input [31:0] input_data;
	
	if(t >= 1 && t <= 20)begin
		compute_a = (a << 5 | a >> 27) + ((b & c) ^ ((~b) & d)) + input_data + 32'h5A827999 + e;
	end
	
	else if(t >= 21 && t <= 40)begin
		compute_a = (a << 5 | a >> 27) + (b ^ c ^ d) + input_data + 32'h6ED9EBA1 + e;
	end
	
	else if(t >= 41 && t <= 60)begin
		compute_a = (a << 5 | a >> 27) + ((b &c ) ^ (b & d) ^ (c & d)) + input_data + 32'h8f1bbcdc + e;
	end
	
	else begin
		compute_a = (a << 5 | a >> 27) + (b ^ c ^ d) + input_data + 32'hca62c1d6 + e;
	end
	
endfunction 	
always @(posedge clk)begin
	if(compute_enable)begin
		if(round >= 1 && round <= 20)begin

			//first round, a b c d e must be equal to the initial input h. compute new values for each var
			//assign the input data, 1st 32 bits into our w register
			if(round == 1)begin
				w[round - 1] <= input_data;
				//a <= (h0 << 5 | h0 >> 27) + ((h1 & h2) ^ ((h1 ^ 32'hFFFFFFFF) & h3)) + input_data + 32'h5A827999 + h4;
				a <= compute_a(h0, h1, h2, h3, h4, round, input_data);
				b <= h0;
				c <= (h1 << 30 | h1 >> 2);
				d <= h2;
				e <= h3;
			end
			
			//from round 2 - 16, a b c d e must now be the value assigned to it from the last cycle. Again compute 
			//values for each. assign into w the 32 bits in our block.
			else if(round > 1 && round < 17)begin
				w[round - 1] <= input_data;
				//a <= (a << 5 | a >> 27); /*+ ((b & c) ^ ((~b) & d)) + input_data + 32'h5a827999 + e;*/
				a <= compute_a(a, b, c, d, e, round, input_data);
				b <= a;
				c <= (b << 30 | b >> 2);
				d <= c;
				e <= d;
			end
			
			//finally, when it is greater than 16, the block has been done, we mut now use bits from w to compute new w. It is no longer input 
			//data aka bits from the 512 bit block. Again compute a b c d e.
			else begin
				w[(round - 1) % 16] <= ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) % 16]) << 1) | 
											  ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) % 16]) >> 31);
				/*a <= (a << 5 | a >> 27) + ((b & c) ^ ((b ^ 32'hFFFFFFFF) & d)) + 
					  (((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) %  16]) << 1) |
					  ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) %  16]) >> 31)) +
					  32'h5a827999 + e;*/
				a <= compute_a(a, b, c, d, e, round, (((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) %  16]) << 1) |
					  ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) %  16]) >> 31)));
				b <= a;
				c <= (b << 30 | b >> 2);
				d <= c;
				e <= d;
			end
		end
		
		//20 <= t <= 39, compute a, b, c, d, e with new equation
		else if(round >= 21 && round <= 40)begin
			
			w[(round - 1) % 16] <= ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) % 16]) << 1) | 
										  ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) % 16]) >> 31);
			a <= (a << 5 | a >> 27); /*+ (b ^ c ^ d) + 
				  (((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) %  16]) << 1) |
				  ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) %  16]) >> 31)) + 
				  32'h6ED9EBA1 + e;*/
			b <= a;
			c <= (b << 30 | b >> 2);
			d <= c;
			e <= d;
		end
		
		
		//40 <= t <= 59, compute a,b,c,d,e with new equations
		else if(round >= 41 && round <= 60)begin

			w[(round - 1) % 16] <= ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) % 16]) << 1) | 
										  ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) % 16]) >> 31);
			a <= (a << 5 | a >> 27); /*+ ((b &c ) ^ (b & d) ^ (c & d)) + 
				  (((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) %  16]) << 1) |
				  ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) %  16]) >> 31)) +
				  32'h8f1bbcdc + e;*/
			b <= a;
			c <= (b << 30 | b >> 2);
			d <= c;
			e <= d;
		end
		
		//60 <= t <= 79, compute a,b,c,d,e with new equations
		else if(round >= 61 && round <= 80)begin
			
			w[(round - 1) % 16] <= ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) % 16]) << 1) | 
										  ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) % 16]) >> 31);
			a <= (a << 5 | a >> 27); /*+ (b ^ c ^ d) +
				  (((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) %  16]) << 1) |
				  ((w[(round - 4) % 16] ^ w[(round - 9) % 16] ^ w[(round - 15) % 16] ^ w[(round - 17) %  16]) >> 31)) +
				  32'hca62c1d6 + e;*/
				  
			b <= a;
			c <= (b << 30 | b >> 2);
			d <= c;
			e <= d;
		end
		
		//compute new h0 - h4
		else begin
			/*new_h0 <= h0 + a;
			new_h1 <= h1 + b;
			new_h2 <= h2 + c;
			new_h3 <= h3 + d;
			new_h4 <= h4 + e;*/
			
		/*	h0 <= h0 + a;
			h1 <= h1 + b;
			h2 <= h2 + c;
			h3 <= h3 + d;
			h4 <= h4 + e;*/
			
			hash <= {(h0 + a), (h1 + b), (h2 + c), (h3 + d), (h4 + e)};
		end
	end
	
	else begin
		//do nothing
	end
end
endmodule 