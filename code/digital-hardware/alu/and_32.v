`timescale 1ns/1ps

module and_32(A,B,result);
input [31:0] A,B;
output [31:0] result;

genvar i;

generate
    for (i=0 ; i<32; i=i+1 ) begin : and_bits
        and and_gate(result[i], A[i], B[i]);
    end
endgenerate
endmodule