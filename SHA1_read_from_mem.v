module SHA1_read_from_mem(
				 state,
				 clk,
				 port,
				 zero,
				 upper_32,
				 lower_32,
				 concat_one,
				 message_size,
				 read_en,
				 padding_length,
				 port_A_data_out,
				 output_data,
				 message_addr,
				 bytes_read,
				 round,
				 compute_enable,
				 finish
);

input clk;
input [1:0] state;
input [31:0] padding_length;
input [31:0] port_A_data_out;
input port;
input zero;
input upper_32;
input lower_32;
input concat_one;
input [31:0] message_size;
input read_en;

output [31:0] output_data;

output [7:0] round;
output [31:0] bytes_read;
output [15:0] message_addr;
output compute_enable;

output finish;

reg [31:0] data;
reg [7:0] r = 0;
reg [15:0] addr = 4;
reg comp_en;
reg done;
reg [31:0] read = 4;

assign output_data = data;
assign round = r;
assign finish = (read - 4 == padding_length && r == 83) ? 1 : 0;
assign bytes_read = read;
assign compute_enable = comp_en;
assign message_addr = addr;

always @(posedge clk)begin
	if(state == 2'b10 && read_en)begin
		comp_en <= 1;
		if(r < 16)begin
			case({port, zero, upper_32, lower_32, concat_one})
			5'b10000:
			begin
				data <= {port_A_data_out[7:0], port_A_data_out[15:8], port_A_data_out[23:16], port_A_data_out[31:24]};
				addr <= addr + 4;
			end
			
			5'b01000:
			begin
				data <= 32'h00000000;
			end
			
			5'b00100:
			begin
				data <= message_size >> 29;
			end
			
			5'b00010:
			begin
				data <= message_size * 8;
			end
			
			5'b00001:
			begin
				addr <= addr + 4;
				case((message_size) % 4)
				0:
				begin
					data <= 32'h80000000;
				end
				
				1:begin		
					data <= {port_A_data_out[7:0],24'h800000};
				 end
							
				2:begin
					data <= {port_A_data_out[7:0], port_A_data_out[15:8], 16'h8000};
				end
							  
				3:begin
					data <= {port_A_data_out[7:0], port_A_data_out[15:8], port_A_data_out[23:16], 8'h80};
				 end
				endcase
			end
			endcase
			read <= read + 4;
			r <= r + 1;
		end

		else if(r == 83)begin
			r <= 0;
			comp_en <= 0;
			addr <= addr + 4;
		end
		
		else begin
			r <= r + 1;
			if(addr % 64 == 4)begin
				addr <= addr - 4;
			end
			
			else begin
			
			end
		end
	end
	
	else begin
	
	end
end

endmodule
