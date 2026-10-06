module multdiv(
    data_operandA, data_operandB,
    ctrl_MULT, ctrl_DIV, clock,
    data_result, data_exception, data_resultRDY
);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    wire start;
    wire busy, busy_next;
    wire done;
    wire update;

    wire [63:0] multiplicand, multiplicand_next;
    wire [31:0] multiplier, multiplier_next;
    wire [63:0] product, product_next;
    wire [63:0] addend, sum;

    wire [4:0] count, count_next, count_plus_one;

    wire exception_next;

    // either control signal cancels the previous operation.
    // division itself is not implemented yet.
    assign start = ctrl_MULT | ctrl_DIV;

    // count values 0 through 31 give 32 calculation cycles.
    assign done = busy & (&count) & ~start;

    assign busy_next =
        start ? ctrl_MULT :
        done  ? 1'b0 :
                busy;

    assign update = start | busy;

    md_register #(1) busy_reg(
        .d(busy_next),
        .clock(clock),
        .enable(1'b1),
        .q(busy)
    );

    // capture A on start, then shift it left each cycle.
    assign multiplicand_next =
        start ? {32'b0, data_operandA} :
                {multiplicand[62:0], 1'b0};

    md_register #(64) multiplicand_reg(
        .d(multiplicand_next),
        .clock(clock),
        .enable(update),
        .q(multiplicand)
    );

    // capture B on start, then shift it right each cycle.
    assign multiplier_next =
        start ? data_operandB :
                {1'b0, multiplier[31:1]};

    md_register #(32) multiplier_reg(
        .d(multiplier_next),
        .clock(clock),
        .enable(update),
        .q(multiplier)
    );

    // add the shifted A only when the current B bit is 1.
    assign addend = multiplier[0] ? multiplicand : 64'b0;

    md_adder #(64) product_adder(
        .a(product),
        .b(addend),
        .sum(sum)
    );

    assign product_next = start ? 64'b0 : sum;

    md_register #(64) product_reg(
        .d(product_next),
        .clock(clock),
        .enable(update),
        .q(product)
    );

    // structural cycle counter.
    md_adder #(5) counter_adder(
        .a(count),
        .b(5'b00001),
        .sum(count_plus_one)
    );

    assign count_next = start ? 5'b0 : count_plus_one;

    md_register #(5) count_reg(
        .d(count_next),
        .clock(clock),
        .enable(update),
        .q(count)
    );

    // register ready so it stays high for one full cycle.
    md_register #(1) ready_reg(
        .d(done),
        .clock(clock),
        .enable(1'b1),
        .q(data_resultRDY)
    );

    // for nonnegative operands, bits 63:31 must all be zero
    // for the product to fit in a signed 32-bit result.
    assign exception_next =
        start ? 1'b0 :
        done  ? (|sum[63:31]) :
                data_exception;

    md_register #(1) exception_reg(
        .d(exception_next),
        .clock(clock),
        .enable(1'b1),
        .q(data_exception)
    );

    assign data_result = product[31:0];

endmodule