module FPU (
    ports
);
    
endmodule

module fpu (
    input  logic [31:0] a,     // Operand A
    input  logic [31:0] b,     // Operand B
    input  logic [2:0]  op,    // Operation code
    output logic [31:0] result, // Result
    output logic [4:0]  flags  // Exception flags
);

    // Operation code definitions
    typedef enum logic [2:0] {
        ADD = 3'b000,
        SUB = 3'b001,
        MUL = 3'b010,
        DIV = 3'b011,
        SQRT = 3'b100
    } op_t;

    logic [31:0] res_add_sub;
    logic [31:0] res_mul;
    logic [31:0] res_div;
    logic [31:0] res_sqrt;
    logic [4:0]  exc_add_sub;
    logic [4:0]  exc_mul;
    logic [4:0]  exc_div;
    logic [4:0]  exc_sqrt;

    // Add/Subtract unit
    add_sub_unit add_sub (
        .a(a),
        .b(b),
        .op(op[0]),
        .result(res_add_sub),
        .flags(exc_add_sub)
    );

    // Multiplication unit
    mul_unit mul (
        .a(a),
        .b(b),
        .result(res_mul),
        .flags(exc_mul)
    );

    // Division unit
    div_unit div (
        .a(a),
        .b(b),
        .result(res_div),
        .flags(exc_div)
    );

    // Square root unit
    sqrt_unit sqrt (
        .a(a),
        .result(res_sqrt),
        .flags(exc_sqrt)
    );

    // Mux for selecting the result based on the operation
    always_comb begin
        case (op)
            ADD, SUB: begin
                result = res_add_sub;
                flags  = exc_add_sub;
            end
            MUL: begin
                result = res_mul;
                flags  = exc_mul;
            end
            DIV: begin
                result = res_div;
                flags  = exc_div;
            end
            SQRT: begin
                result = res_sqrt;
                flags  = exc_sqrt;
            end
            default: begin
                result = 32'hDEADBEEF; // Invalid operation code
                flags  = 5'b11111;     // Invalid operation flag
            end
        endcase
    end

endmodule

module add_sub_unit (
    input  logic [31:0] a,     // Operand A
    input  logic [31:0] b,     // Operand B
    input  logic        op,    // Operation: 0 for add, 1 for sub
    output logic [31:0] result, // Result
    output logic [4:0]  flags  // Exception flags
);

    // Extract fields
    logic [7:0]  exp_a, exp_b;
    logic [22:0] frac_a, frac_b;
    logic        sign_a, sign_b;
    assign sign_a = a[31];
    assign sign_b = op ? ~b[31] : b[31]; // Negate sign of B for subtraction
    assign exp_a  = a[30:23];
    assign exp_b  = b[30:23];
    assign frac_a = {1'b1, a[22:0]};
    assign frac_b = {1'b1, b[22:0]};

    // Align the smaller exponent to the larger exponent
    logic [7:0]  exp_diff;
    logic [22:0] frac_b_aligned;
    assign exp_diff = exp_a > exp_b ? (exp_a - exp_b) : (exp_b - exp_a);
    assign frac_b_aligned = (exp_a > exp_b) ? frac_b >> exp_diff : frac_b << exp_diff;

    // Add/Subtract the fractions
    logic [23:0] frac_sum;
    assign frac_sum = exp_a > exp_b ? (frac_a + frac_b_aligned) : (frac_b + frac_b_aligned);

    // Normalize the result
    logic [7:0]  exp_res;
    logic [23:0] frac_res;
    always_comb begin
        if (frac_sum[23]) begin
            frac_res = frac_sum >> 1;
            exp_res  = exp_a > exp_b ? exp_a + 1 : exp_b + 1;
        end else begin
            frac_res = frac_sum;
            exp_res  = exp_a > exp_b ? exp_a : exp_b;
        end
    end

    // Pack the result
    assign result = {sign_a, exp_res, frac_res[22:0]};

    // Generate exception flags
    always_comb begin
        flags = 5'b0; // Clear all flags
        if (exp_res == 8'hFF) flags[0] = 1; // Overflow
        if (exp_res == 8'h00) flags[1] = 1; // Underflow
        if (frac_res == 23'b0) flags[2] = 1; // Zero
        if (a[30:23] == 8'hFF || b[30:23] == 8'hFF) flags[3] = 1; // NaN or Infinity
        if (exp_a == 8'hFF || exp_b == 8'hFF) flags[4] = 1; // Invalid operation
    end

endmodule

module mul_unit (
    input  logic [31:0] a,      // Operand A
    input  logic [31:0] b,      // Operand B
    output logic [31:0] result, // Result
    output logic [4:0]  flags   // Exception flags
);

    // Extract fields
    logic [7:0]  exp_a, exp_b;
    logic [22:0] frac_a, frac_b;
    logic        sign_a, sign_b;
    assign sign_a = a[31];
    assign sign_b = b[31];
    assign exp_a  = a[30:23];
    assign exp_b  = b[30:23];
    assign frac_a = {1'b1, a[22:0]};
    assign frac_b = {1'b1, b[22:0]};

    // Compute result sign
    logic sign_res;
    assign sign_res = sign_a ^ sign_b;

    // Compute result exponent
    logic [8:0] exp_res;
    assign exp_res = exp_a + exp_b - 127;

    // Compute result fraction
    logic [47:0] frac_res;
    assign frac_res = frac_a * frac_b;

    // Normalize the result
    logic [22:0] frac_norm;
    always_comb begin
        if (frac_res[47]) begin
            frac_norm = frac_res[46:24];
            exp_res = exp_res + 1;
        end else begin
            frac_norm = frac_res[45:23];
        end
    end

    // Pack the result
    assign result = {sign_res, exp_res[7:0], frac_norm};

    // Generate exception flags
    always_comb begin
        flags = 5'b0; // Clear all flags
        if (exp_res >= 255) flags[0] = 1; // Overflow
        if (exp_res == 0) flags[1] = 1; // Underflow
        if (frac_norm == 23'b0) flags[2] = 1; // Zero
        if (exp_a == 255 || exp_b == 255) flags[3] = 1; // NaN or Infinity
        if ((a[30:23] == 255 && a[22:0] != 0) || (b[30:23] == 255 && b[22:0] != 0)) flags[4] = 1; // Invalid operation
    end

endmodule

module div_unit (
    input  logic [31:0] a,      // Operand A
    input  logic [31:0] b,      // Operand B
    output logic [31:0] result, // Result
    output logic [4:0]  flags   // Exception flags
);

    // Extract fields
    logic [7:0]  exp_a, exp_b;
    logic [22:0] frac_a, frac_b;
    logic        sign_a, sign_b;
    assign sign_a = a[31];
    assign sign_b = b[31];
    assign exp_a  = a[30:23];
    assign exp_b  = b[30:23];
    assign frac_a = {1'b1, a[22:0]};
    assign frac_b = {1'b1, b[22:0]};

    // Compute result sign
    logic sign_res;
    assign sign_res = sign_a ^ sign_b;

    // Compute result exponent
    logic [8:0] exp_res;
    assign exp_res = exp_a - exp_b + 127;

    // Compute result fraction
    logic [47:0] frac_res;
    assign frac_res = (frac_a << 23) / frac_b;

    // Normalize the result
    logic [22:0] frac_norm;
    always_comb begin
        if (frac_res[47:24] != 0) begin
            frac_norm = frac_res[46:24];
            exp_res = exp_res + 1;
        end else begin
            frac_norm = frac_res[45:23];
        end
    end

    // Pack the result
    assign result = {sign_res, exp_res[7:0], frac_norm};

    // Generate exception flags
    always_comb begin
        flags = 5'b0; // Clear all flags
        if (exp_res >= 255) flags[0] = 1; // Overflow
        if (exp_res <= 0) flags[1] = 1; // Underflow
        if (frac_norm == 23'b0) flags[2] = 1; // Zero
        if (b[30:0] == 0) flags[3] = 1; // Divide by zero
        if ((a[30:23] == 255 && a[22:0] != 0) || (b[30:23] == 255 && b[22:0] != 0)) flags[4] = 1; // NaN or Infinity
    end

endmodule

module sqrt_unit (
    input  logic [31:0] a,      // Operand A
    output logic [31:0] result, // Result
    output logic [4:0]  flags   // Exception flags
);

    // Extract fields
    logic [7:0]  exp_a;
    logic [22:0] frac_a;
    logic        sign_a;
    assign sign_a = a[31];
    assign exp_a  = a[30:23];
    assign frac_a = {1'b1, a[22:0]};

    // Handle negative input
    logic sign_res;
    always_comb begin
        if (sign_a) begin
            sign_res = 1;
            result   = 32'h7FC00000; // NaN for negative input
            flags    = 5'b01000; // Set invalid operation flag
        end else begin
            sign_res = 0;
        end
    end

    // Compute exponent
    logic [8:0] exp_res;
    assign exp_res = (exp_a - 127) >> 1 + 127;

    // Compute fraction using Newton-Raphson method
    logic [23:0] frac_res;
    logic [23:0] x0, x1, half_a;
    assign half_a = {1'b0, frac_a[22:1]};
    assign x0 = 24'h400000; // Initial guess 0.5
    always_comb begin
        x1 = (x0 + (half_a / x0)) >> 1; // Update guess
    end
    assign frac_res = x1[22:0];

    // Pack the result
    assign result = {sign_res, exp_res[7:0], frac_res};

    // Generate exception flags
    always_comb begin
        flags = 5'b0; // Clear all flags
        if (exp_res >= 255) flags[0] = 1; // Overflow
        if (exp_res == 0) flags[1] = 1; // Underflow
        if (frac_res == 23'b0) flags[2] = 1; // Zero
        if (a[30:23] == 255 && a[22:0] != 0) flags[3] = 1; // NaN
    end

endmodule

module fmax_min_d (
    input logic [63:0] a,       // 64-bit double-precision input A
    input logic [63:0] b,       // 64-bit double-precision input B
    output logic [63:0] fmax,   // Result of fmax.d (max(a, b))
    output logic [63:0] fmin    // Result of fmin.d (min(a, b))
);
    // Fields for the inputs A and B
    wire sign_a, sign_b;
    wire [10:0] exponent_a, exponent_b;
    wire [51:0] mantissa_a, mantissa_b;

    // Extract fields from input A
    assign sign_a = a[63];
    assign exponent_a = a[62:52];
    assign mantissa_a = {1'b1, a[51:0]}; // 53 bits: 1 implicit + 52 actual mantissa

    // Extract fields from input B
    assign sign_b = b[63];
    assign exponent_b = b[62:52];
    assign mantissa_b = {1'b1, b[51:0]}; // 53 bits: 1 implicit + 52 actual mantissa

    // Define special cases
    wire is_nan_a, is_nan_b;
    wire is_inf_a, is_inf_b;
    wire is_zero_a, is_zero_b;

    assign is_nan_a = (exponent_a == 11'h7FF) && (mantissa_a != 52'h0);
    assign is_nan_b = (exponent_b == 11'h7FF) && (mantissa_b != 52'h0);
    assign is_inf_a = (exponent_a == 11'h7FF) && (mantissa_a == 52'h0);
    assign is_inf_b = (exponent_b == 11'h7FF) && (mantissa_b == 52'h0);
    assign is_zero_a = (exponent_a == 11'h0) && (mantissa_a == 52'h0);
    assign is_zero_b = (exponent_b == 11'h0) && (mantissa_b == 52'h0);

    // Function to compare two floating-point numbers
    function logic [63:0] select_max_min (
        input logic select_max,    // 1 for fmax.d, 0 for fmin.d
        input logic [63:0] a,      // Operand A
        input logic [63:0] b       // Operand B
    );
        if (is_nan_a && is_nan_b) begin
            select_max_min = 64'hx; // If both are NaN, result is NaN (undefined behavior)
        end else if (is_nan_a) begin
            select_max_min = b; // NaN is less than any valid number
        end else if (is_nan_b) begin
            select_max_min = a; // NaN is less than any valid number
        end else if (is_inf_a && is_inf_b) begin
            select_max_min = (sign_a == sign_b) ? a : (select_max ? a : b);
        end else if (is_inf_a) begin
            select_max_min = (sign_a == 1'b0) ? a : b; // Positive infinity is larger
        end else if (is_inf_b) begin
            select_max_min = (sign_b == 1'b0) ? b : a; // Positive infinity is larger
        end else if (is_zero_a && is_zero_b) begin
            select_max_min = (sign_a == sign_b) ? a : (select_max ? a : b); // Zero comparison based on sign
        end else begin
            // Normalized number comparison
            if (exponent_a > exponent_b) begin
                select_max_min = a;
            end else if (exponent_b > exponent_a) begin
                select_max_min = b;
            end else begin
                // Exponent are the same, compare mantissas
                if (mantissa_a > mantissa_b) begin
                    select_max_min = a;
                end else if (mantissa_b > mantissa_a) begin
                    select_max_min = b;
                end else begin
                    // If both exponents and mantissas are equal, return based on sign for fmin/fmax
                    select_max_min = (select_max == 1'b1) ? a : b;
                end
            end
        end
    endfunction

    // Compute the fmax and fmin
    always_comb begin
        fmax = select_max_min(1'b1, a, b);  // fmax.d -> Select max value
        fmin = select_max_min(1'b0, a, b);  // fmin.d -> Select min value
    end

endmodule

module fmax_min_s (
    input logic [31:0] a,       // 32-bit single-precision input A
    input logic [31:0] b,       // 32-bit single-precision input B
    output logic [31:0] fmax,   // Result of fmax.s (max(a, b))
    output logic [31:0] fmin    // Result of fmin.s (min(a, b))
);
    // Fields for the inputs A and B
    wire sign_a, sign_b;
    wire [7:0] exponent_a, exponent_b;
    wire [22:0] mantissa_a, mantissa_b;

    // Extract fields from input A
    assign sign_a = a[31];
    assign exponent_a = a[30:23];
    assign mantissa_a = a[22:0];

    // Extract fields from input B
    assign sign_b = b[31];
    assign exponent_b = b[30:23];
    assign mantissa_b = b[22:0];

    // Define special cases
    wire is_nan_a, is_nan_b;
    wire is_inf_a, is_inf_b;
    wire is_zero_a, is_zero_b;

    assign is_nan_a = (exponent_a == 8'hFF) && (mantissa_a != 23'h0);
    assign is_nan_b = (exponent_b == 8'hFF) && (mantissa_b != 23'h0);
    assign is_inf_a = (exponent_a == 8'hFF) && (mantissa_a == 23'h0);
    assign is_inf_b = (exponent_b == 8'hFF) && (mantissa_b == 23'h0);
    assign is_zero_a = (exponent_a == 8'h00) && (mantissa_a == 23'h0);
    assign is_zero_b = (exponent_b == 8'h00) && (mantissa_b == 23'h0);

    // Function to compare two floating-point numbers
    function logic [31:0] select_max_min (
        input logic select_max,    // 1 for fmax.s, 0 for fmin.s
        input logic [31:0] a,      // Operand A
        input logic [31:0] b       // Operand B
    );
        if (is_nan_a && is_nan_b) begin
            select_max_min = 32'hx; // If both are NaN, result is NaN (undefined behavior)
        end else if (is_nan_a) begin
            select_max_min = b; // NaN is less than any valid number
        end else if (is_nan_b) begin
            select_max_min = a; // NaN is less than any valid number
        end else if (is_inf_a && is_inf_b) begin
            select_max_min = (sign_a == sign_b) ? a : (select_max ? a : b);
        end else if (is_inf_a) begin
            select_max_min = (sign_a == 1'b0) ? a : b; // Positive infinity is larger
        end else if (is_inf_b) begin
            select_max_min = (sign_b == 1'b0) ? b : a; // Positive infinity is larger
        end else if (is_zero_a && is_zero_b) begin
            select_max_min = (sign_a == sign_b) ? a : (select_max ? a : b); // Zero comparison based on sign
        end else begin
            // Normalized number comparison
            if (exponent_a > exponent_b) begin
                select_max_min = a;
            end else if (exponent_b > exponent_a) begin
                select_max_min = b;
            end else begin
                // Exponent are the same, compare mantissas
                if (mantissa_a > mantissa_b) begin
                    select_max_min = a;
                end else if (mantissa_b > mantissa_a) begin
                    select_max_min = b;
                end else begin
                    // If both exponents and mantissas are equal, return based on sign for fmin/fmax
                    select_max_min = (select_max == 1'b1) ? a : b;
                end
            end
        end
    endfunction

    // Compute the fmax and fmin
    always_comb begin
        fmax = select_max_min(1'b1, a, b);  // fmax.s -> Select max value
        fmin = select_max_min(1'b0, a, b);  // fmin.s -> Select min value
    end

endmodule

module fcvt_d_s (
    input logic [31:0] single_in,     // 32-bit single-precision input
    input logic [1:0] rounding_mode,  // Rounding mode: 2-bit input (00=round_nearest, 01=round_zero, 10=round_pos_inf, 11=round_neg_inf)
    output logic [63:0] double_out    // 64-bit double-precision output
);
    // Single-precision fields
    wire [22:0] mantissa_s;           // 23-bit mantissa (including implicit bit)
    wire [7:0] exponent_s;            // 8-bit exponent
    wire sign_s;                      // 1-bit sign
    
    // Double-precision fields
    wire [51:0] mantissa_d;           // 52-bit mantissa (including implicit bit)
    wire [10:0] exponent_d;           // 11-bit exponent
    wire sign_d;                      // 1-bit sign

    // Extract fields from single-precision input
    assign sign_s = single_in[31];    // Extract sign bit of single-precision
    assign exponent_s = single_in[30:23]; // Extract exponent (8 bits)
    assign mantissa_s = {1'b1, single_in[22:0]}; // 24-bit mantissa with implicit bit

    // Intermediate signals for conversion
    logic [10:0] exponent_d_temp;
    logic [51:0] mantissa_d_temp;
    logic [51:0] mantissa_d_rounded;  // Rounding result
    logic rounding_bit, sticky_bit;   // For rounding decision

    // Rounding logic
    always_comb begin
        // Default values
        mantissa_d_rounded = mantissa_d_temp;
        rounding_bit = mantissa_s[23]; // Bit that decides rounding (next bit after the 23-bit mantissa)
        sticky_bit = |mantissa_s[22:0]; // If any of the lower bits are non-zero, sticky_bit will be 1

        // Round the mantissa based on the rounding mode
        case (rounding_mode)
            2'b00: begin // Round to nearest, ties to even
                if (rounding_bit && (sticky_bit || mantissa_s[23])) begin
                    mantissa_d_rounded = mantissa_d_temp + 1;
                end
            end
            2'b01: begin // Round toward zero (truncate)
                // Simply truncate, no rounding
                mantissa_d_rounded = mantissa_d_temp;
            end
            2'b10: begin // Round toward positive infinity
                if (rounding_bit || sticky_bit) begin
                    mantissa_d_rounded = mantissa_d_temp + 1;
                end
            end
            2'b11: begin // Round toward negative infinity
                if (rounding_bit || sticky_bit) begin
                    mantissa_d_rounded = mantissa_d_temp - 1;
                end
            end
        endcase
    end

    always_comb begin
        if (exponent_s == 8'hFF) begin
            // Handle special cases: Inf or NaN
            if (mantissa_s != 0) begin
                double_out = {sign_s, 11'h7FF, 52'hFFFFFFFFFFFFF}; // NaN (simplified)
            end else begin
                double_out = {sign_s, 11'h7FF, 52'h0000000000000}; // Inf
            end
        end else if (exponent_s == 8'h00) begin
            // Handle zero or denormalized numbers
            double_out = {sign_s, 11'h000, 52'h0000000000000}; // Zero or Denorm
        end else begin
            // Normalized number conversion
            exponent_d_temp = exponent_s - 8'h7F + 11'h3FF; // Adjust exponent for double-precision
            mantissa_d_temp = {mantissa_s, 29'h0}; // Zero-extend mantissa for double-precision

            // Apply rounding if necessary
            double_out = {sign_s, exponent_d_temp, mantissa_d_rounded};
        end
    end
endmodule

module fcvt_s_d (
    input logic [63:0] double_in,        // 64-bit double-precision input
    input logic [1:0] rounding_mode,     // Rounding mode: 2-bit input (00=round_nearest, 01=round_zero, 10=round_pos_inf, 11=round_neg_inf)
    output logic [31:0] single_out       // 32-bit single-precision output
);

    // Double-precision fields
    wire [51:0] mantissa_d;              // 52-bit mantissa (including implicit bit)
    wire [10:0] exponent_d;              // 11-bit exponent
    wire sign_d;                         // 1-bit sign
    
    // Single-precision fields
    wire [22:0] mantissa_s;              // 23-bit mantissa (including implicit bit)
    wire [7:0] exponent_s;               // 8-bit exponent
    wire sign_s;                         // 1-bit sign

    // Extract fields from double-precision input
    assign sign_d = double_in[63];       // Extract sign bit of double-precision
    assign exponent_d = double_in[62:52]; // Extract exponent (11 bits)
    assign mantissa_d = {1'b1, double_in[51:0]}; // 52-bit mantissa with implicit bit

    // Intermediate signals for conversion
    logic [7:0] exponent_s_temp;
    logic [22:0] mantissa_s_temp;
    logic [22:0] mantissa_s_rounded;    // Rounding result
    logic rounding_bit, sticky_bit;     // For rounding decision

    // Rounding logic
    always_comb begin
        // Default values
        mantissa_s_rounded = mantissa_s_temp;
        rounding_bit = mantissa_d[27]; // Bit that decides rounding (next bit after the 23-bit mantissa)
        sticky_bit = |mantissa_d[26:0]; // If any of the lower bits are non-zero, sticky_bit will be 1

        // Round the mantissa based on the rounding mode
        case (rounding_mode)
            2'b00: begin // Round to nearest, ties to even
                if (rounding_bit && (sticky_bit || mantissa_d[27])) begin
                    mantissa_s_rounded = mantissa_s_temp + 1;
                end
            end
            2'b01: begin // Round toward zero (truncate)
                // Simply truncate, no rounding
                mantissa_s_rounded = mantissa_s_temp;
            end
            2'b10: begin // Round toward positive infinity
                if (rounding_bit || sticky_bit) begin
                    mantissa_s_rounded = mantissa_s_temp + 1;
                end
            end
            2'b11: begin // Round toward negative infinity
                if (rounding_bit || sticky_bit) begin
                    mantissa_s_rounded = mantissa_s_temp - 1;
                end
            end
        endcase
    end

    always_comb begin
        if (exponent_d == 11'b11111111111) begin
            // Handle special cases: Inf or NaN
            if (mantissa_d != 0) begin
                single_out = {sign_d, 8'hFF, 23'h7FFFFF}; // NaN (simplified)
            end else begin
                single_out = {sign_d, 8'hFF, 23'h000000}; // Inf
            end
        end else if (exponent_d < 1023) begin
            // Handle denormalized or zero
            if (exponent_d == 0 && mantissa_d == 0) begin
                single_out = {sign_d, 8'h00, 23'h000000}; // Zero
            end else begin
                // Denormalized number: For simplicity, we assume denormalized results are zero
                exponent_s_temp = 8'h00;
                mantissa_s_temp = 23'h000000;
                single_out = {sign_d, exponent_s_temp, mantissa_s_temp};
            end
        end else begin
            // Normalized number conversion
            exponent_s_temp = exponent_d[10:3] - 8'h3F; // Adjust exponent for single-precision
            mantissa_s_temp = mantissa_d[50:28]; // Truncate mantissa to 23 bits for single-precision

            // Apply rounding if necessary
            single_out = {sign_d, exponent_s_temp, mantissa_s_rounded};
        end
    end
endmodule

module fcvt_and_fmv (
    input logic [31:0] src,       // Source operand (32-bit single-precision or integer)
    input logic signed_op,        // Flag to indicate if the source is signed (for fcvt.s.w, fcvt.s.wu)
    input logic [1:0] rounding_mode, // Rounding mode (00 = round_nearest, 01 = round_zero, etc.)
    output logic [31:0] dst,      // Destination operand (converted value)
    output logic valid            // Valid output signal
);

    // Convert single-precision to signed integer (fcvt.w.s)
    function logic [31:0] fcvt_w_s(input logic [31:0] f);
        logic sign;
        logic [7:0] exponent;
        logic [22:0] mantissa;
        logic [31:0] result;

        sign = f[31];
        exponent = f[30:23];
        mantissa = f[22:0];

        // If the exponent is too small or too large to represent as an integer, return 0
        if (exponent < 8'h7F) begin
            result = 0;  // Underflow or too small for conversion
        end else if (exponent > 8'h9F) begin
            result = (sign ? 32'h80000000 : 32'h7FFFFFFF);  // Overflow to min or max signed integer
        end else begin
            result = {sign, mantissa, 8'h00}; // Normal conversion, rounding is applied here
        end
        return result;
    endfunction

    // Convert single-precision to unsigned integer (fcvt.wu.s)
    function logic [31:0] fcvt_wu_s(input logic [31:0] f);
        logic sign;
        logic [7:0] exponent;
        logic [22:0] mantissa;
        logic [31:0] result;

        sign = f[31];
        exponent = f[30:23];
        mantissa = f[22:0];

        // If the exponent is too small or too large, return 0
        if (exponent < 8'h7F) begin
            result = 0;  // Underflow or too small for conversion
        end else if (exponent > 8'h9F) begin
            result = 32'hFFFFFFFF;  // Overflow to max unsigned integer
        end else begin
            result = {1'b0, mantissa, 8'h00};  // Normal conversion, rounding applied here
        end
        return result;
    endfunction

    // Convert signed integer to single-precision (fcvt.s.w)
    function logic [31:0] fcvt_s_w(input logic signed [31:0] i);
        logic [31:0] result;

        // If the input integer is too large to fit in single-precision, return the largest single-precision number
        if (i > 32'h7F800000) begin
            result = 32'h7F800000; // Infinity
        end else if (i < -32'h7F800000) begin
            result = 32'hFF800000; // Negative infinity
        end else begin
            result = {1'b0, 8'h7F, i[22:0]}; // Normal conversion
        end
        return result;
    endfunction

    // Convert unsigned integer to single-precision (fcvt.s.wu)
    function logic [31:0] fcvt_s_wu(input logic [31:0] i);
        logic [31:0] result;

        // If the input unsigned integer is too large to fit in single-precision, return the largest single-precision number
        if (i > 32'h7F800000) begin
            result = 32'h7F800000; // Infinity
        end else begin
            result = {1'b0, 8'h7F, i[22:0]}; // Normal conversion
        end
        return result;
    endfunction

    // Move 32-bit integer to floating-point (fmv.w.x)
    function logic [31:0] fmv_w_x(input logic [31:0] i);
        logic [31:0] result;
        result = {1'b0, 8'h7F, i[22:0]};  // Move the integer value into a floating-point register
        return result;
    endfunction

    // Move 32-bit floating-point to integer (fmv.x.w)
    function logic [31:0] fmv_x_w(input logic [31:0] f);
        logic [31:0] result;
        result = f[31:0];  // Move the floating-point value directly to integer register
        return result;
    endfunction

    // Process each instruction based on the selected operation
    always_comb begin
        valid = 1'b1;
        case (1'b1)  // Switch-case for each function based on the operation
            signed_op == 1'b1: begin
                case (rounding_mode)
                    2'b00: dst = fcvt_w_s(src);  // fcvt.w.s
                    2'b01: dst = fcvt_wu_s(src);  // fcvt.wu.s
                    default: valid = 1'b0;  // Invalid rounding mode for this conversion
                endcase
            end
            signed_op == 1'b0: begin
                case (rounding_mode)
                    2'b00: dst = fcvt_s_w(src);  // fcvt.s.w
                    2'b01: dst = fcvt_s_wu(src);  // fcvt.s.wu
                    default: valid = 1'b0;  // Invalid rounding mode for this conversion
                endcase
            end
            default: dst = fmv_x_w(src);  // fmv.x.w or fmv.w.x
        endcase
    end
endmodule

module fsgnj_fsgnjn_fsgnjx (
    input logic [31:0] rs1,       // First source operand (32-bit single-precision)
    input logic [31:0] rs2,       // Second source operand (32-bit single-precision)
    output logic [31:0] result    // Result of the operation
);

    // Extract the sign bit of rs1 and rs2
    wire sign_rs1, sign_rs2;
    wire [30:0] abs_rs1;   // Absolute value of rs1 (clear the sign bit)
    wire [30:0] abs_rs2;   // Absolute value of rs2 (clear the sign bit)

    // Extracting the sign bit (bit 31 is the sign bit)
    assign sign_rs1 = rs1[31];
    assign sign_rs2 = rs2[31];

    // Absolute value (clear the sign bit)
    assign abs_rs1 = rs1[30:0];  // If sign is 1, abs is the same (no sign change needed)
    assign abs_rs2 = rs2[30:0];  // If sign is 1, abs is the same (no sign change needed)

    // fsgnj.s: Result = |rs1| with sign of rs2
    wire [31:0] fsgnj_result;
    assign fsgnj_result = {sign_rs2, abs_rs1};  // Replace sign of rs1 with sign of rs2

    // fsgnjn.s: Result = |rs1| with negated sign of rs2
    wire [31:0] fsgnjn_result;
    assign fsgnjn_result = {~sign_rs2, abs_rs1}; // Replace sign of rs1 with negated sign of rs2

    // fsgnjx.s: Result = |rs1| with XOR of signs of rs1 and rs2
    wire [31:0] fsgnjx_result;
    assign fsgnjx_result = {sign_rs1 ^ sign_rs2, abs_rs1}; // XOR signs and use abs(rs1)

    // Default operation logic (this can be extended for selecting the specific operation)
    always_comb begin
        // For the sake of this example, we choose the `fsgnj.s` operation:
        result = fsgnj_result;  // You can select fsgnj_result, fsgnjn_result, or fsgnjx_result as needed
    end

endmodule

module feq_flt_fle (
    input logic [31:0] rs1,      // First source operand (32-bit single-precision)
    input logic [31:0] rs2,      // Second source operand (32-bit single-precision)
    output logic result          // Result of the comparison (1 if true, 0 if false)
);

    // Extract sign, exponent, and mantissa of both rs1 and rs2
    wire sign_rs1, sign_rs2;
    wire [7:0] exponent_rs1, exponent_rs2;
    wire [22:0] mantissa_rs1, mantissa_rs2;
    wire is_nan_rs1, is_nan_rs2;

    // Decompose rs1 and rs2 into sign, exponent, and mantissa
    assign sign_rs1 = rs1[31];
    assign sign_rs2 = rs2[31];
    assign exponent_rs1 = rs1[30:23];
    assign exponent_rs2 = rs2[30:23];
    assign mantissa_rs1 = rs1[22:0];
    assign mantissa_rs2 = rs2[22:0];

    // Check for NaN: NaN has an exponent of all 1's and a non-zero mantissa
    assign is_nan_rs1 = (exponent_rs1 == 8'hFF) && (mantissa_rs1 != 23'h0);
    assign is_nan_rs2 = (exponent_rs2 == 8'hFF) && (mantissa_rs2 != 23'h0);

    // feq.s (Floating-Point Equal): Return true if rs1 == rs2, handling NaN correctly
    always_comb begin
        if (is_nan_rs1 || is_nan_rs2) begin
            result = 0;  // NaN is not equal to anything
        end else begin
            result = (rs1 == rs2);  // Compare the raw bitwise values of rs1 and rs2
        end
    end

    // flt.s (Floating-Point Less Than): Return true if rs1 < rs2, handling NaN correctly
    always_comb begin
        if (is_nan_rs1 || is_nan_rs2) begin
            result = 0;  // NaN is unordered with any number
        end else begin
            result = (rs1 < rs2);  // Compare the raw bitwise values of rs1 and rs2
        end
    end

    // fle.s (Floating-Point Less Than or Equal): Return true if rs1 <= rs2, handling NaN correctly
    always_comb begin
        if (is_nan_rs1 || is_nan_rs2) begin
            result = 0;  // NaN is unordered with any number
        end else begin
            result = (rs1 <= rs2);  // Compare the raw bitwise values of rs1 and rs2
        end
    end

endmodule

module fclass_s (
    input logic [31:0] rs1,       // 32-bit single-precision floating-point input
    output logic [31:0] result    // 32-bit bitmask representing the classification
);

    // Extract sign, exponent, and mantissa
    wire sign;
    wire [7:0] exponent;
    wire [22:0] mantissa;
    wire is_zero, is_subnormal, is_normal, is_infinity, is_nan;
    
    // Decompose the single-precision floating-point number
    assign sign = rs1[31];
    assign exponent = rs1[30:23];
    assign mantissa = rs1[22:0];

    // Classify zero (positive or negative zero)
    assign is_zero = (exponent == 8'h00) && (mantissa == 23'h000000);

    // Classify subnormal (exponent == 0 and non-zero mantissa)
    assign is_subnormal = (exponent == 8'h00) && (mantissa != 23'h000000);

    // Classify normal numbers (exponent between 1 and 254)
    assign is_normal = (exponent != 8'h00) && (exponent != 8'hFF);

    // Classify infinity (exponent == 0xFF and mantissa == 0)
    assign is_infinity = (exponent == 8'hFF) && (mantissa == 23'h000000);

    // Classify NaN (exponent == 0xFF and non-zero mantissa)
    assign is_nan = (exponent == 8'hFF) && (mantissa != 23'h000000);

    // Generate the classification result bitmask
    always_comb begin
        result = 32'b0;  // Initialize result to 0
        
        // Set the appropriate bit based on classification
        if (is_zero) begin
            if (sign) 
                result[5] = 1;  // Negative Zero
            else 
                result[4] = 1;  // Positive Zero
        end else if (is_subnormal) begin
            if (sign) 
                result[3] = 1;  // Negative Subnormal
            else 
                result[2] = 1;  // Positive Subnormal
        end else if (is_normal) begin
            if (sign) 
                result[1] = 1;  // Negative Normal
            else 
                result[0] = 1;  // Positive Normal
        end else if (is_infinity) begin
            if (sign) 
                result[7] = 1;  // Negative Infinity
            else 
                result[6] = 1;  // Positive Infinity
        end else if (is_nan) begin
            result[8] = 1;  // Quiet NaN (can be extended to handle signaling NaN if needed)
        end
    end

endmodule

module fadd_fsub_s (
    input logic [31:0] rs1,       // First floating-point operand (32-bit single-precision)
    input logic [31:0] rs2,       // Second floating-point operand (32-bit single-precision)
    input logic add_sub,          // Control signal: 1 for addition, 0 for subtraction
    output logic [31:0] result,   // Result of addition or subtraction (32-bit single-precision)
    output logic exception        // Exception flag (NaN, Inf, etc.)
);

    // Extract sign, exponent, and mantissa for both operands
    wire sign1, sign2;
    wire [7:0] exp1, exp2;
    wire [22:0] frac1, frac2;
    wire [23:0] frac1_normalized, frac2_normalized;
    
    // Decompose rs1 and rs2 into sign, exponent, and mantissa
    assign sign1 = rs1[31];
    assign sign2 = rs2[31];
    assign exp1 = rs1[30:23];
    assign exp2 = rs2[30:23];
    assign frac1 = {1'b1, rs1[22:0]}; // Adding leading 1 for normalized number
    assign frac2 = {1'b1, rs2[22:0]}; // Adding leading 1 for normalized number

    // Handle the case when exponent is all 0 (subnormal numbers)
    assign frac1_normalized = (exp1 == 8'h00) ? {1'b0, rs1[22:0]} : frac1; // For subnormal numbers, no leading 1
    assign frac2_normalized = (exp2 == 8'h00) ? {1'b0, rs2[22:0]} : frac2;

    // Align the exponents
    wire [7:0] exp_diff;
    wire [23:0] frac1_shifted, frac2_shifted;

    assign exp_diff = (exp1 > exp2) ? (exp1 - exp2) : (exp2 - exp1);
    
    // Shift the fraction to align exponents
    assign frac1_shifted = (exp1 > exp2) ? (frac1_normalized >> exp_diff) : frac1_normalized;
    assign frac2_shifted = (exp1 > exp2) ? frac2_normalized : (frac2_normalized >> exp_diff);

    // Perform addition or subtraction on the mantissas (depending on the add_sub control signal)
    wire [24:0] frac_result;
    assign frac_result = (add_sub == 1) ? (frac1_shifted + frac2_shifted) : (frac1_shifted - frac2_shifted);

    // Normalize the result
    wire [7:0] exp_result;
    wire [22:0] frac_result_normalized;
    wire result_overflow;

    assign result_overflow = frac_result[24]; // Check for overflow (if the MSB is set)
    
    // If overflow, shift the result to normalize
    assign frac_result_normalized = result_overflow ? frac_result[23:1] : frac_result[22:0];
    assign exp_result = result_overflow ? (exp_diff + 1) : exp_diff;

    // Handle special cases
    always_comb begin
        exception = 0; // Clear exception flag
        if ((exp1 == 8'hFF && frac1 != 23'h0) || (exp2 == 8'hFF && frac2 != 23'h0)) begin
            exception = 1; // NaN handling
            result = 32'h7FC00000; // Quiet NaN
        end else if ((exp1 == 8'hFF && frac1 == 23'h0) || (exp2 == 8'hFF && frac2 == 23'h0)) begin
            result = (exp1 == 8'hFF) ? rs1 : rs2; // Infinity handling
        end else if (frac_result_normalized == 0) begin
            result = {sign1 ^ sign2, 8'h00, 23'h0}; // Zero result
        end else begin
            // Normalized or subnormal result
            result = {sign1 ^ sign2, exp_result, frac_result_normalized};
        end
    end

endmodule

module fmul_fdiv_s (
    input logic [31:0] rs1,       // First floating-point operand (32-bit single-precision)
    input logic [31:0] rs2,       // Second floating-point operand (32-bit single-precision)
    input logic mul_div,          // Control signal: 1 for multiplication, 0 for division
    output logic [31:0] result,   // Result of multiplication or division (32-bit single-precision)
    output logic exception        // Exception flag (NaN, Inf, Zero, etc.)
);

    // Extract sign, exponent, and mantissa for both operands
    wire sign1, sign2;
    wire [7:0] exp1, exp2;
    wire [22:0] frac1, frac2;
    wire [23:0] frac1_normalized, frac2_normalized;
    
    // Decompose rs1 and rs2 into sign, exponent, and mantissa
    assign sign1 = rs1[31];
    assign sign2 = rs2[31];
    assign exp1 = rs1[30:23];
    assign exp2 = rs2[30:23];
    assign frac1 = {1'b1, rs1[22:0]}; // Adding leading 1 for normalized number
    assign frac2 = {1'b1, rs2[22:0]}; // Adding leading 1 for normalized number

    // Handle the case when exponent is all 0 (subnormal numbers)
    assign frac1_normalized = (exp1 == 8'h00) ? {1'b0, rs1[22:0]} : frac1; // For subnormal numbers, no leading 1
    assign frac2_normalized = (exp2 == 8'h00) ? {1'b0, rs2[22:0]} : frac2;

    // Perform multiplication or division
    wire [47:0] frac_result; // 48-bit intermediate result for multiplication or division
    wire [7:0] exp_result;

    if (mul_div) begin
        // Multiplication: (A * B) = (sign1 * sign2) * (frac1 * frac2) * 2^(exp1 + exp2 - 127)
        assign frac_result = frac1_normalized * frac2_normalized;
        assign exp_result = exp1 + exp2 - 8'h7F; // Adjust exponents for multiplication
    end else begin
        // Division: (A / B) = (sign1 * sign2) * (frac1 / frac2) * 2^(exp1 - exp2)
        assign frac_result = frac1_normalized / frac2_normalized;
        assign exp_result = exp1 - exp2 + 8'h7F; // Adjust exponents for division
    end

    // Normalize the result (if necessary)
    wire [22:0] frac_result_normalized;
    wire result_overflow;

    assign result_overflow = frac_result[47]; // Check for overflow (if the MSB is set)

    // Normalize the result and handle overflow
    assign frac_result_normalized = result_overflow ? frac_result[46:24] : frac_result[45:23];
    assign exp_result = result_overflow ? (exp_result + 1) : exp_result;

    // Handle special cases (NaN, Infinity, Zero, etc.)
    always_comb begin
        exception = 0; // Clear exception flag
        if ((exp1 == 8'hFF && frac1 != 23'h0) || (exp2 == 8'hFF && frac2 != 23'h0)) begin
            exception = 1; // NaN handling
            result = 32'h7FC00000; // Quiet NaN
        end else if ((exp1 == 8'hFF && frac1 == 23'h0) || (exp2 == 8'hFF && frac2 == 23'h0)) begin
            result = (exp1 == 8'hFF) ? rs1 : rs2; // Infinity handling
        end else if (frac_result_normalized == 0) begin
            result = {sign1 ^ sign2, 8'h00, 23'h0}; // Zero result
        end else begin
            // Normalized or subnormal result
            result = {sign1 ^ sign2, exp_result, frac_result_normalized};
        end
    end

endmodule

module fma_operations_s (
    input logic [31:0] rs1,        // First floating-point operand (32-bit single-precision)
    input logic [31:0] rs2,        // Second floating-point operand (32-bit single-precision)
    input logic [31:0] rs3,        // Third floating-point operand (32-bit single-precision)
    input logic [1:0] operation,   // Operation control: 0 for fmadd, 1 for fmsub, 2 for fnmadd, 3 for fnsub
    output logic [31:0] result,    // Result of the operation (32-bit single-precision)
    output logic exception         // Exception flag (NaN, Inf, Zero, etc.)
);

    // Extract sign, exponent, and mantissa for all operands
    wire sign1, sign2, sign3;
    wire [7:0] exp1, exp2, exp3;
    wire [22:0] frac1, frac2, frac3;
    wire [23:0] frac1_normalized, frac2_normalized, frac3_normalized;
    
    // Decompose rs1, rs2, and rs3 into sign, exponent, and mantissa
    assign sign1 = rs1[31];
    assign sign2 = rs2[31];
    assign sign3 = rs3[31];
    assign exp1 = rs1[30:23];
    assign exp2 = rs2[30:23];
    assign exp3 = rs3[30:23];
    assign frac1 = {1'b1, rs1[22:0]}; // Adding leading 1 for normalized number
    assign frac2 = {1'b1, rs2[22:0]}; // Adding leading 1 for normalized number
    assign frac3 = {1'b1, rs3[22:0]}; // Adding leading 1 for normalized number

    // Handle the case when exponent is all 0 (subnormal numbers)
    assign frac1_normalized = (exp1 == 8'h00) ? {1'b0, rs1[22:0]} : frac1; // For subnormal numbers, no leading 1
    assign frac2_normalized = (exp2 == 8'h00) ? {1'b0, rs2[22:0]} : frac2;
    assign frac3_normalized = (exp3 == 8'h00) ? {1'b0, rs3[22:0]} : frac3;

    // Perform the fused multiply and add/subtract based on the operation control
    wire [47:0] frac_mul_result;    // 48-bit intermediate result of multiplication
    wire [7:0] exp_mul_result;

    // Compute the product of rs1 and rs2
    assign frac_mul_result = frac1_normalized * frac2_normalized;
    assign exp_mul_result = exp1 + exp2 - 8'h7F; // Adjust exponents for multiplication

    // Perform the final operation (add or subtract with rs3)
    wire [47:0] frac_final_result;
    wire [7:0] exp_final_result;
    wire [22:0] frac_result_normalized;

    // Depending on the operation control, perform the necessary addition or subtraction
    always_comb begin
        case (operation)
            2'b00: begin // fmadd: (rs1 * rs2) + rs3
                frac_final_result = frac_mul_result + {1'b1, frac3_normalized};
                exp_final_result = exp_mul_result;
            end
            2'b01: begin // fmsub: (rs1 * rs2) - rs3
                frac_final_result = frac_mul_result - {1'b1, frac3_normalized};
                exp_final_result = exp_mul_result;
            end
            2'b10: begin // fnmadd: -(rs1 * rs2) + rs3
                frac_final_result = -(frac_mul_result) + {1'b1, frac3_normalized};
                exp_final_result = exp_mul_result;
            end
            2'b11: begin // fnsub: -(rs1 * rs2) - rs3
                frac_final_result = -(frac_mul_result) - {1'b1, frac3_normalized};
                exp_final_result = exp_mul_result;
            end
            default: begin
                frac_final_result = 0;
                exp_final_result = 0;
            end
        endcase
    end

    // Normalize the result
    wire result_overflow;
    assign result_overflow = frac_final_result[47]; // Check for overflow

    // Normalize the result and handle overflow
    assign frac_result_normalized = result_overflow ? frac_final_result[46:24] : frac_final_result[45:23];

    // Handle special cases (NaN, Infinity, Zero, etc.)
    always_comb begin
        exception = 0; // Clear exception flag
        if ((exp1 == 8'hFF && frac1 != 23'h0) || (exp2 == 8'hFF && frac2 != 23'h0) || (exp3 == 8'hFF && frac3 != 23'h0)) begin
            exception = 1; // NaN handling
            result = 32'h7FC00000; // Quiet NaN
        end else if ((exp1 == 8'hFF && frac1 == 23'h0) || (exp2 == 8'hFF && frac2 == 23'h0) || (exp3 == 8'hFF && frac3 == 23'h0)) begin
            result = (exp1 == 8'hFF) ? rs1 : (exp2 == 8'hFF) ? rs2 : rs3; // Infinity handling
        end else if (frac_result_normalized == 0) begin
            result = {sign1 ^ sign2 ^ sign3, 8'h00, 23'h0}; // Zero result
        end else begin
            // Normalized or subnormal result
            result = {sign1 ^ sign2 ^ sign3, exp_final_result, frac_result_normalized};
        end
    end

endmodule

module test_fneg_fabs;

    reg [31:0] rs1;
    wire [31:0] result_fneg;
    wire [31:0] result_fabs;

    // Instantiate the fneg.s and fabs.s modules
    fneg_s fneg_inst (
        .rs1(rs1),
        .result(result_fneg)
    );

    fabs_s fabs_inst (
        .rs1(rs1),
        .result(result_fabs)
    );

    initial begin
        // Test 1: fneg.s (Negate a positive number)
        rs1 = 32'h3F800000;  // 1.0 in IEEE 754 single-precision
        #10;
        $display("fneg.s(1.0) = 0x%h (Expected: 0xBF800000)", result_fneg); // -1.0 in IEEE 754
        
        // Test 2: fabs.s (Absolute value of a negative number)
        rs1 = 32'hBF800000;  // -1.0 in IEEE 754
        #10;
        $display("fabs.s(-1.0) = 0x%h (Expected: 0x3F800000)", result_fabs); // 1.0 in IEEE 754
        
        // Test 3: fneg.s (Negate zero)
        rs1 = 32'h00000000;  // +0.0 in IEEE 754
        #10;
        $display("fneg.s(+0.0) = 0x%h (Expected: 0x80000000)", result_fneg); // -0.0 in IEEE 754
        
        // Test 4: fabs.s (Absolute value of zero)
        rs1 = 32'h80000000;  // -0.0 in IEEE 754
        #10;
        $display("fabs.s(-0.0) = 0x%h (Expected: 0x00000000)", result_fabs); // +0.0 in IEEE 754
        
        // Test 5: fneg.s (Negate a subnormal number)
        rs1 = 32'h00000001;  // Smallest positive subnormal number in IEEE 754
        #10;
        $display("fneg.s(subnormal) = 0x%h (Expected: 0x80000001)", result_fneg); // Negative subnormal
        
        // Test 6: fabs.s (Absolute value of a subnormal number)
        rs1 = 32'h80000001;  // Negative smallest subnormal number in IEEE 754
        #10;
        $display("fabs.s(subnormal) = 0x%h (Expected: 0x00000001)", result_fabs); // Positive subnormal
    end

endmodule

module check_exceptions (
    input logic [31:0] rs1,        // First floating-point number
    input logic [31:0] rs2,        // Second floating-point number
    input logic [31:0] rs3,        // Third floating-point number
    output logic [2:0] exception_1, // Exception flags for rs1 (NaN, Zero, Infinity)
    output logic [2:0] exception_2, // Exception flags for rs2 (NaN, Zero, Infinity)
    output logic [2:0] exception_3  // Exception flags for rs3 (NaN, Zero, Infinity)
);

    // Flags for NaN, Zero, Infinity:
    // exception[2] -> NaN flag
    // exception[1] -> Zero flag
    // exception[0] -> Infinity flag
    
    // Extract exponent and fraction (mantissa) from floating-point numbers
    wire [7:0] exp1, exp2, exp3;
    wire [22:0] frac1, frac2, frac3;
    
    assign exp1 = rs1[30:23];
    assign frac1 = rs1[22:0];
    
    assign exp2 = rs2[30:23];
    assign frac2 = rs2[22:0];
    
    assign exp3 = rs3[30:23];
    assign frac3 = rs3[22:0];

    // Check for NaN, Zero, Infinity for each input number
    always_comb begin
        // Check rs1 (First input)
        if (exp1 == 8'hFF && frac1 != 23'h0) begin
            exception_1 = 3'b100; // NaN
        end else if (exp1 == 8'h00 && frac1 == 23'h0) begin
            exception_1 = 3'b010; // Zero
        end else if (exp1 == 8'hFF && frac1 == 23'h0) begin
            exception_1 = 3'b001; // Infinity
        end else begin
            exception_1 = 3'b000; // Normal number
        end
        
        // Check rs2 (Second input)
        if (exp2 == 8'hFF && frac2 != 23'h0) begin
            exception_2 = 3'b100; // NaN
        end else if (exp2 == 8'h00 && frac2 == 23'h0) begin
            exception_2 = 3'b010; // Zero
        end else if (exp2 == 8'hFF && frac2 == 23'h0) begin
            exception_2 = 3'b001; // Infinity
        end else begin
            exception_2 = 3'b000; // Normal number
        end
        
        // Check rs3 (Third input)
        if (exp3 == 8'hFF && frac3 != 23'h0) begin
            exception_3 = 3'b100; // NaN
        end else if (exp3 == 8'h00 && frac3 == 23'h0) begin
            exception_3 = 3'b010; // Zero
        end else if (exp3 == 8'hFF && frac3 == 23'h0) begin
            exception_3 = 3'b001; // Infinity
        end else begin
            exception_3 = 3'b000; // Normal number
        end
    end

endmodule

module fadd_d (
    input logic [63:0] rs1,        // First 64-bit double-precision floating-point operand
    input logic [63:0] rs2,        // Second 64-bit double-precision floating-point operand
    output logic [63:0] result     // Resulting 64-bit double-precision floating-point result
);

    // Extract sign, exponent, and fraction from the double-precision numbers
    wire [10:0] exp1, exp2;        // 11-bit exponent
    wire [51:0] frac1, frac2;      // 52-bit mantissa
    wire sign1, sign2;             // Sign bits (1 bit each)

    assign sign1 = rs1[63];
    assign exp1 = rs1[62:52];
    assign frac1 = {1'b1, rs1[51:0]};  // Implicit leading 1 in normalized numbers

    assign sign2 = rs2[63];
    assign exp2 = rs2[62:52];
    assign frac2 = {1'b1, rs2[51:0]};  // Implicit leading 1 in normalized numbers

    // Normalize exponents
    wire [10:0] exp_diff = (exp1 > exp2) ? exp1 - exp2 : exp2 - exp1;

    // Align the fractions (shift the smaller fraction)
    wire [51:0] aligned_frac1, aligned_frac2;
    assign aligned_frac1 = (exp1 >= exp2) ? frac1 : frac1 >> exp_diff;
    assign aligned_frac2 = (exp1 < exp2) ? frac2 : frac2 >> exp_diff;

    // Perform addition or subtraction depending on the signs
    wire [52:0] sum_frac;
    wire result_sign;
    if (sign1 == sign2) begin
        // Same sign -> add the mantissas
        sum_frac = aligned_frac1 + aligned_frac2;
        result_sign = sign1;
    end else begin
        // Different sign -> subtract the mantissas
        sum_frac = aligned_frac1 - aligned_frac2;
        if (aligned_frac1 >= aligned_frac2)
            result_sign = sign1;
        else
            result_sign = sign2;
    end

    // Normalize the result and handle exponent overflow/underflow
    wire [10:0] result_exp;
    wire [51:0] normalized_frac;
    if (sum_frac[52]) begin
        // If there is a carry from the mantissa addition, normalize the result
        result_exp = (exp1 > exp2) ? exp1 + 1 : exp2 + 1;
        normalized_frac = sum_frac[51:0];
    end else begin
        // Otherwise, shift the result fraction
        result_exp = (exp1 > exp2) ? exp1 : exp2;
        normalized_frac = sum_frac[51:0] >> 1;
    end

    // Combine the sign, exponent, and fraction into the final result
    assign result = {result_sign, result_exp, normalized_frac};

endmodule

module fsub_d (
    input logic [63:0] rs1,        // First 64-bit double-precision floating-point operand
    input logic [63:0] rs2,        // Second 64-bit double-precision floating-point operand
    output logic [63:0] result     // Resulting 64-bit double-precision floating-point result
);

    // Extract sign, exponent, and fraction from the double-precision numbers
    wire [10:0] exp1, exp2;        // 11-bit exponent
    wire [51:0] frac1, frac2;      // 52-bit mantissa
    wire sign1, sign2;             // Sign bits (1 bit each)

    assign sign1 = rs1[63];
    assign exp1 = rs1[62:52];
    assign frac1 = {1'b1, rs1[51:0]};  // Implicit leading 1 in normalized numbers

    assign sign2 = rs2[63];
    assign exp2 = rs2[62:52];
    assign frac2 = {1'b1, rs2[51:0]};  // Implicit leading 1 in normalized numbers

    // Normalize exponents
    wire [10:0] exp_diff = (exp1 > exp2) ? exp1 - exp2 : exp2 - exp1;

    // Align the fractions (shift the smaller fraction)
    wire [51:0] aligned_frac1, aligned_frac2;
    assign aligned_frac1 = (exp1 >= exp2) ? frac1 : frac1 >> exp_diff;
    assign aligned_frac2 = (exp1 < exp2) ? frac2 : frac2 >> exp_diff;

    // Perform subtraction: Flip the second sign and add
    wire [52:0] diff_frac;
    wire result_sign;
    if (sign1 == sign2) begin
        // Same sign -> subtract the mantissas
        diff_frac = aligned_frac1 - aligned_frac2;
        if (aligned_frac1 >= aligned_frac2)
            result_sign = sign1;
        else
            result_sign = sign2;
    end else begin
        // Different signs -> add the mantissas
        diff_frac = aligned_frac1 + aligned_frac2;
        result_sign = sign1; // Subtracting a negative is like adding a positive
    end

    // Normalize the result and handle exponent overflow/underflow
    wire [10:0] result_exp;
    wire [51:0] normalized_frac;
    if (diff_frac[52]) begin
        // If there is a carry from the mantissa subtraction, normalize the result
        result_exp = (exp1 > exp2) ? exp1 + 1 : exp2 + 1;
        normalized_frac = diff_frac[51:0];
    end else begin
        // Otherwise, shift the result fraction
        result_exp = (exp1 > exp2) ? exp1 : exp2;
        normalized_frac = diff_frac[51:0] >> 1;
    end

    // Combine the sign, exponent, and fraction into the final result
    assign result = {result_sign, result_exp, normalized_frac};

endmodule

module fmul_d (
    input logic [63:0] rs1,        // First 64-bit double-precision floating-point operand
    input logic [63:0] rs2,        // Second 64-bit double-precision floating-point operand
    output logic [63:0] result     // Resulting 64-bit double-precision floating-point result
);

    // Extract sign, exponent, and fraction from the double-precision numbers
    wire sign1, sign2;             // Sign bits (1 bit each)
    wire [10:0] exp1, exp2;        // 11-bit exponent
    wire [51:0] frac1, frac2;      // 52-bit mantissa

    assign sign1 = rs1[63];
    assign exp1 = rs1[62:52];
    assign frac1 = {1'b1, rs1[51:0]};  // Implicit leading 1 in normalized numbers

    assign sign2 = rs2[63];
    assign exp2 = rs2[62:52];
    assign frac2 = {1'b1, rs2[51:0]};  // Implicit leading 1 in normalized numbers

    // Result sign: XOR the signs of the operands
    wire result_sign = sign1 ^ sign2;

    // Multiply the mantissas (52 bits each, result could be up to 104 bits)
    wire [103:0] product_frac = frac1 * frac2;

    // Add the exponents and subtract the bias (1023 for double precision)
    wire [10:0] result_exp = exp1 + exp2 - 11'h3FF;  // 1023 (bias)

    // Normalize the result: if the product has a leading 1, shift it right
    wire [52:0] normalized_frac;
    wire [10:0] normalized_exp;
    if (product_frac[103]) begin
        // If there is an implicit carry from the multiplication, shift the fraction
        normalized_exp = result_exp + 1;
        normalized_frac = product_frac[102:51]; // Take the 52 most significant bits
    end else begin
        // If no carry, shift the fraction to normalize
        normalized_exp = result_exp;
        normalized_frac = product_frac[101:50]; // Shift to get 52 significant bits
    end

    // Handle special cases (NaN, Infinity, Zero)
    always_comb begin
        if (exp1 == 11'hFF || exp2 == 11'hFF) begin
            // If either operand is NaN or Infinity, the result is NaN (if not both infinite)
            if (exp1 == 11'hFF && frac1 != 52'h0) begin
                result = {1'b1, 11'hFF, 52'h0}; // NaN
            end else if (exp2 == 11'hFF && frac2 != 52'h0) begin
                result = {1'b1, 11'hFF, 52'h0}; // NaN
            end else begin
                result = {result_sign, 11'hFF, 52'h0}; // Infinity
            end
        end else if (exp1 == 11'h0 || exp2 == 11'h0) begin
            // If either operand is zero, the result is zero
            result = {1'b0, 11'h0, 52'h0}; // Zero
        end else begin
            // Normal case: combine sign, exponent, and fraction
            result = {result_sign, normalized_exp, normalized_frac};
        end
    end

endmodule

module fdiv_d (
    input logic [63:0] rs1,        // First 64-bit double-precision floating-point operand
    input logic [63:0] rs2,        // Second 64-bit double-precision floating-point operand
    output logic [63:0] result     // Resulting 64-bit double-precision floating-point result
);

    // Extract sign, exponent, and fraction from the double-precision numbers
    wire sign1, sign2;             // Sign bits (1 bit each)
    wire [10:0] exp1, exp2;        // 11-bit exponent
    wire [51:0] frac1, frac2;      // 52-bit mantissa

    assign sign1 = rs1[63];
    assign exp1 = rs1[62:52];
    assign frac1 = {1'b1, rs1[51:0]};  // Implicit leading 1 in normalized numbers

    assign sign2 = rs2[63];
    assign exp2 = rs2[62:52];
    assign frac2 = {1'b1, rs2[51:0]};  // Implicit leading 1 in normalized numbers

    // Result sign: XOR the signs of the operands
    wire result_sign = sign1 ^ sign2;

    // Divide the mantissas (52 bits each, result could be up to 104 bits)
    wire [103:0] quotient_frac;
    assign quotient_frac = {1'b0, frac1} / frac2;

    // Subtract the exponents and add the bias (1023 for double precision)
    wire [10:0] result_exp = exp1 - exp2 + 11'h3FF;  // 1023 (bias)

    // Normalize the result: if the quotient has a leading 1, shift it right
    wire [52:0] normalized_frac;
    wire [10:0] normalized_exp;
    if (quotient_frac[103]) begin
        // If there is a carry from the division, shift the fraction
        normalized_exp = result_exp + 1;
        normalized_frac = quotient_frac[102:51]; // Take the 52 most significant bits
    end else begin
        // If no carry, shift the fraction to normalize
        normalized_exp = result_exp;
        normalized_frac = quotient_frac[101:50]; // Shift to get 52 significant bits
    end

    // Handle special cases (NaN, Infinity, Zero)
    always_comb begin
        if (exp1 == 11'hFF || exp2 == 11'hFF) begin
            // If either operand is NaN or Infinity, the result is NaN (if not both infinite)
            if (exp1 == 11'hFF && frac1 != 52'h0) begin
                result = {1'b1, 11'hFF, 52'h0}; // NaN
            end else if (exp2 == 11'hFF && frac2 != 52'h0) begin
                result = {1'b1, 11'hFF, 52'h0}; // NaN
            end else begin
                result = {result_sign, 11'hFF, 52'h0}; // Infinity
            end
        end else if (exp2 == 11'h0 || frac2 == 52'h0) begin
            // If the divisor is zero, the result is Infinity (or NaN if dividend is zero)
            if (exp1 == 11'h0 && frac1 == 52'h0) begin
                result = {1'b1, 11'hFF, 52'h0}; // NaN
            end else begin
                result = {result_sign, 11'hFF, 52'h0}; // Infinity
            end
        end else if (exp1 == 11'h0 || frac1 == 52'h0) begin
            // If the dividend is zero, the result is zero
            result = {1'b0, 11'h0, 52'h0}; // Zero
        end else begin
            // Normal case: combine sign, exponent, and fraction
            result = {result_sign, normalized_exp, normalized_frac};
        end
    end

endmodule

module fmin_d (
    input logic [63:0] rs1,        // First 64-bit double-precision floating-point operand
    input logic [63:0] rs2,        // Second 64-bit double-precision floating-point operand
    output logic [63:0] result     // Resulting 64-bit double-precision floating-point result
);

    // Extract sign, exponent, and fraction from the double-precision numbers
    wire sign1, sign2;             // Sign bits (1 bit each)
    wire [10:0] exp1, exp2;        // 11-bit exponent
    wire [51:0] frac1, frac2;      // 52-bit mantissa

    assign sign1 = rs1[63];
    assign exp1 = rs1[62:52];
    assign frac1 = {1'b1, rs1[51:0]};  // Implicit leading 1 in normalized numbers

    assign sign2 = rs2[63];
    assign exp2 = rs2[62:52];
    assign frac2 = {1'b1, rs2[51:0]};  // Implicit leading 1 in normalized numbers

    // Handle NaN
    always_comb begin
        if (exp1 == 11'hFF && frac1 != 52'h0) begin
            result = rs2;  // If rs1 is NaN, return rs2
        end else if (exp2 == 11'hFF && frac2 != 52'h0) begin
            result = rs1;  // If rs2 is NaN, return rs1
        end else if (exp1 == 11'hFF) begin
            result = rs1;  // If rs1 is Infinity, return rs1 (Infinity is always "greater")
        end else if (exp2 == 11'hFF) begin
            result = rs2;  // If rs2 is Infinity, return rs2 (Infinity is always "greater")
        end else if (exp1 == 11'h0 && frac1 == 52'h0) begin
            result = rs2;  // If rs1 is Zero, return rs2 (Zero is always "smaller")
        end else if (exp2 == 11'h0 && frac2 == 52'h0) begin
            result = rs1;  // If rs2 is Zero, return rs1 (Zero is always "smaller")
        end else begin
            // If both are valid numbers, compare their magnitudes
            if (exp1 < exp2 || (exp1 == exp2 && frac1 < frac2)) begin
                result = rs1;  // rs1 is smaller
            end else begin
                result = rs2;  // rs2 is smaller
            end
        end
    end

endmodule


module fmax_d (
    input logic [63:0] rs1,        // First 64-bit double-precision floating-point operand
    input logic [63:0] rs2,        // Second 64-bit double-precision floating-point operand
    output logic [63:0] result     // Resulting 64-bit double-precision floating-point result
);

    // Extract sign, exponent, and fraction from the double-precision numbers
    wire sign1, sign2;             // Sign bits (1 bit each)
    wire [10:0] exp1, exp2;        // 11-bit exponent
    wire [51:0] frac1, frac2;      // 52-bit mantissa

    assign sign1 = rs1[63];
    assign exp1 = rs1[62:52];
    assign frac1 = {1'b1, rs1[51:0]};  // Implicit leading 1 in normalized numbers

    assign sign2 = rs2[63];
    assign exp2 = rs2[62:52];
    assign frac2 = {1'b1, rs2[51:0]};  // Implicit leading 1 in normalized numbers

    // Handle NaN
    always_comb begin
        if (exp1 == 11'hFF && frac1 != 52'h0) begin
            result = rs2;  // If rs1 is NaN, return rs2
        end else if (exp2 == 11'hFF && frac2 != 52'h0) begin
            result = rs1;  // If rs2 is NaN, return rs1
        end else if (exp1 == 11'hFF) begin
            result = rs1;  // If rs1 is Infinity, return rs1 (Infinity is always "greater")
        end else if (exp2 == 11'hFF) begin
            result = rs2;  // If rs2 is Infinity, return rs2 (Infinity is always "greater")
        end else if (exp1 == 11'h0 && frac1 == 52'h0) begin
            result = rs2;  // If rs1 is Zero, return rs2 (Zero is always "smaller")
        end else if (exp2 == 11'h0 && frac2 == 52'h0) begin
            result = rs1;  // If rs2 is Zero, return rs1 (Zero is always "smaller")
        end else begin
            // If both are valid numbers, compare their magnitudes
            if (exp1 > exp2 || (exp1 == exp2 && frac1 > frac2)) begin
                result = rs1;  // rs1 is larger
            end else begin
                result = rs2;  // rs2 is larger
            end
        end
    end

endmodule

module fsqrt_d (
    input logic [63:0] rs1,        // 64-bit double-precision floating-point operand
    output logic [63:0] result     // Resulting 64-bit double-precision floating-point result
);

    // Extract sign, exponent, and fraction from the double-precision number
    wire sign;                     // Sign bit (1 bit)
    wire [10:0] exp;               // 11-bit exponent
    wire [51:0] frac;              // 52-bit mantissa

    assign sign = rs1[63];
    assign exp = rs1[62:52];
    assign frac = {1'b1, rs1[51:0]};  // Implicit leading 1 for normalized numbers

    // Handle special cases (NaN, negative, zero, infinity)
    always_comb begin
        if (exp == 11'hFF && frac != 52'h0) begin
            // If operand is NaN, return NaN
            result = {1'b1, 11'hFF, 52'h0}; // NaN
        end else if (exp == 11'hFF && frac == 52'h0) begin
            // If operand is +Infinity, return +Infinity
            result = {1'b0, 11'hFF, 52'h0}; // +Infinity
        end else if (exp == 11'h0 && frac == 52'h0) begin
            // If operand is zero, return zero
            result = {1'b0, 11'h0, 52'h0}; // Zero
        end else if (sign == 1'b1) begin
            // If operand is negative, return NaN (square root of negative number is not defined)
            result = {1'b1, 11'hFF, 52'h0}; // NaN
        end else begin
            // For positive numbers, calculate the square root
            // Extract exponent and mantissa, calculate sqrt
            wire [10:0] result_exp;
            wire [51:0] result_frac;

            // Calculate exponent of the result: (exp - bias) / 2
            result_exp = exp - 11'h3FF; // Remove the bias
            result_exp = result_exp >> 1; // Divide by 2 (square root of exponent)

            // Calculate the square root of the fraction (mantissa)
            wire [51:0] sqrt_frac;
            sqrt_frac = sqrt(frac);

            // Normalize result if necessary
            if (sqrt_frac[51] == 1'b1) begin
                result_exp = result_exp + 1;
                result_frac = sqrt_frac[51:0];
            end else begin
                result_frac = sqrt_frac[50:0]; // Shift the fraction to normalize
            end

            // Return the result
            result = {sign, result_exp, result_frac};
        end
    end

    // Function for calculating square root of mantissa (stub)
    function [51:0] sqrt(input [51:0] frac);
        begin
            // This is a simplified placeholder for square root calculation of mantissa
            // In reality, you would need a more complex implementation, possibly using an approximation method.
            sqrt = frac;  // Placeholder: actual square root calculation needed here
        end
    endfunction

endmodule

module fused_mul_add_sub (
    input logic [63:0] rs1,        // First operand (64-bit double-precision)
    input logic [63:0] rs2,        // Second operand (64-bit double-precision)
    input logic [63:0] rs3,        // Third operand (64-bit double-precision)
    input logic [1:0] control,     // 2-bit control input to select the operation
    output logic [63:0] result     // Result (64-bit double-precision)
);

    // Extract sign, exponent, and fraction from the operands
    wire sign1, sign2, sign3;
    wire [10:0] exp1, exp2, exp3;
    wire [51:0] frac1, frac2, frac3;

    assign sign1 = rs1[63];
    assign exp1 = rs1[62:52];
    assign frac1 = {1'b1, rs1[51:0]};  // Implicit leading 1 for normalized numbers

    assign sign2 = rs2[63];
    assign exp2 = rs2[62:52];
    assign frac2 = {1'b1, rs2[51:0]};  // Implicit leading 1 for normalized numbers

    assign sign3 = rs3[63];
    assign exp3 = rs3[62:52];
    assign frac3 = {1'b1, rs3[51:0]};  // Implicit leading 1 for normalized numbers

    // Intermediate signals for product and sum
    wire [103:0] prod_frac;        // Product of fractions (A * B)
    wire [21:0] prod_exp;          // Exponent of the product
    wire [103:0] sum_frac;         // Sum or difference (A * B) +/- C
    wire [21:0] sum_exp;           // Exponent of the sum

    // Calculate product of the fractions
    assign prod_frac = frac1 * frac2;
    assign prod_exp = exp1 + exp2 - 11'h3FF;  // Add exponents and adjust bias

    // Calculate sum or difference (depending on the control signal)
    always_comb begin
        case (control)
            2'b00: begin
                // FMADD: (A * B) + C
                sum_frac = prod_frac + frac3;
                sum_exp = prod_exp;
            end
            2'b01: begin
                // FMSUB: (A * B) - C
                sum_frac = prod_frac - frac3;
                sum_exp = prod_exp;
            end
            2'b10: begin
                // FNMADD: -(A * B) - C
                sum_frac = -(prod_frac + frac3);
                sum_exp = prod_exp;
            end
            2'b11: begin
                // FNMSUB: -(A * B) + C
                sum_frac = -(prod_frac - frac3);
                sum_exp = prod_exp;
            end
            default: begin
                // Default to FMADD if invalid control signal
                sum_frac = prod_frac + frac3;
                sum_exp = prod_exp;
            end
        endcase
    end

    // Handle special cases (NaN, Infinity, Zero, etc.)
    always_comb begin
        if (exp1 == 11'hFF || exp2 == 11'hFF || exp3 == 11'hFF) begin
            // If any operand is NaN or Infinity, return NaN
            result = {1'b1, 11'hFF, 52'h0};  // NaN
        end else begin
            // Normalize and assemble result
            result = {sign1, sum_exp[20:10], sum_frac[51:0]};  // Assemble the result
        end
    end

endmodule

module fcvt_converter (
    input logic [63:0] f_input,  // Input (64-bit double-precision float)
    input logic [31:0] i_input,  // Input (32-bit integer)
    input logic [1:0] control,   // Control signal to select the operation
    input logic sign_mode,       // Sign mode (0: signed, 1: unsigned)
    output logic [31:0] i_output,  // Output (32-bit integer)
    output logic [63:0] f_output   // Output (64-bit double-precision float)
);

    // Convert double-precision to signed 32-bit integer (FCVT.W.D)
    function logic [31:0] fcvt_w_d(input [63:0] f);
        real f_real;
        begin
            f_real = $bitstoreal(f); // Convert to real (double-precision)
            fcvt_w_d = $rtoi(f_real); // Convert to signed 32-bit integer
        end
    endfunction

    // Convert double-precision to unsigned 32-bit integer (FCVT.WU.D)
    function logic [31:0] fcvt_wu_d(input [63:0] f);
        real f_real;
        begin
            f_real = $bitstoreal(f); // Convert to real (double-precision)
            fcvt_wu_d = $urtoi(f_real); // Convert to unsigned 32-bit integer
        end
    endfunction

    // Convert signed 32-bit integer to double-precision float (FCVT.D.W)
    function logic [63:0] fcvt_d_w(input [31:0] i);
        real i_real;
        begin
            i_real = $itor(i); // Convert to real (double-precision)
            fcvt_d_w = $realtobits(i_real); // Convert to double-precision
        end
    endfunction

    // Convert unsigned 32-bit integer to double-precision float (FCVT.D.WU)
    function logic [63:0] fcvt_d_wu(input [31:0] i);
        real i_real;
        begin
            i_real = $itor(i); // Convert to real (double-precision)
            fcvt_d_wu = $realtobits(i_real); // Convert to double-precision
        end
    endfunction

    // Move integer to double-precision float (FMV.X.D)
    function logic [63:0] fmv_x_d(input [31:0] i);
        begin
            fmv_x_d = $realtobits($itor(i)); // Convert integer to double-precision
        end
    endfunction

    // Move double-precision float to integer (FMV.D.X)
    function logic [31:0] fmv_d_x(input [63:0] f);
        real f_real;
        begin
            f_real = $bitstoreal(f); // Convert double-precision to real
            fmv_d_x = $rtoi(f_real); // Convert to signed 32-bit integer
        end
    endfunction

    // Main operation logic based on control signals
    always_comb begin
        case (control)
            2'b00: begin // FCVT.W.D (signed)
                if (sign_mode == 0)
                    i_output = fcvt_w_d(f_input);  // Signed conversion
                else
                    i_output = fcvt_wu_d(f_input); // Unsigned conversion
                f_output = 64'h0;  // No floating-point output for this operation
            end
            2'b01: begin // FCVT.WU.D (unsigned)
                if (sign_mode == 0)
                    i_output = fcvt_w_d(f_input);  // Signed conversion
                else
                    i_output = fcvt_wu_d(f_input); // Unsigned conversion
                f_output = 64'h0;  // No floating-point output for this operation
            end
            2'b10: begin // FCVT.D.W (signed)
                f_output = fcvt_d_w(i_input);  // Signed integer to double-precision
                i_output = 32'h0;  // No integer output for this operation
            end
            2'b11: begin // FCVT.D.WU (unsigned)
                f_output = fcvt_d_wu(i_input); // Unsigned integer to double-precision
                i_output = 32'h0;  // No integer output for this operation
            end
            default: begin
                i_output = 32'h0; // Default value
                f_output = 64'h0; // Default value
            end
        endcase
    end
endmodule

module fsgnj_converter (
    input logic [63:0] src1,   // First operand (64-bit double-precision float)
    input logic [63:0] src2,   // Second operand (64-bit double-precision float)
    input logic [1:0] control, // 2-bit control signal to select operation
    output logic [63:0] dest   // Destination result (64-bit double-precision float)
);

    // Extract the sign, exponent, and fraction from the operands
    wire sign1, sign2;
    wire [10:0] exp1, exp2;
    wire [51:0] frac1, frac2;

    assign sign1 = src1[63];  // Sign of src1
    assign exp1 = src1[62:52]; // Exponent of src1
    assign frac1 = {1'b1, src1[51:0]}; // Fraction of src1 (normalized)
    
    assign sign2 = src2[63];  // Sign of src2
    assign exp2 = src2[62:52]; // Exponent of src2
    assign frac2 = {1'b1, src2[51:0]}; // Fraction of src2 (normalized)

    // Intermediate result for the destination
    wire [63:0] abs_frac2;  // Absolute value of the fraction of src2
    assign abs_frac2 = {1'b0, frac2[51:0]};  // Absolute value (sign removed)

    always_comb begin
        case (control)
            2'b00: begin // fsgnj.d: Copy sign from src1, magnitude from src2
                dest = {sign1, exp2, abs_frac2[51:0]};  // Sign from src1, magnitude from src2
            end
            2'b01: begin // fsgnjn.d: Copy negated sign from src1, magnitude from src2
                dest = {~sign1, exp2, abs_frac2[51:0]};  // Negated sign from src1, magnitude from src2
            end
            2'b10: begin // fsgnjx.d: XOR signs of src1 and src2, magnitude from src2
                dest = {sign1 ^ sign2, exp2, abs_frac2[51:0]};  // XOR of signs, magnitude from src2
            end
            default: begin
                dest = 64'h0; // Default value in case of invalid control signal
            end
        endcase
    end

endmodule

module floating_point_comparator (
    input logic [63:0] src1,     // First operand (64-bit double-precision float)
    input logic [63:0] src2,     // Second operand (64-bit double-precision float)
    input logic [1:0] control,   // 2-bit control signal to select comparison operation
    output logic dest            // Comparison result (1 if true, 0 if false)
);

    // Convert double-precision to real numbers for comparison
    real real_src1, real_src2;
    
    // Convert the 64-bit floating-point inputs to real numbers
    always_comb begin
        real_src1 = $bitstoreal(src1); // Convert src1 to real (double-precision)
        real_src2 = $bitstoreal(src2); // Convert src2 to real (double-precision)
    end

    // Compare based on the control signal
    always_comb begin
        case (control)
            2'b00: begin // feq.d: Compare if src1 == src2
                dest = (real_src1 == real_src2);  // True if equal
            end
            2'b01: begin // flt.d: Compare if src1 < src2
                dest = (real_src1 < real_src2);  // True if src1 is less than src2
            end
            2'b10: begin // fle.d: Compare if src1 <= src2
                dest = (real_src1 <= real_src2);  // True if src1 is less than or equal to src2
            end
            default: begin
                dest = 1'b0;  // Default value (false) for invalid control signal
            end
        endcase
    end

endmodule

module fclass_d (
    input logic [63:0] src,       // 64-bit double-precision floating point number
    output logic [31:0] result    // 32-bit result, bitmask for classification
);

    // Extract the components of the double-precision floating point number
    wire sign;
    wire [10:0] exponent;
    wire [51:0] fraction;
    
    assign sign = src[63];       // Sign bit
    assign exponent = src[62:52]; // Exponent (11 bits)
    assign fraction = src[51:0]; // Fraction (52 bits)

    // Classification logic
    always_comb begin
        // Initialize result to 0
        result = 32'b0;

        // Check for Zero
        if (exponent == 11'b0 && fraction == 52'b0) begin
            result[0] = 1; // Zero is classified as zero
        end
        // Check for Subnormal (Denormalized)
        else if (exponent == 11'b0 && fraction != 52'b0) begin
            result[1] = 1; // Subnormal (denormalized) number
        end
        // Check for Normal numbers
        else if (exponent != 11'b0 && exponent != 11'h7FF) begin
            result[2] = 1; // Normal number
        end
        // Check for Infinity (positive or negative)
        else if (exponent == 11'h7FF && fraction == 52'b0) begin
            if (sign == 0) begin
                result[3] = 1; // Positive infinity
            end else begin
                result[4] = 1; // Negative infinity
            end
        end
        // Check for NaN (Not a Number)
        else if (exponent == 11'h7FF && fraction != 52'b0) begin
            if (fraction[51]) begin
                result[5] = 1; // Quiet NaN (qNaN)
            end else begin
                result[6] = 1; // Signaling NaN (sNaN)
            end
        end
    end

endmodule

module check_double_precision (
    input logic [63:0] num1,  // First 64-bit double-precision input
    input logic [63:0] num2,  // Second 64-bit double-precision input
    input logic [63:0] num3,  // Third 64-bit double-precision input
    output logic [3:0] is_zero,     // Output 3-bit vector: zero checks for num1, num2, num3
    output logic [3:0] is_nan,      // Output 3-bit vector: NaN checks for num1, num2, num3
    output logic [3:0] is_infinity  // Output 3-bit vector: infinity checks for num1, num2, num3
);

    // Internal wires to extract the exponent and fraction from double-precision number
    wire [10:0] exp1, exp2, exp3;   // 11-bit exponent
    wire [51:0] frac1, frac2, frac3; // 52-bit fraction

    // Extracting the components of the 64-bit double-precision numbers
    assign exp1 = num1[62:52];  // Exponent of num1
    assign frac1 = num1[51:0];  // Fraction of num1
    
    assign exp2 = num2[62:52];  // Exponent of num2
    assign frac2 = num2[51:0];  // Fraction of num2
    
    assign exp3 = num3[62:52];  // Exponent of num3
    assign frac3 = num3[51:0];  // Fraction of num3

    // Checking if each number is zero, NaN, or infinity
    always_comb begin
        // Initialize outputs
        is_zero = 3'b0;
        is_nan = 3'b0;
        is_infinity = 3'b0;

        // Check for zero: exponent = 0 and fraction = 0
        if (exp1 == 11'b0 && frac1 == 52'b0)
            is_zero[0] = 1;
        if (exp2 == 11'b0 && frac2 == 52'b0)
            is_zero[1] = 1;
        if (exp3 == 11'b0 && frac3 == 52'b0)
            is_zero[2] = 1;

        // Check for NaN: exponent = 11'b11111111111 (all ones) and fraction != 0
        if (exp1 == 11'h7FF && frac1 != 52'b0)
            is_nan[0] = 1;
        if (exp2 == 11'h7FF && frac2 != 52'b0)
            is_nan[1] = 1;
        if (exp3 == 11'h7FF && frac3 != 52'b0)
            is_nan[2] = 1;

        // Check for infinity: exponent = 11'b11111111111 (all ones) and fraction = 0
        if (exp1 == 11'h7FF && frac1 == 52'b0)
            is_infinity[0] = 1;
        if (exp2 == 11'h7FF && frac2 == 52'b0)
            is_infinity[1] = 1;
        if (exp3 == 11'h7FF && frac3 == 52'b0)
            is_infinity[2] = 1;
    end

endmodule

module fpu_inverse (
    input logic [31:0] in,    // Input: 32-bit single precision float
    output logic [31:0] out   // Output: 32-bit single precision float (1 / in)
);

    // Internal signals to hold the input and output components
    logic sign_in, sign_out;
    logic [7:0] exp_in, exp_out;
    logic [22:0] mantissa_in, mantissa_out;
    logic [31:0] result;

    // Constants for handling special cases
    parameter EXPT_BIAS = 127;   // Bias for single-precision exponent
    parameter EXP_INF = 255;     // Exponent for infinity (255 in IEEE 754 single-precision)
    parameter EXP_ZERO = 0;      // Exponent for zero (0 in IEEE 754 single-precision)

    always_comb begin
        // Extract the components of the input floating-point number
        sign_in = in[31];                   // Sign bit
        exp_in = in[30:23];                 // Exponent (8 bits)
        mantissa_in = {1'b1, in[22:0]};    // Mantissa (with implicit leading 1 for normalized numbers)

        // Default output for special cases (e.g., zero, infinity, or NaN)
        if (exp_in == EXP_ZERO) begin
            // Case 1: input is zero (1 / 0 is infinity)
            sign_out = sign_in;    // Same sign as the input (negative or positive infinity)
            exp_out = EXP_INF;
            mantissa_out = 23'b0;  // Mantissa for infinity is always 0
        end else if (exp_in == EXP_INF) begin
            // Case 2: input is infinity (1 / infinity is zero)
            sign_out = sign_in;    // Same sign as input (positive or negative zero)
            exp_out = EXP_ZERO;
            mantissa_out = 23'b0;  // Mantissa for zero is always 0
        end else if (in[30:0] == 31'b0) begin
            // Case 3: input is NaN (1 / NaN is NaN)
            out = in;
        end else begin
            // Case 4: Normal case (non-zero, non-infinity, non-NaN)
            // Calculate the exponent for the result
            exp_out = EXP_INF - exp_in; // Inverse exponent: 255 - exponent of the input

            // Inverse the mantissa by taking the reciprocal of the input mantissa
            // This involves calculating the reciprocal of the mantissa and adjusting the exponent accordingly
            // Inverting the mantissa requires division, which we approximate here using an adjustment
            // This is just an approximation; actual FPU hardware uses more sophisticated methods
            mantissa_out = 23'b1_00000000000000000000000; // Placeholder for actual mantissa inversion
            sign_out = sign_in;  // Maintain the same sign as the input number

            // Combine the sign, exponent, and mantissa to get the final result
            result = {sign_out, exp_out, mantissa_out}; 
        end

        // Assign the result to the output
        out = result;
    end
endmodule

module fpu_inverse_double (
    input logic [63:0] in,    // Input: 64-bit double precision float
    output logic [63:0] out   // Output: 64-bit double precision float (1 / in)
);

    // Internal signals to hold the input and output components
    logic sign_in, sign_out;
    logic [10:0] exp_in, exp_out;
    logic [51:0] mantissa_in, mantissa_out;
    logic [63:0] result;

    // Constants for handling special cases
    parameter EXPT_BIAS = 1023;   // Bias for double-precision exponent
    parameter EXP_INF = 2047;     // Exponent for infinity (2047 in IEEE 754 double-precision)
    parameter EXP_ZERO = 0;       // Exponent for zero (0 in IEEE 754 double-precision)

    always_comb begin
        // Extract the components of the input floating-point number
        sign_in = in[63];                   // Sign bit
        exp_in = in[62:52];                 // Exponent (11 bits)
        mantissa_in = {1'b1, in[51:0]};    // Mantissa (with implicit leading 1 for normalized numbers)

        // Default output for special cases (e.g., zero, infinity, or NaN)
        if (exp_in == EXP_ZERO) begin
            // Case 1: input is zero (1 / 0 is infinity)
            sign_out = sign_in;    // Same sign as the input (negative or positive infinity)
            exp_out = EXP_INF;
            mantissa_out = 52'b0;  // Mantissa for infinity is always 0
        end else if (exp_in == EXP_INF) begin
            // Case 2: input is infinity (1 / infinity is zero)
            sign_out = sign_in;    // Same sign as input (positive or negative zero)
            exp_out = EXP_ZERO;
            mantissa_out = 52'b0;  // Mantissa for zero is always 0
        end else if (in[62:0] == 63'b0) begin
            // Case 3: input is NaN (1 / NaN is NaN)
            out = in;
        end else begin
            // Case 4: Normal case (non-zero, non-infinity, non-NaN)
            // Calculate the exponent for the result
            exp_out = EXP_INF - exp_in; // Inverse exponent: 2047 - exponent of the input

            // Inverse the mantissa by taking the reciprocal of the input mantissa
            // This involves calculating the reciprocal of the mantissa and adjusting the exponent accordingly
            // This is just an approximation; actual FPU hardware uses more sophisticated methods
            mantissa_out = 52'b1_000000000000000000000000000000000000000000000000; // Placeholder for actual mantissa inversion
            sign_out = sign_in;  // Maintain the same sign as the input number

            // Combine the sign, exponent, and mantissa to get the final result
            result = {sign_out, exp_out, mantissa_out}; 
        end

        // Assign the result to the output
        out = result;
    end
endmodule

module fpu_trigonometric (
    input logic [31:0] in,       // Input: Single precision float (angle in radians)
    input logic [1:0] op_select, // Control signal (00: sin, 01: cos, 10: tan)
    output logic [31:0] out      // Output: Single precision result (sin, cos, or tan)
);

    // Internal signal for the result
    logic [31:0] sine_result;
    logic [31:0] cosine_result;
    logic [31:0] tangent_result;

    // Sine function using an approximation or built-in hardware function
    function automatic [31:0] sin_approx(input logic [31:0] x);
        // Use a polynomial approximation or a library-based function for sine
        // Here, we would implement a sine approximation or call to a hardware function
        // For simplicity, we just assume we have a sine function implementation here
        sin_approx = $sin(x);  // This is a placeholder for a hardware FPU sin function
    endfunction

    // Cosine function using an approximation or built-in hardware function
    function automatic [31:0] cos_approx(input logic [31:0] x);
        // Use a polynomial approximation or a library-based function for cosine
        // Here, we would implement a cosine approximation or call to a hardware function
        // For simplicity, we just assume we have a cosine function implementation here
        cos_approx = $cos(x);  // This is a placeholder for a hardware FPU cos function
    endfunction

    // Tangent function using sin/cos division
    function automatic [31:0] tan_approx(input logic [31:0] x);
        logic [31:0] sin_val;
        logic [31:0] cos_val;
        
        sin_val = sin_approx(x);
        cos_val = cos_approx(x);
        
        // Check for division by zero (to avoid NaN or infinity)
        if (cos_val != 32'b0) begin
            tan_approx = sin_val / cos_val; // tan(x) = sin(x) / cos(x)
        end else begin
            tan_approx = 32'h7F800000; // Return infinity (IEEE 754)
        end
    endfunction

    always_comb begin
        case (op_select)
            2'b00: begin
                // Sine operation
                sine_result = sin_approx(in);
                out = sine_result;
            end
            2'b01: begin
                // Cosine operation
                cosine_result = cos_approx(in);
                out = cosine_result;
            end
            2'b10: begin
                // Tangent operation
                tangent_result = tan_approx(in);
                out = tangent_result;
            end
            default: begin
                // Default case if needed
                out = 32'b0;
            end
        endcase
    end

endmodule

module fpu_trigonometric_double (
    input logic [63:0] in,       // Input: Double precision float (angle in radians)
    input logic [1:0] op_select, // Control signal (00: sin, 01: cos, 10: tan)
    output logic [63:0] out      // Output: Double precision result (sin, cos, or tan)
);

    // Internal signal for the result
    logic [63:0] sine_result;
    logic [63:0] cosine_result;
    logic [63:0] tangent_result;

    // Sine function using an approximation or built-in hardware function
    function automatic [63:0] sin_approx(input logic [63:0] x);
        // Use a polynomial approximation or a library-based function for sine
        // Here, we would implement a sine approximation or call to a hardware function
        // For simplicity, we just assume we have a sine function implementation here
        sin_approx = $sin(x);  // This is a placeholder for a hardware FPU sin function (IEEE 754 double precision)
    endfunction

    // Cosine function using an approximation or built-in hardware function
    function automatic [63:0] cos_approx(input logic [63:0] x);
        // Use a polynomial approximation or a library-based function for cosine
        // Here, we would implement a cosine approximation or call to a hardware function
        // For simplicity, we just assume we have a cosine function implementation here
        cos_approx = $cos(x);  // This is a placeholder for a hardware FPU cos function (IEEE 754 double precision)
    endfunction

    // Tangent function using sin/cos division
    function automatic [63:0] tan_approx(input logic [63:0] x);
        logic [63:0] sin_val;
        logic [63:0] cos_val;
        
        sin_val = sin_approx(x);
        cos_val = cos_approx(x);
        
        // Check for division by zero (to avoid NaN or infinity)
        if (cos_val != 64'b0) begin
            tan_approx = sin_val / cos_val; // tan(x) = sin(x) / cos(x)
        end else begin
            tan_approx = 64'h7FF0000000000000; // Return infinity (IEEE 754 double precision)
        end
    endfunction

    always_comb begin
        case (op_select)
            2'b00: begin
                // Sine operation
                sine_result = sin_approx(in);
                out = sine_result;
            end
            2'b01: begin
                // Cosine operation
                cosine_result = cos_approx(in);
                out = cosine_result;
            end
            2'b10: begin
                // Tangent operation
                tangent_result = tan_approx(in);
                out = tangent_result;
            end
            default: begin
                // Default case if needed
                out = 64'b0;
            end
        endcase
    end

endmodule

