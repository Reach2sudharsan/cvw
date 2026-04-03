// datapath.sv
// RISC-V pipelined processor
// sanarayanan@hmc.edu, sgopalakrishnan@hmc.edu 2026

module datapath(
    input   logic           clk, reset,
    // Control signals from controller
    input   logic           ALUOpD,
    input   logic           ALUResultSrcD,
    input   logic [1:0]     ResultSrcD,
    input   logic [1:0]     ALUSrcD,
    input   logic           JumpD,
    input   logic           IsJalrD,
    input   logic           RegWriteD,
    input   logic [2:0]     ImmSrcD,
    input   logic [1:0]     ALUControlD,
    input   logic           BranchD,
    input   logic           MemWriteD,
    input   logic           MemEnD,
    // CSR data from privileged unit
    input   logic [31:0]    CSRReadDataM,
    // Inputs from IFU (Instruction Fetch Unit)
    input   logic [31:0]    PC, PCPlus4,
    input   logic [31:0]    Instr,
    // Outputs for memory / loads / stores
    output  logic [31:0]    IEUAdrE, IEUAdrM, WriteDataM,
    output  logic [1:0]     IEUAdrb10M,
    // Branch/jump control
    output  logic           PCSrcE,
    // Instruction in decode stage
    output  logic [31:0]    InstrD,
    // Performance monitoring
    output  logic [7:0]     HpmSignalM,
    // Memory control
    output  logic [3:0]     WriteByteEnM,
    output  logic           MemEnM,
    // Stall signal to IFU
    output  logic           StallF,
    // CSR address
    output  logic [11:0]    csr_addrM,
    // Data from memory
    input   logic [31:0]    ReadDataM
);

    // ============================================================================
    // Internal Signals
    // ============================================================================

    // Pipeline registers and data
    logic [31:0] ImmExtD, ImmExtE;
    logic [31:0] R1, R2, SrcAE, SrcBE;
    logic [31:0] ALUResultE, ALUResultM, ALUResultW, IEUResultE, IEUResultM, IEUResultW, JumpMuxResultE;
    logic [31:0] ResultW, SizedResultW;
    logic [15:0] HalfResultW;
    logic [7:0] ByteResultW;
    logic [2:0] LoadTypeM, LoadTypeW;
    logic [2:0] Funct3D, Funct3E, Funct3M;
    logic Funct7b0D, Funct7b0E;
    logic Funct7b5D, Funct7b5E;
    logic [6:0] OpD, OpE, OpM;
    logic [31:0] InstrF;
    logic [31:0] PCF, PCD, PCE;
    logic [31:0] PCPlus4F, PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W;
    logic [4:0] Rs1D, Rs2D, RdD, Rs1E, Rs2E, RdE, RdM, RdW;
    logic [31:0] RD1D, RD2D, RD1E, RD2E, RD2M;
    logic RegWriteE, RegWriteM, JumpE, BranchE, ALUOpE;
    logic [1:0] ALUSrcE;
    logic IsJalrE;
    logic [1:0] ResultSrcE, ResultSrcM, ResultSrcW, ALUControlE;
    logic [31:0] IEUAdrW;
    logic HpmAddE, HpmBranchTakenE, Eq, Lt, Ltu;
    logic SubE;
    logic [7:0] HpmSignalE;
    logic [31:0] WriteDataE, ReadDataW, CSRReadDataW;
    logic [1:0] StoreTypeM;
    logic MemWriteE, MemWriteM;
    logic [1:0] ForwardAE, ForwardBE;
    logic lwStall, StallD, FlushD, FlushE;
    logic [31:0] Aout, Bout;
    logic MemEnE;
    logic ALUResultSrcE;

    // ============================================================================
    // Hazard Detection Unit
    // ============================================================================

    hazard_unit hzunit(
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .RdM(RdM),
        .RdW(RdW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ResultSrcEb0(ResultSrcE[0]),
        .PCSrcE(PCSrcE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .lwStall(lwStall),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

    // ============================================================================
    // FETCH STAGE
    // ============================================================================

    // Fetch stage assignments
    assign InstrF = Instr;
    assign PCF = PC;
    assign PCPlus4F = PCPlus4;

    // Pipeline registers: Fetch to Decode
    flopenr #(32) F2D_instr(.clk(clk), .reset(reset), .enable(~StallD), .flush(FlushD), .D(InstrF), .Q(InstrD));
    flopenr #(32) F2D_PC(.clk(clk), .reset(reset), .enable(~StallD), .flush(FlushD), .D(PCF), .Q(PCD));
    flopenr #(32) F2D_PCPlus4(.clk(clk), .reset(reset), .enable(~StallD), .flush(FlushD), .D(PCPlus4F), .Q(PCPlus4D));

    // ============================================================================
    // DECODE STAGE
    // ============================================================================

    // Decode instruction fields
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD = InstrD[11:7];
    assign Funct3D = InstrD[14:12];
    assign Funct7b0D = InstrD[25];
    assign Funct7b5D = InstrD[30];
    assign OpD = InstrD[6:0];

    // Register file
    regfile rf(.clk, .WE3(RegWriteW), .A1(Rs1D), .A2(Rs2D),
        .A3(RdW), .WD3(SizedResultW), .RD1(RD1D), .RD2(RD2D));

    // Immediate extension
    extend ext(.Instr(InstrD[31:7]), .ImmSrc(ImmSrcD), .ImmExt(ImmExtD));

    // Pipeline registers: Decode to Execute (Datapath)
    flopenr #(32) D2E_PC(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(PCD), .Q(PCE));
    flopenr #(32) D2E_PCPlus4(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(PCPlus4D), .Q(PCPlus4E));
    flopenr #(5) D2E_Rs1(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(Rs1D), .Q(Rs1E));
    flopenr #(5) D2E_Rs2(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(Rs2D), .Q(Rs2E));
    flopenr #(5) D2E_Rd(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(RdD), .Q(RdE));
    flopenr #(32) D2E_RD1(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(RD1D), .Q(RD1E));
    flopenr #(32) D2E_RD2(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(RD2D), .Q(RD2E));
    flopenr #(32) D2E_ImmExt(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(ImmExtD), .Q(ImmExtE));
    flopenr #(3) D2E_Funct3(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(Funct3D), .Q(Funct3E));
    flopenr #(1) D2E_Funct7b0(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(Funct7b0D), .Q(Funct7b0E));
    flopenr #(1) D2E_Funct7b5(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(Funct7b5D), .Q(Funct7b5E));
    flopenr #(7) D2E_Op(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(OpD), .Q(OpE));
    flopenr #(1) D2E_MemWrite(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(MemWriteD), .Q(MemWriteE));
    flopenr #(1) D2E_ALUResultSrc(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(ALUResultSrcD), .Q(ALUResultSrcE));
    flopenr #(1) D2E_MemEn(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(MemEnD), .Q(MemEnE));

    logic [11:0] csr_addrE;
    flopenr #(12) D2E_CsrAdr(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(InstrD[31:20]), .Q(csr_addrE));

    // Pipeline registers: Decode to Execute (Controller)
    flopenr #(1) D2E_RegWrite(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(RegWriteD), .Q(RegWriteE));
    flopenr #(2) D2E_ResultSrc(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(ResultSrcD), .Q(ResultSrcE));
    flopenr #(1) D2E_Jump(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(JumpD), .Q(JumpE));
    flopenr #(1) D2E_Branch(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(BranchD), .Q(BranchE));
    flopenr #(2) D2E_ALUControl(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(ALUControlD), .Q(ALUControlE));
    flopenr #(2) D2E_ALUSrc(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(ALUSrcD), .Q(ALUSrcE));
    flopenr #(1) D2E_IsJalr(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(IsJalrD), .Q(IsJalrE));
    flopenr #(1) D2E_ALUOp(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(ALUOpD), .Q(ALUOpE));

    // ============================================================================
    // EXECUTE STAGE
    // ============================================================================

    // Comparator for branch conditions
    cmp cmp(.R1(Aout), .R2(Bout), .Eq, .Lt, .Ltu);

    // Forwarding multiplexers for ALU operands
    logic [31:0] ForwardMA;
    logic [31:0] ForwardMB;
    mux2 #(32) forwardMAmux(IEUResultM, CSRReadDataM, ResultSrcM[1], ForwardMA);
    mux2 #(32) forwardMBmux(IEUResultM, CSRReadDataM, ResultSrcM[1], ForwardMB);
    mux3 #(32) forwardAmux(RD1E, SizedResultW, ForwardMA, ForwardAE, Aout);
    mux3 #(32) forwardBmux(RD2E, SizedResultW, ForwardMB, ForwardBE, Bout);

    // ALU source multiplexers
    mux2 #(32) srcamux(Aout, PCE, ALUSrcE[1], SrcAE);
    mux2 #(32) srcbmux(Bout, ImmExtE, ALUSrcE[0], SrcBE);

    // ALU
    alu alu(
        .SrcA(SrcAE),
        .SrcB(SrcBE),
        .ALUControl(ALUControlE),
        .Funct3(Funct3E),
        // .Op(OpE), --> originally used for Zmmul
        // .Funct7b0(Funct7b0E), --> originally used for Zmmul
        .Funct7b5(Funct7b5E),
        .IsJalr(IsJalrE),
        .ALUResult(ALUResultE),
        .IEUAdr(IEUAdrE)
    );

    // Result selection for lui, jalr, and ALU operations
    mux2 #(32) luijalrmux(ImmExtE, PCPlus4E, JumpE, JumpMuxResultE);
    mux2 #(32) ieuresultmux(ALUResultE, JumpMuxResultE, ALUResultSrcE, IEUResultE);

    // Performance monitoring signals
    assign SubE = ALUControlE[1];
    assign HpmAddE = ALUOpE && (Funct3E == 3'b000) && ~SubE;

    // Branch taken signal
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

    // PC source control (jump or taken branch)
    assign PCSrcE = JumpE | HpmBranchTakenE;

    // Performance monitoring signal assembly
    assign HpmSignalE = {
        ALUOpE,                  // hpm[10]: # of R-type and I-type instrs
        JumpE,                   // hpm[9]: # of jumps
        OpE == 7'b011,           // hpm[8]: # of loads from data memory
        MemWriteE,               // hpm[7]: # of writes to data memory
        RegWriteE,               // hpm[6]: # of writes to RegFile
        HpmBranchTakenE,         // hpm[5]: # of branches taken
        BranchE,                 // hpm[4]: # of branches eval
        HpmAddE                  // hpm[3]: # adds
    };

    // Store data alignment for different store types
    always_comb begin
        casez ({Funct3E[1:0], IEUAdrE[1:0]})
            4'b10_??: WriteDataE = Bout; // sw
            4'b01_0?: WriteDataE = {16'b0, Bout[15:0]}; // sh
            4'b01_1?: WriteDataE = {Bout[15:0], 16'b0}; // sh
            4'b00_00: WriteDataE = {24'b0, Bout[7:0]}; // sb
            4'b00_01: WriteDataE = {16'b0, Bout[7:0], 8'b0}; // sb
            4'b00_10: WriteDataE = {8'b0, Bout[7:0], 16'b0}; // sb
            4'b00_11: WriteDataE = {Bout[7:0], 24'b0}; // sb
            default: WriteDataE = Bout;
        endcase
    end

    // Pipeline registers: Execute to Memory (Datapath)
    flopenr #(32) E2M_ALUResult(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(ALUResultE), .Q(ALUResultM));
    flopenr #(8) E2M_HpmSignal(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(HpmSignalE), .Q(HpmSignalM));
    flopenr #(32) E2M_WriteData(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(WriteDataE), .Q(WriteDataM));
    flopenr #(5) E2M_Rd(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(RdE), .Q(RdM));
    flopenr #(32) E2M_PCPlus4(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(PCPlus4E), .Q(PCPlus4M));
    flopenr #(32) E2M_IEUAdr(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(IEUAdrE), .Q(IEUAdrM));
    flopenr #(7) E2M_Op(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(OpE), .Q(OpM));
    flopenr #(1) E2M_MemWrite(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(MemWriteE), .Q(MemWriteM));
    flopenr #(32) E2M_IEUResult(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(IEUResultE), .Q(IEUResultM));
    flopenr #(1) E2M_MemEn(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(MemEnE), .Q(MemEnM));
    flopenr #(12) E2M_CsrAdr(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(csr_addrE), .Q(csr_addrM));
    flopenr #(3) E2M_Funct3(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(Funct3E), .Q(Funct3M));


    // Pipeline registers: Execute to Memory (Controller)
    flopenr #(2) E2M_ResultSrc(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(ResultSrcE), .Q(ResultSrcM));
    flopenr #(1) E2M_RegWrite(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(RegWriteE), .Q(RegWriteM));


    // ============================================================================
    // MEMORY STAGE
    // ============================================================================

    // Memory address lower bits for byte/halfword alignment
    assign IEUAdrb10M = IEUAdrM[1:0];

    // Determine store type based on opcode and funct3
    assign StoreTypeM = (OpM == 7'b0100011) ? Funct3M[1:0] : 2'b11;

    // Determine load type
    assign LoadTypeM = (OpM == 7'b0000011) ? Funct3M : 3'b111;

    // Byte enable generation for stores
    always_comb begin
        casez ({StoreTypeM, IEUAdrb10M})
            4'b10_??: WriteByteEnM = {(4){MemWriteM}}; // sw
            4'b01_0?: WriteByteEnM = {2'b0, {(2){MemWriteM}}}; // sh
            4'b01_1?: WriteByteEnM = {{(2){MemWriteM}}, 2'b0}; // sh
            4'b00_00: WriteByteEnM = {3'b0, MemWriteM}; // sb
            4'b00_01: WriteByteEnM = {2'b0, MemWriteM, 1'b0}; // sb
            4'b00_10: WriteByteEnM = {1'b0, MemWriteM, 2'b0}; // sb
            4'b00_11: WriteByteEnM = {MemWriteM, 3'b0}; // sb
            default: WriteByteEnM = {(4){MemWriteM}};
        endcase
    end

    // Pipeline registers: Memory to Writeback
    flopenr #(5) M2W_Rd(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(RdM), .Q(RdW));
    flopenr #(32) M2W_PCPlus4(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(PCPlus4M), .Q(PCPlus4W));
    flopenr #(32) M2W_ReadData(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(ReadDataM), .Q(ReadDataW));
    flopenr #(32) M2W_ALUResult(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(ALUResultM), .Q(ALUResultW));
    flopenr #(32) M2W_CSRReadData(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(CSRReadDataM), .Q(CSRReadDataW));
    flopenr #(32) M2W_IEUResult(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(IEUResultM), .Q(IEUResultW));
    flopenr #(2) M2W_ResultSrc(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(ResultSrcM), .Q(ResultSrcW));
    flopenr #(3) M2W_LoadType(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(LoadTypeM), .Q(LoadTypeW));
    flopenr #(1) M2W_RegWrite(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(RegWriteM), .Q(RegWriteW));

    // ============================================================================
    // WRITEBACK STAGE
    // ============================================================================

    // Result multiplexer: select between ALU result, memory data, or CSR data
    mux3 #(32) resultmux(IEUResultW, ReadDataW, CSRReadDataW, ResultSrcW, ResultW);

    // Load data sizing and sign extension
    mux2 #(16) halfmux(ResultW[15:0], ResultW[31:16], IEUResultW[1], HalfResultW);
    mux2 #(8) bytemux(HalfResultW[7:0], HalfResultW[15:8], IEUResultW[0], ByteResultW);

    always_comb begin
        case (LoadTypeW)
            3'b010: SizedResultW = ResultW; // lw
            3'b001: SizedResultW = {{16{HalfResultW[15]}}, HalfResultW}; // lh
            3'b101: SizedResultW = {16'b0, HalfResultW}; // lhu
            3'b000: SizedResultW = {{24{ByteResultW[7]}}, ByteResultW}; // lb
            3'b100: SizedResultW = {24'b0, ByteResultW}; // lbu
            default: SizedResultW = ResultW;
        endcase
    end

endmodule
