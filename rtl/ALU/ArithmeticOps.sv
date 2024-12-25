import ALUOperations::*;

module ArithmeticOps (
    input  logic [31:0] opA,
    input  logic [31:0] opB,
    input  logic        cIn,
    input  alu_op_t     aluOp,
    output logic [31:0] out,
    output logic [6:0]  flags
);
    logic signed [31:0] signedA = opA;
    logic signed [31:0] signedB = opB;
    logic [31:0] unsignedA = opA;
    logic [31:0] unsignedB = opB;

    // flags
    logic carryOut;
    logic oddParityFlag;
    logic evenParityFlag;
    logic overflowFlag;
    logic signFlag;
    logic zeroFlag;
    logic divideByZeroFlag;

    logic enableMultiplier;
    logic selectMultiplier;
    logic [1:0] signMultiplier;
    logic [31:0] outMultiplier;

    logic enableDivider;
    logic selectDivider;
    logic signDivider;
    logic [31:0] outDivider;

    logic enableMinMax;
    logic selectMinMax;
    logic signMinMax;
    logic [31:0] outMinMax;

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
                {carryOut, out}     = signedA + signedB + cIn;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_SUB: begin
                {carryOut, out}     = signedA - signedB;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
                end
            ALU_SLT: begin
                out                 = (signedA < signedB) ? 32'b1 : 32'b0;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
                end
            ALU_SLTU: begin
                out                 = (unsignedA < unsignedB) ? 32'b1 : 32'b0;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_SRA: begin
                out                 = signedA >>> signedB[4:0];
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_MUL: begin
                out                 = outMultiplier;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b1;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h3;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_MULH: begin
                out                 = outMultiplier;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b1;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b1;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h3;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_MULHU: begin
                out                 = outMultiplier;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b1;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b1;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_MULHSU: begin
                out                 = outMultiplier;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b1;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b1;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h2;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_DIV: begin
                out                 = (opB == 0) ? 32'b0 : outDivider;
                carryOut            = 1'b0;
                divideByZeroFlag    = (opB == 0) ? 1'b1 : 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = (opB == 0) ? 1'b0 : 1'b1;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b1;
                signMinMax          = 1'b0;
            end
            ALU_DIVU: begin
                out                 = (opB == 0) ? 32'b0 : outDivider;
                carryOut            = 1'b0;
                divideByZeroFlag    = (opB == 0) ? 1'b1 : 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = (opB == 0) ? 1'b0 : 1'b1;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b1;
                signMinMax          = 1'b0;
            end
            ALU_REM: begin
                out                 = (opB == 0) ? 32'b0 : outDivider;
                carryOut            = 1'b0;
                divideByZeroFlag    = (opB == 0) ? 1'b1 : 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = (opB == 0) ? 1'b0 : 1'b1;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b1;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_REMU: begin
                out                 = (opB == 0) ? 32'b0 : outDivider;
                carryOut            = 1'b0;
                divideByZeroFlag    = (opB == 0) ? 1'b1 : 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = (opB == 0) ? 1'b0 : 1'b1;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b1;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b1;
                signMinMax          = 1'b0;
            end
            ALU_INCA: begin
                {out, carryOut}     = opA + 1;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_DECA: begin
                {out, carryOut}     = opA - 1;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_ABS: begin
                out                 = (signedA < 0) ? -signedA : signedA;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_NEG: begin
                out                 = -signedA;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_MIN: begin
                out                 = outMinMax;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b1;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b1;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_MINU: begin
                out                 = outMinMax;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b1;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b1;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b1;
            end
            ALU_MAX: begin
                out                 = outMinMax;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b1;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
            ALU_MAXU: begin
                out                 = outMinMax;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b1;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b1;
            end
            default: begin
                out                 = 32'b0;
                carryOut            = 1'b0;
                divideByZeroFlag    = 1'b0;
                enableMultiplier    = 1'b0;
                enableDivider       = 1'b0;
                enableMinMax        = 1'b0;
                selectMultiplier    = 1'b0;
                selectDivider       = 1'b0;
                selectMinMax        = 1'b0;
                signMultiplier      = 2'h0;
                signDivider         = 1'b0;
                signMinMax          = 1'b0;
            end
        endcase
    end

    always_comb begin
        oddParityFlag   = ^out;
        evenParityFlag  = !(^out);
        signFlag        = out[31];
        zeroFlag        = (out == 32'b0) ? 1'b1 : 1'b0;
        case (aluOp)
            ALU_ADD:    overflowFlag = ((signedA[31] & signedB[31] & !(out[31])) | (!(signedA[31]) & !(signedB[31]) & out[31]));
            ALU_SUB:    overflowFlag = ((signedA[31] & !(signedB[31]) & !(out[31])) | (!(signedA[31]) & signedB[31] & out[31]));
            ALU_INCA:   overflowFlag = signedA[31] & !(out[31]);
            ALU_DECA:   overflowFlag = signedA[31] & !(out[31]);
            ALU_NEG:    overflowFlag = (out == 32'h80000000) ? 1'b1 : 1'b0;
            default:    overflowFlag = 1'b0;
        endcase
    end

    assign flags = {divideByZeroFlag, carryOut, overflowFlag, evenParityFlag, oddParityFlag, signFlag, zeroFlag};

endmodule
