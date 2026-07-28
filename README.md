# RV32I Single-Cycle Processor

A single-cycle RISC-V CPU implementing a subset of the RV32I base integer instruction set, written in SystemVerilog.

This project was built as a hands-on exercise in computer architecture going from individual datapath components (ALU, register file, immediate generator) up to a fully wired single-cycle CPU capable of running simple assembly programs.

## Features

 32-bit single-cycle datapath (fetch, decode, execute, memory, writeback all in one clock cycle)
 32 x 32-bit register file with `x0` hardwired to zero
 Instruction memory loaded from a `.hex` file at simulation start
 Data memory with word-aligned load/store
 Immediate generator supporting I-type, S-type, B-type, U-type, and J-type encodings
 Branch and jump (`jal`, `jalr`) support with PC redirection
 
 Currently supported instructions:
  - R-type: `add`, `sub`, `sll`, `slt`, `sltu`, `xor`, `srl`, `sra`, `or`, `and`
  - I-type (ALU immediate): `addi`, `slti`, `sltiu`, `xori`, `ori`, `andi`, `slli`, `srli`, `srai`
  - Load / Store: `lb`, `lh`, `lw`, `lbu`, `lhu`, `sb`, `sh`, `sw` (`data_mem` is byte-indexed with a `lsmem`/`lsmem_signed` control pair selecting width and sign-extension)
  - Branches: `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`
  - Jumps: `jal`, `jalr`
  - Upper immediate: `lui`, `auipc`

> Not yet implemented: `ecall`, `ebreak`, `fence`.

## Known Issues / Notes

> **Testbenches may not all run cleanly.** The `tb_phase1.sv` .. `tb_phase4.sv` testbenches were written incrementally as the design grew, one phase at a time. As later phases changed module interfaces, control signals, and internal structure (e.g. the control unit refactor and the addition of `branch_man.sv`), the earlier-phase testbenches weren't always updated to match. So some of them may fail to compile or give incorrect results against the current RTL. `tb_alu.sv`, `tb_regfile.sv`, `tb_sum.sv`, and `tb_fibonacci.sv` are the ones most likely to reflect the current design; treat the `tb_phaseN.sv` files as a historical record of development rather than a guaranteed-passing test suite.

> **`instr_mem.sv` has a hardcoded `$readmemh` filename.** It currently loads `bubble_sort.hex` unconditionally, regardless of which testbench is run. To run `sum.hex` or `fibonacci.hex` against `tb_phase4.sv` / `tb_fibonacci.sv`, swap the filename in `instr_mem.sv` (or parameterize it) before compiling — otherwise the testbench will be checking results against whatever program `bubble_sort.hex` actually contains.

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

## Sample Program: `fibonacci.s`

This program generates the first 10 Fibonacci numbers and stores each one to memory as it goes:

```asm
addi x1, zero, 0    # a = 0
addi x2, zero, 1    # b = 1
addi x3, zero, 0    # i = 0 (loop counter)
addi x4, zero, 10   # how many terms to generate
addi x5, zero, 0    # mem_addr = 0

loop:
sw   x1, 0(x5)       # store current fib number
add  x6, x1, x2      # temp = a + b
add  x1, zero, x2    # a = b
add  x2, zero, x6    # b = temp
addi x3, x3, 1        # i++
addi x5, x5, 4        # mem_addr += 4 (next word)
bne  x4, x3, loop     # repeat until i == 10

done:
jal  x0, done          # infinite loop / halt
```

Expected result: memory addresses `0x0` through `0x24` hold the first 10 Fibonacci numbers (`0, 1, 1, 2, 3, 5, 8, 13, 21, 34`), and the CPU spins in the `done:` loop afterward. The pre-assembled machine code is in `programs/fibonacci.hex`, and `tb/tb_fibonacci.sv` checks the result.

## Running the Simulation

This project was developed and tested using [Icarus Verilog](http://iverilog.icarus.com/) in the initial phases.

**Note:** the current code does not simulate cleanly on Icarus Verilog version 13.0; it throws several unexpected/incorrect errors on SystemVerilog constructs used here (e.g. the `ctrl_t`/`alu_op_t` typedefs in `cpu_defs.svh`). Because of this, simulation was moved to Vivado for later phases. The commands below are kept for reference and may still work on other iverilog versions, but if you hit strange compile errors on 13.0, try Vivado instead.

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

To run the Fibonacci program instead:

```bash
iverilog -g2012 -o Sim/fibonacci_sim rtl/*.sv tb/tb_fibonacci.sv
vvp Sim/fibonacci_sim
```

Individual module testbenches (`tb_alu.sv`, `tb_regfile.sv`, etc.) can be compiled and run the same way against their respective RTL files for isolated unit testing.

## Design Overview

The datapath follows the classic single-cycle RISC-V structure:

1. **Fetch**: `pc_reg` holds the current PC; `instr_mem` returns the instruction at that address.
2. **Decode**: `control_unit` derives control signals from the opcode/funct3/funct7 fields; `imm_gen` extracts and sign-extends the immediate; `regfile` reads `rs1`/`rs2`.
3. **Execute**: `alu` performs the operation selected by the control unit, with operand B chosen between `rs2`, the immediate, or `pc+4` (for `jal` link address).
4. **Memory**: `data_mem` is read or written depending on the instruction (`lw`/`sw`).
5. **Writeback**: the ALU result or memory read data is written back to the register file, selected by `mem_to_reg`.
6. **PC Update**: the next PC is computed as `pc+4`, or `pc+imm` if a branch is taken or the instruction is `jal`.
