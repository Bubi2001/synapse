import ALUOperations::*;

module LogicOps (
    input  logic [31:0] opA,
    input  logic [31:0] opB,
    input  logic        cIn,
    input  alu_op_t     aluOp,
    output logic [31:0] out,
    output logic [6:0]  flags
);
    // flags
    logic carryOut;
    logic oddParityFlag;
    logic evenParityFlag;
    logic overflowFlag;
    logic signFlag  ;
    logic zeroFlag;
    logic divideByZeroFlag;

    logic [5:0] leadingCount;
    logic [5:0] trailingCount;
    logic [5:0] oneCount;
    logic [31:0] bdepOut;
    logic [31:0] grevOut;
    logic [31:0] shuffleOut;
    logic [31:0] unshuffleOut;

    CountZeros CountZeros (
        .num(opA),
        .leadingCount(leadingCount),
        .trailingCount(trailingCount)
    );

    CountOnes CountOnes (
        .num(opA),
        .oneCount(oneCount)
    );

    BitDeposit BitDeposit(
        .opA(opA),
        .opB(opB),
        .out(bdepOut)
    );

    GeneralizedReverse GeneralizedReverse(
        .data(opA),
        .pattern(opB),
        .result(grevOut)
    );

    Shuffle Shuffle(
        .data(opA),
        .pattern(opB),
        .result(shuffleOut)
    );

    Unshuffle Unshuffle(
        .data(opA),
        .pattern(opB),
        .result(unshuffleOut)
    );

    always_comb begin
        case (aluOp)
            ALU_AND:    out = opA & opB;
            ALU_OR:     out = opA | opB;
            ALU_XOR:    out = opA ^ opB;
            ALU_NAND:   out = !(opA & opB);
            ALU_NOR:    out = !(opA | opB);
            ALU_XNOR:   out = !(opA ^ opB);
            ALU_ANDN:   out = opA & (!opB);
            ALU_ORN:    out = opA | (!opB);
            ALU_XORN:   out = opA ^ (!opB);
            ALU_NOT:    out = !opA;
            ALU_SLL:    out = opA << opB[4:0];
            ALU_SRL:    out = opA >> opB[4:0];
            ALU_SLO:    out = (opA << opB[4:0]) | ((1 << opB[4:0]) - 1);
            ALU_SRO:    out = (opA >> opB[4:0]) | ((32'hFFFFFFFF << (32 - opB[4:0])));
            ALU_ROL:    out = (opA << opB[4:0]) | (opA >> (32 - opB[4:0]));
            ALU_ROR:    out = (opA << opB[4:0]) | (opA << (32 - opB[4:0]));
            ALU_SBSET:  out = opA | (1 << opB[4:0]);
            ALU_SBCLR:  out = opA & !(1 << opB[4:0]);
            ALU_SBINV:  out = opA ^ (1 << opB[4:0]);
            ALU_SBEXT:  out = (opA >> opB[4:0]) & 1;
            ALU_CLZ:    out = leadingCount;
            ALU_CTZ:    out = trailingCount;
            ALU_PCNT:   out = oneCount;
            ALU_BEXT:   out = (opA >> opB[4:0]) & 1;
            ALU_BDEP:   out = bdepOut;
            ALU_GREV:   out = grevOut;
            ALU_SHFL:   out = shuffleOut;
            ALU_UNSHFL: out = unshuffleOut;
            ALU_RLTC:   out = ((opA << opB[4:0]) | (opA >> (32 - opB[4:0]))) | (cIn << (opB[4:0]-1));
            ALU_RRTC:   out = ((opA >> opB[4:0]) | (opA << (32 - opB[4:0]))) | (cIn << (32-opB[4:0]));
            ALU_BITREV: out = {opA[0], opA[1], opA[2], opA[3], opA[4], opA[5], opA[6], opA[7], opA[8], opA[9], opA[10], opA[11], opA[12], opA[13], opA[14], opA[15], opA[16], opA[17], opA[18], opA[19], opA[20], opA[21], opA[22], opA[23], opA[24], opA[25], opA[26], opA[27], opA[28], opA[29], opA[30], opA[31]}; 
            ALU_BSWAP:  out = {opA[7:0], opA[15:8], opA[23:16], opA[31:24]};
            default:    out = 32'b0;
        endcase
    end

    always_comb begin
        
    end

    always_comb begin
        zeroFlag            = (out == 32'b0) ? 1'b1 : 1'b0;
        signFlag            = out[31];
        oddParityFlag       = ^out;
        evenParityFlag      = !(^out);
        overflowFlag        = 1'b0;
        carryOut            = 1'b0;
        divideByZeroFlag    = 1'b0;
    end

    assign flags = {divideByZeroFlag, carryOut, overflowFlag, evenParityFlag, oddParityFlag, signFlag, zeroFlag};

endmodule
