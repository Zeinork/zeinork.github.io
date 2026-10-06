module decoder_32(
    input [4:0] select,
    input enable,
    output [31:0] out
);
    // Start with enable represented as a 32-bit value,
    // then shift it left by select.

    assign out = {31'b0, enable} << select;
endmodule