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
        output  logic [1:0]     IEUAdrb10,
        input   logic [31:0]    ReadData
    );

    logic [31:0] ImmExt;
    logic [31:0] R1, R2, SrcA, SrcB;
    logic [31:0] ALUResult, IEUResult, Result, SizedResult, JumpMuxResult;
    logic [15:0] HalfResult;
    logic [7:0] ByteResult;
    logic [2:0] LoadType;

    // register file logic
    regfile rf(.clk, .WE3(RegWrite), .A1(Instr[19:15]), .A2(Instr[24:20]),
        .A3(Instr[11:7]), .WD3(SizedResult), .RD1(R1), .RD2(R2));

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

    // half and byte muxes
    mux2 #(16) halfmux(Result[15:0], Result[31:16], IEUResult[1], HalfResult);
    mux2 #(8) bytemux(HalfResult[7:0], HalfResult[15:8], IEUResult[0], ByteResult);

    assign LoadType = (Instr[6:0] == 7'b0000011) ? Funct3 : 3'b111; // determines type of load instruction to perform
    assign IEUAdrb10 = IEUAdr[1:0];

    always_comb begin

        case (LoadType)
            3'b010: SizedResult = Result; // lw
            3'b001: SizedResult = {{16{HalfResult[15]}}, HalfResult}; // lh
            3'b101: SizedResult = {16'b0, HalfResult}; // lhu
            3'b000: SizedResult = {{24{ByteResult[7]}}, ByteResult}; // lb
            3'b100: SizedResult = {24'b0, ByteResult}; // lbu
            default: SizedResult = Result;
        endcase
    end

    always_comb begin
        casez ({Funct3[1:0], IEUAdr[1:0]})
            4'b10_??: WriteData = R2; // sw

            4'b01_0?: WriteData = {16'b0, R2[15:0]}; // sh
            4'b01_1?: WriteData = {R2[15:0], 16'b0}; // sh

            4'b00_00: WriteData = {24'b0, R2[7:0]}; // sb
            4'b00_01: WriteData = {16'b0, R2[7:0], 8'b0}; // sb
            4'b00_10: WriteData = {8'b0, R2[7:0], 16'b0}; // sb
            4'b00_11: WriteData = {R2[7:0], 24'b0}; // sb

            default: WriteData = R2;

        endcase
    end

endmodule
