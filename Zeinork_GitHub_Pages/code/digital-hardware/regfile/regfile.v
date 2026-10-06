module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	// add your code here
	wire[31:0] write_select;
	wire[31:0] read_a;
	wire[31:0] read_b;

	//decode which register to write
	decoder_32 write_decoder(
		.select(ctrl_writeReg),
		.enable(ctrl_writeEnable),
		.out(write_select)
	);

	//decoder which registers to write for port A and B
	decoder_32 read_decoder_a(
		.select(ctrl_readRegA),
		.enable(1'b1),
		.out(read_a)
	);
		decoder_32 read_decoder_b(
		.select(ctrl_readRegB),
		.enable(1'b1),
		.out(read_b)
	);

	//register 0
	tristate_32 zero_read_a(
		.data_in(32'b0),
		.enable(read_a[0]),
		.data_out(data_readRegA)
	);
	tristate_32 zero_read_b(
		.data_in(32'b0),
		.enable(read_b[0]),
		.data_out(data_readRegB)
	);

genvar r;
generate
	for(r = 1; r<32; r =r+1) begin : registers
	wire[31:0] stored_data;
	register_32 stor(
		.clock(clock),
		.reset(ctrl_reset),
		.enable(write_select[r]),
		.data_in(data_writeReg),
		.data_out(stored_data)
	);
	tristate_32 read_buffer_a(
		.data_in(stored_data),
		.enable(read_a[r]),
		.data_out(data_readRegA)
	);
	tristate_32 read_buffer_b(
		.data_in(stored_data),
		.enable(read_b[r]),
		.data_out(data_readRegB)
	);
	end
endgenerate

endmodule
