module Divider (
    input logic [31:0] a,                // First 32-bit input (dividend)
    input logic [31:0] b,                // Second 32-bit input (divisor)
    input logic control,                 // Control signal: 0 for division, 1 for remainder
    input logic signControl,             // Control signal: 0 for unsigned, 1 for signed
    output logic [31:0] result           // Output 32-bit result (quotient or remainder)
);

    // Internal signals to hold signed or unsigned values
    logic signed [31:0] signed_a, signed_b;
    logic unsigned [31:0] unsigned_a, unsigned_b;

    // Perform division or remainder based on ctrl_operation
    always_comb begin
        if (signControl) begin
            signed_a = a;  // Treat inputs as signed
            signed_b = b;  // Treat inputs as signed
        end else begin
            unsigned_a = a;  // Treat inputs as unsigned
            unsigned_b = b;  // Treat inputs as unsigned
        end

        // Operation selection
        if (control == 0) begin
            // Division operation
            if (signControl) begin
                result = signed_a / signed_b;  // Signed division
            end else begin
                result = unsigned_a / unsigned_b;  // Unsigned division
            end
        end else begin
            // Remainder operation
            if (signControl) begin
                result = signed_a % signed_b;  // Signed remainder
            end else begin
                result = unsigned_a % unsigned_b;  // Unsigned remainder
            end
        end
    end

endmodule