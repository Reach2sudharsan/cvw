// riscvsingle.sv
// RISC-V single-cycle processor
// sgopalakrishnan@g.hmc.edu

module privileged(
    input logic clk, reset,
    input logic [31:0] Instr,
    // input logic        csr_we,
    // input logic [31:0] csr_wdata,
    output logic [31:0] csr_rdata
);

    csrfile csrf(.clk, .reset, .csr_addr(Instr[31:20]), .csr_rdata(csr_rdata));

endmodule
