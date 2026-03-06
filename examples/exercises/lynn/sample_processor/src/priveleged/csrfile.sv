// riscvsingle.sv

module csrfile(
    input logic     clk, reset,
    // input logic     csr_we,
    input logic [11:0] csr_addr,
    // input logic [31:0] csr_wdata,
    output logic [31:0] csr_rdata

);

    logic [63:0] rdcycle;
    logic [63:0] rdtime;
    logic [63:0] rdinsret;

    always_ff @(posedge clk or posedge reset)

        if (reset) begin
            rdcycle <= 64'b0;
            rdtime <= 64'b0;
            rdinsret <= 64'b0;
        end

        else begin
            rdcycle <= rdcycle + 1;
            rdtime <= rdtime + 1;
            rdinsret <= rdinsret + 1;
        end

    always_comb begin
        case (csr_addr)
            12'hC00: csr_rdata = rdcycle[31:0];
            12'hC80: csr_rdata = rdcycle[63:32];

            12'hC01: csr_rdata = rdtime[31:0];
            12'hC81: csr_rdata = rdtime[63:32];

            12'hC02: csr_rdata = rdinsret[31:0];
            12'hC82: csr_rdata = rdinsret[63:32];

            default: csr_data = 32'b0;
        endcase
    end

endmodule
