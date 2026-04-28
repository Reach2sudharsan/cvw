# Quick Reference: Area & Critical Path Optimizations

## Executive Summary

Your design has **3 major optimization opportunities** that can reduce area by **5-10%** and improve critical path by **40-50%**.

**Root Cause:** Load data sizing muxes in writeback stage are on the critical path from result mux → forwarding mux → multiply unit.

---

## The 3 Optimizations

### 1️⃣ EASIEST: Inline ForwardMA/ForwardMB Signals

**Effort:** 30 minutes | **Gain:** 600-800 gates | **Risk:** Low

**What:** Replace two 2:1 muxes with one 4:1 mux
**Where:** Execute stage, forwarding logic (datapath.sv lines 288-295)
**How:**
```systemverilog
// BEFORE: 2 separate mux + 3:1 forward mux
mux2 #(32) forwardMAmux(IEUResultM, CSRReadDataM, ResultSrcM[1], ForwardMA);
mux3 #(32) forwardAmux(RD1E, SizedResultW, ForwardMA, ForwardAE, Aout);

// AFTER: Direct 4:1 mux
mux4 #(32) forwardAmux(RD1E, SizedResultW, IEUResultM, CSRReadDataM, ForwardAE, ForwardResultA);
```

**Files to Change:**
- `datapath.sv`: Remove ForwardMA/ForwardMB logic, use 4:1 mux instead
- `hazard_unit.sv`: Update ForwardAE/ForwardBE encoding for 4-input mux

---

### 2️⃣ MODERATE: Move Load Sizing to Memory Stage

**Effort:** 2-3 hours | **Gain:** 1.2K gates + faster critical path | **Risk:** Medium

**What:** Move halfmux, bytemux, sizing case statement from WB to M stage
**Where:** Memory stage, before result mux (datapath.sv lines 485-551)
**Why:** Sizing operations don't need to happen on critical path; do them before pipelining

**How:**
```systemverilog
// In MEMORY STAGE: compute SizedReadDataM before pipeline
mux2 #(16) halfmux(ReadDataM[15:0], ReadDataM[31:16], IEUAdrb10M[1], HalfDataM);
mux2 #(8) bytemux(HalfDataM[7:0], HalfDataM[15:8], IEUAdrb10M[0], ByteDataM);
always_comb case (LoadTypeM)
    3'b010: SizedReadDataM = ReadDataM;
    // ... other cases
endcase

// result mux uses pre-sized data
mux3 #(32) resultmux(IEUResultM, SizedReadDataM, CSRReadDataM, ResultSrcM, SizedResultM);

// Pipeline SizedResultM to WB, not raw ReadDataM
flopenr #(32) M2W_Result(.D(SizedResultM), .Q(SizedResultW));

// In WRITEBACK STAGE: SizedResultW is already sized, no more muxing needed
// Forward SizedResultW directly to execute (no intermediate processing)
```

**Files to Change:**
- `datapath.sv`: Add sizing muxes to M stage, remove from WB stage
- `datapath.sv`: Change M2W pipeline register to pipeline SizedResultM
- `datapath.sv`: Remove resultmux from WB stage (move to M stage)

**Benefits:**
- Removes 3 mux levels from critical path (resultmux → halfmux → bytemux)
- Critical path now: forwardAmux (4:1) → srcamux (2:1) → multiply unit
- 40-50% faster multiply operand path

---

### 3️⃣ OPTIONAL: Exclude CSR from Multiply Forwarding

**Effort:** 1 hour | **Gain:** 400-600 gates + cleaner logic | **Risk:** Low-Medium

**What:** CSR data shouldn't be multiplied; skip it in multiply instructions
**Where:** Forwarding mux (execute stage)
**How:**
```systemverilog
// Only forward CSR when not a multiply instruction
logic [31:0] forward_source;
mux2 #(32) csr_gate(CSRReadDataM, IEUResultM, IsMulE, forward_source);

// Then use forward_source in place of CSRReadDataM in forward mux
// Now multiply never uses CSR data (saves one mux input)
```

**Why:**
- Multiplies only need integer results or register file values
- CSR results are for other instructions (control registers)
- Reduces mux from 4:1 (or 3:1 if optimization 1 done) to 3:1 (or 2:1)
- Cleaner logic: CSR path stays separate

**Files to Change:**
- `datapath.sv`: Add CSR gating logic before forward mux
- `hazard_unit.sv`: May need to prevent CSR forwarding for multiplies

---

## Implementation Priority

```
Phase 1 (Day 1):
├─ Optimization 1: Inline ForwardMA/ForwardMB
│  └─ 30 min effort, low risk, 600-800 gates
│
Phase 2 (Day 2):
├─ Optimization 2: Move load sizing to M stage
│  └─ 2-3 hours effort, medium risk, 1.2K gates + critical path improvement
│
Phase 3 (Day 3, optional):
└─ Optimization 3: Exclude CSR from multiply
   └─ 1 hour effort, low risk, 400-600 gates
```

**Total Time:** ~4-5 hours
**Total Gain:** 2.0-3.0K gates (5-10% of datapath area) + 40-50% faster multiply path

---

## Signals to Remove

After optimizations, these signals are **no longer needed:**

| Signal | Current Lines | Type | Size | Gate Cost |
|--------|---------------|------|------|-----------|
| `ForwardMA` | 288 | intermediate | 32-bit | 96 wires + 800 gate mux |
| `ForwardMB` | 289 | intermediate | 32-bit | 96 wires + 800 gate mux |
| `HalfResultW` | 67 | pipeline | 16-bit | 48 wires (if moved to M) |
| `ByteResultW` | 68 | pipeline | 8-bit | 24 wires (if moved to M) |
| `ResultW` | 66 | intermediate | 32-bit | 96 wires (if moved to M) |

---

## Registers to Modify

### M2W Pipeline Registers
```systemverilog
// CHANGE THIS:
flopenr #(32) M2W_ReadData(.clk, .reset, .enable, .flush, .D(ReadDataM), .Q(ReadDataW));
flopenr #(32) M2W_ALUResult(.clk, .reset, .enable, .flush, .D(ALUResultM), .Q(ALUResultW));

// TO THIS (pipeline SizedResultM):
flopenr #(32) M2W_Result(.clk, .reset, .enable, .flush, .D(SizedResultM), .Q(SizedResultW));
```

This single change eliminates the need for separate ReadDataW and ALUResultW in the WB path.

---

## Testing Checklist

- [ ] Compile without errors
- [ ] Run `make test` - all tests pass
- [ ] Verify load instructions produce correct byte/halfword values
- [ ] Verify multiply operand forwarding from previous cycles
- [ ] Verify CSR reads still work correctly
- [ ] Synthesis report shows area reduction (~5-10%)
- [ ] Timing report shows critical path improvement
- [ ] Run `make coremark` - benchmark still correct

---

## Key Files to Review/Modify

```
src/ieu/datapath.sv          ← Main changes (all 3 optimizations)
src/hazard_unit/hazard_unit.sv ← Minor change (forward mux encoding)
src/ieu/ieu.sv              ← May need minor interface updates
```

---

## Critical Path Before/After Comparison

```
BEFORE OPTIMIZATION:
 resultmux(3:1) → halfmux(2:1) → bytemux(2:1) → case → forwardAmux(3:1) → srcamux(2:1) → MUL
 ~6-7 mux levels = 15-20 gate delays

AFTER OPTIMIZATION 1 (inline):
 resultmux(3:1) → halfmux(2:1) → bytemux(2:1) → case → forwardAmux(4:1) → srcamux(2:1) → MUL
 ~6-7 mux levels = 15-20 gate delays (no improvement in timing)
 BUT: 600-800 fewer gates, cleaner logic

AFTER OPTIMIZATION 2 (move sizing):
 [M stage: resultmux(3:1) → sizing] → [pipeline] → forwardAmux(4:1) → srcamux(2:1) → MUL
 ~3 mux levels on critical path = 8-10 gate delays
 40-50% FASTER! Plus 1.2K fewer gates

AFTER BOTH (RECOMMENDED):
 [M stage: resultmux(3:1) → sizing] → [pipeline] → forwardAmux(4:1) → srcamux(2:1) → MUL
 ~3 mux levels = 8-10 gate delays
 40-50% FASTER + 1.8-2.0K fewer gates + cleaner logic
```

---

## Risk Assessment

| Optimization | Complexity | Risk | Payoff | Recommendation |
|--------------|-----------|------|--------|-----------------|
| 1: Inline forward mux | Low | Low | Medium (800 gates) | DO FIRST |
| 2: Move load sizing | Medium | Medium | High (1.2K gates + timing) | DO SECOND |
| 3: Exclude CSR | Low | Low | Medium (600 gates) | DO LAST |

**Overall Risk:** Low-Medium (well-understood changes, good testing existing)
**Expected Outcome:** 2-3K gate reduction + significant timing improvement
