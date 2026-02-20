// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

module cmp(
        input   logic [31:0]    R1, R2,
        output  logic           Eq, Lt, Ltu
    );

    logic [32:0] SumExt;

    assign Eq = (R1 == R2);
    assign Lt = ($signed(R1) < $signed(R2));
    assign Ltu = (R1 < R2);


endmodule
