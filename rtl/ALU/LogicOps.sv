import ALUOperations::*;

module LogicOps (
    input  logic [31:0] opA,
    input  logic [31:0] opB,
    input  logic        cIn,
    input  alu_op_t     aluOp,
    output logic [31:0] out,
    output logic [5:0]  flags
);
    
endmodule

module riscv_b_extension (
    input logic [31:0] rs1,    // First operand
    input logic [31:0] rs2,    // Second operand (if needed)
    input logic [4:0]  funct7,  // Function code (for distinguishing operations)
    input logic [4:0]  rs1_index, // Bit index for sbext and similar instructions
    output logic [31:0] result  // Result of the operation
);

    always_comb begin
        case (funct7)
            7'b0000000: begin // sbset
                result = rs1 | (1 << rs1_index); // Set bit
            end

            7'b0000001: begin // sbclr
                result = rs1 & ~(1 << rs1_index); // Clear bit
            end

            7'b0000010: begin // sbinv
                result = rs1 ^ (1 << rs1_index); // Invert bit
            end

            7'b0000011: begin // sbext
                result = (rs1 >> rs1_index) & 1;  // Extract bit (sbext)
            end

            7'b0000100: begin // clz (Count Leading Zeros)
                result = count_leading_zeros(rs1);
            end

            7'b0000101: begin // ctz (Count Trailing Zeros)
                result = count_trailing_zeros(rs1);
            end

            7'b0000110: begin // pcnt (Population Count)
                result = population_count(rs1);
            end

            7'b0000111: begin // bdep (Bit Deposit)
                result = bit_deposit(rs1, rs2);
            end

            7'b0001001: begin // shfl (Shuffle)
                result = shuffle(rs1, rs2);
            end

            7'b0001010: begin // unshfl (Unshuffle)
                result = unshuffle(rs1, rs2);
            end

            default: result = 32'h00000000; // Default case
        endcase
    end

    // Count leading zeros in a 32-bit integer
    function logic [31:0] count_leading_zeros(input logic [31:0] value);
        integer i;
        begin
            for (i = 31; i >= 0; i = i - 1) begin
                if (value[i] == 1) begin
                    count_leading_zeros = 31 - i;
                    return;
                end
            end
            count_leading_zeros = 32; // if value is 0
        end
    endfunction

    // Count trailing zeros in a 32-bit integer
    function logic [31:0] count_trailing_zeros(input logic [31:0] value);
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1) begin
                if (value[i] == 1) begin
                    count_trailing_zeros = i;
                    return;
                end
            end
            count_trailing_zeros = 32; // if value is 0
        end
    endfunction

    // Count the number of 1s in a 32-bit integer (population count)
    function logic [31:0] population_count(input logic [31:0] value);
        integer i;
        begin
            population_count = 0;
            for (i = 0; i < 32; i = i + 1) begin
                population_count = population_count + value[i];
            end
        end
    endfunction

    // Bit deposit operation (bdep)
    function logic [31:0] bit_deposit(input logic [31:0] value, input logic [31:0] mask);
        begin
            bit_deposit = (value & mask);
        end
    endfunction

    // Shuffle bits based on the second operand (shfl)
    function logic [31:0] shuffle(input logic [31:0] value, input logic [31:0] mask);
        begin
            shuffle = (value ^ mask);
        end
    endfunction

    // Unshuffle bits based on the second operand (unshfl)
    function logic [31:0] unshuffle(input logic [31:0] value, input logic [31:0] mask);
        begin
            unshuffle = (value ^ mask);
        end
    endfunction

endmodule

module riscv_b_extension(
    input logic [31:0] rs1,    // Source register 1
    input logic [31:0] rs2,    // Source register 2
    input logic [31:0] rs3,    // Shuffle control register (for shfl/unshfl)
    output logic [31:0] rd,    // Destination register (result)
    input logic [3:0] opcode   // Instruction opcode
);

// Define opcodes for grev, shfl, unshfl (arbitrary encoding, modify as needed)
localparam OPCODE_GREV   = 4'b0001;
localparam OPCODE_SHFL   = 4'b0010;
localparam OPCODE_UNSHFL = 4'b0011;

// Perform the Generalized Reverse (grev)
function logic [31:0] grev(input logic [31:0] data, input logic [31:0] mask);
    integer i;
    logic [31:0] result;
    result = 32'b0;
    for (i = 0; i < 32; i++) begin
        if (mask[i]) begin
            result[i] = data[31-i];  // Reverse bit i with position 31-i
        end
    end
    return result;
endfunction

// Perform the Shuffle (shfl)
function logic [31:0] shfl(input logic [31:0] data, input logic [31:0] control);
    integer i;
    logic [31:0] result;
    result = 32'b0;
    for (i = 0; i < 32; i++) begin
        result[i] = data[control[i]];  // Shuffle bits based on control register
    end
    return result;
endfunction

// Perform the Unshuffle (unshfl)
function logic [31:0] unshfl(input logic [31:0] data, input logic [31:0] control);
    integer i;
    logic [31:0] result;
    result = 32'b0;
    for (i = 0; i < 32; i++) begin
        result[control[i]] = data[i];  // Unshuffle bits based on control register
    end
    return result;
endfunction

// Main execution logic
always_ff @(posedge clk) begin
    case (opcode)
        OPCODE_GREV:   rd <= grev(rs1, rs2);       // Generalized Reverse
        OPCODE_SHFL:   rd <= shfl(rs1, rs3);       // Shuffle
        OPCODE_UNSHFL: rd <= unshfl(rs1, rs3);     // Unshuffle
        default:       rd <= 32'b0;                // Default case
    endcase
end

endmodule

module rotate (
    input logic [31:0] a,        // Operand A (32 bits)
    input logic [31:0] b,        // Operand B (Number of positions to rotate)
    input logic [1:0] rot_sel,   // Control signal to select rotation type
    input logic cin,             // Carry input (used for RLTC and RRTC)
    output logic [31:0] result,  // Rotation result (32 bits)
    output logic cout            // Carry output (used for RLTC and RRTC)
);

    // Internal signals for rotation logic
    logic [31:0] temp_a;
    logic [31:0] shifted_left;
    logic [31:0] shifted_right;
    logic [31:0] rotated_left;
    logic [31:0] rotated_right;
    
    // Control rotation based on rot_sel
    always_comb begin
        case(rot_sel)
            2'b00: begin // ROL (Rotate Left)
                shifted_left = a << b[4:0];                      // Left shift a by b positions
                rotated_left = a >> (32 - b[4:0]);                // Get the wrap-around bits
                result = shifted_left | rotated_left;             // Combine the results
                cout = shifted_left[31];                          // Carry-out is the leftmost bit
            end

            2'b01: begin // ROR (Rotate Right)
                shifted_right = a >> b[4:0];                     // Right shift a by b positions
                rotated_right = a << (32 - b[4:0]);               // Get the wrap-around bits
                result = shifted_right | rotated_right;           // Combine the results
                cout = shifted_right[0];                          // Carry-out is the rightmost bit
            end

            2'b10: begin // RLTC (Rotate Left Through Carry)
                shifted_left = a << b[4:0];                      // Left shift a by b positions
                rotated_left = a >> (32 - b[4:0]);                // Get the wrap-around bits
                result = shifted_left | rotated_left;             // Combine the results
                cout = shifted_left[31];                          // Carry-out from leftmost bit

                // Incorporate carry input to the rotation
                if (b[0] == 1'b0) begin
                    result[0] = cin;                            // Set LSB of result to carry input
                end else begin
                    result[31] = cin;                           // Set MSB of result to carry input
                end
            end

            2'b11: begin // RRTC (Rotate Right Through Carry)
                shifted_right = a >> b[4:0];                     // Right shift a by b positions
                rotated_right = a << (32 - b[4:0]);               // Get the wrap-around bits
                result = shifted_right | rotated_right;           // Combine the results
                cout = shifted_right[0];                          // Carry-out from rightmost bit

                // Incorporate carry input to the rotation
                if (b[0] == 1'b0) begin
                    result[31] = cin;                           // Set MSB of result to carry input
                end else begin
                    result[0] = cin;                            // Set LSB of result to carry input
                end
            end

            default: begin
                result = 32'b0;
                cout = 0;
            end
        endcase
    end

endmodule

module Endian_Swap (
    input logic [31:0] in,    // 32-bit input integer
    output logic [31:0] out   // 32-bit output integer with swapped endianness
);

    always_comb begin
        // Swap the bytes of the 32-bit input integer
        out = {in[7:0], in[15:8], in[23:16], in[31:24]};
    end

endmodule

module Bit_Reverse (
    input logic [31:0] in,    // 32-bit input integer
    output logic [31:0] out   // 32-bit output with bit-reversed integer
);

    always_comb begin
        // Perform bit reversal using the bit-select approach
        out = {in[0], in[1], in[2], in[3], in[4], in[5], in[6], in[7],
               in[8], in[9], in[10], in[11], in[12], in[13], in[14], in[15],
               in[16], in[17], in[18], in[19], in[20], in[21], in[22], in[23],
               in[24], in[25], in[26], in[27], in[28], in[29], in[30], in[31]};
    end

endmodule