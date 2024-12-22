package ALUOperations;
    // Define an enum for ALU operations
    typedef enum logic [5:0] {
        ALU_NOP     = 6'h00,    // No Operation
        ALU_ADD     = 6'h01,    // Addition             (out = a + b + c)
        ALU_SUB     = 6'h02,    // Subtraction          (out = a - b)
        ALU_AND     = 6'h03,    // Bitwise AND          (out = a & b)
        ALU_OR      = 6'h04,    // Bitwise OR           (out = a | b)
        ALU_XOR     = 6'h05,    // Bitwise XOR          (out = a ^ b)
        ALU_NAND    = 6'h06,    // Bitwise NAND         (out = ~(a & b))
        ALU_NOR     = 6'h07,    // Bitwise NOR          (out = ~(a | b))
        ALU_XNOR    = 6'h08,    // Bitwise XNOR         (out = ~(a ^ b))
        ALU_ANDN    = 6'h09,    // Bitwise ANDN         (out = a & ~b)
        ALU_ORN     = 6'h0A,    // Bitwise ORN          (out = a | ~b)
        ALU_XORN    = 6'h0B,    // Bitwise XORN         (out = a ^ ~b)
        ALU_NOT     = 6'h0C,    // Bitwise NOT          (out = ~a)
        ALU_SLL     = 6'h0D,    // Shift Left Logic     (out = a << b)
        ALU_SLT     = 6'h0E,    // Set Less Than        (out = (a < b) ? 1 : 0)
        ALU_SLTU    = 6'h0F,    // SLT Unsigned         (out = (a < b) ? 1 : 0)
        ALU_SRL     = 6'h10,    // Shift Right Logical  (out = a >> b)
        ALU_SRA     = 6'h11,    // SR Arithmetic        (out = a >> b)
        ALU_MUL     = 6'h12,    // Multiplication       (out = [31:0](a * b))
        ALU_MULH    = 6'h13,    // Multiplication       (out = [63:32](a * b))
        ALU_MULHU   = 6'h14,    // Mult. Unsigned       (out = [63:32](a * b))
        ALU_MULHSU  = 6'h15,    // Mult. SignedUnsigned (out = [63:32](a * b))
        ALU_DIV     = 6'h16,    // Division, Quotient   (out = a / b)
        ALU_DIVU    = 6'h17,    // Div. Quo. Unsigned   (out = a / b)
        ALU_REM     = 6'h18,    // Division, Remainder  (out = a % b)
        ALU_REMU    = 6'h19,    // Div. Rem. Unsigned   (out = a % b)
        ALU_SLO     = 6'h1A,    // Shift Left Ones      (out = (a << b[4:0]) | ((1 << b[4:0]) - 1))
        ALU_SRO     = 6'h1B,    // Shift Right Ones     (out = (a >> b[4:0]) | ((32'hFFFFFFFF << (32 - b[4:0]))))
        ALU_ROL     = 6'h1C,    // Rotate Left          (out = (a << b[4:0]) | (a >> (32 - b[4:0])))
        ALU_ROR     = 6'h1D,    // Rotate Right         (out = (a >> b[4:0]) | (a << (32 - b[4:0])))
        ALU_SBSET   = 6'h1E,    // Single Bit Set       (out = a | (1 << b[4:0]))
        ALU_SBCLR   = 6'h1F,    // Single Bit Clear     (out = a & ~(1 << b[4:0]))
        ALU_SBINV   = 6'h20,    // Single Bit Invert    (out = a ^ (1 << b[4:0]))
        ALU_SBEXT   = 6'h21,    // Single Bit Extract   (out = (a >> b[4:0]) & 1)
        ALU_CLZ     = 6'h22,    // Count Leading Zeros
        ALU_CTZ     = 6'h23,    // Count Trailing Zeros
        ALU_PCNT    = 6'h24,    // Population Count
        ALU_BEXT    = 6'h25,    // Bit Extract          (out = (a >> b[4:0]) & 1)
        ALU_BDEP    = 6'h26,    // Bit Deposit          (out)
        ALU_GREV    = 6'h27,    // Generalized Reverse
        ALU_SHFL    = 6'h28,    // Shuffle
        ALU_UNSHFL  = 6'h29,    // Unshuffle
        ALU_INCA    = 6'h2A,    // Increment A          (out = a + 1)
        ALU_DECA    = 6'h2B,    // Decrement A          (out = a - 1)
        ALU_ABS     = 6'h2C,    // Absolute Value       (out = |a|)
        ALU_NEG     = 6'h2D,    // Arithmetic Negation  (out = -a)
        ALU_RLTC    = 6'h2E,    // Rotate Left Carry    (out = ((a << b[4:0]) | (a >> (32 - b[4:0]))) | (c << (b[4:0]-1)
        ALU_RRTC    = 6'h2F,    // Rotate Right Carry   (out = ((a >> b[4:0]) | (a << (32 - b[4:0]))) | (c << (32-b[4:0])))
        ALU_BITREV  = 6'h30,    // Bit Reverse          (out[31:0] = a[0:31])
        ALU_BSWAP   = 6'h31,    // Byte Swap (endianness)
        ALU_MIN     = 6'h32,    // Minimum              (out = min(a,b))
        ALU_MINU    = 6'h33,    // Minimum Unsigned     (out = min(a,b))
        ALU_MAX     = 6'h34,    // Maximum              (out = max(a,b))
        ALU_MAXU    = 6'h35     // Maximum Unsigned     (out = max(a,b))
    } alu_op_t;
endpackage
