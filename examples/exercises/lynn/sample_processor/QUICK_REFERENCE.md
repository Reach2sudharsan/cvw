# Quick Reference: Signal Consistency Issues & Fixes

## ❌ CRITICAL ISSUES FOUND: 3

### Issue #1: Wrong Signal Name in ieu.sv
```
datapath.sv outputs:    NextAdrE [31:0]
ieu.sv tries to use:    IEUAdrE  ← WRONG NAME (doesn't exist in datapath)
```
**Fix:** Change `.IEUAdrE(IEUAdrE)` → `.NextAdrE(IEUAdrE)` in ieu.sv line ~95

---

### Issue #2: Missing branch_targetF in ieu.sv  
```
datapath.sv outputs:    branch_targetF [31:0]
ieu.sv exports:         ??? (not declared)
riscvsingle.sv passes:  ??? (not connected)
ifu.sv expects:         branch_target [31:0]
```
**Fix:**
1. Add output port to ieu.sv: `output logic [31:0] branch_targetF;`
2. Add connection in ieu.sv: `.branch_targetF(branch_targetF),`
3. Add connection in riscvsingle.sv: `.branch_target(branch_targetF),`

---

### Issue #3: Signal Name Mismatch in riscvsingle.sv
```
riscvsingle.sv sends:   IEUAdrE  [31:0]
ifu.sv expects:         NextAdrE [31:0]  ← DIFFERENT NAME
```
**Fix:** Change `.IEUAdr(IEUAdrE)` → `.NextAdrE(IEUAdrE)` in riscvsingle.sv line ~18

---

## 📊 Signal Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ DATAPATH outputs (src/ieu/datapath.sv)                          │
├─────────────────────────────────────────────────────────────────┤
│ ✓ NextAdrE [31:0]      → IEU  → riscvsingle → IFU NextAdrE    │
│ ✓ IEUAdrM [31:0]       → IEU  → riscvsingle → (not used)       │
│ ❌ branch_targetF [31:0] → ??? (MISSING) → ??? → IFU branch_target │
│ ✓ PCSrcE [1:0]         → IEU  → riscvsingle → IFU PCSrc       │
│ ✓ JumpTargetD [31:0]   → IEU  → riscvsingle → IFU JumpTarget  │
│ ✓ JumpPredictD [1]     → IEU  → riscvsingle → IFU JumpPredict │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Fixes Required (in order)

### Fix A: ieu.sv (2 changes)
```diff
// Add output port (after line 15):
+ output  logic [31:0]    branch_targetF,

// Fix datapath connection (line ~95):
- .IEUAdrE(IEUAdrE),
+ .NextAdrE(IEUAdrE),

// Add datapath connection (line ~111):
+ .branch_targetF(branch_targetF),
```

### Fix B: riscvsingle.sv (1 change)
```diff
  ifu ifu(
      .clk(clk),
      .reset(reset),
      .PCSrc(PCSrc),
      .JumpTarget(JumpTarget),
      .JumpPredict(JumpPredict),
      .StallF(StallF),
-     .IEUAdr(IEUAdrE),
+     .NextAdrE(IEUAdrE),
+     .branch_target(branch_targetF),
      .PC(PC),
      .PCPlus4(PCPlus4)
  );
```

---

## ✅ Verification Checklist

After applying fixes, verify:
- [ ] `ieu.sv` has output declaration for `branch_targetF`
- [ ] `ieu.sv` datapath instantiation has `.NextAdrE()` connection (not `.IEUAdrE()`)
- [ ] `ieu.sv` datapath instantiation has `.branch_targetF()` connection
- [ ] `riscvsingle.sv` ifu instantiation has `.NextAdrE()` parameter (not `.IEUAdr()`)
- [ ] `riscvsingle.sv` ifu instantiation has `.branch_target()` parameter
- [ ] All changes match the Expected Fixes section exactly
- [ ] Compilation succeeds with no undefined port errors

---

## 📁 Files to Modify

| File | Changes | Lines |
|------|---------|-------|
| `src/ieu/ieu.sv` | Add port + fix connection + add connection | 15, 95, 111 |
| `src/riscvsingle.sv` | Fix connection names, add connection | 18-19 |

**Total lines to change:** ~5 lines

---

## 🎯 Impact

**Without fixes:** IFU doesn't receive branch prediction target and execute stage address signals

**With fixes:** Full signal chain working:
- Execute stage addresses flow from datapath → IEU → top level → IFU
- Branch prediction targets flow from datapath → IEU → top level → IFU
- Pipeline can execute branches and jumps correctly
