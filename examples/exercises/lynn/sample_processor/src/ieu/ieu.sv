// ieu.sv
// RISC-V pipelined processor
// sanarayanan@hmc.edu, sgopalakrishnan@hmc.edu 2026

`include "parameters.svh"

module ieu(
    // Clock and reset
    input   logic           clk,
    input   logic           reset,
    input   logic [31:0]    Instr,
    input   logic [31:0]    PC,
    input   logic [31:0]    PCPlus4,
    output  logic [31:0]    IEUAdrE,
    output  logic [31:0]    IEUAdrM,
    input   logic [31:0]    ReadData,
    output  logic [31:0]    WriteData,
    output  logic [3:0]     WriteByteEn,
    output  logic           MemEn,
    output  logic           PCSrc,
    input   logic [31:0]    CSRReadData,
    output  logic [11:0]    csr_addrM,
    output  logic [7:0]     HpmSignal,
    output  logic           StallF
);

// ----------------------------------
// Internal control signals
// ----------------------------------
logic RegWrite, Jump, Branch, MemWrite, IsJalr, ALUResultSrc, MemEnD;
logic [1:0] ResultSrc, ALUSrc;
logic [2:0] ImmSrc;
logic [1:0] ALUControl;
logic [1:0] IEUAdrb10;
logic ALUOp;
logic [31:0] InstrD;

// ----------------------------------
// Controller instantiation
// ----------------------------------
controller c(
    .Op(InstrD[6:0]),
    .IEUAdrb10(IEUAdrb10),
    .Funct3(InstrD[14:12]),
    .Funct7b5(InstrD[30]),
    .ALUResultSrc(ALUResultSrc),
    .ResultSrc(ResultSrc),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
    .ImmSrc(ImmSrc),
    .ALUControl(ALUControl),
    .MemEn(MemEnD),
    .Jump(Jump),
    .IsJalr(IsJalr),
    .Branch(Branch),
    .MemWrite(MemWrite),
    .ALUOp(ALUOp)
    `ifdef DEBUG
    , .insn_debug(Instr)
    `endif
);

// ----------------------------------
// Datapath instantiation
// ----------------------------------
datapath dp(
    .clk(clk),
    .reset(reset),
    .ALUOpD(ALUOp),
    .ALUResultSrcD(ALUResultSrc),
    .ResultSrcD(ResultSrc),
    .ALUSrcD(ALUSrc),
    .JumpD(Jump),
    .IsJalrD(IsJalr),
    .RegWriteD(RegWrite),
    .ImmSrcD(ImmSrc),
    .ALUControlD(ALUControl),
    .BranchD(Branch),
    .MemWriteD(MemWrite),
    .CSRReadDataM(CSRReadData),
    .MemEnD(MemEnD),
    .PC(PC),
    .PCPlus4(PCPlus4),
    .Instr(Instr),
    .ReadDataM(ReadData),
    .IEUAdrE(IEUAdrE),
    .IEUAdrM(IEUAdrM),
    .WriteDataM(WriteData),
    .IEUAdrb10M(IEUAdrb10),
    .PCSrcE(PCSrc),
    .InstrD(InstrD),
    .WriteByteEnM(WriteByteEn),
    .MemEnM(MemEn),
    .HpmSignalM(HpmSignal),
    .StallF(StallF),
    .csr_addrM(csr_addrM)
);

endmodule
