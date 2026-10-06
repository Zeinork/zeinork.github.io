`timescale 1ns/1ps

module alu_flags(A,B,sub,result,overflow,isNotEqual,isLessThan);

input [31:0] A, B;
input sub;
input [31:0] result;

output overflow;
output isNotEqual;
output isLessThan;

wire signs_different;
wire signs_adjusted;
wire overflow_w;
wire result_sign_different;

//signed overflow for addition and subtraction
xor signs_xor(signs_different, A[31], B[31]);
xor mode_xor(signs_adjusted, signs_different, sub);
not sign_not(overflow_w, signs_adjusted);
xor result_xor(result_sign_different, A[31], result[31]);
and overflow_and(overflow,overflow_w, result_sign_different);

//Nonzero subtraction result (A != B)
or not_equal_or(isNotEqual,
        result[0],  result[1],  result[2],  result[3],result[4],  result[5],  
        result[6],  result[7], result[8],  result[9],  result[10], result[11],
        result[12], result[13], result[14], result[15], result[16], result[17], 
        result[18], result[19], result[20], result[21], result[22], result[23],
        result[24], result[25], result[26], result[27],result[28], result[29], 
        result[30], result[31]);

//signed less-than, subtraction signs for overflow
xor less_than_xor(isLessThan, result[31], overflow);
endmodule