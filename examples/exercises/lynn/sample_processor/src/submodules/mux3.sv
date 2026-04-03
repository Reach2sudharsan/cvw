// mux3.sv
// RISC-V pipelined processor
// sanadawatan@hmc.edu, sgopalakrishnan@hmc.edu 2026

module mux3 #(parameter WIDTH) (
        input   logic [WIDTH-1:0]   A,
        input   logic [WIDTH-1:0]   B,
        input   logic [WIDTH-1:0]   C,
        input   logic [1:0]         select,

        output  logic [WIDTH-1:0]   result
    );

    always_comb begin
        case(select)
            2'b00: result = A;
            2'b01: result = B;
            2'b10: result = C;
            default: result = 'x;
        endcase
    end

endmodule
