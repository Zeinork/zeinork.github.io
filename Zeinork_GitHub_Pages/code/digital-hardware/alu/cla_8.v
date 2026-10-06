`timescale 1ns/1ps
module cla_8(A,B, Cin, Sum, P, G);
//8 bit carry look ahead adder

input [7:0] A, B;
input Cin;

output [7:0] Sum;
output P, G;

wire [7:0] p, g;
wire [7:0] c; //c[i], carry entering bit i
wire c1_term;

wire c2_term1, c2_term2;

wire c3_term1, c3_term2, c3_term3;

wire c4_term1, c4_term2, c4_term3, c4_term4;

wire c5_term1, c5_term2, c5_term3, c5_term4, c5_term5;

wire c6_term1, c6_term2, c6_term3, c6_term4, c6_term5, c6_term6;

wire c7_term1, c7_term2, c7_term3, c7_term4, c7_term5, c7_term6, c7_term7;

wire G_term1, G_term2, G_term3, G_term4, G_term5, G_term6, G_term7;

assign c[0] = Cin;


g_propogate gp0(.a(A[0]), .b(B[0]), .g(g[0]), .p(p[0]));
g_propogate gp1(.a(A[1]), .b(B[1]), .g(g[1]), .p(p[1]));
g_propogate gp2(.a(A[2]), .b(B[2]), .g(g[2]), .p(p[2]));
g_propogate gp3(.a(A[3]), .b(B[3]), .g(g[3]), .p(p[3]));
g_propogate gp4(.a(A[4]), .b(B[4]), .g(g[4]), .p(p[4]));
g_propogate gp5(.a(A[5]), .b(B[5]), .g(g[5]), .p(p[5]));
g_propogate gp6(.a(A[6]), .b(B[6]), .g(g[6]), .p(p[6]));
g_propogate gp7(.a(A[7]), .b(B[7]), .g(g[7]), .p(p[7]));

//carry equations
and c1_and(c1_term, p[0], Cin);
or c1_or(c[1],g[0],c1_term);

and c2_and1(c2_term1, p[1], g[0]);
and c2_and2(c2_term2, p[1], p[0], Cin);
or c2_or(c[2],g[1], c2_term1, c2_term2);

and c3_and1(c3_term1, p[2], g[1]);
and c3_and2(c3_term2, p[2], p[1], g[0]);
and c3_and3(c3_term3, p[2], p[1], p[0], Cin);
or  c3_or(c[3],g[2], c3_term1, c3_term2, 
c3_term3);

and c4_and1(c4_term1, p[3], g[2]);
and c4_and2(c4_term2, p[3], p[2], g[1]);
and c4_and3(c4_term3, p[3], p[2], p[1], g[0]);
and c4_and4(c4_term4, p[3], p[2], p[1], p[0], Cin);
or  c4_or(c[4],g[3], c4_term1, c4_term2, 
c4_term3, c4_term4);

and c5_and1(c5_term1, p[4], g[3]);
and c5_and2(c5_term2, p[4], p[3], g[2]);
and c5_and3(c5_term3, p[4], p[3], p[2], g[1]);
and c5_and4(c5_term4, p[4], p[3], p[2], p[1], g[0]);
and c5_and5(c5_term5, p[4], p[3], p[2], p[1], p[0], Cin);
or  c5_or(c[5],g[4], c5_term1, c5_term2, 
c5_term3, c5_term4, c5_term5);

and c6_and1(c6_term1, p[5], g[4]);
and c6_and2(c6_term2, p[5], p[4], g[3]);
and c6_and3(c6_term3, p[5], p[4], p[3], g[2]);
and c6_and4(c6_term4, p[5], p[4], p[3], p[2], g[1]);
and c6_and5(c6_term5, p[5], p[4], p[3], p[2], p[1], g[0]);
and c6_and6(c6_term6, p[5], p[4], p[3], p[2], p[1], p[0], Cin);
or  c6_or(c[6],g[5], c6_term1, c6_term2, 
c6_term3, c6_term4, c6_term5, c6_term6);

and c7_and1(c7_term1, p[6], g[5]);
and c7_and2(c7_term2, p[6], p[5], g[4]);
and c7_and3(c7_term3, p[6], p[5], p[4], g[3]);
and c7_and4(c7_term4, p[6], p[5], p[4], p[3], g[2]);
and c7_and5(c7_term5, p[6], p[5], p[4], p[3], p[2], g[1]);
and c7_and6(c7_term6, p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
and c7_and7(c7_term7, p[6], p[5], p[4], p[3], p[2], p[1], p[0], Cin);
or  c7_or(c[7],g[6], c7_term1, c7_term2, 
c7_term3, c7_term4, c7_term5, c7_term6, c7_term7);

//sum bits
xor sum0(Sum[0], p[0], c[0]);
xor sum1(Sum[1], p[1], c[1]);
xor sum2(Sum[2], p[2], c[2]);
xor sum3(Sum[3], p[3], c[3]);
xor sum4(Sum[4], p[4], c[4]);
xor sum5(Sum[5], p[5], c[5]);
xor sum6(Sum[6], p[6], c[6]);
xor sum7(Sum[7], p[7], c[7]);
//incoming carry through
and group_p(P, p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0]);
//outgoing carry, INDEPENDENT OF Cin
and G_and1(G_term1, p[7], g[6]);

and G_and2(G_term2, p[7], p[6], g[5]);

and G_and3(G_term3, p[7], p[6], p[5], g[4]);

and G_and4(G_term4, p[7], p[6], p[5], p[4], g[3]);

and G_and5(G_term5, p[7], p[6], p[5], p[4], p[3], g[2]);

and G_and6(G_term6, p[7], p[6], p[5], p[4], p[3], p[2], g[1]);

and G_and7(G_term7, p[7], p[6], p[5], p[4], p[3], p[2], p[1], g[0]);

or group_g(G, g[7], G_term1, G_term2, G_term3, 
G_term4, G_term5, G_term6, G_term7);
endmodule