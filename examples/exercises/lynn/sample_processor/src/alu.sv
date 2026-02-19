// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

module alu(
        input   logic [31:0]    SrcA, SrcB,
        input   logic [1:0]     ALUControl,
        input   logic [2:0]     Funct3,
        input   logic           Funct7b5, // NEW INPUT ADDED
        output  logic [31:0]    ALUResult, IEUAdr
    );

    logic [32:0] SumExt;
    logic [31:0] CondInvb, Sum, SLT, SLTU;
    logic ALUOp, Sub, Overflow, Neg, LT;
    logic [2:0] ALUFunct;

    assign {Sub, ALUOp} = ALUControl;

    // Add or subtract
    assign CondInvb = Sub ? ~SrcB : SrcB;
    assign Sum = SrcA + CondInvb + {{(31){1'b0}}, Sub};
    assign IEUAdr = Sum; // Send this out to IFU and LSU, for optimizing instrs with PC+imm

    // Set less than based on subtraction result
    assign Overflow = (SrcA[31] ^ SrcB[31]) & (SrcA[31] ^ Sum[31]);
    assign Neg = Sum[31];
    assign LT = Neg ^ Overflow;
    assign SLT = {31'b0, LT};

    // Set less than unsigned
    assign SumExt = {1'b0, SrcA} + {1'b0, ~SrcB} + 1'b1;
    assign SLTU = {31'b0, ~SumExt[32]};


    assign ALUFunct = Funct3 & {3{ALUOp}}; // Force ALUFunct to 0 to Add when ALUOp = 0


    always_comb begin
        case (ALUFunct)
            3'b000: ALUResult = Sum; // add or sub
            3'b010: ALUResult = SLT; // slt
            3'b011: ALUResult = SLTU; // sltu
            3'b110: ALUResult = SrcA | SrcB; // or
            3'b100: ALUResult = SrcA ^ SrcB; // xori
            3'b111: ALUResult = SrcA & SrcB; // and
            3'b001: ALUResult = SrcA << SrcB[4:0]; // sll
            3'b101:
                    case(Funct7b5)
                        0: ALUResult = SrcA >> SrcB[4:0]; // srl
                        1: ALUResult = $signed(SrcA) >>> SrcB[4:0]; // sra
                        default: ALUResult = 'x;
                    endcase
            default: ALUResult = 'x;
        endcase
    end
endmodule
