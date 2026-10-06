module md_register #(parameter WIDTH = 32)(
    input [WIDTH-1:0] d,
    input clock,
    input enable,
    output [WIDTH-1:0] q
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: bits
            dffe_ref ff(
                .q(q[i]),
                .d(d[i]),
                .clk(clock),
                .en(enable),
                .clr(1'b0)
            );
        end
    endgenerate

endmodule