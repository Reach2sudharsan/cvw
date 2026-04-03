// riscvsingle.sv
// RISC-V pipelined processor
// sanadawatan@hmc.edu, sgopalakrishnan@hmc.edu 2026

`include "parameters.svh"

module riscvsingle (
    input  logic          clk,
    input  logic          reset,

    // Instruction memory interface
    output logic [31:0]   PC,
    input  logic [31:0]   Instr,

    // Data memory interface
    output logic [31:0]   IEUAdr,
    input  logic [31:0]   ReadData,
    output logic [31:0]   WriteData,
    output logic         MemEn,
    output logic         WriteEn,
    output logic [3:0]   WriteByteEn // byte write strobes (1-hot per byte)

    // // Privileged/CSR outputs
    // output logic [31:0]  csr_rdata
);

// ----------------------------------
// Internal signals
// ----------------------------------
logic [31:0] IEUAdrE;
logic [31:0] PCPlus4;
logic        PCSrc;
logic [7:0]  HpmSignal;
logic [31:0] CSRReadData;
logic        StallF;
logic [11:0] csr_addrM;

// IFU: Instruction fetch unit
ifu ifu(
    .clk(clk),
    .reset(reset),
    .PCSrc(PCSrc),
    .StallF(StallF),
    .IEUAdr(IEUAdrE),
    .PC(PC),
    .PCPlus4(PCPlus4)
);

// IEU: Integer execution unit (ALU, pipeline, memory signals)
ieu ieu(
    .clk(clk),
    .reset(reset),
    .Instr(Instr),
    .PC(PC),
    .StallF(StallF),
    .PCPlus4(PCPlus4),
    .PCSrc(PCSrc),
    .WriteByteEn(WriteByteEn),
    .IEUAdrE(IEUAdrE),
    .IEUAdrM(IEUAdr),
    .WriteData(WriteData),
    .ReadData(ReadData),
    .CSRReadData(CSRReadData),
    .MemEn(MemEn),
    .HpmSignal(HpmSignal),
    .csr_addrM(csr_addrM)
);

// Privileged CSR interface
privileged prv(
    .clk(clk),
    .reset(reset),
    .csr_addr(csr_addrM),
    .HpmSignal(HpmSignal),
    .csr_rdata(CSRReadData)
);

// Write enable is asserted if any byte lane is enabled
assign WriteEn = |WriteByteEn;

endmodule
