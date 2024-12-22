module GeneralizedReverse (
    input logic [31:0] data,      // 32-bit input data
    input logic [31:0] pattern,   // 32-bit pattern
    output logic [31:0] result    // 32-bit output result
);
    always_comb begin
        result = 32'b0;
        for (int i = 0; i < 32; i++) begin
            if (pattern[i]) begin
                result[i] = data[31-i];  // Reverse bit i with position 31-i
            end
        end
    end

endmodule
