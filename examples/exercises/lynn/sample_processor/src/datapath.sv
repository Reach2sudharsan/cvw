// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

module datapath(
        input   logic           clk, reset,
        input   logic [2:0]     Funct3,
        input   logic           Funct7b5, // NEW SIGNAL ADDED
        input   logic           ALUResultSrc, ResultSrc,
        input   logic [1:0]     ALUSrc,
        input   logic           Jump, // NEW SIGNAL ADDED
        input   logic           RegWrite,
        input   logic [2:0]     ImmSrc,
        input   logic [1:0]     ALUControl,
        output  logic           Eq, Lt, Ltu,
        input   logic [31:0]    PC, PCPlus4,
        input   logic [31:0]    Instr,
        output  logic [31:0]    IEUAdr, WriteData,
        input   logic [31:0]    ReadData
    );

    logic [31:0] ImmExt;
    logic [31:0] R1, R2, SrcA, SrcB;
    logic [31:0] ALUResult, IEUResult, Result, JumpMuxResult;

    // register file logic
    regfile rf(.clk, .WE3(RegWrite), .A1(Instr[19:15]), .A2(Instr[24:20]),
        .A3(Instr[11:7]), .WD3(Result), .RD1(R1), .RD2(R2));

    extend ext(.Instr(Instr[31:7]), .ImmSrc, .ImmExt);

    // ALU logic
    cmp cmp(.R1, .R2, .Eq, .Lt, .Ltu);

    mux2 #(32) srcamux(R1, PC, ALUSrc[1], SrcA);
    mux2 #(32) srcbmux(R2, ImmExt, ALUSrc[0], SrcB);

    alu alu(.SrcA, .SrcB, .ALUControl, .Funct3, .Funct7b5, .ALUResult, .IEUAdr);

    // Need to add Jump Flag
    mux2 #(32) jumpmux(ImmExt, PCPlus4, Jump, JumpMuxResult); // jumpmux
    mux2 #(32) ieuresultmux(ALUResult, JumpMuxResult, ALUResultSrc, IEUResult); // now takes in jumpMuxResult instead of PCPlus4
    mux2 #(32) resultmux(IEUResult, ReadData, ResultSrc, Result);

    assign WriteData = R2;
endmodule
