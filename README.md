# Pipelined RISC-V Processor (RV32I, 5-Stage) with Hazard Handling

This project implements a **5-stage pipelined RISC-V processor** supporting a subset of the **RV32I instruction set**. Designed in **SystemVerilog**, it includes a fully working **hazard detection unit** (for both **data hazards** and **control hazards**) with **forwarding, stalling, and flushing logic**.

The processor is simulated using **Icarus Verilog** and validated with **GTKWave** through directed tests and waveform analysis.

This project is part of my **RTL Design portfolio** and demonstrates hands-on expertise in pipelined microarchitecture, hazard mitigation strategies, and cycle-level validation through waveform inspection.

---

## ✅ Features

- **ISA**: RV32I (subset)
- **Architecture**: 5-stage pipeline
- **Pipeline Stages**: IF → ID → EX → MEM → WB
- **Hazard Unit**:
  - Data Hazard Detection (RAW)
  - Control Hazard Detection (BEQ)
  - Forwarding, Stalling, and Flushing
- **Language**: SystemVerilog
- **Simulation Tool**: Icarus Verilog (`iverilog`)
- **Waveform Viewer**: GTKWave
- **Testbench**: Directed tests with memory initialization
- **Validation**: Waveform screenshots and PC/register tracing

---

## ✅ Instructions Implemented

The following instructions were implemented:

| Instruction | Operation          | Status |
|-------------|--------------------|--------|
| `addi`      | Add Immediate       | ✅     |
| `add`       | Add Register        | ✅     |
| `or`        | Bitwise OR          | ✅     |
| `and`       | Bitwise AND         | ✅     |
| `slt`       | Set Less Than       | ✅     |
| `lw`        | Load Word           | ✅     |
| `sw`        | Store Word          | ✅     |
| `beq`       | Branch If Equal     | ✅     |
| `jal`       | Jump And Link       | ✅     |

---

## 🧪 Hazard Unit Validation

### 🔁 Data Hazard (RAW) Test:
```assembly
addi x1, x0, 5
add x2, x1, x1   # Depends on x1
add x3, x2, x1   # Depends on x2
```
### 🔁 Data Hazard (RAW) Test:
```assembly
beq x1, x1, LABEL
addi x8, x0, 1      # Should be flushed if branch taken
LABEL: add x9, x0, x0
```
