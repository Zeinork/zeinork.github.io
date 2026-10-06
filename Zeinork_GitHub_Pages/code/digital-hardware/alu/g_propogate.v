`timescale 1ns/1ps
module g_propogate(a,b,g,p);

input a,b;
output g,p;

and g1(g,a,b);
xor x1(p,a,b);

endmodule