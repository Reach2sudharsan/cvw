# Detailed Implementation Examples

## Optimization 1: Inline ForwardMA/ForwardMB (EASIEST WIN)

### Current Code (datapath.sv lines 288-295)
```systemverilog
// Forwarding multiplexers for ALU operands
logic [31:0] ForwardMA;
logic [31:0] ForwardMB;
mux2 #(32) forwardMAmux(IEUResultM, CSRReadDataM, ResultSrcM[1], ForwardMA);
mux2 #(32) forwardMBmux(IEUResultM, CSRReadDataM, ResultSrcM[1], ForwardMB);
mux3 #(32) forwardAmux(RD1E, SizedResultW, ForwardMA, ForwardAE, Aout);
mux3 #(32) forwardBmux(RD2E, SizedResultW, ForwardMB, ForwardBE, Bout);
```

### Optimized Code (Direct Mux4)
```systemverilog
// Forwarding multiplexers for ALU operands
// Instead of: Reg → 3:1 mux [RD1E, SizedResultW, ForwardMA]
// Use direct 4:1 mux: [RD1E, SizedResultW, IEUResultM (or CSRReadDataM)]
// This inlines ForwardMA/ForwardMB and uses a single mux level

logic [31:0] ForwardResultA, ForwardResultB;

// 4:1 mux for operand A forwarding
// ForwardAE[1:0] encoding:
//   00: Register file (RD1E)
//   01: Writeback result (SizedResultW)
//   10: Memory stage result (IEUResultM)
//   (No need for 11 if CSR not used in multiply path)
mux4 #(32) forwardAmux(RD1E, SizedResultW, IEUResultM, 32'bx, ForwardAE, ForwardResultA);
mux4 #(32) forwardBmux(RD2E, SizedResultW, IEUResultM, 32'bx, ForwardBE, ForwardResultB);

// ALU source multiplexers (these still needed for PC/Immediate muxing)
mux2 #(32) srcamux(ForwardResultA, PCE, ALUSrcE[1], SrcAE);
mux2 #(32) srcbmux(ForwardResultB, ImmExtE, ALUSrcE[0], SrcBE);
```

### Changes Needed
**Remove:**
- `logic [31:0] ForwardMA, ForwardMB;`
- `mux2 #(32) forwardMAmux(...)`
- `mux2 #(32) forwardMBmux(...)`
- Rename current `forwardAmux` and `forwardBmux` to handle 4 inputs
- Update hazard_unit to generate ForwardAE/ForwardBE for 4 inputs instead of 3

**Benefits:**
- Removes 2 × 32-bit mux modules (600-800 gates)
- Removes 2 intermediate 32-bit signals
- Same logic depth (1 × 4:1 vs 1 × 2:1 + 1 × 3:1)

---

## Optimization 2: Move Load Data Sizing to Memory Stage

### Current Code (datapath.sv lines 575-591)
```systemverilog
// WriteBACK STAGE

// Result multiplexer
mux3 #(32) resultmux(IEUResultW, ReadDataW, CSRReadDataW, ResultSrcW, ResultW);

// Load data sizing
mux2 #(16) halfmux(ResultW[15:0], ResultW[31:16], IEUResultW[1], HalfResultW);
mux2 #(8) bytemux(HalfResultW[7:0], HalfResultW[15:8], IEUResultW[0], ByteResultW);

always_comb begin
    case (LoadTypeW)
        3'b010: SizedResultW = ResultW;              // lw
        3'b001: SizedResultW = {{16{HalfResultW[15]}}, HalfResultW};  // lh
        3'b101: SizedResultW = {16'b0, HalfResultW};  // lhu
        3'b000: SizedResultW = {{24{ByteResultW[7]}}, ByteResultW};   // lb
        3'b100: SizedResultW = {24'b0, ByteResultW};  // lbu
        default: SizedResultW = ResultW;
    endcase
end
```

### Optimized Code (Move to Memory Stage)
```systemverilog
// ============================================================================
// MEMORY STAGE
// ============================================================================
// ... existing memory stage code ...

// Load data sizing happens here (non-critical path)
logic [31:0] SizedReadDataM, SizedResultM;
logic [15:0] HalfDataM;
logic [7:0] ByteDataM;

// Select bytes for load sizing
mux2 #(16) halfmux(ReadDataM[15:0], ReadDataM[31:16], IEUAdrb10M[1], HalfDataM);
mux2 #(8) bytemux(HalfDataM[7:0], HalfDataM[15:8], IEUAdrb10M[0], ByteDataM);

// Size and sign-extend load data
always_comb begin
    case (LoadTypeM)
        3'b010: SizedReadDataM = ReadDataM;                            // lw
        3'b001: SizedReadDataM = {{16{HalfDataM[15]}}, HalfDataM};     // lh
        3'b101: SizedReadDataM = {16'b0, HalfDataM};                   // lhu
        3'b000: SizedReadDataM = {{24{ByteDataM[7]}}, ByteDataM};      // lb
        3'b100: SizedReadDataM = {24'b0, ByteDataM};                   // lbu
        default: SizedReadDataM = ReadDataM;
    endcase
end

// Result mux: ALU | SizedLoad | CSR
mux3 #(32) resultmux(IEUResultM, SizedReadDataM, CSRReadDataM, ResultSrcM, SizedResultM);

// Pipeline registers: Memory to Writeback
flopenr #(32) M2W_ReadData(.clk, .reset, .enable(1'b1), .flush(1'b0),
                            .D(SizedResultM), .Q(SizedResultW));
// ... other M2W registers ...

// ============================================================================
// WRITEBACK STAGE
// ============================================================================
// No load data sizing needed here anymore
// Just use SizedResultW directly, no intermediate muxing required
// If forwarding, use SizedResultW directly as computed in M stage
```

### Changes Needed
**In Memory Stage:**
- Add `SizedReadDataM`, `HalfDataM`, `ByteDataM` signals
- Move `halfmux` and `bytemux` to Memory stage
- Move load sizing case statement to Memory stage
- Change `resultmux` inputs to use `SizedReadDataM` instead of `ReadDataM`

**In WriteBACK Stage:**
- **Remove:** `halfmux`, `bytemux` instantiations
- **Remove:** `HalfResultW`, `ByteResultW` signals
- **Remove:** Load sizing case statement
- **Remove:** `resultmux` and associated sizing logic
- Change pipeline register to pass `SizedResultM` → `SizedResultW` directly
- Use `SizedResultW` directly in forwarding (no additional muxing)

**In Datapath Outputs:**
- `SizedResultW` now comes directly from pipeline, no additional mux
- Forwarding muxes get `SizedResultW` which is pre-sized

**Benefits:**
- Removes 3 muxes from critical path (halfmux, bytemux, resultmux)
- Removes intermediate signals: `ResultW`, `HalfResultW`, `ByteResultW`
- Moves load sizing out of critical path (~300-400 gates saved)
- Critical path: WB result now simple pipeline register, not a mux

---

## Optimization 3: Remove CSR from Multiply Forwarding Path

### Current Code (hazard_unit.sv)
```systemverilog
// ForwardAE/ForwardBE values:
// 00: No forwarding (use register file)
// 01: Forward from Writeback
// 10: Forward from Memory
// (Can include 11 for other sources)
```

### Optimized Code with CSR Check
```systemverilog
// In datapath.sv - Forwarding mux creation:

// Only forward CSR to non-multiply instructions
logic [31:0] ForwardMA_Safe, ForwardMB_Safe;

// If multiply instruction, don't use CSR data
mux2 #(32) csrFilterA(CSRReadDataM, IEUResultM, IsMulM, ForwardMA_Safe);
mux2 #(32) csrFilterB(CSRReadDataM, IEUResultM, IsMulM, ForwardMB_Safe);

// Then use ForwardMA_Safe, ForwardMB_Safe instead of CSRReadDataM in mux
mux3 #(32) forwardAmux(RD1E, SizedResultW, ForwardMA_Safe, ForwardAE, Aout);
mux3 #(32) forwardBmux(RD2E, SizedResultW, ForwardMB_Safe, ForwardBE, Bout);
```

### Alternative: Prevent CSR from being a forwarding source for multiply
```systemverilog
// In hazard_unit - modify forwarding logic:

always_comb begin
    if ((Rs1E == RdM) && RegWriteM && (Rs1E != 0) && !IsMulE) begin
        ForwardAE = 2'b10; // Forward from memory, but only if NOT multiply
    end else if ((Rs1E == RdW) && RegWriteW && (Rs1E != 0)) begin
        ForwardAE = 2'b01; // Forward from writeback (always safe)
    end else begin
        ForwardAE = 2'b00; // No forwarding
    end
end
```

**Issue:** This approach limits multiply operand forwarding from M stage when result is CSR

**Better approach:** Keep CSR separate from integer result forwarding:
```systemverilog
// Only use IEUResultM for multiply forwarding, not CSRReadDataM
mux2 #(32) forwardAmux_mul(RD1E, IEUResultM, ForwardAE[1] & IsMulE, ForwardResultA_mul);
mux2 #(32) forwardAmux_other(RD1E, ForwardMA, ForwardAE[1] & !IsMulE, ForwardResultA_other);
mux2 #(1) muxsel(..., IsMulE, ForwardResultA);
```

Actually, this gets complicated. **Simpler approach:**

### Simplest Solution: Conditional Mux Input Based on IsMulE
```systemverilog
// Forward mux only includes CSR if not a multiply operation
logic [31:0] mux_input_2; // 3rd input to forward mux

// For multiply: use IEUResultM only
// For other ops: use CSRReadDataM or IEUResultM based on ResultSrcM
mux2 #(32) forward_select(CSRReadDataM, IEUResultM, IsMulE, mux_input_2);

mux3 #(32) forwardAmux(RD1E, SizedResultW, mux_input_2, ForwardAE, Aout);
```

**Benefits:**
- Multiply operands never use CSR data (which can't happen anyway)
- Saves one mux input width consideration
- Reduces mux fan-in from 4 to 3 for multiply path

---

## Testing Strategy

After implementing optimizations:

1. **Verify functionality:** Run existing test suite
   ```bash
   make test
   ```

2. **Check synthesis:** Verify area reduction in synthesis report
   ```bash
   make synth
   grep "Total cell area" *.rpt
   ```

3. **Verify timing:** Check critical path delay
   ```bash
   grep "Critical path" *.rpt
   ```

4. **Run benchmarks:** Ensure correctness on real workloads
   ```bash
   make coremark
   ```

5. **Verify forwarding:** Add specific test cases for:
   - Multiply result forwarding to next multiply
   - Load-to-multiply forwarding
   - CSR-to-execute forwarding (should not affect multiply)
