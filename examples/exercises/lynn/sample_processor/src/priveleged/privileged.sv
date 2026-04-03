// privileged.sv
// RISC-V pipelined processor
// sanadawatan@hmc.edu, sgopalakrishnan@hmc.edu 2026

module privileged(
    input logic        clk,
    input logic        reset,
    input logic [11:0] csr_addr,
    input logic [7:0]  HpmSignal,
    output logic [31:0] csr_rdata
);

    // CSR file instantiation
    csrfile csrf(
        .clk(clk),
        .reset(reset),
        .csr_addr(csr_addr),
        .HpmSignal(HpmSignal),
        .csr_rdata(csr_rdata)
    );

endmodule
