module tristate_32(
    input [31:0] data_in,
    input enable,
    output [31:0] data_out
);

    // The high-impedance constant is: 32'bz
    assign data_out = enable? data_in : 32'bz;
endmodule