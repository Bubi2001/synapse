module BitDeposit (
    input logic [31:0] opA,
    input logic [31:0] opB,
    output logic [31:0] out
);
    logic [31:0] result;
    logic [5:0] oneCount;
    integer i;

    always_comb begin
        result = 32'b0; // Initialize result to 0
        for (i = 0; i < 32; i = i + 1) begin
            if (opB[i] == 1'b1) begin
                if (i == 0) begin
                    oneCount = 0;
                end else begin
                    CountOnes CountOnes(.num(opB[0:i-1]), .oneCount(oneCount));
                end
                result[i] = opA[oneCount];
            end
        end
    end

    assign out = result;

endmodule
