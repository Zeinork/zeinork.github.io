`timescale 1ns/1ps
module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, 
data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

wire [31:0] arithmetic_result, 
and_result, or_result, 
sll_result, sra_result;

wire sub;

wire [31:0] logic_result, shift_result, arithmetic_or_logic;

//add,sub control
//ADD opcode ends in 0, SUB opcode ends in 1
assign sub = ctrl_ALUopcode[0];

//arithmetic unit
add_sub_32 arithmetic_unit(.A(data_operandA), .B(data_operandB),
.sub(sub), .result(arithmetic_result));

//flags
alu_flags flags_unit(.A(data_operandA), .B(data_operandB),
.sub(sub), .result(arithmetic_result), .overflow(overflow),
.isNotEqual(isNotEqual), .isLessThan(isLessThan));

//bitwise logic
and_32 and_unit(.A(data_operandA), .B(data_operandB),
 .result(and_result));

or_32 or_unit(.A(data_operandA), .B(data_operandB),
 .result(or_result));
//shifters
sll_32 sll_unit(.A(data_operandA), 
.shiftamt(ctrl_shiftamt),
 .result(sll_result));

 sra_32 sra_unit(.A(data_operandA), 
 .shiftamt(ctrl_shiftamt),
 .result(sra_result));

//result selection muxs
assign logic_result = ctrl_ALUopcode[0]
    ? or_result
    : and_result;

assign shift_result = ctrl_ALUopcode[0]
    ? sra_result
    : sll_result;

assign arithmetic_or_logic = ctrl_ALUopcode[1]
    ? logic_result
    : arithmetic_result;

assign data_result = ctrl_ALUopcode[2]
    ? shift_result
    : arithmetic_or_logic;
endmodule