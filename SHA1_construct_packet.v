module SHA1_construct_packet(
					clk,
					state,
					bytes_read,
					message_size,
					port_A_clk,
					padding_length,
					message_addr,
					port_A_addr,
					port,
					zero,
					upper_32,
					lower_32,
					concat_one,
					read_en
);

input clk;
input [1:0] state;
input [31:0] bytes_read;
input [31:0] message_size;
input [31:0] padding_length;
input [15:0] message_addr;

output port_A_clk;
output [15:0] port_A_addr;
output port;
output zero;
output upper_32;
output lower_32;
output concat_one;
output read_en;

reg p;
reg z;
reg u;
reg l;
reg c;
reg read;
reg init = 0;

assign port_A_clk = clk;
assign port_A_addr = (init) ? message_addr : 0;
assign port = p;
assign zero = z;
assign upper_32 = u;
assign lower_32 = l;
assign concat_one = c;
assign read_en = read;

always @(posedge clk)begin
	if(state == 2'b10)begin
		read <= 1;
		init <= 1;
		if(bytes_read == message_size)begin
			c <= 1;
			p <= 0;
			z <= 0;
			u <= 0;
			l <= 0;
		end
		
		else if(bytes_read < message_size)begin
			if(bytes_read + 4 > message_size)begin
				c <= 1;
				p <= 0;
				z <= 0;
				u <= 0;
				l <= 0;
			end
			
			else begin
				c <= 0;
				p <= 1;
				z <= 0;
				u <= 0;
				l <= 0;
			end	
		end
		
		else begin
			if(padding_length - bytes_read == 8)begin
				c <= 0;
				p <= 0;
				z <= 0;
				u <= 1;
				l <= 0;
			end
			
			else if(padding_length - bytes_read == 4)begin
				c <= 0;
				p <= 0;
				z <= 0;
				u <= 0;
				l <= 1;
			end
			
			else if(padding_length - bytes_read > 0)begin
				c <= 0;
				p <= 0;
				z <= 1;
				u <= 0;
				l <= 0;
			end
			
			else begin
				c <= 0;
				p <= 0;
				z <= 0;
				u <= 0;
				l <= 0;
			end
		end
	end
	
	else begin
	
	end

end
endmodule 