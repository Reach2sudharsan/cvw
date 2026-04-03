// controller.sv
// RISC-V pipelined processor
// sanarayanan@hmc.edu, sgopalakrishnan@hmc.edu 2026

`include "parameters.svh"

module controller(
    input   logic [6:0]   Op,
    input   logic [1:0]   IEUAdrb10,
    input   logic [2:0]   Funct3,
    input   logic         Funct7b5,
    output  logic         ALUResultSrc,
    output  logic [1:0]   ResultSrc,
    output  logic         RegWrite,
    output  logic [1:0]   ALUSrc,
    output  logic [2:0]   ImmSrc,
    output  logic [1:0]   ALUControl,
    output  logic         MemEn,
    output  logic         Jump,
    output  logic         IsJalr,
    output  logic         Branch,
    output  logic         MemWrite,
    output  logic         ALUOp
    `ifdef DEBUG
    , input   logic [31:0]  insn_debug
    `endif
);

// Internal signals
logic Sub;
logic [13:0] controls;

// Main decoder
// Controls format: RegWrite_ImmSrc_ALUSrc_ALUOp_ALUResultSrc_MemWrite_ResultSrc_Branch_Jump_MemEn
always_comb
    case(Op)
        7'b0000011: controls = 14'b1_000_01_0_0_0_01_0_0_1; // lw
        7'b0100011: controls = 14'b0_001_01_0_0_1_00_0_0_1; // sw
        7'b0110011: controls = 14'b1_xxx_00_1_0_0_00_0_0_0; // R-type
        7'b0010011: controls = 14'b1_000_01_1_0_0_00_0_0_0; // I-type ALU
        7'b1100011: controls = 14'b0_010_11_0_0_0_00_1_0_0; // B-type
        7'b1101111: controls = 14'b1_011_11_0_1_0_00_0_1_0; // jal
        7'b0110111: controls = 14'b1_100_xx_0_1_0_00_0_0_0; // lui
        7'b0010111: controls = 14'b1_100_11_0_0_0_00_0_0_0; // auipc
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
// Determine if subtraction is needed for ALU operations (e.g., sub, slt, etc.)
assign Sub = ALUOp & (Op[5:0] != 6'b100111) & ((Funct3 == 3'b000) & Funct7b5 & Op[5] & ~Op[2] | (Funct3 == 3'b010));
assign ALUControl = {Sub, ALUOp};

// Determine if this is a JALR instruction
assign IsJalr = (Op == 7'b1100111) & (Funct3 == 3'b000);

endmodule
