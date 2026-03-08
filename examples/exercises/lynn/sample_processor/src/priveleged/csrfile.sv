// riscvsingle.sv

// mar 6 is when I passed Zicntr tests

module csrfile(
    input logic     clk, reset,
    // input logic     csr_we,
    input logic [11:0] csr_addr,
    input logic [7:0]  HpmSignal,
    // input logic [31:0] csr_wdata,
    output logic [31:0] csr_rdata

);

    logic [63:0] rdcycle = 64'b0;
    logic [63:0] rdtime = 64'b0;
    logic [63:0] rdinsret = 64'b0;

    logic [63:0] hpmcounter [31:3];

    integer i;


    always_ff @(posedge clk or posedge reset)

        if (reset) begin
            rdcycle <= 64'b0;
            rdtime <= 64'b0;
            rdinsret <= 64'b0;

            for (i = 3; i <= 31; i++)
                hpmcounter[i] <= 64'b0;
        end

        else begin
            rdcycle <= rdcycle + 1;
            rdtime <= rdtime + 1;
            rdinsret <= rdinsret + 1;

            if (HpmSignal[0])
                hpmcounter[3] <= hpmcounter[3] + 1; // add / addi instruction

            if (HpmSignal[1])
                hpmcounter[4] <= hpmcounter[4] + 1; // branch evaluated

            if (HpmSignal[2])
                hpmcounter[5] <= hpmcounter[5] + 1; // branch taken

            if (HpmSignal[3])
                hpmcounter[6] <= hpmcounter[6] + 1; // register file write

            if (HpmSignal[4])
                hpmcounter[7] <= hpmcounter[7] + 1; // store instruction

            if (HpmSignal[5])
                hpmcounter[8] <= hpmcounter[8] + 1; // load instruction

            if (HpmSignal[6])
                hpmcounter[9] <= hpmcounter[9] + 1; // jump instruction

            if (HpmSignal[7])
                hpmcounter[10] <= hpmcounter[10] + 1; // R-type / I-type instruction


        end

    always_comb begin
        case (csr_addr)
            12'hC00: csr_rdata = rdcycle[31:0];
            12'hC80: csr_rdata = rdcycle[63:32];

            12'hC01: csr_rdata = rdtime[31:0];
            12'hC81: csr_rdata = rdtime[63:32];

            12'hC02: csr_rdata = rdinsret[31:0];
            12'hC82: csr_rdata = rdinsret[63:32];

            default: begin
                if (csr_addr >= 12'hC03 && csr_addr <= 12'hC1F)
                    csr_rdata = hpmcounter[csr_addr - 12'hC00][31:0];

                else if (csr_addr >= 12'hC83 && csr_addr <= 12'hC9F)
                    csr_rdata = hpmcounter[csr_addr - 12'hC80][63:32];

                else
                    csr_rdata = 32'b0;
            end



            // csr_rdata = 32'b0;
        endcase
    end

endmodule
