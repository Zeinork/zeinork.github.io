`timescale 1ns/1ps

module sra_32(A, shiftamt, result);

input [31:0] A;
input [4:0] shiftamt;

output [31:0] result;

wire [31:0] stage1, stage2, stage4, stage8;

wire sign_bit;

assign sign_bit = A[31];

//optionally shift right by 1.
assign stage1 = shiftamt[0]
    ? {sign_bit, A[31:1]}
    : A;


//optionally shift right by 2.
assign stage2 = shiftamt[1]
    ? {{2{sign_bit}}, stage1[31:2]}
    : stage1;

assign stage4 = shiftamt[2]
    ? {{4{sign_bit}}, stage2[31:4]}
    : stage2;

assign stage8 = shiftamt[3]
    ? {{8{sign_bit}}, stage4[31:8]}
    : stage4;

assign result = shiftamt[4]
    ? {{16{sign_bit}}, stage8[31:16]}
    : stage8;

endmodule