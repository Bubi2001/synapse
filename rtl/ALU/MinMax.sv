module MinMax (
    input logic [31:0] a,              // First 32-bit input
    input logic [31:0] b,              // Second 32-bit input
    input logic enable,                // Add enable signal
    input logic control,               // Control signal: 0 for minimum, 1 for maximum
    input logic signControl,           // Control signal: 0 for unsigned, 1 for signed
    output logic [31:0] result         // Output 32-bit result
);

    // Internal signal to hold the result as a signed or unsigned value
    logic signed [31:0] signed_a, signed_b;
    logic unsigned [31:0] unsigned_a, unsigned_b;

    // Assign input values to signed/unsigned variables based on the signControl signal
    always_comb begin
        if (enable) begin
            if (signControl) begin
                signed_a = a;  // Treat inputs as signed
                signed_b = b;  // Treat inputs as signed
                // For signed values, compare and get the max/min
                if (control)
                    result = (signed_a > signed_b) ? signed_a : signed_b;  // Maximum
                else
                    result = (signed_a < signed_b) ? signed_a : signed_b;  // Minimum
            end else begin
                unsigned_a = a;  // Treat inputs as unsigned
                unsigned_b = b;  // Treat inputs as unsigned
                // For unsigned values, compare and get the max/min
                if (control)
                    result = (unsigned_a > unsigned_b) ? unsigned_a : unsigned_b;  // Maximum
                else
                    result = (unsigned_a < unsigned_b) ? unsigned_a : unsigned_b;  // Minimum
            end
        end else begin
            // Disable logic when enable is low
            signed_a = 0;
            signed_b = 0;
            unsigned_a = 0;
            unsigned_b = 0;
            result = 0;
        end
    end

endmodule
