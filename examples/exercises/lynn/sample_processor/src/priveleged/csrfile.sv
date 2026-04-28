// csrfile.sv
// RISC-V pipelined processor
// sanarayanan@hmc.edu, sgopalakrishnan@hmc.edu 2026

module csrfile(
    input  logic        clk,
    input  logic        reset,
    input  logic [11:0] csr_addr,
    input  logic [7:0]  HpmSignal,
    output logic [31:0] csr_rdata
);

// Counters for standard CSR cycle/time/instruction-retired registers
logic [31:0] rdcycle = 32'd0;
logic [31:0] rdtime = 32'd0;
logic [31:0] rdinsret = 32'd0;

// Hardware performance counters, using the CSR range [0xC03..0xC1F] + upper halves [0xC83..0xC9F]
logic [31:0] hpmcounter [5:3];

integer i;

// Counters update (increment) logic
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        rdcycle  <= 32'd0;
        rdtime   <= 32'd0;
        rdinsret <= 32'd0;

        // for (i = 3; i <= 31; i = i + 1)
        //     hpmcounter[i] <= 64'd0;
    end else begin
        rdcycle  <= rdcycle + 1;
        rdtime   <= rdtime + 1;
        rdinsret <= rdinsret + (HpmSignal[1] | HpmSignal[3] | HpmSignal[4] | HpmSignal[6]);

        // if (HpmSignal[0]) hpmcounter[3]  <= hpmcounter[3]  + 1; // add/addi
        // if (HpmSignal[1]) hpmcounter[4]  <= hpmcounter[4]  + 1; // branch evaluated
        if (HpmSignal[2]) hpmcounter[5]  <= hpmcounter[5]  + 1; // branch taken
        // if (HpmSignal[3]) hpmcounter[6]  <= hpmcounter[6]  + 1; // register file write
        // if (HpmSignal[4]) hpmcounter[7]  <= hpmcounter[7]  + 1; // store instruction
        // if (HpmSignal[5]) hpmcounter[8]  <= hpmcounter[8]  + 1; // load instruction
        // if (HpmSignal[6]) hpmcounter[9]  <= hpmcounter[9]  + 1; // jump instruction
        // if (HpmSignal[7]) hpmcounter[10] <= hpmcounter[10] + 1; // R-type/I-type instruction
    end
end

// CSR read data
always_comb begin
    case (csr_addr)
        12'hC00: csr_rdata = rdcycle[31:0];
        // 12'hC80: csr_rdata = rdcycle[63:32];

        12'hC01: csr_rdata = rdtime[31:0];
        // 12'hC81: csr_rdata = rdtime[63:32];

        12'hC02: csr_rdata = rdinsret[31:0];
        // 12'hC82: csr_rdata = rdinsret[63:32];

        default: begin
            // if (csr_addr >= 12'hC03 && csr_addr <= 12'hC1F)
            //     csr_rdata = hpmcounter[csr_addr - 12'hC00][31:0];
            // else if (csr_addr >= 12'hC83 && csr_addr <= 12'hC9F)
            //     csr_rdata = hpmcounter[csr_addr - 12'hC80][63:32];
            // else
            //     csr_rdata = 32'd0;
            csr_rdata = 32'd0;
        end
    endcase
end

endmodule
