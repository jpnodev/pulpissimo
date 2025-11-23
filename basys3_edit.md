# Basys3 Port - File Changes Log

This document tracks all file modifications made during the Basys3 port.

## Phase 1: Initial Port Setup

### 1. Target Directory Creation
- **Action**: Copied `target/fpga/pulpissimo-nexys` to `target/fpga/pulpissimo-basys3`
- **Command**: `cp -r target/fpga/pulpissimo-nexys target/fpga/pulpissimo-basys3`
- **Date**: 2025-11-23

---

### 2. FPGA Settings Configuration
- **File**: `target/fpga/pulpissimo-basys3/fpga-settings.mk`
- **Backup**: ⚠️ Not created (will create for future edits)
- **Changes**:
  - Changed `BOARD` from `nexys` to `basys3`
  - Set `XILINX_PART` to `xc7a35tcpg236-1` (Basys3 FPGA)
  - Set `XILINX_BOARD` to `digilentinc.com:basys3:part0:1.2`
  - Removed Nexys revision logic (not needed for Basys3)
  - Kept clock period settings: FC=100ns, PER=200ns, SLOW=30517ns
- **Rationale**: Configure build system for Basys3 Artix-7 35T FPGA

---

### 3. Constraints File Creation
- **File**: `target/fpga/pulpissimo-basys3/constraints/pulpissimo-basys3.xdc` (NEW)
- **Backup**: N/A (new file)
- **Changes**: Created new XDC file with Basys3-specific pin mappings:
  - **Clock**: W5 (100MHz oscillator)
  - **Reset Button**: U18 (center button)
  - **UART**: B18 (RX), A18 (TX) - USB-UART bridge
  - **JTAG**: PMOD JA pins (J1, L2, J2, G2)
  - **LEDs**: U16, E19, U19, V19 (4 LEDs)
  - **Switches**: V17, V16
  - **QSPI**: PMOD JC pins
  - **SD Card**: PMOD JD pins
  - **I2C/I2S**: PMOD JB pins
- **Rationale**: Basys3 has different pinout than Nexys4/A7

---

### 4. TCL Build Script Update
- **File**: `target/fpga/pulpissimo-basys3/tcl/run.tcl`
- **Backup**: ⚠️ Not created (will create for future edits)
- **Changes**: Modified constraint loading logic (lines 61-76):
  - Added condition to check if `$BOARD == "basys3"`
  - Load `pulpissimo-basys3.xdc` for Basys3
  - Preserved existing Nexys logic with `elseif`
- **Rationale**: Ensure correct constraints file is loaded for Basys3 builds

---

### 5. Bender Source File Generation
- **File**: `target/fpga/pulpissimo/tcl/generated/compile.tcl` (GENERATED)
- **Command**: `../../utils/bin/bender script vivado -t fpga -t xilinx > pulpissimo/tcl/generated/compile.tcl`
- **Rationale**: Generated Vivado TCL script that includes all RTL sources managed by Bender
- **Status**: ✅ Generated successfully, RTL elaboration completed

---

### 6. Phase 1 Verification Build
- **Status**: ❌ **FAILED** (Expected - resource over-utilization)
- **Build Command**: `make all -j16`
- **Synthesis**: ✅ PASSED
- **Implementation**: ❌ FAILED at placement stage

**Resource Utilization - Phase 1 Baseline:**
```
Resource         Required    Available    Over-Utilization
---------------------------------------------------------
LUTs             43,523      20,800       +109% (2.09x)
RAMB36           80          50           +60%  (1.6x)
RAMB18/36 Total  160         100          +60%  (1.6x)
DSPs             ~14         90           ✅ OK
```

**Error Messages:**
- `ERROR: [DRC UTLZ-1] Resource utilization: LUT as Logic over-utilized`
  - Design requires 43,523 LUTs but only 20,800 available
- `ERROR: [DRC UTLZ-1] Resource utilization: RAMB36/FIFO over-utilized`
  - Design requires 80 RAMB36 but only 50 available
- `ERROR: [DRC UTLZ-1] Resource utilization: RAMB18 and RAMB36/FIFO over-utilized`
  - Design requires 160 total but only 100 available

**Next Steps:** Proceed to Phase 2-5 optimizations to reduce resource usage.

---

### 7. Makefile Update for Log Preservation
- **File**: `target/fpga/pulpissimo-basys3/Makefile`
- **Backup**: ✅ `Makefile_old` created
- **Changes**: Modified `clean` target to preserve logs:
  - Created `build/` directory for log archival
  - Move `*.log` files to `build/` before clean
  - Move `vivado_pid*` and `vivado.jou` to `build/`
  - Still delete build artifacts (bitstreams, temporary files)
- **Rationale**: Preserve build logs for debugging and tracking progress across phases
- **Logs Archived**: Moved Phase 1 build logs to `build/` directory

---

## Phase 2: Core Optimization (In Progress)

### 1. Disable FPU & Select IBEX Core
- **File**: `target/fpga/pulpissimo-basys3/rtl/xilinx_pulpissimo.v`
- **Backup**: ✅ `xilinx_pulpissimo_old.v` created
- **Changes** (lines 78-80):
  - Changed `CORE_TYPE` from `0` (RISCY) to `2` (IBEX RV32EC)
  - Changed `USE_FPU` from `1` to `0` (DISABLED)
  - `USE_HWPE` already `0` (no change needed)
- **Rationale**: 
  - IBEX RV32EC is a smaller core without FPU support
  - FPU consumes ~3,000-5,000 LUTs
  - IBEX RV32EC uses fewer resources than RISCY
- **Additional Checks**:
  - ✅ Verified CORE_TYPE only set in xilinx_pulpissimo.v
  - ✅ USE_FPU parameter propagates through pulpissimo.sv and soc_domain.sv
  - ✅ No additional configuration files need modification

### 2. Phase 2 Verification Build
- **Status**: ❌ **FAILED** (Expected - still over-utilized)
- **Build Command**: `make all -j16`
- **Synthesis**: ✅ PASSED
- **Implementation**: ❌ FAILED at placement stage

**Resource Utilization - Phase 2 Results:**
```
Resource         Required    Available    Over-Utilization    vs Phase 1
-------------------------------------------------------------------------
LUTs             35,160      20,800       +69% (1.69x)       -19% ✅ (-8,363)
RAMB36           80          50           +60% (1.6x)        No change
RAMB18/36 Total  160         100          +60% (1.6x)        No change  
DSPs             4           90           ✅ OK              -10 ✅
```

**Phase 2 Impact Analysis:**
- **LUT Reduction**: 8,363 LUTs saved (19% reduction from 43,523 → 35,160)
  - FPU removal + IBEX RV32EC core delivered expected ~3k-5k+ LUT savings
- **BRAM**: No change (as expected - memory size unchanged)
- **Remaining Gap**:
  - Still need to reduce LUTs by **14,360** more (41% further reduction)
  - Still need to reduce BRAM by **60** (38% reduction)

**Next Steps:** Proceed to Phase 3 (Peripheral Reduction) to disable unused peripherals.

---

## Phase 3: Peripheral Reduction (In Progress)

### 1. Clone Dependencies
- **Command**: `./utils/bin/bender clone pulp_io` and `./utils/bin/bender clone pulp_soc`
- **Result**: Dependencies cloned to `working_dir/pulp_io` and `working_dir/pulp_soc`
- **Rationale**: Need to modify `pulp_io` package which is a dependency

### 2. Disable Unused Peripherals  
- **File**: `working_dir/pulp_io/src/udma_cfg_pkg.sv`
- **Backup**: ✅ `udma_cfg_pkg_old.sv` created
- **Changes** (lines 22-31):
  - `N_QSPIM`: 1 → **0** (DISABLED)
  - `N_UART`: **1** (KEEP - needed for console)
  - `N_I2C`: 1 → **0** (DISABLED)
  - `N_SDIO`: 1 → **0** (DISABLED)
  - `N_CPI`: 1 → **0** (DISABLED)
  - `N_HYPER`: 1 → **0** (DISABLED)
  - `N_FILTER`: **1** (KEEP - required to avoid uDMA arbiter bug with single channel)
- **Rationale**: 
  - Unused peripherals consume logic resources
  - QSPI, I2C, SDIO, CPI, and HyperBus not needed for basic operation
  - UART essential for console communication
  - FILTER must stay enabled to prevent uDMA arbiter issues

### 3. Phase 3 Verification Build
- **Status**: 🔄 Starting...

---

## Phase 4: Padframe Adaptation (In Progress)

### 1. Update Padframe Muxing
- **File**: `hw/padframe/padframe_adapter.sv`
- **Backup**: ✅ `padframe_adapter_old.sv` created
- **Changes**:
  - Updated `N_CONNECTED_*` constants to `0` for QSPI, I2C, SDIO, CPI, HYPER
  - Wrapped `ASSIGN_*` macros in `generate` blocks checking `if (udma_cfg_pkg::N_* > 0)`
- **Rationale**: 
  - Resolves synthesis error `[Synth 8-6058]` (mismatch between configured and connected peripherals)
  - Ensures assignments are only generated for active peripherals

### 2. Phase 4 Verification Build
- **Status**: ❌ **FAILED** (Expected - still over-utilized)
- **Build Command**: `make all -j16`
- **Synthesis**: ✅ PASSED
- **Implementation**: ❌ FAILED at placement stage

**Resource Utilization - Phase 4 Results:**
```
Resource         Required    Available    Over-Utilization    vs Phase 2
-------------------------------------------------------------------------
LUTs             25,732      20,800       +24% (1.24x)       -27% ✅ (-9,428)
RAMB36           80          50           +60% (1.6x)        No change
RAMB18/36 Total  160         100          +60% (1.6x)        No change  
```

**Phase 4 Impact Analysis:**
- **LUT Reduction**: 9,428 LUTs saved (27% reduction from 35,160 → 25,732)
  - Disabling QSPI, I2C, SDIO, CPI, HYPER was highly effective
- **Total Progress**: 43,523 → 25,732 (41% total reduction)
- **Remaining Gap**:
  - **LUTs**: Need to reduce by **4,932** more (19% further reduction)
  - **BRAM**: Need to reduce by **60** (38% reduction)

**Next Steps:** Proceed to Phase 5 (Memory Reduction) to reduce L2 TCDM size.

---

## Phase 5: Memory Reduction ✅ COMPLETE

### 1. Reduce L2 TCDM Size
- **Goal**: Reduce BRAM usage to fit Basys3 (100 BRAMs available) while maximizing capacity.
- **Files Modified**:
  - `working_dir/pulp_soc/rtl/pulp_soc/pulp_soc.sv`: Changed `L2_BANK_SIZE` to `8192` (32KB/bank).
  - `hw/includes/soc_mem_map.svh`: Updated `SOC_MEM_MAP_TCDM_END_ADDR` to `32'h1C03_0000` (128KB range).
- **Rationale**: 
  - 128KB TCDM + 64KB Private = 192KB total.
  - Basys3 has ~225KB total BRAM (50 RAMB36).
  - Utilization: ~86% (43/50 RAMB36s). Maximizes usage without overflow.

### 2. Phase 5 Verification Build
- **Status**: ❌ **FAILED** (LUTs over-utilized, but BRAM OK!)
- **Build Command**: `make all -j16`
- **Synthesis**: ✅ PASSED
- **Implementation**: ❌ FAILED at placement (LUTs)

**Resource Utilization - Phase 5 Results:**
```
Resource         Required    Available    Over-Utilization    vs Phase 4
-------------------------------------------------------------------------
LUTs             24,909      20,800       +20% (1.20x)        -3% ✅ (-823)
RAMB36           48          50           96% (OK)            -40% ✅ (Fits!)
RAMB18/36 Total  96          100          96% (OK)            -40% ✅ (Fits!)
```

**Phase 5 Impact Analysis:**
- **BRAM**: **SOLVED**. Reduced from 80 -> 48 RAMB36s.
  - 192KB total memory (128KB TCDM + 64KB Private) fits perfectly.
  - Maximized usage (96%) as requested.
- **LUTs**: Slight reduction (25,732 -> 24,909).
  - Still need to save ~4,100 LUTs.

**Next Steps:** Phase 6 - Final LUT Reduction (Disable HWPE, XPULP).

---

## Phase 6: Final LUT Reduction (Pending)

---

## Notes
- **Backup Policy**: Starting from next edit, all files will be backed up with `_old` suffix before modification
- **Build Status**: Phase 1 verification build in progress
