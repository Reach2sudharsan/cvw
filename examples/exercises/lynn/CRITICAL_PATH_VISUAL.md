# Critical Path Visual Summary

## Current Critical Path (SLOW)

```
WRITEBACK STAGE
===============
ReadDataM ─┐
ALUResultM ├──→ resultmux (3:1) ──→ ResultW
CSRReadDataM ─┘
              │
              ↓
          halfmux (2:1) ──→ HalfResultW
              │
              ↓
          bytemux (2:1) ──→ ByteResultW
              │
              ↓
          Case statement ──→ SizedResultW
              │
              │ [Pipeline Register]
              ↓
EXECUTE STAGE (next cycle)
==========================
RD1E ────────────┐
SizedResultW ────├──→ forwardAmux (3:1) ──→ Aout ──→ srcamux (2:1) ──→ SrcAE
ForwardMA ───────┘                                                        │
                                                                         ↓
                                                                  Multiply Unit
                                                                  (CRITICAL)
RD2E ────────────┐
SizedResultW ────├──→ forwardBmux (3:1) ──→ Bout ──→ srcbmux (2:1) ──→ SrcBE
ForwardMB ───────┘                                                        │
                                                                         ↓
                                                                  Multiply Unit
```

**Critical Path Delay:** resultmux → halfmux → bytemux → forwardAmux → srcamux → Multiply
**Estimated Delay:** 6-7 mux levels = ~15-20 gate delays (at 32-bit width)

---

## Optimized Critical Path (FAST)

### After Optimization 1 (Inline ForwardMA/ForwardMB)
```
WRITEBACK STAGE (unchanged)
===========================
ReadDataM ─┐
ALUResultM ├──→ resultmux (3:1) ──→ ResultW
CSRReadDataM ─┘
              │
              ↓
          halfmux (2:1) ──→ HalfResultW
              │
              ↓
          bytemux (2:1) ──→ ByteResultW
              │
              ↓
          Case statement ──→ SizedResultW
              │
              │ [Pipeline Register]
              ↓
EXECUTE STAGE (next cycle)
==========================
RD1E ───────────────────┐
SizedResultW ───────────├──→ forwardAmux (4:1) ──→ Aout ──→ srcamux (2:1) ──→ SrcAE
IEUResultM (from ForwardMA) ─┘                                                  │
CSRReadDataM (from ForwardMB) (3rd input)                                       ↓
                                                                         Multiply Unit
```

**Improvement:** Same mux depth (still slow), 600-800 gates saved
**Critical Path Delay:** Still 6 levels (not improved)

---

### After Optimization 2 (Move Load Sizing to M Stage)
```
MEMORY STAGE
============
ReadDataM ──→ halfmux (2:1) ──→ HalfDataM
              │
              ↓
          bytemux (2:1) ──→ ByteDataM
              │
              ↓
          Case statement ──→ SizedReadDataM
              │
              ├──┐
              │  │
IEUResultM ──┤  ├──→ resultmux (3:1) ──→ SizedResultM
CSRReadDataM ┤  │
             └──┘
              │
              │ [Pipeline Register]
              ↓
WRITEBACK STAGE
===============
Just forwards SizedResultW (no additional muxes)
              │
              │
              ↓
EXECUTE STAGE (next cycle)
==========================
RD1E ───────────────────┐
SizedResultW ───────────├──→ forwardAmux (4:1) ──→ Aout ──→ srcamux (2:1) ──→ SrcAE
IEUResultM ─────────────┘
              │
              │
              ↓
          Multiply Unit ✓ CRITICAL PATH NOW SHORTER!
```

**Improvement:** resultmux, halfmux, bytemux moved before pipeline register
**Critical Path Delay:** 3 levels (resultmux, forwardAmux, srcamux) = 8-10 gate delays
**Speedup:** 40-50% faster than original!

---

### After Both Optimizations (RECOMMENDED)
```
MEMORY STAGE
============
ReadDataM ──→ Sizing Muxes ──→ SizedReadDataM
              │
              ├──┐
              │  │
IEUResultM ──┤  ├──→ resultmux (3:1) ──→ SizedResultM
CSRReadDataM ┤  │
             └──┘
              │
              │ [Pipeline Register - carries SizedResultM]
              ↓
EXECUTE STAGE (next cycle)
==========================
RD1E ───────────────────┐
SizedResultW ───────────├──→ forwardAmux (4:1) ──→ Aout ──→ srcamux (2:1) ──→ SrcAE
IEUResultM ─────────────┘
              │
              ↓
          Multiply Unit ✓✓ OPTIMAL
```

**Total Improvement:**
- **Area:** -2.0-3.0K gates (5-10% of datapath)
- **Critical Path:** 3 mux levels vs 6+ levels = 40-50% speedup
- **Signals Removed:** HalfResultW, ByteResultW, ForwardMA, ForwardMB, intermediate signals

---

## Area Breakdown (Estimated)

### Gates in Current Design
```
resultmux (3:1, 32-bit)      ~800 gates
halfmux (2:1, 16-bit)        ~400 gates
bytemux (2:1, 8-bit)         ~200 gates
Load sizing case statement   ~300 gates
forwardMAmux (2:1, 32-bit)   ~800 gates
forwardMBmux (2:1, 32-bit)   ~800 gates
forwardAmux (3:1, 32-bit)    ~1200 gates
forwardBmux (3:1, 32-bit)    ~1200 gates
srcamux (2:1, 32-bit)        ~800 gates
srcbmux (2:1, 32-bit)        ~800 gates
Intermediate signals         ~600 gates (wiring)
─────────────────────────────────────
TOTAL in critical path      ~8.6K gates
```

### After Optimizations
```
resultmux (moved to M stage, not on critical path from WB)
halfmux (moved to M stage)
bytemux (moved to M stage)
Load sizing (moved to M stage)
[ForwardMA/ForwardMB removed - inlined]
forwardAmux (4:1, 32-bit)    ~1400 gates (slightly larger, 4 inputs vs 3)
forwardBmux (4:1, 32-bit)    ~1400 gates
srcamux (unchanged)          ~800 gates
srcbmux (unchanged)          ~800 gates
Intermediate signals (fewer) ~200 gates
─────────────────────────────────────
TOTAL on critical path      ~4.6K gates (47% reduction!)
```

---

## Signal Flow Before/After

### BEFORE: SizedResultW Computation Chain
```
resultmux()
  → ResultW
    → halfmux()
      → HalfResultW
        → bytemux()
          → ByteResultW
            → case statement
              → SizedResultW
                → forwardAmux()
```
**9 logic stages from result mux to forwarding mux**

### AFTER: Direct Forwarding
```
SizedResultM (computed in M stage)
  → [Pipeline Register]
    → SizedResultW (arrives pre-computed)
      → forwardAmux()
```
**1 logic stage from result to forwarding mux**

---

## Signal Elimination Impact

```
REMOVE:
─────
HalfResultW (16-bit pipeline signal)          ~48 byte wires
ByteResultW (8-bit pipeline signal)           ~24 byte wires
ForwardMA (32-bit intermediate signal)        ~96 byte wires
ForwardMB (32-bit intermediate signal)        ~96 byte wires
ResultW (32-bit intermediate)                 ~96 byte wires

SUBTOTAL                                      ~360 byte wires
Equivalent to: ~600-800 gates of routing

ADD (from M stage):
──────
HalfDataM (16-bit, local to M stage)          ~0 wire cost (non-critical)
ByteDataM (8-bit, local to M stage)           ~0 wire cost (non-critical)
```

**Net wiring improvement:** Frees up critical wiring resources

---

## Validation Checklist

- [ ] Load-to-Execute forwarding still works with moved sizing
- [ ] Byte/halfword sizing produces correct results
- [ ] All instruction types still receive correct forward values
- [ ] CSR reads don't interfere with multiply path
- [ ] Timing closure met (critical path now faster)
- [ ] Area reduction confirmed in synthesis
