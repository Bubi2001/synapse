module Shuffle (
    input logic [31:0] data,      // 32-bit input data
    input logic [31:0] pattern,   // 32-bit control register
    output logic [31:0] result    // 32-bit output result
);
    always_comb begin
        result = 32'b0;
        for (int i = 0; i < 32; i++) begin
            result[i] = data[pattern[i]];  // Shuffle bits based on control register
        end
    end

endmodule
