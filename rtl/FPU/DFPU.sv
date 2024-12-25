module DFPU (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [63:0] opA,
    input  logic [63:0] opB,
    input  logic [63:0] opC,
    input  fpu_op_t     fpuOp,
    input  logic        enable,
    output logic [63:0] fpuOut,
    output logic [6:0]  flagsOut
);
    typedef enum logic [2:0] {
        NORMAL  = 3'h0,
        QNAN    = 3'h1,
        SNAN    = 3'h2,
        POSINF  = 3'h3,
        NEGINF  = 3'h4,
        POSZERO = 3'h5,
        NEGZERO = 3'h6
    } float_type_t;

    function float_type_t classify (input logic [63:0] op);
        logic sign;
        logic [10:0] exp;
        logic [51:0] mant;
        sign = op[63];
        exp = op[62:52];
        mant = op[51:0];

        if (exp == 11'h7FF) begin
            if (mant == 0) begin
                classify = sign ? NEGINF : POSINF;
            end else begin
                classify = mant[51] ? SNAN : QNAN;
            end
        end else if (exp == 0) begin
            if (mant == 0) begin
                classify = sign ? NEGZERO : POSZERO;
            end else begin
                classify = NORMAL;
            end
        end else begin
            classify = NORMAL;
        end
    endfunction

    assign typeA = classify(opA);
    assign typeB = classify(opB);
    assign typeC = classify(opC);

endmodule
