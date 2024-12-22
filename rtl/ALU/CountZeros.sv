module CountZeros (
    input logic [31:0] num,             // 32-bit input number
    output logic [5:0] leadingCount,    // Output count for leading zeroes
    output logic [5:0] trailingCount    // Output count for trailing zeroes
);
    always_comb begin
        leadingCount = 0;
        trailingCount = 0;
        // Count leading zeroes
        for (int i = 31; i >= 0; i--) begin
            if (num[i] == 0) leadingCount++;
            else break;
        end
        // Count trailing zeroes
        for (int i = 0; i < 32; i++) begin
            if (num[i] == 0) trailingCount++;
            else break;
        end
    end

endmodule
