// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020 kacassidy@hmc.edu 2025

`include "parameters.svh"

module riscvsingle (
        input   logic           clk,
        input   logic           reset,

        output  logic [31:0]    PC,  // instruction memory target address
        input   logic [31:0]    Instr, // instruction memory read data

        output  logic [31:0]    IEUAdr,  // data memory target address
        input   logic [31:0]    ReadData, // data memory read data
        output  logic [31:0]    WriteData, // data memory write data

        output  logic           MemEn,
        output  logic           WriteEn,
        output  logic [3:0]     WriteByteEn  // strobes, 1 hot stating weather a byte should be written on a store
    );

    logic [31:0] IEUAdrE,PCPlus4;
    logic PCSrc;
    logic Load;
    logic [7:0] HpmSignal;

    logic [31:0] CSRReadData;

    logic StallF;

    ifu ifu(.clk, .reset, .PCSrc, .StallF, .IEUAdr(IEUAdrE), .PC, .PCPlus4);
    ieu ieu(.clk, .reset, .Instr, .PC, .StallF, .PCPlus4, .PCSrc, .WriteByteEn,
            .IEUAdrE(IEUAdrE), .IEUAdrM(IEUAdr), .WriteData, .ReadData, .CSRReadData, .MemEn, .HpmSignal
        );

    privileged prv(.clk, .reset, .Instr, .HpmSignal, .csr_rdata(CSRReadData));


    assign WriteEn = |WriteByteEn;

endmodule
