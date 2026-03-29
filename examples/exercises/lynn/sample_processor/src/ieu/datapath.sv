// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

module datapath(
        input   logic           clk, reset,
        // input   logic [2:0]     Funct3,
        // input   logic [6:0]     Op,
        // input   logic           Funct7b0, // NEW SIGNAL ADDED
        // input   logic           Funct7b5, // NEW SIGNAL ADDED
        input   logic           ALUOpD,
        input   logic           ALUResultSrcD,
        input   logic [1:0]     ResultSrcD,
        input   logic [1:0]     ALUSrcD,
        input   logic           JumpD, // NEW SIGNAL ADDED
        input   logic           IsJalrD, // FOR JALR
        input   logic           RegWriteD,
        input   logic [2:0]     ImmSrcD,
        input   logic [1:0]     ALUControlD,
        input   logic           BranchD,
        input   logic           MemWriteD,
        input   logic [31:0]    CSRReadDataM, // CSR Read
        // output  logic           Eq, Lt, Ltu,
        input   logic [31:0]    PC, PCPlus4,
        input   logic [31:0]    Instr,
        output  logic [31:0]    IEUAdrE, WriteData,
        output  logic [1:0]     IEUAdrb10,
        output  logic           PCSrcE,
        // output  logic [31:0]    R1, // CSR
        output  logic [31:0]    InstrD,
        output  logic           HpmSignalM,
        input   logic [31:0]    ReadData
    );

    logic [31:0] ImmExtD, ImmExtE;
    logic [31:0] R1, R2, SrcAE, SrcBE;
    logic [31:0] ALUResultE, ALUResultM, IEUResultE, IEUResultM, Result, SizedResult, JumpMuxResultE;
    logic [15:0] HalfResult;
    logic [7:0] ByteResult;
    logic [2:0] LoadType;

    logic [2:0]  Funct3D, Funct3E, Funct3M;
    logic Funct7b0D, Funct7b0E;
    logic Funct7b5D, Funct7b5E;
    logic [6:0]  OpD, OpE;

    logic [31:0] InstrF, InstrD;
    logic [31:0] PCF, PCD, PCE;
    logic [31:0] PCPlus4F, PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W;
    logic [4:0] Rs1D, Rs2D, RdD, Rs1E, Rs2E, RdE;
    logic [31:0] RD1D, RD2D, RD1E, RD2E, RD2M;

    logic RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE;

    logic IsJalrD, IsJalrE;
    logic [1:0] ResultSrcE, ALUControlE;

    logic [31:0] IEUAdrE, IEUAdrM;


    logic HpmAddE, HpmBranchTakenE, Eq, Lt, Ltu;

    logic [6:0] HpmSignalE;

    logic [11:0] CsrAdrF, CsrAdrD, CsrAdrE, CsrAdrM;


    // --------------- FETCH STAGE ---------------
    assign InstrF = Instr;
    assign PCF = PC;
    assign PCPlus4F = PCPlus4;
    assign CsrAdrF = InstrF[31:20];
    // assign Funct3F = Funct3;
    // assign Funct7b0F = Funct7b0;
    // assign Funct7b5F = Funct7b5;
    // assign OpF = Op;
    // assign IsJalrF = IsJalr;


    // Fetch to Decode registers
    flopenr #(32) F2D_instr(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(InstrF), .Q(InstrD));
    flopenr #(32) F2D_PC(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(PCF), .Q(PCD));
    flopenr #(32) F2D_PCPlus4(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(PCPlus4F), .Q(PCPlus4D));
    flopenr #(12) F2D_CsrAdr(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(CsrAdrF), .Q(CsrAdrD));

    // flopenr #(3) F2D_Funct3(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(Funct3F), .Q(Funct3D));
    // flopenr #(1) F2D_Funct7b0(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(Funct7b0F), .Q(Funct7b0D));
    // flopenr #(1) F2D_Funct7b5(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(Funct7b5F), .Q(Funct7b5D));
    // flopenr #(7) F2D_Op(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(OpF), .Q(OpD));

    // flopenr #(1) F2D_IsJalr(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(Funct7b5F), .Q(Funct7b5D));




    // --------------- DECODE STAGE ---------------
    // register file logic
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD = InstrD[11:7];

    assign Funct3D = InstrD[14:12];
    assign Funct7b0D = InstrD[25];
    assign Funct7b5D = InstrD[30];
    assign OpD = InstrD[6:0];


    regfile rf(.clk, .WE3(RegWriteD), .A1(Rs1D), .A2(Rs2D),
        .A3(RdD), .WD3(SizedResult), .RD1(RD1D), .RD2(RD2D));

    extend ext(.Instr(InstrD[31:7]), .ImmSrcD, .ImmExtD);


    // Decode to Execute Datapath registers
    flopenr #(32) D2E_PC(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(PCF), .Q(PCD));
    flopenr #(32) D2E_PCPlus4(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(PCPlus4D), .Q(PCPlus4E));

    flopenr #(5) D2E_Rs1(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(Rs1D), .Q(Rs1E));
    flopenr #(5) D2E_Rs2(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(Rs2D), .Q(Rs2E));
    flopenr #(5) D2E_Rd(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(RdD), .Q(RdE));

    flopenr #(32) D2E_RD1(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(RD1D), .Q(RD1E));
    flopenr #(32) D2E_RD2(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(RD2D), .Q(RD2E));

    flopenr #(32) D2E_ImmExt(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(ImmExtD), .Q(ImmExtE));

    flopenr #(3) D2E_Funct3(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(Funct3D), .Q(Funct3E));
    flopenr #(1) D2E_Funct7b0(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(Funct7b0D), .Q(Funct7b0E));
    flopenr #(1) D2E_Funct7b5(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(Funct7b5D), .Q(Funct7b5E));
    flopenr #(7) D2E_Op(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(OpD), .Q(OpE));

    flopenr #(12) D2E_CsrAdr(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(CsrAdrD), .Q(CsrAdrE));


    // Decode to Execute Controller registers
    flopenr #(1) D2E_RegWrite(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(RegWriteD), .Q(RegWriteE));
    flopenr #(2) D2E_ResultSrc(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(ResultSrcD), .Q(ResultSrcE));
    flopenr #(1) D2E_MemWrite(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(MemWriteD), .Q(MemWriteE));
    flopenr #(1) D2E_Jump(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(JumpD), .Q(JumpE));
    flopenr #(1) D2E_Branch(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(BranchD), .Q(BranchE));
    flopenr #(2) D2E_ALUControl(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(ALUControlD), .Q(ALUControlE));
    flopenr #(2) D2E_ALUSrc(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(ALUSrcD), .Q(ALUSrcE));

    flopenr #(1) D2E_IsJalr(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(IsJalrD), .Q(IsJalrE));


    // --------------- EXECUTE STAGE ---------------
    // ALU logic
    cmp cmp(.RD1E, .RD2E, .Eq, .Lt, .Ltu);

    mux2 #(32) srcamux(RD1E, PCE, ALUSrcE[1], SrcAE);
    mux2 #(32) srcbmux(RD2E, ImmExtE, ALUSrcE[0], SrcBE);

    alu alu(.SrcAE, .SrcBE, .ALUControlE, .Funct3E, .OpE, .Funct7b0E, .Funct7b5E, .IsJalrE, .ALUResultE, .IEUAdrE);

    // Need to add Jump Flag
    mux2 #(32) jumpmux(ImmExtE, PCPlus4E, JumpE, JumpMuxResultE); // jumpmux
    mux2 #(32) ieuresultmux(ALUResultE, JumpMuxResultE, ALUResultSrcE, IEUResultE); // now takes in jumpMuxResult instead of PCPlus4
    // mux2 #(32) resultmux(IEUResult, ReadData, ResultSrc, Result); // change to mux3 for csr

    assign HpmAddE = ALUOp && (Funct3 == 3'b000) && ~Sub;
    // assign HpmBranch = Branch;
    assign HpmBranchTakenE =
        (BranchE &
            (
                Eq & (Funct3E == 3'b000)     |
                ~Eq & (Funct3E == 3'b001)    |
                Lt & (Funct3E == 3'b100)     |
                ~Lt & (Funct3E == 3'b101)    |
                Ltu & (Funct3E == 3'b110)    |
                ~Ltu & (Funct3E == 3'b111)
            )
        );

    // PCSrc logic
    assign PCSrcE = JumpE | HpmBranchTakenE;

    // hpm[10]_hpm[9]_hpm[8]_hpm[7]_hpm[6]_hpm[5]_hpm[4]_hpm[3]
    assign HpmSignalE = {
                    ALUOp,                  // hpm[10]: # of R-type and I-type instrs
                    JumpE,                   // hpm[9]: # of jumps
                    OpE == 7'b011,           // hpm[8]: # of loads from data memory
                    MemWriteE,               // hpm[7]: # of writes to data memory
                    RegWriteE,               // hpm[6]: # of writes to RegFile
                    HpmBranchTakenE,         // hpm[5]: # of branches taken
                    BranchE,                 // hpm[4]: # of branches eval
                    HpmAddE                  // hpm[3]: # adds
                };





    // Execute to Memory Datapath registers
    flopenr #(32) E2M_ALUResult(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(ALUResultE), .Q(ALUResultM));
    flopenr #(12) E2M_CsrAdr(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(CsrAdrE), .Q(CsrAdrM));
    flopenr #(7) E2M_HpmSignal(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(HpmSignalE), .Q(HpmSignalM));
    flopenr #(7) E2M_HpmSignal(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(HpmSignalE), .Q(HpmSignalM));

    flopenr #(3) E2M_Funct3(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(Funct3E), .Q(Funct3M));
    flopenr #(32) E2M_IEUAdr(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(IEUAdrE), .Q(IEUAdrM));
    flopenr #(32) E2M_RD2(.clk(clk), .reset(reset), .enable(1), .flush(0), .D(RD2E), .Q(RD2M));


    // --------------- MEMORY STAGE ---------------
    always_comb begin
        casez ({Funct3M[1:0], IEUAdrM[1:0]})
            4'b10_??: WriteData = RD2M; // sw

            4'b01_0?: WriteData = {16'b0, RD2M[15:0]}; // sh
            4'b01_1?: WriteData = {RD2M[15:0], 16'b0}; // sh

            4'b00_00: WriteData = {24'b0, RD2M[7:0]}; // sb
            4'b00_01: WriteData = {16'b0, RD2M[7:0], 8'b0}; // sb
            4'b00_10: WriteData = {8'b0, RD2M[7:0], 16'b0}; // sb
            4'b00_11: WriteData = {RD2M[7:0], 24'b0}; // sb

            default: WriteData = RD2M;

        endcase
    end




    // --------------- WRITEBACK STAGE ---------------


    mux3 #(32) resultmux(IEUResult, ReadData, CSRReadData, ResultSrc, Result);


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



    // debug
    // always_comb begin
        // if (IsJalr) begin
            // $display("JALR: R1=%h ImmExt=%h SrcA=%h SrcB=%h IEUAdr=%h ALUSrc=%b",
                    // R1, ImmExt, SrcA, SrcB, IEUAdr, ALUSrc);
        // end
    // end

endmodule
