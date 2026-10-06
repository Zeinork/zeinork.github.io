module md_adder #(parameter WIDTH = 64)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] sum
);

    wire [WIDTH:0] carry;
    assign carry[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: bits
            assign sum[i] = a[i] ^ b[i] ^ carry[i];

            assign carry[i+1] =
                (a[i] & b[i]) |
                ((a[i] ^ b[i]) & carry[i]);
        end
    endgenerate

endmodule