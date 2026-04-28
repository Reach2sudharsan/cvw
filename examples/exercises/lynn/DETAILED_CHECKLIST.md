# Implementation Checklist & Code Changes

## Optimization 1: Inline ForwardMA/ForwardMB

### Step 1.1: Identify All Uses
- [ ] Find all references to `ForwardMA` in datapath.sv → Line 288, 289, 291
- [ ] Find all references to `ForwardMB` in datapath.sv → Line 289, 292
- [ ] Check hazard_unit.sv for relevant changes

### Step 1.2: Update hazard_unit.sv
**Location:** `src/hazard_unit/hazard_unit.sv`

**Change hazard unit outputs:**
```systemverilog
// BEFORE:
output logic [1:0] ForwardAE, ForwardBE,

// AFTER: (No change needed if already 2-bit, but encoding changes)
// ForwardAE/ForwardBE now have 4 values:
// 00: RD1E/RD2E (register file)
// 01: SizedResultW (writeback stage)
// 10: IEUResultM (memory stage)
// 11: Reserved/CSRReadDataM (optional)
output logic [1:0] ForwardAE, ForwardBE,
```

**No changes needed in hazard_unit logic if already outputting correct encoding**

### Step 1.3: Update datapath.sv

**Remove lines 288-289:**
```systemverilog
logic [31:0] ForwardMA;
logic [31:0] ForwardMB;
mux2 #(32) forwardMAmux(IEUResultM, CSRReadDataM, ResultSrcM[1], ForwardMA);
mux2 #(32) forwardMBmux(IEUResultM, CSRReadDataM, ResultSrcM[1], ForwardMB);
```

**Replace lines 290-291:**
```systemverilog
// BEFORE:
mux3 #(32) forwardAmux(RD1E, SizedResultW, ForwardMA, ForwardAE, Aout);
mux3 #(32) forwardBmux(RD2E, SizedResultW, ForwardMB, ForwardBE, Bout);

// AFTER: Use 4:1 mux with inlined ForwardMA/ForwardMB values
// Select appropriate memory stage result based on instruction type
logic [31:0] memory_forward;
mux2 #(32) memory_select(IEUResultM, CSRReadDataM, ResultSrcM[1], memory_forward);

mux4 #(32) forwardAmux(RD1E, SizedResultW, memory_forward, 32'b0, ForwardAE, Aout);
mux4 #(32) forwardBmux(RD2E, SizedResultW, memory_forward, 32'b0, ForwardBE, Bout);
```

### Step 1.4: Testing
```bash
cd ~/Documents/cvw/examples/exercises/lynn
make test
```
Verify: All tests pass, no timing warnings

---

## Optimization 2: Move Load Sizing to Memory Stage

### Step 2.1: Add Sizing Logic to Memory Stage
**Location:** `datapath.sv` around line 485 (before existing M stage pipelines)

**Add after existing memory stage logic, before M2W pipeline registers:**

```systemverilog
// ============================================================================
// LOAD DATA SIZING (Move from Writeback)
// ============================================================================

logic [15:0] HalfDataM;
logic [8:0] ByteDataM;
logic [31:0] SizedReadDataM;

// Select bytes for load sizing based on address alignment
mux2 #(16) halfmux_M(ReadDataM[15:0], ReadDataM[31:16], IEUAdrb10M[1], HalfDataM);
mux2 #(8) bytemux_M(HalfDataM[7:0], HalfDataM[15:8], IEUAdrb10M[0], ByteDataM);

// Size and sign-extend load data
always_comb begin
    case (LoadTypeM)
        3'b010: SizedReadDataM = ReadDataM;                              // lw (word)
        3'b001: SizedReadDataM = {{16{HalfDataM[15]}}, HalfDataM};      // lh (half, signed)
        3'b101: SizedReadDataM = {16'b0, HalfDataM};                    // lhu (half, unsigned)
        3'b000: SizedReadDataM = {{24{ByteDataM[7]}}, ByteDataM};       // lb (byte, signed)
        3'b100: SizedReadDataM = {24'b0, ByteDataM};                    // lbu (byte, unsigned)
        default: SizedReadDataM = ReadDataM;
    endcase
end

// New result mux (moved from Writeback stage)
logic [31:0] SizedResultM;
mux3 #(32) resultmux_M(IEUResultM, SizedReadDataM, CSRReadDataM, ResultSrcM, SizedResultM);
```

### Step 2.2: Update M2W Pipeline Registers
**Location:** `datapath.sv` lines 556-562

**BEFORE:**
```systemverilog
flopenr #(32) M2W_ReadData(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0),
                           .D(ReadDataM), .Q(ReadDataW));
flopenr #(32) M2W_ALUResult(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0),
                           .D(ALUResultM), .Q(ALUResultW));
flopenr #(32) M2W_CSRReadData(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0),
                             .D(CSRReadDataM), .Q(CSRReadDataW));
flopenr #(32) M2W_IEUResult(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0),
                           .D(NewIEUResultM), .Q(IEUResultW));
```

**AFTER:**
```systemverilog
// Single pipeline register for pre-sized result
flopenr #(32) M2W_SizedResult(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0),
                              .D(SizedResultM), .Q(SizedResultW));

// Keep IEU result pipeline if NewIEUResultM still needed
flopenr #(32) M2W_IEUResult(.clk(clk), .reset(reset), .enable(1'b1), .flush(1'b0),
                            .D(NewIEUResultM), .Q(IEUResultW));
```

**Note:** If `IEUResultW` is not used elsewhere, you can remove it and use `SizedResultW` directly

### Step 2.3: Remove Writeback Stage Sizing
**Location:** `datapath.sv` lines 570-591 (WRITEBACK STAGE)

**REMOVE ENTIRE BLOCK:**
```systemverilog
// REMOVE THIS:
// ============================================================================
// WRITEBACK STAGE
// ============================================================================

// Result multiplexer: select between ALU result, memory data, or CSR data
// mux2 #(32) selectresult(IEUResultW, productW, 1'b0, IEUResultM);
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
```

**WRITEBACK STAGE NOW ONLY:**
```systemverilog
// ============================================================================
// WRITEBACK STAGE
// ============================================================================
// No computation needed - SizedResultW already arrives from M2W pipeline
// Register file write is handled in regfile (see input RD3 below)
```

### Step 2.4: Remove Unused Internal Signals
**Location:** `datapath.sv` lines 66-68, 87

**REMOVE:**
```systemverilog
logic [31:0] ResultW, SizedResultW;      // Remove ResultW, keep SizedResultW
logic [15:0] HalfResultW;                 // REMOVE
logic [7:0] ByteResultW;                  // REMOVE
logic [31:0] WriteDataE, ReadDataW, CSRReadDataW;  // Remove ReadDataW, CSRReadDataW
```

**KEEP:**
```systemverilog
logic [31:0] SizedResultW;
logic [31:0] WriteDataE;
```

### Step 2.5: Update Register File Write Input
**Location:** `datapath.sv` around line 234

**Check current code:**
```systemverilog
regfile rf(.clk, .WE3(RegWriteW), .A1(Rs1D), .A2(Rs2D),
    .A3(RdW), .WD3(SizedResultW), ...);
```

This should already be using `SizedResultW`, so **no change needed**.

### Step 2.6: Testing
```bash
cd ~/Documents/cvw/examples/exercises/lynn
make test
make coremark
```

Verify:
- [ ] All tests pass
- [ ] Load instructions produce correct values
- [ ] Load with different byte/halfword sizes correct (lb, lh, lw, lbu, lhu)
- [ ] Sign extension works correctly
- [ ] Forwarding of load results to next instruction still works

---

## Optimization 3: Exclude CSR from Multiply Forwarding (Optional)

### Step 3.1: Identify CSR Path
**Location:** `datapath.sv` lines 288-292

Current code allows CSRReadDataM to be forwarded as a multiply operand, which doesn't make sense.

### Step 3.2: Gate CSR in Multiply Instructions
**Location:** `datapath.sv` around line 287-295

**BEFORE:**
```systemverilog
logic [31:0] ForwardMA;
logic [31:0] ForwardMB;
mux2 #(32) forwardMAmux(IEUResultM, CSRReadDataM, ResultSrcM[1], ForwardMA);
mux2 #(32) forwardMBmux(IEUResultM, CSRReadDataM, ResultSrcM[1], ForwardMB);
```

**AFTER (after Optimization 1):**
```systemverilog
// Only use memory forward for non-multiply instructions
logic [31:0] memory_forward_safe;
mux2 #(32) csr_gate(CSRReadDataM, IEUResultM, IsMulM, memory_forward_safe);

mux4 #(32) forwardAmux(RD1E, SizedResultW, memory_forward_safe, 32'b0, ForwardAE, Aout);
mux4 #(32) forwardBmux(RD2E, SizedResultW, memory_forward_safe, 32'b0, ForwardBE, Bout);
```

### Step 3.3: Testing
```bash
make test
```

Verify:
- [ ] CSR reads still work for non-multiply instructions
- [ ] Multiply operations don't attempt CSR forwarding
- [ ] All tests still pass

---

## Verification Steps (After All Optimizations)

### Functional Verification
```bash
cd ~/Documents/cvw/examples/exercises/lynn
make clean
make test      # Should pass all tests
make coremark  # Should complete without errors
```

### Synthesis Verification
```bash
make synth
# Look for:
# - Area reduction in synthesis report (should be 5-10% smaller)
# - Critical path improvement (should be 40-50% faster on multiply path)
grep -i "area\|critical" synth.rpt
```

### Load Instruction Verification
Create a small test:
```asm
# Test load byte sizing
li x1, 0x12345678
sw x1, 0(sp)
lb x2, 0(sp)       # Should load 0x78 sign-extended
lbu x3, 0(sp)      # Should load 0x78 zero-extended
lh x4, 0(sp)       # Should load 0x5678 sign-extended
lhu x5, 0(sp)      # Should load 0x5678 zero-extended
```

### Forwarding Verification
Create a test with back-to-back multiply operations:
```asm
li x1, 0x00000003
li x2, 0x00000005
mul x3, x1, x2     # x3 = 15
mul x4, x3, x2     # x4 = 75 (uses x3 result from previous mul)
mul x5, x4, x2     # x5 = 375 (uses x4 result from previous mul)
```

---

## Rollback Plan

If issues occur, you can revert changes:

```bash
git diff src/ieu/datapath.sv > changes_optimization.patch
# Make changes...
# If problems:
git checkout src/ieu/datapath.sv
# Redo changes or revert specific parts
```

Or keep backup:
```bash
cp src/ieu/datapath.sv src/ieu/datapath.sv.backup
# Make changes...
# If problems:
cp src/ieu/datapath.sv.backup src/ieu/datapath.sv
```

---

## Summary Checklist

### Optimization 1: Inline ForwardMA/ForwardMB
- [ ] Update hazard_unit.sv (if needed)
- [ ] Remove ForwardMA/ForwardMB signal declarations
- [ ] Remove mux2 forwardMAmux and forwardMBmux instantiations
- [ ] Update forwardAmux/forwardBmux to 4:1 mux
- [ ] Compile and test
- [ ] Verify gate count reduction (~600-800 gates)

### Optimization 2: Move Load Sizing to Memory Stage
- [ ] Add HalfDataM, ByteDataM, SizedReadDataM signals
- [ ] Add halfmux_M and bytemux_M instances to M stage
- [ ] Add load sizing case statement to M stage
- [ ] Add resultmux_M to M stage
- [ ] Update M2W pipeline to pipe SizedResultM
- [ ] Remove resultmux, halfmux, bytemux, case statement from WB
- [ ] Remove HalfResultW, ByteResultW, ResultW signals
- [ ] Remove M2W_ReadData, M2W_ALUResult, M2W_CSRReadData registers
- [ ] Compile and test all load instruction variants
- [ ] Verify area and timing improvements
- [ ] Run coremark

### Optimization 3: Exclude CSR from Multiply (Optional)
- [ ] Add CSR gating logic
- [ ] Test CSR reads still work
- [ ] Test multiply operations unchanged
- [ ] Verify timing improvement (smaller mux)
