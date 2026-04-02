// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

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


    always_comb begin
        mul_tmp = 64'b0;//$signed({{32{SrcA[31]}}, SrcA}) * $signed({{32{SrcB[31]}}, SrcB}); // 64-bit product
        mulhsu_tmp = 64'b0;//$signed({{32{SrcA[31]}}, SrcA}) * $unsigned({32'b0, SrcB});   // signed × unsigned
        mulhu_tmp = 64'b0;//{32'b0, SrcA} * {32'b0, SrcB};;             // unsigned × unsigned

        case (ALUFunct)
            3'b000: ALUResult = Funct7b0 && (Op == 7'b0110011) ? mul_tmp[31:0] : Sum; // add or sub OR mul
            3'b010: ALUResult = Funct7b0 && (Op == 7'b0110011) ? mulhsu_tmp[63:32] : SLT; // slt OR mulhsu
            3'b011: ALUResult = Funct7b0 && (Op == 7'b0110011) ? mulhu_tmp[63:32] : SLTU; // sltu OR mulhu
            3'b110: ALUResult = SrcA | SrcB; // or
            3'b100: ALUResult = SrcA ^ SrcB; // xori
            3'b111: ALUResult = SrcA & SrcB; // and
            3'b001: ALUResult = Funct7b0 && (Op == 7'b0110011) ? mul_tmp[63:32] : SrcA << SrcB[4:0]; // sll OR mulh


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
