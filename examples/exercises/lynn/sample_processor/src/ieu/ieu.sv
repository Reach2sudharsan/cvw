// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

`include "parameters.svh"

module ieu(
        input   logic           clk, reset,
        input   logic [31:0]    Instr,
        input   logic [31:0]    PC, PCPlus4,
        output  logic           PCSrc,
        output  logic [3:0]     WriteByteEn,
        output  logic [31:0]    IEUAdr, WriteData,
        input   logic [31:0]    ReadData,
        input   logic [31:0]    CSRReadData,
        output  logic           MemEn,
        output  logic [7:0]     HpmSignal
        // output  logic [31:0]    R1,
    );

    logic RegWrite, Jump, Brach, MemWrite, IsJalr, Eq, Lt, Ltu, ALUResultSrc;
    logic [31:0] InstrD;
    logic [1:0] ResultSrc;
    logic [1:0] ALUSrc;
    logic [2:0] ImmSrc;
    logic [1:0] ALUControl;
    logic [1:0] IEUAdrb10;

    controller c(.Op(InstrD[6:0]), .Funct3(InstrD[14:12]), .Funct7b5(InstrD[30]), .Eq, .Lt, .Ltu,
        .IEUAdrb10, .ALUResultSrc, .ResultSrc, .WriteByteEn, .PCSrc,
        .ALUSrc, .RegWrite, .ImmSrc, .ALUControl, .MemEn, .Jump, .IsJalr, .HpmSignal, .Branch, .MemWrite
    `ifdef DEBUG
        , .insn_debug(Instr)
    `endif
    );

    datapath dp(.clk, .reset, .Funct3(Instr[14:12]), .Op(Instr[6:0]), .Funct7b0(Instr[25]), .Funct7b5(Instr[30]),
        .ALUResultSrcD(ALUResultSrc), .ResultSrcD(ResultSrc), .ALUSrcD(ALUSrc), .JumpD(Jump), .IsJalr, .RegWriteD(RegWrite), .ImmSrcD(ImmSrc), .PCSrcE(PCSrc), .ALUControlD(ALUControl), .CSRReadData, .Eq, .Lt, .Ltu,
        .PC, .PCPlus4, .Instr, .IEUAdr, .WriteData, .IEUAdrb10, .ReadData, .BranchD(Branch), .MemWriteD(MemWrite), .InstrD(InstrD));
endmodule
