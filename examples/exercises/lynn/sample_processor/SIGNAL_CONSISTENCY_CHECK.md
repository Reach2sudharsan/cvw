# Signal Consistency Check Report
**Date:** April 24, 2026  
**Purpose:** Verify signal bit widths and connections are consistent between all modules

---

## Summary of Issues Found

### 🔴 CRITICAL ISSUES

#### 1. **datapath.sv Output Signal Name Mismatch in ieu.sv**
**Location:** `datapath.sv` → `ieu.sv` (datapath instantiation)

**Issue:** Signal name mismatch between datapath outputs and ieu.sv instantiation

| Signal | datapath.sv Output | ieu.sv Connection | ieu.sv Port | Status |
|--------|---|---|---|---|
| Execute stage address | `NextAdrE` [31:0] | `.IEUAdrE(IEUAdrE)` | `output IEUAdrE` [31:0] | ❌ NAME MISMATCH |

**Details:**
- **datapath.sv outputs:** `NextAdrE` [31:0]
- **ieu.sv tries to connect:** `.IEUAdrE(IEUAdrE)`
  - But datapath doesn't have a `IEUAdrE` output port!
  - Should be: `.NextAdrE(IEUAdrE)` to rename/forward the signal

**Fix Required:**
```verilog
// In ieu.sv datapath instantiation, CHANGE:
.IEUAdrE(IEUAdrE),

// TO:
.NextAdrE(IEUAdrE),
```

---

#### 2. **branch_targetF Output Missing from ieu.sv**
**Location:** `ieu.sv` (datapath instantiation) → `riscvsingle.sv`

**Issue:** `branch_targetF` is output by datapath.sv but:
1. **Not connected** in ieu.sv's datapath instantiation
2. **Not declared** as output in ieu.sv module ports
3. **Not routed** in riscvsingle.sv to ifu

**Current state:**
```verilog
// datapath.sv has:
output logic [31:0] branch_targetF,

// ieu.sv datapath instantiation MISSING:
.branch_targetF(???)

// ieu.sv module ports MISSING:
output logic [31:0] branch_targetF,

// riscvsingle.sv doesn't pass to ifu:
ifu ifu(
    ...
    // ✗ Missing: .branch_target(???)
);
```

**Fix Required:** Add complete signal chain

---

#### 3. **IFU Module Input Signal Mismatch (Due to cascading issues above)**
**Location:** `riscvsingle.sv` → `ifu.sv`

Since issues #1 and #2 aren't fixed, ifu doesn't receive required signals:

| Input | riscvsingle.sv Sends | ifu.sv Expects | Status |
|-------|---|---|---|
| NextAdrE / IEUAdr | `IEUAdrE` (if it worked) | `NextAdrE` [31:0] | ❌ NAME MISMATCH |
| branch_target | Nothing | [31:0] | ❌ MISSING |

**Details:**
- **ifu.sv module definition:**
  ```verilog
  input   logic  [1:0]    PCSrc,        // ✓ Correct bit width
  input   logic  [31:0]   JumpTarget,   // ✓
  input   logic           JumpPredict,  // ✓
  input   logic           StallF,       // ✓
  input   logic [31:0]    NextAdrE,     // ❌ NOT RECEIVED (wrong name in chain)
  input   logic [31:0]    branch_target, // ❌ NOT RECEIVED (not connected)
  output  logic [31:0]    PC, PCPlus4   // ✓
  ```

---

### ⚠️ WARNINGS / CLARIFICATIONS NEEDED

#### 4. **JumpPredict Signal Definition**
- **ieu.sv input:** `input logic JumpPredict` (not used locally)
- **datapath.sv output:** `output logic JumpPredictD` (pipeline output)
- **ieu.sv output:** `output logic JumpPredict` (directly from datapath)

**Status:** ✓ Appears correctly connected through datapath

---

## Detailed Signal Mapping

### Signal Flow Through Pipeline

```
datapath.sv (OUTPUTS)
  ├─ NextAdrE [31:0]           ❌ SHOULD BE: .NextAdrE(IEUAdrE) in ieu.sv
  ├─ IEUAdrM [31:0]            ✓ Connected as .IEUAdrM(IEUAdrM)
  ├─ WriteDataM [31:0]         ✓ Connected as .WriteDataM(WriteData)
  ├─ branch_targetF [31:0]     ❌ MISSING CONNECTION in ieu.sv
  ├─ PCSrcE [1:0]              ✓ Connected as .PCSrcE(PCSrc)
  ├─ JumpTargetD [31:0]        ✓ Connected as .JumpTargetD(JumpTarget)
  ├─ JumpPredictD [1]          ✓ Connected as .JumpPredictD(JumpPredict)
  └─ InstrD [31:0]             ✓ Connected as .InstrD(InstrD)
        ↓
ieu.sv (OUTPUTS TO riscvsingle)
  ├─ IEUAdrE [31:0]            ✓ (but sourced from NextAdrE with wrong connection name)
  ├─ IEUAdrM [31:0]            ✓
  ├─ WriteData [31:0]          ✓
  ├─ PCSrc [1:0]               ✓
  ├─ JumpTarget [31:0]         ✓
  ├─ JumpPredict [1]           ✓
  ├─ StallF [1]                ✓
  ├─ branch_targetF [31:0]     ❌ NOT AN OUTPUT PORT (missing)
  └─ csr_addrM [11:0]          ✓
        ↓
riscvsingle.sv (TOP LEVEL)
  sends to ifu():
  ├─ PCSrc [1:0]               ✓
  ├─ JumpTarget [31:0]         ✓
  ├─ JumpPredict [1]           ✓
  ├─ StallF [1]                ✓
  ├─ IEUAdrE [31:0]            ✓ (BUT named NextAdrE in ifu)
  ├─ branch_targetF [31:0]     ❌ NOT CONNECTED
  └─ PC [31:0] / PCPlus4 [31:0]✓
        ↓
ifu.sv (INPUTS)
  ├─ PCSrc [1:0]               ✓
  ├─ JumpTarget [31:0]         ✓
  ├─ JumpPredict [1]           ✓
  ├─ StallF [1]                ✓
  ├─ NextAdrE [31:0]           ❌ RECEIVES as IEUAdrE (wrong name)
  └─ branch_target [31:0]      ❌ NOT RECEIVED (no riscvsingle connection)
```

---

## Required Fixes

### Fix #1: Update ieu.sv datapath Instantiation (CRITICAL)
**File:** `src/ieu/ieu.sv`  
**Priority:** CRITICAL - Required for execute stage address routing

**Changes needed:**
1. Fix the `IEUAdrE` connection name
2. Add missing `branch_targetF` connection
3. Add `branch_targetF` output port to ieu.sv

**Step 1 - Update datapath instantiation:**
```verilog
// CHANGE FROM (line ~95):
.IEUAdrE(IEUAdrE),

// CHANGE TO:
.NextAdrE(IEUAdrE),  // Renames datapath output NextAdrE → ieu output IEUAdrE
```

**Step 2 - Add missing branch_targetF output port to ieu.sv:**
```verilog
// ADD after line 15 (after IEUAdrM output):
output  logic [31:0]    branch_targetF,
```

**Step 3 - Add branch_targetF connection to datapath instantiation:**
```verilog
// ADD in datapath instantiation (after .MemEnM line, ~line 110):
.branch_targetF(branch_targetF),
```

---

### Fix #2: Update riscvsingle.sv ifu Instantiation (CRITICAL)
**File:** `src/riscvsingle.sv`  
**Priority:** CRITICAL - Required for branch prediction to work

**Changes needed:**
```verilog
// CHANGE FROM:
ifu ifu(
    .clk(clk),
    .reset(reset),
    .PCSrc(PCSrc),
    .JumpTarget(JumpTarget),
    .JumpPredict(JumpPredict),
    .StallF(StallF),
    .IEUAdr(IEUAdrE),
    .PC(PC),
    .PCPlus4(PCPlus4)
);

// CHANGE TO:
ifu ifu(
    .clk(clk),
    .reset(reset),
    .PCSrc(PCSrc),
    .JumpTarget(JumpTarget),
    .JumpPredict(JumpPredict),
    .StallF(StallF),
    .NextAdrE(IEUAdrE),      // ← Fixed signal name
    .branch_target(branch_targetF),  // ← Added missing signal
    .PC(PC),
    .PCPlus4(PCPlus4)
);
```

---

### Fix #3: Verify ieu.sv Exports Correct Signals (VERIFICATION)
**File:** `src/ieu/ieu.sv`  
**Priority:** HIGH - Validation after Fix #1

**Checklist:**
- [ ] ieu.sv has `output logic [31:0] IEUAdrE` (from Fix #1, line ~14)
- [ ] ieu.sv has `output logic [31:0] branch_targetF` (from Fix #2, after line 15)
- [ ] datapath instantiation connects `.NextAdrE(IEUAdrE)` (from Fix #1, line ~95)
- [ ] datapath instantiation connects `.branch_targetF(branch_targetF)` (from Fix #2, line ~111)
- [ ] All control signals are properly routed

---

### Fix #4: Verify ifu.sv Receives All Signals (VERIFICATION)
**File:** `src/ifu/ifu.sv`  
**Priority:** MEDIUM - Validation after Fix #2

**Checklist:**
- [ ] ifu module has `input logic [31:0] NextAdrE` (expected)
- [ ] ifu module has `input logic [31:0] branch_target` (expected)
- [ ] riscvsingle.sv passes both signals correctly (from Fix #2)
- [ ] ifu.sv correctly uses these signals in PCNext mux logic

---

## Testing Checklist

**After Applying All Fixes, Verify:**

### Module Port Verification
- [ ] `src/ieu/ieu.sv` - Check output ports include `IEUAdrE` and `branch_targetF`
- [ ] `src/ieu/datapath.sv` - Confirm outputs `NextAdrE` and `branch_targetF`
- [ ] `src/ifu/ifu.sv` - Verify inputs include `NextAdrE` and `branch_target`
- [ ] `src/riscvsingle.sv` - Check ifu instantiation has all 9 connections

### Signal Width Verification
- [ ] `PCSrc` is [1:0] throughout pipeline
- [ ] `IEUAdrE` / `NextAdrE` is [31:0]
- [ ] `branch_targetF` / `branch_target` is [31:0]
- [ ] `JumpTarget` / `JumpTargetD` is [31:0]
- [ ] `WriteData` / `WriteDataM` is [31:0]
- [ ] All address signals are [31:0]

### Control Signal Verification
- [ ] `StallF` is 1-bit, routing correctly from datapath through ieu to ifu
- [ ] `JumpPredict` / `JumpPredictD` is 1-bit
- [ ] `RegWrite` signals in hazard_unit match stage definitions
- [ ] CSR address `csr_addrM` is [11:0]

### Compilation & Simulation
- [ ] SystemVerilog compilation succeeds with no missing port errors
- [ ] No "port not found" warnings in instantiations
- [ ] Behavioral simulation runs without connectivity errors
- [ ] Branch prediction signals propagate correctly in waveforms

### Git Diff Review
- [ ] `ieu.sv`: 2 additions (port declaration + datapath connection)
- [ ] `riscvsingle.sv`: 1 modification (ifu instantiation signal names)
- [ ] No unintended changes to other files

---

## Next Steps

1. **Apply Fix #1** - Update `src/ieu/ieu.sv`:
   - Fix the `.NextAdrE()` connection in datapath instantiation
   - Add `branch_targetF` output port
   - Add `.branch_targetF()` connection in datapath instantiation

2. **Apply Fix #2** - Update `src/riscvsingle.sv`:
   - Change `.IEUAdr()` to `.NextAdrE()` in ifu instantiation
   - Add `.branch_target()` connection in ifu instantiation

3. **Compile** - Run SystemVerilog compiler:
   ```bash
   cd src/ieu && xvlog *.sv  # or your compile flow
   ```

4. **Verify** - Check compilation output for:
   - No "undefined port" errors
   - No "port width mismatch" warnings
   - No "undefined signal" errors

5. **Simulate** - Run behavioral simulation and check:
   - Branch prediction signals appear in waveforms
   - PC updates correctly with branch predictions
   - All address signals are 32 bits wide

---

## Summary Table

| Issue | File | Line(s) | Fix Type | Severity |
|-------|------|---------|----------|----------|
| `.NextAdrE` connection | ieu.sv | ~95 | Rename connection | CRITICAL |
| `branch_targetF` output port | ieu.sv | +15 | Add port | CRITICAL |
| `.branch_targetF` connection | ieu.sv | ~111 | Add connection | CRITICAL |
| `.NextAdrE()` in ifu call | riscvsingle.sv | ~18 | Rename port | CRITICAL |
| `.branch_target()` in ifu call | riscvsingle.sv | ~19 | Add connection | CRITICAL |

---

**Document Version:** 1.0  
**Generated:** April 24, 2026  
**Status:** Ready for implementation
