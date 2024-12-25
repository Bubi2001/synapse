import ALUOperations::*;

module ALU (
    input  logic        clk,
    input  logic        rst_n
    input  logic [31:0] opA,
    input  logic [31:0] opB,
    input  logic        cIn,
    input  alu_op_t     aluOp,
    input  logic        enable,
    output logic [31:0] aluOut,
    output logic [6:0]  flagsOut
    // [6]divideByZeroFlag; [5]carryOut; [4]overflowFlag; [3]evenParityFlag; [2]oddParityFlag; [1]signFlag; [0]zeroFlag
);
    logic [31:0] aArith, bArith, outArith, aLog, bLog, outLog;
    logic [6:0] flagsArith, flagsLog;
    alu_op_t aluOpArith, aluOpLog;
    logic cArith, cLog;

    ArithmeticOps ArithmeticOps (
        .opA(aArith),
        .opB(bArith),
        .cIn(cArith),
        .aluOp(aluOpArith),
        .out(outArith),
        .flags(flagsArith)
    );

    LogicOps LogicOps (
        .opA(aLog),
        .opB(bLog),
        .cIn(cLog),
        .aluOp(aluOpLog),
        .out(outLog),
        .flags(flagsArith)
    );

    always_comb begin
        case (aluOp)
            ALU_NOP: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_NOP;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = 32'b0;
                flagsOut    = 7'b0;
            end
            ALU_ADD: begin
                aluOpArith  = ALU_ADD;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsLog;
            end
            ALU_SUB: begin
                aluOpArith  = ALU_SUB;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_AND: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_AND;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_OR: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_OR;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_XOR: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_XOR;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_NAND: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_NAND;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_NOR: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_NOR;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_XNOR: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_XNOR;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_ANDN: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_ANDN;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_ORN: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_ORN;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_XORN: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_XORN;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_NOT: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_NOT;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_SLL: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_SLL;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_SLT: begin
                aluOpArith  = ALU_SLT;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_SLTU: begin
                aluOpArith  = ALU_SLTU;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_SRL: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_SRL;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_SRA: begin
                aluOpArith  = ALU_SRA;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_MUL: begin
                aluOpArith  = ALU_MUL;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_MULH: begin
                aluOpArith  = ALU_MULH;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_MULHU: begin
                aluOpArith  = ALU_MULHU;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_MULHSU: begin
                aluOpArith  = ALU_MULHSU;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_DIV: begin
                aluOpArith  = ALU_DIV;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_DIVU: begin
                aluOpArith  = ALU_DIVU;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_REM: begin
                aluOpArith  = ALU_REM;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_REMU: begin
                aluOpArith  = ALU_REMU;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_SLO: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_SLO;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_SRO: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_SRO;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_ROL: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_ROL;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_ROR: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_ROR;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_SBSET: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_SBSET;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_SBCLR: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_SBCLR;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_SBINV: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_SBINV;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_SBEXT: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_SBEXT;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_CLZ: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_CLZ;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_CTZ: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_CTZ;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_PCNT: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_PCNT;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_BEXT:begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_BEXT;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_BDEP: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_BDEP;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_GREV: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_GREV;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_SHFL: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_SHFL;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_UNSHFL: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_UNSHFL;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_INCA: begin
                aluOpArith  = ALU_INCA;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_DECA: begin
                aluOpArith  = ALU_DECA;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_ABS: begin
                aluOpArith  = ALU_ABS;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_NEG: begin
                aluOpArith  = ALU_NEG;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_RLTC: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_RLTC;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_RRTC: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_RRTC;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_BITREV: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_BITREV;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_BSWAP: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_BSWAP;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = opA;
                bLog        = opB;
                cLog        = cIn;
                aluOut      = outLog;
                flagsOut    = flagsLog;
            end
            ALU_MIN: begin
                aluOpArith  = ALU_MIN;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_MINU: begin
                aluOpArith  = ALU_MINU;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_MAX: begin
                aluOpArith  = ALU_MAX;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            ALU_MAXU: begin
                aluOpArith  = ALU_MAXU;
                aluOpLog    = ALU_NOP;
                aArith      = opA;
                bArith      = opB;
                cArith      = cIn;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = outArith;
                flagsOut    = flagsArith;
            end
            default: begin
                aluOpArith  = ALU_NOP;
                aluOpLog    = ALU_NOP;
                aArith      = 32'b0;
                bArith      = 32'b0;
                cArith      = 1'b0;
                aLog        = 32'b0;
                bLog        = 32'b0;
                cLog        = 1'b0;
                aluOut      = 32'b0;
                flagsOut    = 7'b0;
            end
        endcase
    end

endmodule
