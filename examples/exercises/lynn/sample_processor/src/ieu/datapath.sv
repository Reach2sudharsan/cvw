// datapath.sv
// RISC-V pipelined processor
// sanarayanan@hmc.edu, sgopalakrishnan@hmc.edu 2026

module datapath #(
    parameter BUFFER_SIZE,
    parameter TAG_SIZE,
    parameter PHT_SIZE = 256, // NEW
    parameter GHR_WIDTH = 8 // NEW
    ) (
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
    output  logic [31:0]    NextAdrE, IEUAdrM, WriteDataM,
    output  logic [1:0]     IEUAdrb10M,
    // Branch/jump control
    output  logic  [1:0]         PCSrcE,
    output  logic [31:0]    JumpTargetD,
    output logic            JumpPredictD,
    output logic [31:0] branch_targetF,


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
    logic [31:0] ALUResultE, ALUResultM, ALUResultW, IEUResultE, IEUResultM, IEUResultTempM, IEUResultW, JumpMuxResultE;
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
    logic RegWriteE, RegWriteM, RegWriteW, JumpE, BranchE, ALUOpE;
    logic [1:0] ALUSrcE;
    logic IsJalrE;
    logic [1:0] ResultSrcE, ResultSrcM, ResultSrcW, ALUControlE;
    logic [31:0] IEUAdrE, IEUAdrW;
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
    logic IsMulD, IsMulE, IsMulM;
    logic [2:0] ALUFunctD, ALUFunctE, ALUFunctM;

    // logic AmsbE, BmsbE;
    logic [31:0] productE;

    // 8-bit partial products: 16 terms, each 18-bit signed (9x9)
    logic signed [17:0] P00E, P01E, P02E, P03E;
    logic signed [17:0] P10E, P11E, P12E, P13E;
    logic signed [17:0] P20E, P21E, P22E, P23E;
    logic signed [17:0] P30E, P31E, P32E, P33E;

    logic signed [17:0] P00M, P01M, P02M, P03M;
    logic signed [17:0] P10M, P11M, P12M, P13M;
    logic signed [17:0] P20M, P21M, P22M, P23M;
    logic signed [17:0] P30M, P31M, P32M, P33M;


    // Branch Prediction
    logic [32+TAG_SIZE:0] BTB [BUFFER_SIZE-1:0];
    logic [$clog2(BUFFER_SIZE)-1:0] buffer_indexF, buffer_indexE;

    logic branch_predictedF, branch_predictedD, branch_predictedE;

    logic [TAG_SIZE-1:0] branch_tagF, branch_tagE;
    logic branch_validF;

    logic [1:0] PHT [PHT_SIZE-1:0];
    logic [$clog2(PHT_SIZE)-1:0] pht_indexF, pht_indexE;

    logic [GHR_WIDTH-1:0] GHRF, GHRD, GHRE;


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
        .FlushE(FlushE),
        .JumpPredict(JumpPredictD),
        .IsMulE(IsMulE)
    );

    // ============================================================================
    // FETCH STAGE
    // ============================================================================

    // ============================================================================
    // BRANCH PREDICTION LOGIC (G-share Predictor)
    // ============================================================================
    // G-share predictor combines:
    //   - Branch Target Buffer (BTB): stores branch target addresses and tags
    //   - Pattern History Table (PHT): stores 2-bit branch prediction counters
    //   - Global History Register (GHR): tracks recent branch outcomes
    //
    // PC BIT ALLOCATION (CRITICAL):
    //   Bits [1:0]   - always 0 (word alignment)
    //   Bits [N+1:2] - BTB/Buffer index, where N = $clog2(BUFFER_SIZE)
    //   Bits [N+1+TAG_SIZE-1:N+2] - BTB tag (TAG_SIZE bits for uniqueness)
    //
    // For example with BUFFER_SIZE=32 ($clog2=5), TAG_SIZE=16:
    //   Bits [6:2] (5 bits)  - buffer index (selects one of 32 BTB entries)
    //   Bits [22:7] (16 bits) - tag for matching (ensures correct entry)
    //
    // PHT INDEXING (G-share):
    //   pht_index = GHR XOR buffer_index
    //   This combines global history with local address for better prediction
    // ============================================================================

    // Fetch stage assignments
    assign InstrF = Instr;
    assign PCF = PC;
    assign PCPlus4F = PCPlus4;

    assign buffer_indexF = PCF[$clog2(BUFFER_SIZE)+1:2];
    // assign pht_indexF = {3'b0, GHRF[2:0]} ^ buffer_indexF;
    assign pht_indexF = GHRF ^ {PCF[$clog2(BUFFER_SIZE)+2], buffer_indexF};
    // assign pht_indexF = GHRF ^ buffer_indexF;

    assign branch_targetF = BTB[buffer_indexF][31:0];
    assign branch_tagF = BTB[buffer_indexF][32+TAG_SIZE-1:32];
    assign branch_validF = BTB[buffer_indexF][32+TAG_SIZE];

     assign branch_predictedF = PHT[pht_indexF][1] && branch_validF && (branch_tagF == PCF[$clog2(BUFFER_SIZE)+TAG_SIZE+1:$clog2(BUFFER_SIZE)+2]) && ~reset;

    // Pipeline registers: Fetch to Decode
    flopenr #(32) F2D_instr(.clk(clk), .reset(reset), .enable(~StallD), .flush(FlushD), .D(InstrF), .Q(InstrD));
    flopenr #(32) F2D_PC(.clk(clk), .reset(reset), .enable(~StallD), .flush(FlushD), .D(PCF), .Q(PCD));
    flopenr #(32) F2D_PCPlus4(.clk(clk), .reset(reset), .enable(~StallD), .flush(FlushD), .D(PCPlus4F), .Q(PCPlus4D));
    flopenr #(1) F2D_branch_predicted(.clk(clk), .reset(reset), .enable(~StallD), .flush(FlushD), .D(branch_predictedF), .Q(branch_predictedD));
    flopenr #(GHR_WIDTH) F2D_GHR(.clk(clk), .reset(reset), .enable(~StallD), .flush(FlushD), .D(GHRF), .Q(GHRD));

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

    // multiply signals
    assign IsMulD = Funct7b0D & (OpD == 7'b0110011);
    assign ALUFunctD =  Funct3D & {3{ALUOpD}};

    logic JumpPredictE;
    assign JumpPredictD = (JumpD & OpD[3]);

    assign JumpTargetD = ImmExtD + PCD;


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

    flopenr #(1) D2E_IsMul(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(IsMulD), .Q(IsMulE));
    flopenr #(3) D2E_ALUFunct(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(ALUFunctD), .Q(ALUFunctE));

    flopenr #(1) D2E_JumpPredict(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(JumpPredictD), .Q(JumpPredictE));

    flopenr #(GHR_WIDTH) D2E_GHR(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(GHRD), .Q(GHRE));
    flopenr #(1) D2E_branch_predicted(.clk(clk), .reset(reset), .enable(1'b1), .flush(FlushE), .D(branch_predictedD), .Q(branch_predictedE));


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
        .Op(OpE), // --> originally used for Zmmul
        .Funct7b0(Funct7b0E), // --> originally used for Zmmul
        .Funct7b5(Funct7b5E),
        .IsJalr(IsJalrE),
        .ALUResult(ALUResultE),
        .IEUAdr(IEUAdrE)
    );

    // Multiply — 8-bit partial products, 4x4 grid of 9x9 signed multipliers
    multiply multiply(
        .SrcAE(SrcAE), .SrcBE(SrcBE),
        .ALUFunctb01E(ALUFunctE[1:0]),
        .P00(P00E), .P01(P01E), .P02(P02E), .P03(P03E),
        .P10(P10E), .P11(P11E), .P12(P12E), .P13(P13E),
        .P20(P20E), .P21(P21E), .P22(P22E), .P23(P23E),
        .P30(P30E), .P31(P31E), .P32(P32E), .P33(P33E)
    );

    // Result selection for lui, jalr, and ALU operations
    mux2 #(32) luijalrmux(ImmExtE, PCPlus4E, JumpE, JumpMuxResultE);
    mux2 #(32) ieuresultmux(ALUResultE, JumpMuxResultE, ALUResultSrcE, IEUResultE);

    // Performance monitoring signals
    assign SubE = ALUControlE[1];
    assign HpmAddE = ALUOpE && (Funct3E == 3'b000) && ~SubE;

    // Branch taken signal
    logic BranchValidE;

    assign BranchValidE = (
                Eq & (Funct3E == 3'b000)     |
                ~Eq & (Funct3E == 3'b001)    |
                Lt & (Funct3E == 3'b100)     |
                ~Lt & (Funct3E == 3'b101)    |
                Ltu & (Funct3E == 3'b110)    |
                ~Ltu & (Funct3E == 3'b111)
            );

    assign HpmBranchTakenE = BranchE & BranchValidE;


    // branch prediction


    assign buffer_indexE = PCE[$clog2(BUFFER_SIZE)+1:2];
    assign pht_indexE = GHRE ^ {PCE[$clog2(BUFFER_SIZE)+2], buffer_indexE};



    logic branch_mispredicted;
    assign branch_mispredicted = HpmBranchTakenE != branch_predictedE;


    always_comb begin
        if ((JumpE&(~JumpPredictE)) | (branch_mispredicted)) PCSrcE = 2'b01;
        else if (JumpPredictD) PCSrcE = 2'b10;
        else if (branch_predictedF) PCSrcE = 2'b11;
        else PCSrcE = 2'b00;
    end


    mux2 #(32) branchpredictmux(PCPlus4E, IEUAdrE, (branch_mispredicted & BranchValidE) || (JumpE&(~JumpPredictE))  , NextAdrE);


    // BTB
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            for (int i = 0; i < BUFFER_SIZE; i++)
                BTB[i] <= {(33+TAG_SIZE){1'b0}};
        end else begin
            if (BranchE) begin
                // BTB[buffer_indexE] <= {1'b1, PCE[$clog2(BUFFER_SIZE)+1+TAG_SIZE-1:$clog2(BUFFER_SIZE)+2], IEUAdrE};
                BTB[buffer_indexE] <= {1'b1, PCE[$clog2(BUFFER_SIZE)+TAG_SIZE+1:$clog2(BUFFER_SIZE)+2], IEUAdrE};
            end
        end
    end

    // PHT (Pattern History Table) - 2-bit saturating counters
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            for (int i = 0; i < PHT_SIZE; i++)
                PHT[i] <= 2'b01;  // Initialize to weakly not taken
        end else if (BranchE) begin
            // Always update on branch execution based on actual outcome
            if (BranchValidE) begin
                // Branch was taken: increment toward 11 (strongly taken)
                if (PHT[pht_indexE] != 2'b11) PHT[pht_indexE] <= PHT[pht_indexE] + 1;
            end else begin
                // Branch was not taken: decrement toward 00 (strongly not taken)
                if (PHT[pht_indexE] != 2'b00) PHT[pht_indexE] <= PHT[pht_indexE] - 1;
            end
        end
    end

    // GHR (Global History Register) - shifts in branch outcomes
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            GHRF <= '0;
        end else if (BranchE) begin
            // Shift left and insert new branch outcome (BranchValidE = taken if 1)
            GHRF <= {GHRF[GHR_WIDTH-2:0], BranchValidE};
        end
    end



    // Performance monitoring signal assembly
    assign HpmSignalE = {
        ALUOpE,                  // hpm[10]: # of R-type and I-type instrs
        JumpE,                   // hpm[9]: # of jumps
        OpE == 7'b011,           // hpm[8]: # of loads from data memory
        MemWriteE,               // hpm[7]: # of writes to data memory
        RegWriteE,               // hpm[6]: # of writes to RegFile
        HpmBranchTakenE,         // hpm[5]: # of branches taken
        branch_predictedF,       // hpm[4]: # originally branches, now number of branches predicted in Fetch
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

    // 8-bit partial product pipeline registers: Execute → Memory (16 x 18-bit)
    flopenr #(18) E2M_P00(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P00E), .Q(P00M));
    flopenr #(18) E2M_P01(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P01E), .Q(P01M));
    flopenr #(18) E2M_P02(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P02E), .Q(P02M));
    flopenr #(18) E2M_P03(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P03E), .Q(P03M));
    flopenr #(18) E2M_P10(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P10E), .Q(P10M));
    flopenr #(18) E2M_P11(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P11E), .Q(P11M));
    flopenr #(18) E2M_P12(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P12E), .Q(P12M));
    flopenr #(18) E2M_P13(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P13E), .Q(P13M));
    flopenr #(18) E2M_P20(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P20E), .Q(P20M));
    flopenr #(18) E2M_P21(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P21E), .Q(P21M));
    flopenr #(18) E2M_P22(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P22E), .Q(P22M));
    flopenr #(18) E2M_P23(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P23E), .Q(P23M));
    flopenr #(18) E2M_P30(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P30E), .Q(P30M));
    flopenr #(18) E2M_P31(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P31E), .Q(P31M));
    flopenr #(18) E2M_P32(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P32E), .Q(P32M));
    flopenr #(18) E2M_P33(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(P33E), .Q(P33M));

    flopenr #(1) E2M_IsMul(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(IsMulE), .Q(IsMulM));
    flopenr #(3) E2M_ALUFunct(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(ALUFunctE), .Q(ALUFunctM));

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

    // Accumulate 16 partial products into 64-bit result
    // Pij is shifted by (i+j)*8 bits; each sign-extended from 18 to 64 bits
    logic signed [63:0] origProductM;
    logic [31:0] productM;

    always_comb begin
        origProductM =
            ({{46{P00M[17]}}, P00M}       ) +   // shift  0
            ({{46{P01M[17]}}, P01M} <<  8 ) +   // shift  8
            ({{46{P02M[17]}}, P02M} << 16 ) +   // shift 16
            ({{46{P03M[17]}}, P03M} << 24 ) +   // shift 24
            ({{46{P10M[17]}}, P10M} <<  8 ) +   // shift  8
            ({{46{P11M[17]}}, P11M} << 16 ) +   // shift 16
            ({{46{P12M[17]}}, P12M} << 24 ) +   // shift 24
            ({{46{P13M[17]}}, P13M} << 32 ) +   // shift 32
            ({{46{P20M[17]}}, P20M} << 16 ) +   // shift 16
            ({{46{P21M[17]}}, P21M} << 24 ) +   // shift 24
            ({{46{P22M[17]}}, P22M} << 32 ) +   // shift 32
            ({{46{P23M[17]}}, P23M} << 40 ) +   // shift 40
            ({{46{P30M[17]}}, P30M} << 24 ) +   // shift 24
            ({{46{P31M[17]}}, P31M} << 32 ) +   // shift 32
            ({{46{P32M[17]}}, P32M} << 40 ) +   // shift 40
            ({{46{P33M[17]}}, P33M} << 48 );    // shift 48
    end

    always_comb begin
        case (ALUFunctM[1:0])
            2'b00: productM = origProductM[31:0]; // MUL {$signed(SrcAE) * $signed(SrcBE)}[31:0];
            default:  // MULH, MULHU, MULHSU
                begin
                    productM = origProductM[63:32]; // origProduct[63:32];
                end
        endcase
    end


    logic [31:0] NewIEUResultM;
    mux2 #(32) selectresult(IEUResultM, productM, IsMulM, NewIEUResultM);

    // Pipeline registers: Memory to Writeback
    flopenr #(5) M2W_Rd(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(RdM), .Q(RdW));
    flopenr #(32) M2W_PCPlus4(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(PCPlus4M), .Q(PCPlus4W));
    flopenr #(32) M2W_ReadData(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(ReadDataM), .Q(ReadDataW));
    flopenr #(32) M2W_ALUResult(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(ALUResultM), .Q(ALUResultW));
    flopenr #(32) M2W_CSRReadData(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(CSRReadDataM), .Q(CSRReadDataW));
    flopenr #(32) M2W_IEUResult(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(NewIEUResultM), .Q(IEUResultW));
    flopenr #(2) M2W_ResultSrc(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(ResultSrcM), .Q(ResultSrcW));
    flopenr #(3) M2W_LoadType(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(LoadTypeM), .Q(LoadTypeW));
    flopenr #(1) M2W_RegWrite(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(RegWriteM), .Q(RegWriteW));
    // flopenr #(32) M2W_Product(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0), .D(productM), .Q(productW));


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
