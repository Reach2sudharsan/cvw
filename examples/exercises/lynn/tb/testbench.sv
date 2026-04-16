// James Kaden Cassidy
// kacassidy@hmc.edu
// 1/22/26

`timescale 1ns/1ps

`include "parameters.svh"

// If DUT_MODULE isn't defined on the vlog command line,
// fall back to a default name.
`define INSTR_BITS 32

`define ELF_BASE_ADR (`XLEN'h8000_0000)
`define IMEM_BASE_ADR (`ELF_BASE_ADR)
`define DMEM_BASE_ADR (`ELF_BASE_ADR)

`define MaxInstrSizeWords 1048576
// 16384
`define MaxDataSizeWords 2097152

`define MTIME_POINTER (`XLEN'h0200bff8)

`define STDOUT (`XLEN'h8000_0001)


module testbench;

  logic clk;
  logic reset;

  // 100 MHz clock: 10 ns period (change as needed)
  initial clk = 0;
  always #5 clk = ~clk;

  // Simple reset sequence
  initial begin
    reset = 1;
    #10;         // hold reset for a bit
    reset = 0;   // release reset
  end

  // Instruction side interface (byte addresses)
  logic [`XLEN-1:0]               PC;
  logic [`INSTR_BITS-1:0]         Instr;

  // Data side interface (byte addresses)
  logic [`XLEN-1:0]               DataAdr;
  logic [`XLEN-1:0]               ReadData, MemReadData, TestbenchRequestReadData;
  logic [`XLEN-1:0]               WriteData, IMEM_WriteData;
  logic                           WriteEn;
  logic                           MemEn;
  logic [`XLEN/8-1:0]             WriteByteEn;   // byte enables, one per 8 bits

/* ------- DEBUG PRINTS ------- */

  always @(negedge clk) begin
    int i;
    #1;

    if (~reset) begin

      // $display("\nPCF: %h \t PCD: %h \t PCE: %h \t JumpPredictE: %h \t PCSrcE: %h \t PCNext: %h",
      //           dut.ieu.dp.PCF,
      //            dut.ieu.dp.PCD,
      //            dut.ieu.dp.PCE,
      //             dut.ieu.dp.JumpPredictE,
      //              dut.ieu.dp.PCSrcE,
      //              dut.ifu.PCNext

      //     );


      // $display("ALmsb: %h \t AHmsb: %h \t BLmsb: %h \t BHmsb: %h          P0: %h \t P1: %h \t P2: %h \t P3: %h \t origProduct: %h \t productE: %h",
      //           dut.ieu.dp.multiply.ALmsb,
      //           dut.ieu.dp.multiply.AHmsb,
      //           dut.ieu.dp.multiply.BLmsb,
      //           dut.ieu.dp.multiply.BHmsb,
      //           dut.ieu.dp.multiply.P0,
      //           dut.ieu.dp.multiply.P1,
      //           dut.ieu.dp.multiply.P2,
      //           dut.ieu.dp.multiply.P3,
      //           dut.ieu.dp.multiply.origProduct,
      //           dut.ieu.dp.multiply.productE

      //            );

      // $display("ALUFunctb01E: %h \t ALUFunctE: %h \t SrcAE: %h \t SrcBE: %h \t IsMulE: %h",
      //           dut.ieu.dp.multiply.ALUFunctb01E,
      //            dut.ieu.dp.ALUFunctE,
      //            dut.ieu.dp.SrcAE,
      //           dut.ieu.dp.SrcBE,
      //           dut.ieu.dp.IsMulE

      //     );

    //  $display("Aout: %h \t Bout: %h",
    //             dut.ieu.dp.Aout,
    //              dut.ieu.dp.Bout,

    //       );


      // $display("\n PCF: %h \t PCD: %h \t PCE: %h \t Instr: %h \t IEUAdrE: %h \t PCPlus4E: %h \t PCSrE: %h \t JumpE: %h \t HpmBrachTakenE: %h \t StallF: %h  \t FlushE: %h",
      //           dut.ieu.dp.PCF,
      //            dut.ieu.dp.PCD,
      //            dut.ieu.dp.PCE,
      //             Instr,
      //              dut.ieu.dp.IEUAdrE,
      //               dut.ieu.dp.PCPlus4E,
      //               dut.ieu.dp.PCSrcE,
      //               dut.ieu.dp.JumpE,
      //               dut.ieu.dp.HpmBranchTakenE,
      //               dut.ieu.dp.StallF,
      //               dut.ieu.dp.FlushE); //// THIS is a really COOL LINE
      // $display(
      //   "Aout: %h \t Bout: %h IEUAdrE: %h \t IEUAdrM: %h \t ReadDataM: %h SizedResultW: %h \t ResultW: %h \t RD1E: %h \t RD2E: %h \t SrcAE: %h \t SrcBE: %h \t ALUResultE: %h \t ALUResultM: %h \t ALUResultW: %h \t ResultSrcW: %h \t RegWriteW: %h \t RdW: %h \t IEUResultE: %h \t IEUResultM: %h \t IEUResultW: %h \t ALUResultSrcE: %h \t Branch: %h \t Lt: %h \t Funct3E: %h \t ForwardAE: %h  \t ForwardBE: %h \t MemWriteE: %h \t MemWriteM: %h  \t WriteDataE: %h \t WriteDataM: %h \t ImmExtE: %h",

      //   dut.ieu.dp.Aout,
      //   dut.ieu.dp.Bout,
      //   dut.ieu.dp.IEUAdrE,
      //   dut.ieu.dp.IEUAdrM,
      //   dut.ieu.dp.ReadDataM,
      //   dut.ieu.dp.SizedResultW,
      //   dut.ieu.dp.ResultW,
      //   dut.ieu.dp.RD1E,
      //   dut.ieu.dp.RD2E,
      //   dut.ieu.dp.SrcAE,
      //   dut.ieu.dp.SrcBE,
      //   dut.ieu.dp.ALUResultE,
      //   dut.ieu.dp.ALUResultM,
      //   dut.ieu.dp.ALUResultW,
      //   dut.ieu.dp.ResultSrcW,
      //   dut.ieu.dp.RegWriteW,
      //   dut.ieu.dp.RdW,
      //   dut.ieu.dp.IEUResultE,
      //   dut.ieu.dp.IEUResultM,
      //   dut.ieu.dp.IEUResultW,
      //   // dut.ieu.dp.NewResultE,
      //   // dut.ieu.dp.NewResultM,
      //   // dut.ieu.dp.NewResultW,
      //   dut.ieu.dp.ALUResultSrcE,
      //   dut.ieu.dp.BranchE,
      //   dut.ieu.dp.Lt,
      //   dut.ieu.dp.Funct3E,
      //   dut.ieu.dp.ForwardAE,
      //   dut.ieu.dp.ForwardBE,
      //   dut.ieu.dp.MemWriteE,
      //   dut.ieu.dp.MemWriteM,
      //   dut.ieu.dp.WriteDataE,
      //   dut.ieu.dp.WriteDataM,
      //   dut.ieu.dp.ImmExtE
      // );

      // $display(

      //     "ALUSrcE %h \t ForwardAE %h \t ForwardBE %h \t Sub %h \t ra %h \t ReadDataM %h \t WriteByteEnM %h \t StoreTypeM %h \t IEUAdrb10M %h \t Rs2E %h \t RdW %h \t CSRReadDataM %h \t MemEn %h",
      //     dut.ieu.dp.ALUSrcE,
      //     dut.ieu.dp.ForwardAE,
      //     dut.ieu.dp.ForwardBE,
      //     dut.ieu.dp.alu.Sub,
      //     dut.ieu.dp.rf.rf[1],
      //     dut.ieu.dp.ReadDataM,
      //     dut.ieu.dp.WriteByteEnM,
      //     dut.ieu.dp.StoreTypeM,
      //     dut.ieu.dp.IEUAdrb10M,
      //     dut.ieu.dp.Rs2E,
      //     dut.ieu.dp.RdW,
      //     dut.ieu.dp.csr_addrM,
      //     DataMemory.En
      // );

      // $display("SrcAE: %h \t SrcBE: %h \t Aout: %h \t Bout: %h \t JumpPredict: %h \t PCSrc: %h",
      //           dut.ieu.dp.SrcAE,
      //            dut.ieu.dp.SrcBE,
      //             dut.ieu.dp.Aout,
      //            dut.ieu.dp.Bout,
      //             dut.ifu.JumpPredict,
      //              dut.ifu.PCSrc
      //     );



      // $display(
      //   "\n t0: %h",

      // );

      // $display("MemEn: %b",
      //         MemEn
      //         );

      // $display("rdcycle: %h, rdtime: %h, rdinsret: %h",
      //         dut.prv.csrf.rdcycle,
      //         dut.prv.csrf.rdtime,
      //         dut.prv.csrf.rdinsret
      //         );
      // if (PC >= 32'h800046dc && PC <= 32'h80004710)
      //       $display("PC=%h Instr=%h x6=%h x1=%h", PC, Instr,
      //                dut.ieu.dp.rf.rf[6],
      //                dut.ieu.dp.rf.rf[1]);
      // if (MemEn && WriteEn)
      //     $display("WRITE: PC=%h DataAdr=%h WriteData=%h ByteEn=%b", PC, DataAdr, WriteData, WriteByteEn);
      // if (MemEn && !WriteEn)
      //     $display("READ: PC=%h DataAdr=%h", PC, DataAdr);

      // if (PC >= 32'h8000030c && PC <= 32'h80000790)
      //     $display("PC=%h Instr=%h x9=%h x22=%h x3=%h", PC, Instr,
      //             dut.ieu.dp.rf.rf[9],
      //             dut.ieu.dp.rf.rf[22],
      //             dut.ieu.dp.rf.rf[3]);


      // $display("SrcA: %h, SrcB: %h, ALUResult: %h",

      //           dut.ieu.dp.alu.SrcA,
      //           dut.ieu.dp.alu.SrcB,
      //           dut.ieu.dp.alu.ALUResult,
      //         );



      // terminate program as it exited program space
      if (Instr === 'x) begin
        $display("Instruction data x (PC: %h)", PC);
        $finish(-1);

    end

    end

  end

  /* ------- PROCESSOR Instantiation ------- */

  ram1p1rwb #(
    .MEMORY_NAME              ("Instruction Memory"),
    .ADDRESS_BITS             (`XLEN),
    .DATA_BITS                (32),
    .MEMORY_SIZE_ENTRIES      (`MaxInstrSizeWords),
    .MEMORY_FILE_BASE_ADDRESS (`ELF_BASE_ADR),
    .MEMORY_ADR_OFFSET        (`IMEM_BASE_ADR),
    .MEMFILE_PLUS_ARG         ("MEMFILE")
  ) InstructionMemory (.clk, .reset, .En(1'b1), .WriteEn(1'b0), .WriteByteEn(4'b0), .MemoryAddress(PC), .WriteData(IMEM_WriteData), .ReadData(Instr));

  ram1p1rwb #(
    .MEMORY_NAME              ("Data Memory"),
    .ADDRESS_BITS             (`XLEN),
    .DATA_BITS                (`XLEN),
    .MEMORY_SIZE_ENTRIES      ((`MaxInstrSizeWords + `MaxDataSizeWords)),
    .MEMORY_FILE_BASE_ADDRESS (`ELF_BASE_ADR),
    .MEMORY_ADR_OFFSET        (`DMEM_BASE_ADR),
    .MEMFILE_PLUS_ARG         ("MEMFILE")
  ) DataMemory (.clk, .reset, .En(MemEn & ~TestbenchRequest), .WriteEn, .WriteByteEn, .MemoryAddress(DataAdr), .WriteData, .ReadData(MemReadData));

  assign ReadData = TestbenchRequest ? TestbenchRequestReadData : MemReadData;

  // ------------------------------------------------------------
  // DUT instantiation
  // ------------------------------------------------------------

  `PROCESSOR_TOP dut (
    .clk            (clk),
    .reset          (reset),

    // Instruction memory interface (byte address)
    .PC             (PC),
    .Instr          (Instr),

    // Data memory interface (byte address + strobes)
    .IEUAdr         (DataAdr),
    .ReadData       (ReadData),
    .WriteData      (WriteData),
    .MemEn          (MemEn),
    .WriteEn        (WriteEn),
    .WriteByteEn    (WriteByteEn)
  );

/* ------- TOHOST Handling ------- */

/*
  Host Target Interface (HTIF) semihosting based on 8 byte value at TOHOST label
  0x00000000_00000001: terminate successfully
  0x00000000_xxxxxxx0: terminate with failure code xxxxxxx
  0x01010000_000000ch: writes the byte ch to the console as ASCII
*/

logic [`XLEN-1:0] TO_HOST_ADR;
logic [31:0] tohost_lo, tohost_hi, payload;

always @(negedge clk) begin
  byte ch;

  #1;
  `ifdef XLEN32
  tohost_lo = DataMemory.Memory[(TO_HOST_ADR-`DMEM_BASE_ADR)>>2];
  tohost_hi = DataMemory.Memory[((TO_HOST_ADR-`DMEM_BASE_ADR)>>2) + 1];
  `endif
  `ifdef XLEN64
  {tohost_hi, tohost_lo} = DataMemory.Memory[(TO_HOST_ADR-`DMEM_BASE_ADR)>>2];
  `endif

  //$display("TOHOST DATA: %h%h, Addr %h, base %h", tohost_hi, tohost_lo, TO_HOST_ADR, `DMEM_BASE_ADR);

  if (MemEn && WriteEn && DataAdr == TO_HOST_ADR`ifdef XLEN32 + 4`endif) begin
    payload = tohost_lo;
    if (tohost_hi == 32'h0 & payload[0]) begin

      if (~(|(payload >> 1))) begin
        $display("INFO: Test Completed!");
      end else begin
        $display("ERROR: Test Failed (code=%d)", (payload >> 1));
      end

      $display("[%0t] INFO: Program Finished! Ending simulation.", $time);
      $finish;

    // Check top bits for "print char" command
    end else if (tohost_hi == 32'h01010000) begin
      ch = tohost_lo[7:0];
      $write("%c", ch);
      if (ch == "\n") $fflush(`STDOUT);
    end

    // clear tohost to be 0
    DataMemory.Memory[(TO_HOST_ADR-`DMEM_BASE_ADR)>>2] = '0;
    `ifdef XLEN32
    DataMemory.Memory[((TO_HOST_ADR-`DMEM_BASE_ADR)>>2) + 1] = '0;
    `endif
  end
end

initial begin

    TO_HOST_ADR = '0; // default
    void'($value$plusargs("TOHOST_ADDR=%h", TO_HOST_ADR)); // override if provided
    $display("[TB] TOHOST_ADDR = 0x%h", TO_HOST_ADR);

    // Wait until reset deasserts
    @(negedge reset);
    $display("[%0t] INFO: Starting simulation.", $time);

end

/* ------- Safety jump-to-self exit ------- */

logic[3:0]       jump_to_self_count;

always_ff @(posedge clk) begin
  if (reset)                    jump_to_self_count <= '0;
  else if (Instr == `XLEN'h06f) jump_to_self_count <= jump_to_self_count + 1;
end

always @(negedge clk) begin
  if (!reset && ((&jump_to_self_count))) begin
      $display("ERROR: Program stuck in infinite loop at address %h", PC);
      $finish(-1);
  end
end

/* ------- MTIME DATA REQUEST ------- */

assign TestbenchRequest = (DataAdr == `MTIME_POINTER) | (DataAdr == `MTIME_POINTER + 4);

logic [63:0] cycle_count;

always_ff @(posedge clk) begin
  if (reset) cycle_count <= 0;
  else       cycle_count <= cycle_count + 1;
end

// Only respond to mtime reads
always_ff @(negedge clk) begin
  TestbenchRequestReadData = 'x;
  if (TestbenchRequest && MemEn && !WriteEn) begin
    if (DataAdr == `MTIME_POINTER)      TestbenchRequestReadData = cycle_count[31:0];
    if (DataAdr == `MTIME_POINTER + 4)  TestbenchRequestReadData = cycle_count[63:32];
  end
end


endmodule
