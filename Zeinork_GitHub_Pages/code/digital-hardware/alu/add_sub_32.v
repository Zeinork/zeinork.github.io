`timescale 1ns/1ps

module add_sub_32(A,B,sub,result);

input [31:0] A,B;
input sub;

output [31:0] result;

wire[31:0] B_modified;
wire carry_out;

//invert each bit of B (if its a subtract operation)
genvar i;

generate
    for (i = 0; i < 32; i = i + 1) begin : invert_bits
        xor invert_gate(B_modified[i], B[i], sub);
    end
endgenerate

//shared adder for addition and subtraction
cla_32 adder(.A(A), .B(B_modified), .Cin(sub), .Sum(result), .Cout(carry_out));

endmodule