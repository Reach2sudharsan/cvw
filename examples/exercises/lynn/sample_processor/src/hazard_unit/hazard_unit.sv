// hazard_unit.sv
// RISC-V pipelined processor
// sanarayanan@hmc.edu, sgopalakrishnan@hmc.edu 2026

module hazard_unit(
    input logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E,
    input logic [4:0] RdE, RdM, RdW,
    input logic       RegWriteM, RegWriteW,
    input logic       ResultSrcEb0, // 1 if load instruction in execute stage
    input logic       PCSrcE,

    output logic [1:0] ForwardAE, ForwardBE,
    output logic       lwStall, StallF, StallD, FlushD, FlushE
);

    // Forwarding logic for ALU operand A (Rs1E)
    // Priority: Memory stage > Writeback stage
    always_comb begin
        if ((Rs1E == RdM) && RegWriteM && (Rs1E != 0)) begin
            ForwardAE = 2'b10; // Forward from memory stage
        end else if ((Rs1E == RdW) && RegWriteW && (Rs1E != 0)) begin
            ForwardAE = 2'b01; // Forward from writeback stage
        end else begin
            ForwardAE = 2'b00; // No forwarding
        end
    end

    // Forwarding logic for ALU operand B (Rs2E)
    // Same priority as above
    always_comb begin
        if ((Rs2E == RdM) && RegWriteM && (Rs2E != 0)) begin
            ForwardBE = 2'b10; // Forward from memory stage
        end else if ((Rs2E == RdW) && RegWriteW && (Rs2E != 0)) begin
            ForwardBE = 2'b01; // Forward from writeback stage
        end else begin
            ForwardBE = 2'b00; // No forwarding
        end
    end

    // Stall logic for load-word hazard
    // Stall if decode stage sources depend on execute stage destination (load)
    assign lwStall = ((Rs1D == RdE) || (Rs2D == RdE)) && ResultSrcEb0;

    // Stall fetch and decode stages on load-word hazard
    assign StallF = lwStall;
    assign StallD = lwStall;

    // Flush logic
    // Flush decode on branch taken
    assign FlushD = PCSrcE;
    // Flush execute on load-word stall or branch taken
    assign FlushE = lwStall || PCSrcE;

endmodule
