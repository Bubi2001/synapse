/*
 *  General Purpose Registers containing 32 32-bit long registers.
 *  Register x0 always reads back 0, read only register.
 *  Remaining Registers can be used as required per the programmer, for default use refer to:
 *  https://en.wikipedia.org/wiki/RISC-V#Register_sets
 */

module RegisterFile (
    input  logic        clk,
    input  logic        rst_n,    // Active-low reset
    input  logic [4:0]  waddr,    // Write address
    input  logic [31:0] wdata,    // Write data
    input  logic        wen,      // Write enable
    input  logic [4:0]  raddr1,   // Read address 1
    output logic [31:0] rdata1,   // Read data 1
    input  logic [4:0]  raddr2,   // Read address 2
    output logic [31:0] rdata2,   // Read data 2
    input  logic [4:0]  raddr3,   // Read address 3
    output logic [31:0] rdata3    // Read data 3
);

    // 32 registers, each 32 bits wide
    logic [31:0] regs [31:0];

    // Write operation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            for (int i = 0; i < 32; i++)
                regs[i] <= 32'b0;
        else if (wen && waddr != 5'b00000)  // Prevent writing to register 0
            regs[waddr] <= wdata;
    end

    // Read operations with register 0 always returning 0
    assign rdata1 = (raddr1 == 5'b00000) ? 32'b0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'b00000) ? 32'b0 : regs[raddr2];
    assign rdata3 = (raddr3 == 5'b00000) ? 32'b0 : regs[raddr3];

endmodule
