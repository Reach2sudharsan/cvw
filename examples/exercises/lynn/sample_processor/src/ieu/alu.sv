// // alu.sv
// // RISC-V pipelined processor
// // sanarayanan@hmc.edu, sgopalakrishnan@hmc.edu 2026

// module alu(
//     input  logic [31:0]  SrcA,
//     input  logic [31:0]  SrcB,
//     input  logic [1:0]   ALUControl,
//     input  logic [2:0]   Funct3,
//     input  logic         Funct7b5,
//     input  logic         IsJalr,
//     output logic [31:0]  ALUResult,
//     output logic [31:0]  IEUAdr
// );

// // ----------------------------------
// // Internal signals
// // ----------------------------------
// logic [32:0] SumExt;
// logic [31:0] CondInvb, Sum, SLT, SLTU;
// logic ALUOp, Sub, Overflow, Neg, LT;
// logic [2:0] ALUFunct;

// // ALUControl fields: {Sub, ALUOp}
// assign {Sub, ALUOp} = ALUControl;

// // ----------------------------------
// // Add/subtract and address generation
// // ----------------------------------
// assign CondInvb = Sub ? ~SrcB : SrcB;
// assign Sum = SrcA + CondInvb + {{31{1'b0}}, Sub};

// // JALR target must be aligned to 2 bytes by clearing bit 0
// assign IEUAdr = IsJalr ? (Sum & ~32'd1) : Sum;

// // ----------------------------------
// // Set Less Than logic
// // ----------------------------------
// // signed less-than: result of Sub operation from ALU plus overflow handling
// assign Overflow = (SrcA[31] ^ SrcB[31]) & (SrcA[31] ^ Sum[31]);
// assign Neg = Sum[31];
// assign LT = Neg ^ Overflow;
// assign SLT = {31'b0, LT};

// // unsigned less-than
// assign SumExt = {1'b0, SrcA} + {1'b0, ~SrcB} + 1'b1;
// assign SLTU = {31'b0, ~SumExt[32]};

// // Function selection for ALU operations (force add path when ALUOp=0)
// assign ALUFunct = Funct3 & {3{ALUOp}};

// // ----------------------------------
// // ALU operation multiplexer
// // ----------------------------------
// always_comb begin
//     case (ALUFunct)
//         3'b000: ALUResult = Sum;            // add/sub
//         3'b010: ALUResult = SLT;            // slt
//         3'b011: ALUResult = SLTU;           // sltu
//         3'b110: ALUResult = SrcA | SrcB;    // or
//         3'b100: ALUResult = SrcA ^ SrcB;    // xor
//         3'b111: ALUResult = SrcA & SrcB;    // and
//         3'b001: ALUResult = SrcA << SrcB[4:0]; // sll

//         3'b101: begin
//             if (!Funct7b5)
//                 ALUResult = SrcA >> SrcB[4:0];        // srl
//             else
//                 ALUResult = $signed(SrcA) >>> SrcB[4:0]; // sra
//         end

//         default: ALUResult = 'x;
//     endcase
// end

// endmodule

// alu.sv
// RISC-V pipelined processor
// sanarayanan@hmc.edu, sgopalakrishnan@hmc.edu 2026

module alu(
        input   logic [31:0]    SrcA, SrcB,
        input   logic [1:0]     ALUControl,
        input   logic [2:0]     Funct3,
        input   logic [6:0]     Op,
        input   logic           Funct7b0, // NEW INPUT ADDED
        input   logic           Funct7b5, // NEW INPUT ADDED
        input   logic           IsJalr,
        output  logic [31:0]    ALUResult, IEUAdr
    );

    logic [32:0] SumExt;
    logic [31:0] CondInvb, Sum, SLT, SLTU;
    logic ALUOp, Sub, Overflow, Neg, LT;
    logic [2:0] ALUFunct;
    logic [63:0] mul_tmp, mulhu_tmp;
    logic signed [63:0] mulhsu_tmp;


    assign {Sub, ALUOp} = ALUControl;

    // Add or subtract
    assign CondInvb = Sub ? ~SrcB : SrcB;
    assign Sum = SrcA + CondInvb + {{(31){1'b0}}, Sub};

    // need to take into account jalr, which must use mask of ~1 to align address

    // Send this out to IFU and LSU, for optimizing instrs with PC+imm
    assign IEUAdr = IsJalr ? (Sum&~1) : Sum;

    // Set less than based on subtraction result
    assign Overflow = (SrcA[31] ^ SrcB[31]) & (SrcA[31] ^ Sum[31]);
    assign Neg = Sum[31];
    assign LT = Neg ^ Overflow;
    assign SLT = {31'b0, LT};

    // Set less than unsigned
    assign SumExt = {1'b0, SrcA} + {1'b0, ~SrcB} + 1'b1;
    assign SLTU = {31'b0, ~SumExt[32]};


    assign ALUFunct = Funct3 & {3{ALUOp}}; // Force ALUFunct to 0 to Add when ALUOp = 0


    ////////////////////// MULTIPLY //////////////////////
    logic signed [32:0] SrcA_ext, SrcB_ext;
    logic signed [65:0] product;
    logic        isMul;

    assign isMul = Funct7b0 & (Op == 7'b0110011);

    // Sign-extend or zero-extend based on operation
    // ALUFunct = Funct3 when ALUOp=1
    // 3'b010 = MULHSU: SrcA signed, SrcB unsigned
    // 3'b011 = MULHU:  both unsigned
    // all others (000, 001): both signed
    always_comb begin
        case (ALUFunct)
            3'b011: begin  // MULHU: unsigned × unsigned
                SrcA_ext = {1'b0, SrcA};
                SrcB_ext = {1'b0, SrcB};
            end
            3'b010: begin  // MULHSU: signed × unsigned
                SrcA_ext = {SrcA[31], SrcA};
                SrcB_ext = {1'b0,     SrcB};
            end
            default: begin // MUL, MULH: signed × signed
                SrcA_ext = {SrcA[31], SrcA};
                SrcB_ext = {SrcB[31], SrcB};
            end
        endcase
    end

    ////////////////////////////////////////////

    // ONE multiplier — synthesis will share this across MUL/MULH/MULHSU/MULHU
    assign product = SrcA_ext * SrcB_ext;


    always_comb begin
        // mul_tmp = $signed({{32{SrcA[31]}}, SrcA}) * $signed({{32{SrcB[31]}}, SrcB}); // 64-bit product
        // mulhsu_tmp = $signed({{32{SrcA[31]}}, SrcA}) * $unsigned({32'b0, SrcB});   // signed × unsigned
        // mulhu_tmp = {32'b0, SrcA} * {32'b0, SrcB};;             // unsigned × unsigned

        case (ALUFunct)
            3'b000: ALUResult = isMul ? product[31:0]  : Sum;          // MUL or ADD/SUB
            3'b001: ALUResult = isMul ? product[63:32] : SrcA << SrcB[4:0]; // MULH or SLL
            3'b010: ALUResult = isMul ? product[63:32] : SLT;          // MULHSU or SLT
            3'b011: ALUResult = isMul ? product[63:32] : SLTU;         // MULHU or SLTU

            3'b110: ALUResult = SrcA | SrcB; // or
            3'b100: ALUResult = SrcA ^ SrcB; // xori
            3'b111: ALUResult = SrcA & SrcB; // and

            3'b101:
                    case(Funct7b5)
                        0: ALUResult = SrcA >> SrcB[4:0]; // srl
                        1: ALUResult = $signed(SrcA) >>> SrcB[4:0]; // sra
                        default: ALUResult = 'x;
                    endcase
            default: ALUResult = 'x;
        endcase
    end

    // always_comb begin
        // if (IsJalr) begin
            // $display("ALU JALR: SrcA=%h SrcB=%h Sum=%h IEUAdr=%h",
                    // SrcA, SrcB, Sum, IEUAdr);
        // end
    // end
endmodule
