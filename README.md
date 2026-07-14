# RV32I Single-Cycle Processor

A single-cycle RISC-V CPU implementing a subset of the RV32I base integer instruction set, written in SystemVerilog.

This project was built as a hands-on exercise in computer architecture — going from individual datapath components (ALU, register file, immediate generator) up to a fully wired single-cycle CPU capable of running simple assembly programs.

## Features

 32-bit single-cycle datapath (fetch, decode, execute, memory, writeback all in one clock cycle)
 32 x 32-bit register file with `x0` hardwired to zero
 Instruction memory loaded from a `.hex` file at simulation start
 Data memory with word-aligned load/store
 Immediate generator supporting I-type, S-type, B-type, and J-type encodings
 Branch and jump (`jal`) support with PC redirection
 
 Currently supported instructions:
  - R-type: `add`, `sub`, `and`, `or`
  - I-type: `addi`, `andi`, `ori`
  - `lw` / `sw`
  - `beq` / `bne`
  - `jal`

> Additional ALU operations (`xor`, `sll`, `srl`, `sra`, `slt`, `sltu`) and their corresponding opcodes are defined in `cpu_defs.svh` but not yet wired into the control unit — planned for a future update.

## Repository Structure

```
.
├── rtl/                 # Core design (RTL)
│   ├── top.sv            # Top-level module wiring the full datapath
│   ├── alu.sv             # Arithmetic/logic unit
│   ├── control_unit.sv    # Instruction decode / control signal generation
│   ├── regfile.sv         # 32x32-bit register file
│   ├── imm_gen.sv         # Immediate value generator
│   ├── instr_mem.sv       # Instruction memory
│   ├── data_mem.sv        # Data memory
│   ├── pc_reg.sv          # Program counter register
│   └── cpu_defs.svh       # Shared types (ctrl_t struct, alu_op_t enum)
├── tb/                   # Testbenches (per-module and full-CPU)
│   ├── tb_alu.sv
│   ├── tb_regfile.sv
│   ├── tb_phase1.sv .. tb_phase4.sv   # Incremental integration testbenches
├── Sim/                  # Compiled simulation binaries (Icarus Verilog output)
├── Waveform/              # Simulation waveform dump + screenshot
│   ├── phase4_tb.vcd
│   └── Waveform.png
├── programs/              # Sample assembly program + its machine code
│   ├── sum.txt             # RV32I assembly source
│   └── sum.hex             # Assembled machine code (loaded via $readmemh)
```

## Sample Program: `sum.txt`

The included test program sums the integers 1 through 20 using a loop:

```asm
addi s0, zero, 0     # s0 = sum = 0
addi s1, zero, 20    # s1 = bound = 20
addi s3, zero, 0     # s3 = i = 0

loop:
addi s3, s3, 1       # i++
add  s0, s0, s3      # sum += i
bne  s3, s1, loop    # repeat until i == 20

done:
```

Expected result: `x8 (sum) = 210`.

## Running the Simulation

This project was developed and tested using [Icarus Verilog](http://iverilog.icarus.com/).

```bash
# Compile the full-CPU testbench
iverilog -g2012 -o Sim/phase4_sim rtl/*.sv tb/tb_phase4.sv

# Run it
vvp Sim/phase4_sim
```

This runs `sum.txt` (pre-assembled into `programs/sum.hex`) through the CPU and checks that register `x8` ends up holding `210`.

To inspect the waveform:
```bash
gtkwave Waveform/phase4_tb.vcd
```

Individual module testbenches (`tb_alu.sv`, `tb_regfile.sv`, etc.) can be compiled and run the same way against their respective RTL files for isolated unit testing.

## Design Overview

The datapath follows the classic single-cycle RISC-V structure:

1. **Fetch** — `pc_reg` holds the current PC; `instr_mem` returns the instruction at that address.
2. **Decode** — `control_unit` derives control signals from the opcode/funct3/funct7 fields; `imm_gen` extracts and sign-extends the immediate; `regfile` reads `rs1`/`rs2`.
3. **Execute** — `alu` performs the operation selected by the control unit, with operand B chosen between `rs2`, the immediate, or `pc+4` (for `jal` link address).
4. **Memory** — `data_mem` is read or written depending on the instruction (`lw`/`sw`).
5. **Writeback** — the ALU result or memory read data is written back to the register file, selected by `mem_to_reg`.
6. **PC Update** — the next PC is computed as `pc+4`, or `pc+imm` if a branch is taken or the instruction is `jal`.


