// alu.sv
// RISC-V pipelined processor
// sanarayanan@hmc.edu, sgopalakrishnan@hmc.edu 2026

module alu(
    input  logic [31:0]  SrcA,
    input  logic [31:0]  SrcB,
    input  logic [1:0]   ALUControl,
    input  logic [2:0]   Funct3,
    input  logic         Funct7b5,
    input  logic         IsJalr,
    output logic [31:0]  ALUResult,
    output logic [31:0]  IEUAdr
);

// ----------------------------------
// Internal signals
// ----------------------------------
logic [32:0] SumExt;
logic [31:0] CondInvb, Sum, SLT, SLTU;
logic ALUOp, Sub, Overflow, Neg, LT;
logic [2:0] ALUFunct;

// ALUControl fields: {Sub, ALUOp}
assign {Sub, ALUOp} = ALUControl;

// ----------------------------------
// Add/subtract and address generation
// ----------------------------------
assign CondInvb = Sub ? ~SrcB : SrcB;
assign Sum = SrcA + CondInvb + {{31{1'b0}}, Sub};

// JALR target must be aligned to 2 bytes by clearing bit 0
assign IEUAdr = IsJalr ? (Sum & ~32'd1) : Sum;

// ----------------------------------
// Set Less Than logic
// ----------------------------------
// signed less-than: result of Sub operation from ALU plus overflow handling
assign Overflow = (SrcA[31] ^ SrcB[31]) & (SrcA[31] ^ Sum[31]);
assign Neg = Sum[31];
assign LT = Neg ^ Overflow;
assign SLT = {31'b0, LT};

// unsigned less-than
assign SumExt = {1'b0, SrcA} + {1'b0, ~SrcB} + 1'b1;
assign SLTU = {31'b0, ~SumExt[32]};

// Function selection for ALU operations (force add path when ALUOp=0)
assign ALUFunct = Funct3 & {3{ALUOp}};

// ----------------------------------
// ALU operation multiplexer
// ----------------------------------
always_comb begin
    case (ALUFunct)
        3'b000: ALUResult = Sum;            // add/sub
        3'b010: ALUResult = SLT;            // slt
        3'b011: ALUResult = SLTU;           // sltu
        3'b110: ALUResult = SrcA | SrcB;    // or
        3'b100: ALUResult = SrcA ^ SrcB;    // xor
        3'b111: ALUResult = SrcA & SrcB;    // and
        3'b001: ALUResult = SrcA << SrcB[4:0]; // sll

        3'b101: begin
            if (!Funct7b5)
                ALUResult = SrcA >> SrcB[4:0];        // srl
            else
                ALUResult = $signed(SrcA) >>> SrcB[4:0]; // sra
        end

        default: ALUResult = 'x;
    endcase
end

endmodule
