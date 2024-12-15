import ALUOperations::*;

module ArithmeticOps (
    input  logic [31:0] opA,
    input  logic [31:0] opB,
    input  logic        cIn,
    input  alu_op_t     aluOp,
    output logic [31:0] out,
    output logic [5:0]  flags
);
    logic signed [31:0] signedA = opA;
    logic signed [31:0] signedB = opB;
    logic [31:0] unsignedA = opA;
    logic [31:0] unsignedB = opB;
    logic carryOut;

    Multiplier Multiplier (
        .a(opA),
        .b(opB),
        .enable(enableMultiplier),
        .control(selectMultiplier),
        .signControl(signMultiplier),
        .result(outMultiplier)
    );

    Divider Divider (
        .a(opA),
        .b(opB),
        .enable(enableDivider),
        .control(selectDivider),
        .signControl(signDivider),
        .result(outDivider)
    );

    MinMax MinMax (
        .a(opA),
        .b(opB),
        .enable(enableMinMax),
        .control(selectMinMax),
        .signControl(signMinMax),
        .result(outMinMax)
    );

    always_comb begin
        case (aluOp)
            ALU_ADD: begin
                {carryOut, out} = signedA + signedB + cIn;
            end
            ALU_SUB: begin
                {carryOut, out} = signedA - signedB;
            end
            ALU_SLT: begin
                out = (signedA < signedB) ? 32'b1 : 32'b0;
                carryOut = 1'b0;
            end
            ALU_SLTU: begin
                out = (unsignedA < unsignedB) ? 32'b1 : 32'b0;
                carryOut = 1'b0;
            end
            ALU_SRA: begin
                out = signedA >>> signedB[4:0];
                carryOut = 1'b0;
            end
            ALU_MUL: begin
            end
            ALU_MULH: begin
            end
            ALU_MULHSU: begin
            end
            ALU_DIV: begin
            end
            ALU_DIVU: begin
            end
            ALU_REM: begin
            end
            ALU_REMU: begin
            end
            ALU_INCA: begin
            end
            ALU_DECA: begin
            end
            ALU_ABS: begin
            end
            ALU_NEG: begin
            end
            ALU_MIN: begin
            end
            ALU_MINU: begin
            end
            ALU_MAX: begin
            end
            ALU_MAXU: begin
            end
            default: begin
                out         = 32'b0;
                carryOut    = 1'b0;
            end
        endcase
    end

endmodule
