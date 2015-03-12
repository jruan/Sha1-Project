module SHA1_hash_interface (       
			clk, 		
			nreset, 	
			start_hash,  
			message_addr,	
			message_size, 
			pad_len,
			hash, 	
			done, 		
			port_A_clk,
			port_A_data_in,
			port_A_data_out,
			port_A_addr,
			port_A_we
);

input	clk;
input	nreset; 
// Initializes the SHA1_hash module

input	start_hash; 
// Tells SHA1_hash to start hashing the given frame

input 	[31:0] message_addr; 
// Starting address of the messagetext frame
// i.e., specifies from where SHA1_hash must read the messagetext frame

input	[31:0] message_size; 
// Length of the message in bytes

//<-----------------------------for testing purposes, remove later -------------------------->
input [31:0] pad_len;

output	[159:0] hash; 
// hash results


input   [31:0] port_A_data_out; 
// read data from the dpsram (messagetext)

output  [31:0] port_A_data_in;
// write data to the dpsram (ciphertext)

output  [15:0] port_A_addr;
// address of dpsram being read/written 

output  port_A_clk;
// clock to dpsram (drive this with the input clk) 

output  port_A_we;
// read/write selector for dpsram

output	done; // done is a signal to indicate that hash  is complete

wire compute_en;

wire [31:0] sec_part;

wire [31:0] padding_length;
wire finish;

wire [1:0] state;
wire [7:0] round;
wire p2_enable;

wire [31:0] output_data;
wire [7:0] output_round;

wire [31:0] bytes_read;

wire port;
wire zero;
wire upper_32;
wire lower_32;
wire concat_one;

wire [15:0] message_address;
wire read_en;

assign done = finish;


//state controller controls what state we are in
SHA1_state_controller state_controller(
					 .nreset(nreset), 
					 .start_hash(start_hash),
					 .state(state)
					 );

//at the initial state stage, we will calculate the padding length that will be use later

SHA1_initial_state initial_state(
				 .clk(clk),
				 .input_state(state),
				 .message_size(message_size),
				 .padding_length(padding_length)
				 );
				 
SHA1_construct_packet construct(
				.clk(clk),
				.state(state),
				.bytes_read(bytes_read),
				.message_size(message_size),
				.port_A_clk(port_A_clk),
				.padding_length(padding_length),
				.message_addr(message_address),
				.port_A_addr(port_A_addr),
				.port(port),
				.zero(zero),
				.upper_32(upper_32),
				.lower_32(lower_32),
				.concat_one(concat_one),
				.read_en(read_en)
				);
				 
//read from mem will be our round incrementer and also where we read from mem and padd up
SHA1_read_from_mem read_from_mem(
				 .state(state),
				 .clk(clk),
				 .port(port),
				 .zero(zero),
				 .upper_32(upper_32),
				 .lower_32(lower_32),
				 .concat_one(concat_one),
				 .message_size(message_size),
				 .read_en(read_en),
				 .padding_length(padding_length),
				 .port_A_data_out(port_A_data_out),
				 .output_data(output_data),
				 .message_addr(message_address),
				 .bytes_read(bytes_read),
				 .round(round),
				 .compute_enable(compute_en),
				 .finish(finish)
				 );
				 
SHA1_alg alg(
				.state(state),
				.clk(clk),
				.input_data(output_data),
				.round(round),
				.compute_enable(compute_en),
				.second_half(sec_part),
				.output_round(output_round),
				.part2_enable(p2_enable)
);

SHA1_alg_part2 p2(
					.clk(clk),
					.second_half(sec_part),
					.in_round(output_round),
					.enable(p2_enable),
					.out(hash)
);

endmodule 