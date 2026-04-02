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
        output  logic [31:0]    IEUAdrE,IEUAdrM, WriteData,
        input   logic [31:0]    ReadData,
        input   logic [31:0]    CSRReadData,
        output  logic           MemEn,
        output  logic [7:0]     HpmSignal,
        output  logic StallF,
        output  logic [11:0]    csr_addrM
        // output  logic [31:0]    R1,
    );

    logic RegWrite, Jump, Branch, MemWrite, IsJalr, Eq, Lt, Ltu, ALUResultSrc, MemEnD;
    logic [31:0] InstrD;
    logic [1:0] ResultSrc;
    logic [1:0] ALUSrc;
    logic [2:0] ImmSrc;
    logic [1:0] ALUControl;
    logic [1:0] IEUAdrb10;
    logic ALUOp;

    controller c(
        .Op(InstrD[6:0]),
        .Eq(Eq), .Lt(Lt), .Ltu(Ltu),
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
