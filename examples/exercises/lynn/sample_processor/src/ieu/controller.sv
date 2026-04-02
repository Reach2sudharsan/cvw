// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

`include "parameters.svh"

module controller(
        input   logic [6:0]   Op,
        input   logic         Eq, Lt, Ltu,
        input   logic [1:0]   IEUAdrb10,
        input   logic [2:0]   Funct3,
        // input   logic         Funct7b0,
        input   logic         Funct7b5,
        output  logic         ALUResultSrc,
        output  logic [1:0]   ResultSrc,
        // output  logic [3:0]   WriteByteEn,
        // output  logic         PCSrc,
        output  logic         RegWrite,
        output  logic [1:0]   ALUSrc,
        output  logic [2:0]   ImmSrc,
        output  logic [1:0]   ALUControl,
        output  logic         MemEn,
        output  logic         Jump, // NEW SIGNAL ADDED
        output  logic         IsJalr,
        output  logic         Branch,
        output  logic         MemWrite,
        // output  logic         CSR
        // output  logic         CSRSrc;

        // considering just having a single N-bit signal for HPM counters

        output logic          ALUOp

    `ifdef DEBUG
        , input   logic [31:0]  insn_debug
    `endif
    );

    // logic Branch;
    logic Sub;
    // logic MemWrite;
    logic [13:0] controls;
    logic [1:0] StoreType;

    logic HpmAdd, HpmBranchTaken;

    // Main decoder
    always_comb
        case(Op)
            // RegWrite_ImmSrc_ALUSrc_ALUOp_ALUResultSrc_MemWrite_ResultSrc_Branch_Jump_Load
            7'b0000011: controls = 14'b1_000_01_0_0_0_01_0_0_1; // lw
            7'b0100011: controls = 14'b0_001_01_0_0_1_00_0_0_1; // sw
            7'b0110011: controls = 14'b1_xxx_00_1_0_0_00_0_0_0; // R-type
            7'b0010011: controls = 14'b1_000_01_1_0_0_00_0_0_0; // I-type ALU
            7'b1100011: controls = 14'b0_010_11_0_0_0_00_1_0_0; // B-type
            7'b1101111: controls = 14'b1_011_11_0_1_0_00_0_1_0; // jal
            7'b0110111: controls = 14'b1_100_xx_0_1_0_00_0_0_0; // lui
            7'b0010111: controls = 14'b1_100_11_0_0_0_00_0_0_0; // aupic
            7'b1100111: controls = 14'b1_000_01_1_1_0_00_0_1_0; // jalr
            7'b1110011: controls = 14'b1_xxx_xx_x_x_0_10_0_0_0; // csrrs

            default: begin
                `ifdef DEBUG
                    controls = 14'bx_xxx_xx_x_x_x_xx_x_x_x; // non-implemented instruction
                    if ((insn_debug !== 'x)) begin
                        $display("Instruction not implemented: %h", insn_debug);
                        $finish(-1);
                    end
                `else
                    controls = 14'b0; // non-implemented instruction
                `endif
            end
        endcase

    assign {RegWrite, ImmSrc, ALUSrc, ALUOp, ALUResultSrc, MemWrite,
        ResultSrc, Branch, Jump, MemEn} = controls;

    // ALU Control Logic
    // assign Sub = ALUOp & ((Funct3 == 3'b000) & Funct7b5 & Op[5] | (Funct3 == 3'b010)); // subtract or SLT
    assign Sub = ALUOp & (Op[5:0] != 6'b100111) & ((Funct3 == 3'b000) & Funct7b5 & Op[5] & ~Op[2] | (Funct3 == 3'b010));
    assign ALUControl = {Sub, ALUOp};

    // assign HpmAdd = ALUOp && (Funct3 == 3'b000) && ~Sub;
    // // assign HpmBranch = Branch;
    // assign HpmBranchTaken =
    //     (Branch &
    //         (
    //             Eq & (Funct3 == 3'b000)     |
    //             ~Eq & (Funct3 == 3'b001)    |
    //             Lt & (Funct3 == 3'b100)     |
    //             ~Lt & (Funct3 == 3'b101)    |
    //             Ltu & (Funct3 == 3'b110)    |
    //             ~Ltu & (Funct3 == 3'b111)
    //         )
    //     );

    // // PCSrc logic
    // assign PCSrc = Jump | HpmBranchTaken;

    // // hpm[10]_hpm[9]_hpm[8]_hpm[7]_hpm[6]_hpm[5]_hpm[4]_hpm[3]
    // assign HpmSignal = {
    //             ALUOp,                  // hpm[10]: # of R-type and I-type instrs
    //             Jump,                   // hpm[9]: # of jumps
    //             Op == 7'b011,           // hpm[8]: # of loads from data memory
    //             MemWrite,               // hpm[7]: # of writes to data memory
    //             RegWrite,               // hpm[6]: # of writes to RegFile
    //             HpmBranchTaken,         // hpm[5]: # of branches taken
    //             Branch,                 // hpm[4]: # of branches eval
    //             HpmAdd                  // hpm[3]: # adds
    //         };


    // MemWrite logic
    // assign WriteByteEn = {(4){MemWrite}}; // currently assigns all 4 bytes to MemWrite

    // assign StoreType = (Op == 7'b0100011) ? Funct3[1:0] : 2'b11;

    // always_comb begin
    //     casez ({StoreType, IEUAdrb10})
    //         4'b10_??: WriteByteEn = {(4){MemWrite}}; // sw

    //         4'b01_0?: WriteByteEn = {2'b0, {(2){MemWrite}}}; // sh
    //         4'b01_1?: WriteByteEn = {{(2){MemWrite}}, 2'b0}; // sh

    //         4'b00_00: WriteByteEn = {3'b0, MemWrite}; // sb
    //         4'b00_01: WriteByteEn = {2'b0, MemWrite, 1'b0}; // sb
    //         4'b00_10: WriteByteEn = {1'b0, MemWrite, 2'b0}; // sb
    //         4'b00_11: WriteByteEn = {MemWrite, 3'b0}; // sb


    //         default: WriteByteEn = {(4){MemWrite}};


    //     endcase
    // end

    assign IsJalr = (Op == 7'b1100111) & (Funct3 == 3'b000);

    // always_comb begin
        // if (Op == 7'b1100111)
            // $display("Controller: MemEn=%0d MemWrite=%0d", MemEn, MemWrite);
    // end



endmodule



 /*
    RTYPE:
    01 - All others
    11 - Subtraction or SLT

    I-TYPE:
    01 - All others
    11 - Subtraction or SLT

    JALR:
    Sub = 1 & (Funct == 000 and Funct7b5 and OP 5 == 1)


    */

    /*
    HPM CSRs


    hpm 3: # of add instructions
        just check to see if ALUOP = 1, Sun = 0, and Funct3 == 000 and increment by 1

    hpm 4: # of branches evaluated
        just check branch flag and increment by 1

    hpm 5: # of branches taken
        just check branch flag and specifically
            (Branch &
                (
                    Eq & (Funct3 == 3'b000)     |
                    ~Eq & (Funct3 == 3'b001)    |
                    Lt & (Funct3 == 3'b100)     |
                    ~Lt & (Funct3 == 3'b101)    |
                    Ltu & (Funct3 == 3'b110)    |
                    ~Ltu & (Funct3 == 3'b111)
                )

    hpm 6: # writes to RegFile
        just check RegWrite

    hpm 7: # writes to data memory (in other words, any store instruction)
        just check MemWrite

    hpm 8: # reads from data memory (in other words, any load instruction)
        just check op == 11

    hpm 9: # jump instructions
        just check Jump

    hpm 10: # R-type and I-type
        just check ALUOp

    */
