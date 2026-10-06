`timescale 1ns/1ps

module sll_32(A, shiftamt, result);

input [31:0] A;
input [4:0] shiftamt;

output [31:0] result;

wire [31:0] stage1, stage2, stage4, stage8;

//optionally shift left by 1.
assign stage1 = shiftamt[0]
    ? {A[30:0], 1'b0}
    : A;

//optionally shift the previous result left by 2.
assign stage2 = shiftamt[1]
    ? {stage1[29:0], 2'b0}
    : stage1;

assign stage4 = shiftamt[2]
    ? {stage2[27:0], 4'b0}
    : stage2;

assign stage8 = shiftamt[3]
    ? {stage4[23:0], 8'b0}
    : stage4;

assign result = shiftamt[4]
    ? {stage8[15:0], 16'b0}
    : stage8;
endmodule