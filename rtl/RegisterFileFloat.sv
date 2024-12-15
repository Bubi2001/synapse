/*
 *  General Purpose Registers containing 32 64-bit long registers. Intended for FPU use.
 *  Registers can be used as required per the programmer, for default use refer to:
 *  https://en.wikipedia.org/wiki/RISC-V#Register_sets
 */

module RegisterFileFloat (
    input  logic        clk,
    input  logic        rst_n,    // Active-low reset
    input  logic [4:0]  waddr,    // Write address
    input  logic [63:0] wdata,    // Write data
    input  logic        wen,      // Write enable
    input  logic [4:0]  raddr1,   // Read address 1
    output logic [63:0] rdata1,   // Read data 1
    input  logic [4:0]  raddr2,   // Read address 2
    output logic [63:0] rdata2,   // Read data 2
    input  logic [4:0]  raddr3,   // Read address 3
    output logic [63:0] rdata3    // Read data 3
);

    // 32 registers, each 64 bits wide
    logic [63:0] regs [31:0];

    // Write operation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 64'b0;
                // regs[i] <= {1'b0,11'h7FF,52'h8000000000000} // qNaN
            end
        end else if (wen && (waddr != raddr1) && (waddr != raddr2) && (waddr != raddr3)) begin
            // avoid reading while writing
            regs[waddr] <= wdata;
        end
    end

    assign rdata1 = regs[raddr1];
    assign rdata2 = regs[raddr2];
    assign rdata3 = regs[raddr3];

endmodule
