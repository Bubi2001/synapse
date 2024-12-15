module Multiplier (
    input logic  [31:0] a,
    input logic  [31:0] b,
    input logic         control,
    input logic  [1:0]  signControl,
    output logic [31:0] result
);
    logic [63:0] product;
    logic signed [31:0] signed_a;
    logic signed [31:0] signed_b;
    logic [31:0] unsigned_a;
    logic [31:0] unsigned_b;

    // Convert inputs based on sign_control signal
    always_comb begin
        case (signControl)
            2'b00: begin
                // Both inputs are unsigned
                unsigned_a = a;
                unsigned_b = b;
                signed_a = 0;
                signed_b = 0;
            end
            2'b11: begin
                // Both inputs are signed
                signed_a = a;
                signed_b = b;
                unsigned_a = 0;
                unsigned_b = 0;
            end
            default: begin
                // a is signed, b is unsigned
                signed_a = a;
                unsigned_b = b;
                signed_b = 0;
                unsigned_a = 0;
            end
        endcase
    end

    // Perform multiplication based on converted inputs
    always_comb begin
        if (signControl == 2'b00) begin
            product = unsigned_a * unsigned_b;
        end else if (signControl == 2'b11) begin
            product = signed_a * signed_b;
        end else begin
            product = signed_a * unsigned_b;
        end
    end

    // Select output based on control signal
    always_comb begin
        if (control) begin
            result = product[63:32]; // Higher 32 bits
        end else begin
            result = product[31:0];  // Lower 32 bits
        end
    end

endmodule