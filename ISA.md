# Instructions

## Base Integer

- ADD
- SUB
- AND
- OR
- XOR
- SLL
- SRL
- SRA
- SLT
- SLTU
- ADDI
- ANDI
- ORI
- XORI
- SLLI
- SRLI
- SRAI
- SLTI
- SLTIU
- BEQ
- BNE
- BGE
- BGEU
- BLT
- BLTU
- JAL
- JALR
- ECALL
- EBREAK
- LB
- LBU
- LH
- LHU
- LW
- LUI
- AUIPC
- FENCE
- SB
- SH
- SW

Absolutely, I’d love to explain what each of these instructions does! Here’s a detailed breakdown:

### **R-Type Instructions**
1. `add rd, rs1, rs2`: Adds the values in `rs1` and `rs2`, stores the result in `rd`.
2. `sub rd, rs1, rs2`: Subtracts `rs2` from `rs1`, stores the result in `rd`.
3. `sll rd, rs1, rs2`: Shifts the bits in `rs1` left by the amount in `rs2`, stores the result in `rd`.
4. `slt rd, rs1, rs2`: Sets `rd` to 1 if `rs1` is less than `rs2`, otherwise sets `rd` to 0.
5. `sltu rd, rs1, rs2`: Same as `slt`, but treats values as unsigned.
6. `xor rd, rs1, rs2`: Performs bitwise XOR on `rs1` and `rs2`, stores the result in `rd`.
7. `srl rd, rs1, rs2`: Shifts the bits in `rs1` right by the amount in `rs2` (logical shift), stores the result in `rd`.
8. `sra rd, rs1, rs2`: Shifts the bits in `rs1` right by the amount in `rs2` (arithmetic shift), stores the result in `rd`.
9. `or rd, rs1, rs2`: Performs bitwise OR on `rs1` and `rs2`, stores the result in `rd`.
10. `and rd, rs1, rs2`: Performs bitwise AND on `rs1` and `rs2`, stores the result in `rd`.

### **I-Type Instructions**
1. `addi rd, rs1, imm`: Adds the immediate value `imm` to `rs1`, stores the result in `rd`.
2. `slli rd, rs1, shamt`: Shifts `rs1` left by `shamt` bits, stores the result in `rd`.
3. `slti rd, rs1, imm`: Sets `rd` to 1 if `rs1` is less than `imm`, otherwise sets `rd` to 0.
4. `sltiu rd, rs1, imm`: Same as `slti`, but treats `imm` as unsigned.
5. `xori rd, rs1, imm`: Performs bitwise XOR between `rs1` and `imm`, stores the result in `rd`.
6. `srli rd, rs1, shamt`: Shifts `rs1` right by `shamt` bits (logical shift), stores the result in `rd`.
7. `srai rd, rs1, shamt`: Shifts `rs1` right by `shamt` bits (arithmetic shift), stores the result in `rd`.
8. `ori rd, rs1, imm`: Performs bitwise OR between `rs1` and `imm`, stores the result in `rd`.
9. `andi rd, rs1, imm`: Performs bitwise AND between `rs1` and `imm`, stores the result in `rd`.
10. `lb rd, imm(rs1)`: Loads a byte from memory at `imm + rs1` into `rd` (signed).
11. `lh rd, imm(rs1)`: Loads a half-word from memory at `imm + rs1` into `rd` (signed).
12. `lw rd, imm(rs1)`: Loads a word from memory at `imm + rs1` into `rd`.
13. `lbu rd, imm(rs1)`: Loads a byte from memory at `imm + rs1` into `rd` (unsigned).
14. `lhu rd, imm(rs1)`: Loads a half-word from memory at `imm + rs1` into `rd` (unsigned).
15. `jalr rd, imm(rs1)`: Jumps to address `imm + rs1`, stores the return address in `rd`.
16. `ecall`: Triggers an environment call to invoke operating system services.
17. `ebreak`: Causes a breakpoint trap for debugging.

### **S-Type Instructions**
1. `sb rs2, imm(rs1)`: Stores the byte from `rs2` into memory at address `imm + rs1`.
2. `sh rs2, imm(rs1)`: Stores the half-word from `rs2` into memory at address `imm + rs1`.
3. `sw rs2, imm(rs1)`: Stores the word from `rs2` into memory at address `imm + rs1`.

### **B-Type Instructions**
1. `beq rs1, rs2, imm`: Branches to `imm` if `rs1` equals `rs2`.
2. `bne rs1, rs2, imm`: Branches to `imm` if `rs1` does not equal `rs2`.
3. `blt rs1, rs2, imm`: Branches to `imm` if `rs1` is less than `rs2`.
4. `bge rs1, rs2, imm`: Branches to `imm` if `rs1` is greater than or equal to `rs2`.
5. `bltu rs1, rs2, imm`: Branches to `imm` if `rs1` is less than `rs2` (unsigned).
6. `bgeu rs1, rs2, imm`: Branches to `imm` if `rs1` is greater than or equal to `rs2` (unsigned).

### **U-Type Instructions**
1. `lui rd, imm`: Loads the upper 20 bits of `rd` with `imm`, lower 12 bits are zero.
2. `auipc rd, imm`: Adds `imm` to the program counter, stores the result in `rd`.

### **J-Type Instructions**
1. `jal rd, imm`: Jumps to address `imm`, stores the return address in `rd`.

These instructions form the core of the RV32I ISA, enabling a wide range of operations from arithmetic to memory access to control flow. Each has its own unique role in facilitating the execution of programs on a RISC-V processor. If you have specific questions about any of these or need more detailed examples, just let me know!

## Integer Multiplication and Division

- MULH
- MULHU
- MULHSU
- DIV
- DIVU
- MUL
- REM
- REMU

Sure thing! The RISC-V M extension (which stands for "Multiply and Divide") includes additional instructions for integer multiplication and division. Here are the prototypes and their functions:

### **R-Type Instructions (M Extension)**
1. `mul rd, rs1, rs2`: Multiplies `rs1` by `rs2` and stores the lower 32 bits of the result in `rd`.
2. `mulh rd, rs1, rs2`: Multiplies `rs1` by `rs2` and stores the upper 32 bits of the signed result in `rd`.
3. `mulhsu rd, rs1, rs2`: Multiplies `rs1` by `rs2` (where `rs2` is unsigned) and stores the upper 32 bits of the result in `rd`.
4. `mulhu rd, rs1, rs2`: Multiplies `rs1` by `rs2` (both unsigned) and stores the upper 32 bits of the result in `rd`.
5. `div rd, rs1, rs2`: Divides `rs1` by `rs2` (signed) and stores the quotient in `rd`.
6. `divu rd, rs1, rs2`: Divides `rs1` by `rs2` (both unsigned) and stores the quotient in `rd`.
7. `rem rd, rs1, rs2`: Divides `rs1` by `rs2` (signed) and stores the remainder in `rd`.
8. `remu rd, rs1, rs2`: Divides `rs1` by `rs2` (both unsigned) and stores the remainder in `rd`.

### Detailed Descriptions:
1. `mul rd, rs1, rs2`: This instruction performs integer multiplication. The product of the values in `rs1` and `rs2` is computed, and the lower 32 bits of this product are stored in `rd`.
2. `mulh rd, rs1, rs2`: This instruction multiplies the signed values in `rs1` and `rs2`, and stores the upper 32 bits of the result in `rd`. Useful for detecting overflow or performing high-precision arithmetic.
3. `mulhsu rd, rs1, rs2`: This instruction multiplies the signed value in `rs1` by the unsigned value in `rs2`, and stores the upper 32 bits of the result in `rd`.
4. `mulhu rd, rs1, rs2`: This instruction multiplies the unsigned values in `rs1` and `rs2`, and stores the upper 32 bits of the result in `rd`.
5. `div rd, rs1, rs2`: This instruction performs integer division. `rs1` is divided by `rs2` and the quotient is stored in `rd`. This operation is signed, meaning it takes into account the signs of the operands.
6. `divu rd, rs1, rs2`: This instruction performs unsigned integer division. `rs1` is divided by `rs2` and the quotient is stored in `rd`.
7. `rem rd, rs1, rs2`: This instruction computes the remainder of the division of `rs1` by `rs2` (signed) and stores the result in `rd`.
8. `remu rd, rs1, rs2`: This instruction computes the remainder of the division of `rs1` by `rs2` (unsigned) and stores the result in `rd`.

These instructions enhance the basic RV32I ISA by enabling efficient handling of more complex arithmetic operations. If you have any specific questions about how these instructions work or need examples, just let me know!

## Atomic

- LR.W
- AMOADD.W
- AMOSWAP.W
- SC.W
- AMOMIN.W
- AMOAND.W
- AMOMAX.W
- AMOOR.W
- AMOMINU.W
- AMOXOR.W
- AMOMAXU.W

Sure! The RISC-V A extension (which stands for "Atomic") includes instructions for atomic memory operations, which are crucial for multi-threaded programming. Here are the prototypes and their functions:

### **R-Type Instructions (A Extension)**
1. `lr.w rd, rs1`: Load-Reserved word. Loads the word at address `rs1` into `rd` and reserves it for a future store.
2. `sc.w rd, rs2, rs1`: Store-Conditional word. Stores the word in `rs2` at the address in `rs1` only if the address was reserved by a previous `lr.w` instruction. The result is 0 on success, non-zero on failure.
3. `amoswap.w rd, rs2, rs1`: Atomic swap. Atomically swaps the contents of `rs1` and `rs2`, storing the original value of `rs1` into `rd`.
4. `amoadd.w rd, rs2, rs1`: Atomic add. Atomically adds the contents of `rs1` and `rs2`, storing the result into `rs1` and the original value of `rs1` into `rd`.
5. `amoxor.w rd, rs2, rs1`: Atomic XOR. Atomically XORs the contents of `rs1` and `rs2`, storing the result into `rs1` and the original value of `rs1` into `rd`.
6. `amoand.w rd, rs2, rs1`: Atomic AND. Atomically ANDs the contents of `rs1` and `rs2`, storing the result into `rs1` and the original value of `rs1` into `rd`.
7. `amoor.w rd, rs2, rs1`: Atomic OR. Atomically ORs the contents of `rs1` and `rs2`, storing the result into `rs1` and the original value of `rs1` into `rd`.
8. `amomin.w rd, rs2, rs1`: Atomic minimum. Atomically stores the minimum of `rs1` and `rs2` into `rs1`, and the original value of `rs1` into `rd`.
9. `amomax.w rd, rs2, rs1`: Atomic maximum. Atomically stores the maximum of `rs1` and `rs2` into `rs1`, and the original value of `rs1` into `rd`.
10. `amominu.w rd, rs2, rs1`: Atomic unsigned minimum. Atomically stores the minimum of `rs1` and `rs2` (unsigned) into `rs1`, and the original value of `rs1` into `rd`.
11. `amomaxu.w rd, rs2, rs1`: Atomic unsigned maximum. Atomically stores the maximum of `rs1` and `rs2` (unsigned) into `rs1`, and the original value of `rs1` into `rd`.

### Detailed Descriptions:
1. **`lr.w rd, rs1`**: Load-Reserved word. Loads the word from the memory address in `rs1` into `rd` and sets a reservation on the address for a subsequent conditional store.
2. **`sc.w rd, rs2, rs1`**: Store-Conditional word. Stores the word from `rs2` into the memory address in `rs1` if the address was reserved by a prior `lr.w` instruction. `rd` is set to 0 if the store is successful, otherwise to a non-zero value.
3. **`amoswap.w rd, rs2, rs1`**: Atomically swaps the values in `rs1` and `rs2`. The original value of `rs1` is loaded into `rd`, and `rs2` is stored in `rs1`.
4. **`amoadd.w rd, rs2, rs1`**: Atomically adds the value in `rs2` to the value in `rs1`, storing the sum in `rs1` and the original value of `rs1` in `rd`.
5. **`amoxor.w rd, rs2, rs1`**: Atomically XORs the values in `rs1` and `rs2`, storing the result in `rs1` and the original value of `rs1` in `rd`.
6. **`amoand.w rd, rs2, rs1`**: Atomically ANDs the values in `rs1` and `rs2`, storing the result in `rs1` and the original value of `rs1` in `rd`.
7. **`amoor.w rd, rs2, rs1`**: Atomically ORs the values in `rs1` and `rs2`, storing the result in `rs1` and the original value of `rs1` in `rd`.
8. **`amomin.w rd, rs2, rs1`**: Atomically computes the minimum of the values in `rs1` and `rs2`, storing the minimum in `rs1` and the original value of `rs1` in `rd`.
9. **`amomax.w rd, rs2, rs1`**: Atomically computes the maximum of the values in `rs1` and `rs2`, storing the maximum in `rs1` and the original value of `rs1` in `rd`.
10. **`amominu.w rd, rs2, rs1`**: Atomically computes the unsigned minimum of the values in `rs1` and `rs2`, storing the unsigned minimum in `rs1` and the original value of `rs1` in `rd`.
11. **`amomaxu.w rd, rs2, rs1`**: Atomically computes the unsigned maximum of the values in `rs1` and `rs2`, storing the unsigned maximum in `rs1` and the original value of `rs1` in `rd`.

These atomic instructions are essential for building synchronization primitives in multi-threaded programs, as they allow operations on shared memory to be completed without interruption.

If you have any further questions or need more details about any of these instructions, feel free to ask!

## Single-Precission Floating Point Arithmetic

-

Certainly! The RISC-V F extension (which stands for "Floating-Point") includes instructions for floating-point arithmetic operations. Here's the breakdown of the prototypes and their functions:

### **R-Type Instructions (F Extension)**
1. `fadd.s rd, rs1, rs2`: Floating-point addition.
2. `fsub.s rd, rs1, rs2`: Floating-point subtraction.
3. `fmul.s rd, rs1, rs2`: Floating-point multiplication.
4. `fdiv.s rd, rs1, rs2`: Floating-point division.
5. `fmin.s rd, rs1, rs2`: Floating-point minimum.
6. `fmax.s rd, rs1, rs2`: Floating-point maximum.
7. `fsqrt.s rd, rs1`: Floating-point square root.
8. `fmadd.s rd, rs1, rs2, rs3`: Floating-point fused multiply-add.
9. `fmsub.s rd, rs1, rs2, rs3`: Floating-point fused multiply-subtract.
10. `fnmadd.s rd, rs1, rs2, rs3`: Floating-point fused negative multiply-add.
11. `fnmsub.s rd, rs1, rs2, rs3`: Floating-point fused negative multiply-subtract.
12. `fcvt.w.s rd, rs1`: Convert floating-point to signed integer.
13. `fcvt.wu.s rd, rs1`: Convert floating-point to unsigned integer.
14. `fcvt.s.w rd, rs1`: Convert signed integer to floating-point.
15. `fcvt.s.wu rd, rs1`: Convert unsigned integer to floating-point.
16. `fmv.x.w rd, rs1`: Move word to integer register.
17. `fmv.w.x rd, rs1`: Move integer to word register.
18. `fsgnj.s rd, rs1, rs2`: Floating-point sign-injection.
19. `fsgnjn.s rd, rs1, rs2`: Floating-point sign-injection (negate).
20. `fsgnjx.s rd, rs1, rs2`: Floating-point sign-injection (xor).
21. `feq.s rd, rs1, rs2`: Floating-point equality comparison.
22. `flt.s rd, rs1, rs2`: Floating-point less-than comparison.
23. `fle.s rd, rs1, rs2`: Floating-point less-than or equal comparison.
24. `fclass.s rd, rs1`: Classify floating-point number.

### Detailed Descriptions:
1. **`fadd.s rd, rs1, rs2`**: Adds the floating-point values in `rs1` and `rs2`, stores the result in `rd`.
2. **`fsub.s rd, rs1, rs2`**: Subtracts the floating-point value in `rs2` from `rs1`, stores the result in `rd`.
3. **`fmul.s rd, rs1, rs2`**: Multiplies the floating-point values in `rs1` and `rs2`, stores the result in `rd`.
4. **`fdiv.s rd, rs1, rs2`**: Divides the floating-point value in `rs1` by `rs2`, stores the result in `rd`.
5. **`fmin.s rd, rs1, rs2`**: Stores the smaller of the floating-point values in `rs1` and `rs2` in `rd`.
6. **`fmax.s rd, rs1, rs2`**: Stores the larger of the floating-point values in `rs1` and `rs2` in `rd`.
7. **`fsqrt.s rd, rs1`**: Computes the square root of the floating-point value in `rs1`, stores the result in `rd`.
8. **`fmadd.s rd, rs1, rs2, rs3`**: Performs floating-point fused multiply-add; computes `(rs1 * rs2) + rs3` with a single rounding.
9. **`fmsub.s rd, rs1, rs2, rs3`**: Performs floating-point fused multiply-subtract; computes `(rs1 * rs2) - rs3` with a single rounding.
10. **`fnmadd.s rd, rs1, rs2, rs3`**: Performs floating-point fused negative multiply-add; computes `-(rs1 * rs2) + rs3` with a single rounding.
11. **`fnmsub.s rd, rs1, rs2, rs3`**: Performs floating-point fused negative multiply-subtract; computes `-(rs1 * rs2) - rs3` with a single rounding.
12. **`fcvt.w.s rd, rs1`**: Converts the floating-point value in `rs1` to a signed integer, stores the result in `rd`.
13. **`fcvt.wu.s rd, rs1`**: Converts the floating-point value in `rs1` to an unsigned integer, stores the result in `rd`.
14. **`fcvt.s.w rd, rs1`**: Converts the signed integer value in `rs1` to a floating-point value, stores the result in `rd`.
15. **`fcvt.s.wu rd, rs1`**: Converts the unsigned integer value in `rs1` to a floating-point value, stores the result in `rd`.
16. **`fmv.x.w rd, rs1`**: Moves the word value from the floating-point register `rs1` to the integer register `rd`.
17. **`fmv.w.x rd, rs1`**: Moves the integer value from the integer register `rs1` to the floating-point register `rd`.
18. **`fsgnj.s rd, rs1, rs2`**: Sets the sign of the floating-point value in `rs1` to match the sign of the floating-point value in `rs2`, stores the result in `rd`.
19. **`fsgnjn.s rd, rs1, rs2`**: Sets the sign of the floating-point value in `rs1` to the opposite sign of the floating-point value in `rs2`, stores the result in `rd`.
20. **`fsgnjx.s rd, rs1, rs2`**: Sets the sign of the floating-point value in `rs1` to the XOR of the signs of the floating-point values in `rs1` and `rs2`, stores the result in `rd`.
21. **`feq.s rd, rs1, rs2`**: Compares the floating-point values in `rs1` and `rs2` for equality, sets `rd` to 1 if they are equal, otherwise sets `rd` to 0.
22. **`flt.s rd, rs1, rs2`**: Compares the floating-point values in `rs1` and `rs2`, sets `rd` to 1 if `rs1` is less than `rs2`, otherwise sets `rd` to 0.
23. **`fle.s rd, rs1, rs2`**: Compares the floating-point values in `rs1` and `rs2`, sets `rd` to 1 if `rs1` is less than or equal to `rs2`, otherwise sets `rd` to 0.
24. **`fclass.s rd, rs1`**: Classifies the floating-point value in `rs1`, writing a result indicating the class to `rd`.

These floating-point instructions significantly extend the capabilities of the RISC-V architecture, allowing it to handle a wide range of scientific and engineering computations more efficiently.

If you have any specific questions or need examples about any of these instructions, feel free to ask!

## Double-Precission Floating Point Arithmetic

-

Sure! The RISC-V D extension (which stands for "Double-Precision Floating-Point") includes instructions for double-precision floating-point arithmetic. Here are the prototypes and their functions:

### **R-Type Instructions (D Extension)**
1. `fadd.d rd, rs1, rs2`: Double-precision floating-point addition.
2. `fsub.d rd, rs1, rs2`: Double-precision floating-point subtraction.
3. `fmul.d rd, rs1, rs2`: Double-precision floating-point multiplication.
4. `fdiv.d rd, rs1, rs2`: Double-precision floating-point division.
5. `fmin.d rd, rs1, rs2`: Double-precision floating-point minimum.
6. `fmax.d rd, rs1, rs2`: Double-precision floating-point maximum.
7. `fsqrt.d rd, rs1`: Double-precision floating-point square root.
8. `fmadd.d rd, rs1, rs2, rs3`: Double-precision floating-point fused multiply-add.
9. `fmsub.d rd, rs1, rs2, rs3`: Double-precision floating-point fused multiply-subtract.
10. `fnmadd.d rd, rs1, rs2, rs3`: Double-precision floating-point fused negative multiply-add.
11. `fnmsub.d rd, rs1, rs2, rs3`: Double-precision floating-point fused negative multiply-subtract.
12. `fcvt.s.d rd, rs1`: Convert double-precision to single-precision floating-point.
13. `fcvt.d.s rd, rs1`: Convert single-precision to double-precision floating-point.
14. `fcvt.w.d rd, rs1`: Convert double-precision floating-point to signed integer.
15. `fcvt.wu.d rd, rs1`: Convert double-precision floating-point to unsigned integer.
16. `fcvt.d.w rd, rs1`: Convert signed integer to double-precision floating-point.
17. `fcvt.d.wu rd, rs1`: Convert unsigned integer to double-precision floating-point.
18. `fmv.x.d rd, rs1`: Move double-precision word to integer register.
19. `fmv.d.x rd, rs1`: Move integer to double-precision word register.
20. `fsgnj.d rd, rs1, rs2`: Double-precision floating-point sign-injection.
21. `fsgnjn.d rd, rs1, rs2`: Double-precision floating-point sign-injection (negate).
22. `fsgnjx.d rd, rs1, rs2`: Double-precision floating-point sign-injection (xor).
23. `feq.d rd, rs1, rs2`: Double-precision floating-point equality comparison.
24. `flt.d rd, rs1, rs2`: Double-precision floating-point less-than comparison.
25. `fle.d rd, rs1, rs2`: Double-precision floating-point less-than or equal comparison.
26. `fclass.d rd, rs1`: Classify double-precision floating-point number.

### Detailed Descriptions:
1. **`fadd.d rd, rs1, rs2`**: Adds the double-precision floating-point values in `rs1` and `rs2`, stores the result in `rd`.
2. **`fsub.d rd, rs1, rs2`**: Subtracts the double-precision floating-point value in `rs2` from `rs1`, stores the result in `rd`.
3. **`fmul.d rd, rs1, rs2`**: Multiplies the double-precision floating-point values in `rs1` and `rs2`, stores the result in `rd`.
4. **`fdiv.d rd, rs1, rs2`**: Divides the double-precision floating-point value in `rs1` by `rs2`, stores the result in `rd`.
5. **`fmin.d rd, rs1, rs2`**: Stores the smaller of the double-precision floating-point values in `rs1` and `rs2` in `rd`.
6. **`fmax.d rd, rs1, rs2`**: Stores the larger of the double-precision floating-point values in `rs1` and `rs2` in `rd`.
7. **`fsqrt.d rd, rs1`**: Computes the square root of the double-precision floating-point value in `rs1`, stores the result in `rd`.
8. **`fmadd.d rd, rs1, rs2, rs3`**: Performs double-precision floating-point fused multiply-add; computes `(rs1 * rs2) + rs3` with a single rounding.
9. **`fmsub.d rd, rs1, rs2, rs3`**: Performs double-precision floating-point fused multiply-subtract; computes `(rs1 * rs2) - rs3` with a single rounding.
10. **`fnmadd.d rd, rs1, rs2, rs3`**: Performs double-precision floating-point fused negative multiply-add; computes `-(rs1 * rs2) + rs3` with a single rounding.
11. **`fnmsub.d rd, rs1, rs2, rs3`**: Performs double-precision floating-point fused negative multiply-subtract; computes `-(rs1 * rs2) - rs3` with a single rounding.
12. **`fcvt.s.d rd, rs1`**: Converts the double-precision floating-point value in `rs1` to a single-precision floating-point value, stores the result in `rd`.
13. **`fcvt.d.s rd, rs1`**: Converts the single-precision floating-point value in `rs1` to a double-precision floating-point value, stores the result in `rd`.
14. **`fcvt.w.d rd, rs1`**: Converts the double-precision floating-point value in `rs1` to a signed integer, stores the result in `rd`.
15. **`fcvt.wu.d rd, rs1`**: Converts the double-precision floating-point value in `rs1` to an unsigned integer, stores the result in `rd`.
16. **`fcvt.d.w rd, rs1`**: Converts the signed integer value in `rs1` to a double-precision floating-point value, stores the result in `rd`.
17. **`fcvt.d.wu rd, rs1`**: Converts the unsigned integer value in `rs1` to a double-precision floating-point value, stores the result in `rd`.
18. **`fmv.x.d rd, rs1`**: Moves the double-precision word value from the floating-point register `rs1` to the integer register `rd`.
19. **`fmv.d.x rd, rs1`**: Moves the integer value from the integer register `rs1` to the double-precision word register `rd`.
20. **`fsgnj.d rd, rs1, rs2`**: Sets the sign of the double-precision floating-point value in `rs1` to match the sign of the double-precision floating-point value in `rs2`, stores the result in `rd`.
21. **`fsgnjn.d rd, rs1, rs2`**: Sets the sign of the double-precision floating-point value in `rs1` to the opposite sign of the double-precision floating-point value in `rs2`, stores the result in `rd`.
22. **`fsgnjx.d rd, rs1, rs2`**: Sets the sign of the double-precision floating-point value in `rs1` to the XOR of the signs of the double-precision floating-point values in `rs1` and `rs2`, stores the result in `rd`.
23. **`feq.d rd, rs1, rs2`**: Compares the double-precision floating-point values in `rs1` and `rs2` for equality, sets `rd` to 1 if they are equal, otherwise sets `rd` to 0.
24. **`flt.d rd, rs1, rs2`**: Compares the double-precision floating-point values in `rs1` and `rs2`, sets `rd` to 1 if `rs1` is less than `rs2`, otherwise sets `rd` to 0.
25. **`fle.d rd, rs1, rs2`**: Compares the double-precision floating-point values in `rs1` and `rs2`, sets `rd` to 1 if `rs1` is less than or equal to `rs2`, otherwise sets `rd` to 0.
26. **`fclass.d rd, rs1`**: Classifies the double-precision floating-point value in `rs1`, writing a result indicating the class to `rd`.

These double-precision floating-point instructions extend the F extension by providing greater precision and a broader range of values, which are essential for scientific and engineering applications.

If you have any specific questions or need examples about any of these instructions, feel free to ask!

## Control and Status Registers

-

Absolutely! The Zicsr extension (which stands for "Control and Status Registers") includes instructions for reading, writing, and modifying control and status registers. Here are the prototypes and their functions:

### **I-Type Instructions (Zicsr Extension)**
1. `csrrw rd, rs1, csr`: Atomic Read/Write CSR.
2. `csrrs rd, rs1, csr`: Atomic Read and Set CSR.
3. `csrrc rd, rs1, csr`: Atomic Read and Clear CSR.
4. `csrrwi rd, imm, csr`: Atomic Read/Write CSR Immediate.
5. `csrrsi rd, imm, csr`: Atomic Read and Set CSR Immediate.
6. `csrrci rd, imm, csr`: Atomic Read and Clear CSR Immediate.

### Detailed Descriptions:
1. **`csrrw rd, rs1, csr`**: Atomically writes the value in `rs1` to the CSR specified by `csr`, and the original value of the CSR is written to `rd`.
2. **`csrrs rd, rs1, csr`**: Atomically reads the CSR specified by `csr` and writes it to `rd`, then sets the CSR to the bitwise OR of the CSR value and the value in `rs1`.
3. **`csrrc rd, rs1, csr`**: Atomically reads the CSR specified by `csr` and writes it to `rd`, then sets the CSR to the bitwise AND of the CSR value and the bitwise complement of the value in `rs1`.
4. **`csrrwi rd, imm, csr`**: Atomically writes the immediate value `imm` to the CSR specified by `csr`, and the original value of the CSR is written to `rd`.
5. **`csrrsi rd, imm, csr`**: Atomically reads the CSR specified by `csr` and writes it to `rd`, then sets the CSR to the bitwise OR of the CSR value and the immediate value `imm`.
6. **`csrrci rd, imm, csr`**: Atomically reads the CSR specified by `csr` and writes it to `rd`, then sets the CSR to the bitwise AND of the CSR value and the bitwise complement of the immediate value `imm`.

These instructions enable efficient manipulation of control and status registers, which are essential for managing system resources and controlling processor behavior in RISC-V architectures.

If you have any specific questions or need examples about any of these instructions, feel free to ask!

## Instruction-Fetch Fence

- FENCE.I

Certainly! The Zifencei extension (which stands for "Instruction-Fetch Fence") includes instructions that ensure proper ordering of instruction-fetches and data accesses, which is crucial in certain scenarios involving self-modifying code and multiprocessor systems. Here are the prototypes and their functions:

### **Zifencei Instruction**
1. `fence.i`: Instruction-Fetch Fence.

### Detailed Description:
1. **`fence.i`**: Ensures that all previous writes to instruction memory are visible to all subsequent instruction fetches. This is especially important when code has been modified and ensures that the new instructions are fetched correctly and executed in the intended order.

The `fence.i` instruction is a single instruction in this extension, but it plays a critical role in maintaining consistency and correct execution in systems where the instruction memory can be modified dynamically.

If you have any further questions or need more details about this instruction, feel free to ask!

## Bit Manipulation

-

Sure! The RISC-V B extension (which stands for "Bit-Manipulation") includes instructions for bitwise operations that are useful in a variety of applications, especially in cryptographic algorithms and performance optimizations. Here are the prototypes and their functions:

### **R-Type Instructions (B Extension)**
1. `andn rd, rs1, rs2`: Bitwise AND NOT.
2. `orn rd, rs1, rs2`: Bitwise OR NOT.
3. `xnor rd, rs1, rs2`: Bitwise XOR NOT.
4. `slo rd, rs1, rs2`: Shift Left Ones.
5. `sro rd, rs1, rs2`: Shift Right Ones.
6. `rol rd, rs1, rs2`: Rotate Left.
7. `ror rd, rs1, rs2`: Rotate Right.
8. `sbset rd, rs1, rs2`: Set Bit.
9. `sbclr rd, rs1, rs2`: Clear Bit.
10. `sbinv rd, rs1, rs2`: Invert Bit.
11. `sbext rd, rs1, rs2`: Extract Bit.
12. `clz rd, rs1`: Count Leading Zeros.
13. `ctz rd, rs1`: Count Trailing Zeros.
14. `pcnt rd, rs1`: Population Count.
15. `bext rd, rs1, rs2`: Bit Field Extract.
16. `bdep rd, rs1, rs2`: Bit Field Deposit.
17. `grev rd, rs1, rs2`: Generalized Reverse.
18. `shfl rd, rs1, rs2`: Shuffle Bits.
19. `unshfl rd, rs1, rs2`: Unshuffle Bits.

### Detailed Descriptions:
1. **`andn rd, rs1, rs2`**: Performs bitwise AND of `rs1` with the NOT of `rs2` and stores the result in `rd`.
2. **`orn rd, rs1, rs2`**: Performs bitwise OR of `rs1` with the NOT of `rs2` and stores the result in `rd`.
3. **`xnor rd, rs1, rs2`**: Performs bitwise XOR of `rs1` with the NOT of `rs2` and stores the result in `rd`.
4. **`slo rd, rs1, rs2`**: Shifts the bits in `rs1` left by the amount specified in `rs2`, filling with ones, and stores the result in `rd`.
5. **`sro rd, rs1, rs2`**: Shifts the bits in `rs1` right by the amount specified in `rs2`, filling with ones, and stores the result in `rd`.
6. **`rol rd, rs1, rs2`**: Rotates the bits in `rs1` to the left by the amount specified in `rs2` and stores the result in `rd`.
7. **`ror rd, rs1, rs2`**: Rotates the bits in `rs1` to the right by the amount specified in `rs2` and stores the result in `rd`.
8. **`sbset rd, rs1, rs2`**: Sets the bit in `rs1` specified by `rs2` and stores the result in `rd`.
9. **`sbclr rd, rs1, rs2`**: Clears the bit in `rs1` specified by `rs2` and stores the result in `rd`.
10. **`sbinv rd, rs1, rs2`**: Inverts the bit in `rs1` specified by `rs2` and stores the result in `rd`.
11. **`sbext rd, rs1, rs2`**: Extracts the bit in `rs1` specified by `rs2` and stores it in `rd`.
12. **`clz rd, rs1`**: Counts the number of leading zeros in `rs1` and stores the result in `rd`.
13. **`ctz rd, rs1`**: Counts the number of trailing zeros in `rs1` and stores the result in `rd`.
14. **`pcnt rd, rs1`**: Counts the number of 1 bits in `rs1` and stores the result in `rd`.
15. **`bext rd, rs1, rs2`**: Extracts a bit field from `rs1` as specified by the mask in `rs2` and stores it in `rd`.
16. **`bdep rd, rs1, rs2`**: Deposits the bit field from `rs1` into `rs2` as specified by the mask in `rs2` and stores the result in `rd`.
17. **`grev rd, rs1, rs2`**: Reverses the bits in `rs1` according to a pattern specified in `rs2` and stores the result in `rd`.
18. **`shfl rd, rs1, rs2`**: Shuffles the bits in `rs1` according to a pattern specified in `rs2` and stores the result in `rd`.
19. **`unshfl rd, rs1, rs2`**: Unshuffles the bits in `rs1` according to a pattern specified in `rs2` and stores the result in `rd`.

These bit-manipulation instructions provide powerful tools for efficiently performing complex bit-level operations, which can greatly optimize performance in specific applications, such as cryptography, error detection and correction, and data compression.

If you have any further questions or need more details about any of these instructions, feel free to ask!

## Custom Instructions

- 
- 