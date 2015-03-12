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
				 //port_A_clk,
				 //message_size,
				 port_A_data_out,
				 output_data,
				 message_addr,
				 bytes_read,
				 //port_A_addr,
				 round,
				 compute_enable,
				 finish
);

input clk;
input [1:0] state;
//input [31:0] message_size;
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

//output port_A_clk;
//output [15:0] port_A_addr;
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
//assign port_A_clk = clk;
/*
reg [15:0] message_addr = 0;
reg [31:0] bytes_read = 0;
reg [7:0] output_round = 0;
reg compute_en;

reg get_from_port_A = 1;
reg [31:0] data;
reg data_and_port = 0;
reg done = 0;
*/

/*
//assign hash = result;
assign port_A_addr = message_addr;
assign round = output_round;
assign compute_enable = compute_en;
assign output_data = (get_from_port_A) ? changeEndian(port_A_data_out) : (data_and_port ? (changeEndian(port_A_data_out) & data) : data);
assign finish = done;

function [31:0] changeEndian; // transform data from the memory to big-endian form (default: little)
    input [31:0] value;
    changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
endfunction
*/
/*
always @(posedge clk)begin
	//if we are in the computation state, begin computing
	if(state == 2'b10)begin
		compute_en <= 1;
		//read from memory if round is less than 16
		if(round < 16)begin
			//if the bytes read is perfectly equal to the message size, the next one should be padded with a 1 and 0's
			if(bytes_read  == message_size)begin
				get_from_port_A <= 0;
				data <= 32'h80000000;
			end
			
			//if bytes read not equal to message size, find where the bytes cut off in case statement and pad 1 over there
			else if(bytes_read < message_size)begin
					if(bytes_read + 4 > message_size)begin
						get_from_port_A <= 0;
						data_and_port <= 1;
						case((message_size) % 4)
						1:begin	
								data <= 32'hFF800000;
						  end
						
						2:begin
								data <= 32'hFFFF8000;
						  end
						  
						3:begin
								data <= 32'hFFFFFF80;
						  end
						endcase
					end
					
					//if we aint done reading data, keep reading and dont pad 1
					else begin
						message_addr <= message_addr + 16'h0004;
					end
			end
			
			//this means we have padded a oene, read everything message size has to offer, now we pad wit 0 until reach 8 before padding length
			//then at 8 before padding length, add size of message
			else begin
					//pad the length of the data
				
					if(padding_length - bytes_read  == 8)begin
						data <= message_size >> 29;
					end
					
					else if(padding_length - bytes_read  == 4)begin
						data <= message_size * 8;
					end
					
					else begin
						data <= 32'h00000000;
					end
					get_from_port_A <= 0;
					data_and_port <= 0;
			end
			
			bytes_read <= bytes_read + 4;
			output_round <= output_round + 8'b0000001;
		end
		
		//if not, check when round is at 79, if it is, computation should be off.
		//if not at 79, keep incremementing
		else begin
			if(output_round == 83 && bytes_read != padding_length)begin
				compute_en <= 0;
				output_round <= 0;
			end
			
			else if(output_round == 83 && bytes_read == padding_length)begin
				compute_en <= 0;
				output_round <= 0;
				done <= 1;
			end
			
			else begin
				output_round <= output_round + 8'b00000001;
			end
		end
	end
	
	//again if not the state, do nothing.
	else begin
		compute_en <= 0;
		message_addr <= 0;
		bytes_read <= 0;
		output_round <= 0;
		data <= 0;
	/*	get_from_port_A <= 1;
		data_and_port <= 0;
	end
end


endmodule */