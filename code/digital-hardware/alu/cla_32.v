`timescale 1ns/1ps

module cla_32(A,B,Cin,Sum,Cout);

input[31:0] A, B;
input Cin;

output [31:0] Sum;
output Cout;

wire[3:0] block_P, block_G;
wire c8,c16,c24;

wire c8_term1;

wire c16_term1, c16_term2;

wire c24_term1, c24_term2, c24_term3;

wire c32_term1, c32_term2, c32_term3, c32_term4;

cla_8 block0(.A(A[7:0]), .B(B[7:0]), .Cin(Cin), 
.Sum(Sum[7:0]), .P(block_P[0]), .G(block_G[0]));

cla_8 block1(.A(A[15:8]), .B(B[15:8]), .Cin(c8), 
.Sum(Sum[15:8]), .P(block_P[1]), .G(block_G[1]));

cla_8 block2(.A(A[23:16]), .B(B[23:16]), .Cin(c16), 
.Sum(Sum[23:16]), .P(block_P[2]), .G(block_G[2]));

cla_8 block3(.A(A[31:24]), .B(B[31:24]), .Cin(c24), 
.Sum(Sum[31:24]), .P(block_P[3]), .G(block_G[3]));

//this again....
and c8_and1(c8_term1, block_P[0], Cin);
or c8_or(c8, block_G[0], c8_term1);

and c16_and1(c16_term1, block_P[1], block_G[0]);
and c16_and2(c16_term2, block_P[1], block_P[0], Cin);
or c16_or(c16, block_G[1], c16_term1, c16_term2);

and c24_and1(c24_term1, block_P[2], block_G[1]);
and c24_and2(c24_term2, block_P[2], block_P[1], block_G[0]);
and c24_and3(c24_term3, block_P[2], block_P[1], block_P[0], Cin);
or c24_or(c24, block_G[2], c24_term1, c24_term2, c24_term3);

and c32_and1(c32_term1, block_P[3], block_G[2]);
and c32_and2(c32_term2, block_P[3], block_P[2], block_G[1]);
and c32_and3(c32_term3, block_P[3], block_P[2], block_P[1], block_G[0]);
and c32_and4(c32_term4, block_P[3], block_P[2], block_P[1], block_P[0], Cin);
or c32_or(Cout, block_G[3], c32_term1, c32_term2, c32_term3, c32_term4);

endmodule