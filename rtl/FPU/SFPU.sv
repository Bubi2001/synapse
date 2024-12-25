module SFPU (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] opA,
    input  logic [31:0] opB,
    input  logic [31:0] opC,
    input  fpu_op_t     fpuOp,
    input  logic        enable,
    output logic [31:0] fpuOut,
    output logic [6:0]  flagsOut
);
    logic divideByZeroFlag;
    logic invalidOperationFlag;
    logic overflowFlag;
    logic underflowFlag;
    logic inexactResultFlag;
    logic signFlag;
    logic zeroFlag;

    typedef enum logic [2:0] {
        NORMAL  = 3'h0,
        QNAN    = 3'h1,
        SNAN    = 3'h2,
        POSINF  = 3'h3,
        NEGINF  = 3'h4,
        POSZERO = 3'h5,
        NEGZERO = 3'h6
    } float_type_t;

    function float_type_t classify (input logic [31:0] op);
        logic sign;
        logic [7:0] exp;
        logic [22:0] mant;
        sign = op[31];
        exp = op[30:23];
        mant = op[22:0];

        if (exp == 8'hFF) begin
            if (mant == 0) begin
                classify = sign ? NEGINF : POSINF;
            end else begin
                classify = mant[22] ? SNAN : QNAN;
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

    always_comb begin
        case (fpuOp)
            FPU_ADD_S: begin
                // Check for NaN propagation
                if ((typeA == QNAN) || (typeA == SNAN) || (typeB == QNAN) || (typeB == SNAN)) begin
                    fpuOut = {opA[31], 8'hFF, 23'h700000}; // NaN
                    divideByZeroFlag = 1'b0;
                    invalidOperationFlag = 1'b1;
                end 
                // Check for Inf - Inf scenario
                else if (((typeA == POSINF) && (typeB == NEGINF)) || ((typeA == NEGINF) && (typeB == POSINF))) begin
                    fpuOut = {1'b0, 8'hFF, 23'h400000}; // NaN
                    divideByZeroFlag = 1'b0;
                    invalidOperationFlag = 1'b1;
                end 
                // Check for Inf + Inf scenario
                else if (((typeA == POSINF) && (typeB == POSINF)) || ((typeA == NEGINF) && (typeB == NEGINF))) begin
                    fpuOut = {opA[31], 8'hFF, 23'h0}; // +/- inf
                    divideByZeroFlag = 1'b0;
                    invalidOperationFlag = 1'b1;
                end 
                // Check for Inf + Normal number scenario
                else if (((typeA == POSINF) || (typeA == NEGINF)) && (typeB == NORMAL)) begin
                    fpuOut = {opA[31], 8'hFF, 23'h0}; // +/- inf
                    divideByZeroFlag = 1'b0;
                    invalidOperationFlag = 1'b1;
                end 
                // Check for Normal number + Inf scenario
                else if ((typeA == NORMAL) && ((typeB == POSINF) || (typeB == NEGINF))) begin
                    fpuOut = {opB[31], 8'hFF, 23'h0}; // +/- inf
                    divideByZeroFlag = 1'b0;
                    invalidOperationFlag = 1'b1;
                end 
                // Perform normal addition
                else begin
                    // Call your normal addition function here
                    fpuOut = ...;
                    divideByZeroFlag = 1'b0;
                    invalidOperationFlag = 1'b0;
                end
            end
            default: begin
                fpuOut = 32'b0;
                divideByZeroFlag = 1'b0;
                invalidOperationFlag = 1'b0;
            end
        endcase
    end

endmodule
