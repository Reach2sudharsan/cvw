# Critical Path and Area Optimization Analysis

## Critical Path Analysis

**Current Critical Path: WriteBACK Result Mux → Forward Muxes → Multiply Unit**

```
ResultW (from resultmux in WB)
  ↓
SizedResultW (through halfmux/bytemux)
  ↓
forwardAmux/forwardBmux (3:1 muxes)
  ↓
Aout/Bout
  ↓
srcamux/srcbmux (2:1 muxes)
  ↓
SrcAE/SrcBE
  ↓
Multiply unit (critical computation)
```

## Major Inefficiencies

### 1. **Load Data Sizing in WriteBACK (CRITICAL PATH)**
**File:** `datapath.sv` lines 575-591

```systemverilog
// Current: 3 separate muxes for load sizing
mux2 #(16) halfmux(ResultW[15:0], ResultW[31:16], IEUResultW[1], HalfResultW);
mux2 #(8) bytemux(HalfResultW[7:0], HalfResultW[15:8], IEUResultW[0], ByteResultW);

always_comb begin
    case (LoadTypeW)
        3'b010: SizedResultW = ResultW;
        3'b001: SizedResultW = {{16{HalfResultW[15]}}, HalfResultW};
        3'b101: SizedResultW = {16'b0, HalfResultW};
        3'b000: SizedResultW = {{24{ByteResultW[7]}}, ByteResultW};
        3'b100: SizedResultW = {24'b0, ByteResultW};
        default: SizedResultW = ResultW;
    endcase
end
```

**Issue:** This path (ResultW → SizedResultW) feeds directly into forwarding muxes that feed the multiply unit.

**Optimization:**
- Move load data sizing to **Memory stage** where it's not on the critical path
- ResultSrcM[1:0] already controls whether we use load data, ALU result, or CSR data
- **Remove:** `halfmux`, `bytemux`, intermediate signals `HalfResultW`, `ByteResultW`
- **Area Reduction:** ~300-400 gates from 3 muxes + intermediate signals
- **Critical Path:** Speeds up WB result mux by 1-2 levels

---

### 2. **Redundant Forwarding Mux Chain (CRITICAL PATH)**
**File:** `datapath.sv` lines 288-295

```systemverilog
// Current: 4 multiplexer levels (3 in ForwardM, 3 in forward, 2 in srcA/srcB)
logic [31:0] ForwardMA, ForwardMB;
mux2 #(32) forwardMAmux(IEUResultM, CSRReadDataM, ResultSrcM[1], ForwardMA);
mux2 #(32) forwardMBmux(IEUResultM, CSRReadDataM, ResultSrcM[1], ForwardMB);

mux3 #(32) forwardAmux(RD1E, SizedResultW, ForwardMA, ForwardAE, Aout);
mux3 #(32) forwardBmux(RD2E, SizedResultW, ForwardMB, ForwardBE, Bout);

mux2 #(32) srcamux(Aout, PCE, ALUSrcE[1], SrcAE);
mux2 #(32) srcbmux(Bout, ImmExtE, ALUSrcE[0], SrcBE);
```

**Issues:**
1. ForwardMA/ForwardMB are intermediate signals used only once each
2. 3 levels of 32-bit muxing (ForwardM 2:1 + Forward 3:1 + Src 2:1)
3. CSRReadDataM/CSRReadDataW shouldn't be in the multiply operand path

**Optimization 1 - Collapse ForwardM muxes:**
- Inline ForwardMA/ForwardMB into forwardAmux/forwardBmux
- Create 4:1 mux (register file, writeback result, memory result, CSR) controlled by ForwardAE/ForwardBE
- **Area Reduction:** ~600-800 gates (eliminate 2 × 32-bit mux + eliminate intermediate signals)

**Optimization 2 - Move CSR out of multiply path:**
- CSRReadData should only go to ALU operations, not multiply
- Check IsMulE/IsMulM before including CSRReadData in critical forwarding
- Add condition to forward logic: `if (!IsMulE) include CSRReadData, else exclude`
- **Area Reduction:** ~400-600 gates (1 fewer input to muxes)
- **Critical Path:** Reduces mux from 4:1 to 3:1

---

### 3. **Multiply Result Selection (NON-CRITICAL BUT COMPLEX)**
**File:** `datapath.sv` lines 549-551

```systemverilog
logic [31:0] NewIEUResultM;
mux2 #(32) selectresult(IEUResultM, productM, IsMulM, NewIEUResultM);
```

**Issue:** This is in the multiply result path, adding one more 32-bit mux

**But:** IEUResultM needs to be passed through regardless (for non-multiply instructions)

**Possible Optimization:**
- Only need this mux when actually forwarding a multiply result
- For most instructions, IEUResultM goes directly to writeback without modification
- Could move multiply result selection to **Execute stage** instead of Memory stage
- Keep partial products (P0E, P1E, P2E, P3E) but don't pipeline them to M stage if result not needed

---

### 4. **Excessive Pipeline Register Width**
**File:** `datapath.sv` - M2W pipeline registers (lines 556-566)

**Current pipeline registers for multiply path:**
- M2W_ALUResult (32-bit) - needed for ALU results
- M2W_IEUResult (32-bit) - needed for combined results
- M2W_CSRReadData (32-bit) - needed for CSR reads
- M2W_ReadData (32-bit) - needed for load data

**Issue:** If multiplication is the only ALU operation in a program, you're still pipelining unused signals

**Potential Optimization:**
- Make M2W_ALUResult and M2W_IEUResult conditional on instruction type
- **But** this adds complexity; may not be worth it

---

### 5. **Unnecessary Intermediate Signals**
**File:** `datapath.sv`

**Signals that can be eliminated:**
1. `HalfResultW` (16-bit) - intermediate in load sizing → **move to M stage or eliminate**
2. `ByteResultW` (8-bit) - intermediate in load sizing → **move to M stage or eliminate**
3. `ForwardMA` (32-bit) - used once → **inline**
4. `ForwardMB` (32-bit) - used once → **inline**
5. `IEUResultTempM` - appears in comments as unused, verify and remove
6. `JumpMuxResultE` (32-bit) - could be inlined if only used once

**Combined Area Reduction:** ~1.0-1.5K gates from removing redundant intermediate signals

---

## Summary of Optimizations

| Priority | Optimization | Location | Area Saved | Critical Path Impact | Difficulty |
|----------|--------------|----------|-----------|----------------------|------------|
| **HIGH** | Move load sizing to M stage | WB stage | 300-400 gates | -1 to -2 levels | Medium |
| **HIGH** | Inline ForwardMA/ForwardMB | Execute stage | 600-800 gates | -0.5 levels | Low |
| **HIGH** | Remove CSR from multiply path | Forward logic | 400-600 gates | -0.5 levels (3:1 vs 4:1) | Medium |
| **MEDIUM** | Remove intermediate load sizing signals | WB/M stages | 200-300 gates | Depends on above | Low |
| **MEDIUM** | Simplify multiply result mux | M stage | ~100 gates | -0.2 levels | High |
| **LOW** | Inline other single-use signals | Various | 200-300 gates | Minimal | Low |

**Total Estimated Area Reduction:** 2.0-3.0K gates (~5-10% of total datapath area)

**Total Critical Path Reduction:** 2-3 mux levels (significant for timing if currently tight)

---

## Recommended Implementation Order

1. **First:** Inline ForwardMA/ForwardMB (low risk, immediate benefit)
2. **Second:** Move load sizing to M stage (moderate complexity, good benefit)
3. **Third:** Remove CSR from multiply forwarding path (needs careful verification)
4. **Fourth:** Clean up intermediate signals as a result of above changes
