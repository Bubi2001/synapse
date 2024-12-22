module CountOnes (
    input logic [31:0] num,       // 32-bit input number
    output logic [5:0] oneCount   // Output count of ones
);
    always_comb begin
        oneCount = 0;
        for (int i = 0; i < 32; i++) begin
            if (num[i] == 1) oneCount++;
        end
    end

endmodule
