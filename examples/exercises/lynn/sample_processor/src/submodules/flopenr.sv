// riscvsingle.sv
// RISC-V single-cycle processor

module flopenr #(parameter WIDTH, parameter DEFAULT = 0) (
        input   logic               clk,
        input   logic               reset,
        input   logic               enable,
        input   logic               flush,
        input   logic [WIDTH-1:0]   D,
        output  logic [WIDTH-1:0]   Q
    );

    always_ff @(posedge clk, posedge reset) begin
        if (reset)  Q <= DEFAULT;
        else if (flush)  Q <= 0;
        else if (enable) Q <= D;

    end

endmodule
