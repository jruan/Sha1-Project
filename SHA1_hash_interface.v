module SHA1_hash (       
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
/*wire [31:0] old_h0 = 32'h67452301;
wire [31:0] old_h1 = 32'hEFCDAB89;
wire [31:0] old_h2 = 32'h98BADCFE;
wire [31:0] old_h3 = 32'h10325476;
wire [31:0] old_h4 = 32'hC3D2E1F0; 
*/
wire [31:0] new_h0;
wire [31:0] new_h1;
wire [31:0] new_h2;
wire [31:0] new_h3;
wire [31:0] new_h4;

wire [31:0] padding_length;
wire finish;

wire [1:0] state;
wire [7:0] round;

wire [31:0] output_data;

//assign done = finish;


//state controller controls what state we are in
SHA1_state_controller state_controller(
					 .nreset(nreset), 
					 .start_hash(start_hash),
					 .done(finish),
					 .state(state)
					 );

//at the initial state stage, we will calculate the padding length that will be use later
SHA1_initial_state initial_state(
				 .clk(clk),
				 .input_state(state),
				 .input_pad(pad_len),				//<--------- again for testing purpose ---------------->
				 .message_size(message_size),
				 .padding_length(padding_length)
				 );
				 
//read from mem will be our round incrementer and also where we read from mem and padd up
SHA1_read_from_mem read_from_mem(
				 .state(state),
				 .clk(clk),
				 .port_A_clk(port_A_clk),
				 .message_size(message_size),
				 .port_A_data_out(port_A_data_out),
				 /*.in_h0(new_h0),
				 .in_h1(new_h1),
				 .in_h2(new_h2),
				 .in_h3(new_h3),
				 .in_h4(new_h4),*/
				 .output_data(output_data),
				 .padding_length(padding_length),
				 .port_A_addr(port_A_addr),
				 .round(round),
				 .compute_enable(compute_en),
				 .finish(finish)
				 //.hash(hash)
				 );

//computes the alg
SHA1_alg alg(
		 .state(state),
		 .clk(clk),
		 .input_data(output_data),
		 .round(round),
		 .compute_enable(compute_en),
		/* .out_h0(new_h0),
		 .out_h1(new_h1),
		 .out_h2(new_h2),
		 .out_h3(new_h3),
		 .out_h4(new_h4),*/
		 .out(hash)
		);
		 
		 
SHA1_finish fin(
				.clk(clk),
				.state(state), 
				/*.in_h0(new_h0),
				.in_h1(new_h1),
				.in_h2(new_h2),
				.in_h3(new_h3),
				.in_h4(new_h4),*/
				.complete(done)
	//			.result(hash)
);


endmodule 