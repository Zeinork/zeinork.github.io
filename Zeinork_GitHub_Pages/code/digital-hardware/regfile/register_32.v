module register_32(
    input clock,
    input reset,
    input enable,
    input [31:0] data_in,
    output [31:0] data_out
);

    genvar bit_index;

    generate
        for (bit_index = 0; bit_index < 32;
             bit_index = bit_index + 1) begin : bits
            //   flip-flop data input  -> data_in[bit_index]
            //   flip-flop output      -> data_out[bit_index]
            //   flip-flop clock       -> clock
            //   flip-flop enable      -> enable
            //   flip-flop clear/reset -> reset

            dffe_ref bit_storage(
            .q(data_out[bit_index]), 
            .d(data_in[bit_index]),
            .clk(clock),
            .en(enable),
            .clr(reset)
            );


        end
    endgenerate

endmodule