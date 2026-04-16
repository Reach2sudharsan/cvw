// ifu.sv
// RISC-V pipelined processor
// sanarayanan@hmc.edu, sgopalakrishnan@hmc.edu 2026

module ifu(
        input   logic           clk, reset,
        input   logic     PCSrc,
        input   logic  [31:0]   JumpTarget,
        input   logic           JumpPredict,
        input   logic           StallF,
        input   logic [31:0]    IEUAdr,
        output  logic [31:0]    PC, PCPlus4
    );

    logic [31:0] PCNext;
    // next PC logic
    logic [31:0] entry_addr;

    initial begin
        // default
        entry_addr = '0;

        // override if provided
        void'($value$plusargs("ENTRY_ADDR=%h", entry_addr));

        $display("[TB] ENTRY_ADDR = 0x%h", entry_addr);
    end

    always_ff @(posedge clk or posedge reset) begin
    if (reset)  PC <= entry_addr;
    else if (!StallF)   PC <= PCNext;
    end

    adder pcadd4(PC, 32'd4, PCPlus4);
    mux3 #(32) pcmux(PCPlus4, IEUAdr, JumpTarget, {JumpPredict, PCSrc}, PCNext);
endmodule
