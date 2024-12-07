module RegisterFile (
    input  logic        clk,
    input  logic        rst_n,    // Active-low reset
    input  logic [3:0]  waddr,    // Write address
    input  logic [31:0] wdata,    // Write data
    input  logic        wen,      // Write enable
    input  logic [3:0]  raddr1,   // Read address 1
    output logic [31:0] rdata1,   // Read data 1
    input  logic [3:0]  raddr2,   // Read address 2
    output logic [31:0] rdata2,   // Read data 2
    input  logic [3:0]  raddr3,   // Read address 3
    output logic [31:0] rdata3    // Read data 3
);

    // 16 registers, each 32 bits wide
    logic [31:0] regs [15:0];

    // Write operation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            for (int i = 0; i < 16; i++)
                regs[i] <= 32'b0;
        else if (wen && waddr != 4'b0000)  // Prevent writing to register 0
            regs[waddr] <= wdata;
    end

    // Read operations with register 0 always returning 0
    assign rdata1 = (raddr1 == 4'b0000) ? 32'b0 : regs[raddr1];
    assign rdata2 = (raddr2 == 4'b0000) ? 32'b0 : regs[raddr2];
    assign rdata3 = (raddr3 == 4'b0000) ? 32'b0 : regs[raddr3];

endmodule
