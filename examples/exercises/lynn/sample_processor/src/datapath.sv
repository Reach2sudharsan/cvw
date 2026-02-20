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
    logic [31:0] ALUResult, IEUResult, Result, SizedResult, JumpMuxResult;
    logic [15:0] HalfResult;
    logic [7:0] ByteResult;

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

    always_comb begin

        case ({Instr[6:0], Funct3})
            10'b0000011_010: SizedResult = Result;
            10'b0000011_001: SizedResult = {{16{HalfResult[15]}}, HalfResult};
            10'b0000011_101: SizedResult = {16'b0, HalfResult};
            10'b0000011_000: SizedResult = {{24{ByteResult[7]}}, ByteResult};
            10'b0000011_100: SizedResult = {24'b0, ByteResult};
            default: SizedResult = Result;
        endcase
    end




    // IEUResult (Address) and Result


    // lh t0, 0(r1)
    // lh t0, 2(r1)
    // lh t0, 4(t1)
    // lh t0, 8(t1)

    assign WriteData = R2;
endmodule
