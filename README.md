# RV32I Single-Cycle Processor

A single-cycle RISC-V CPU implementing the RV32I base integer instruction set plus machine-mode traps and CSRs, written in SystemVerilog. It can now run a bare-metal "Hello World" over a simulated UART.

This project is a hands-on exercise in computer architecture: from individual datapath blocks (ALU, register file, immediate generator) up to a CPU with a trap mechanism and memory-mapped I/O.

## What's New

- **CSR unit** with `mtvec`, `mepc`, `mcause`, `mtval`, `mscratch` and `mstatus`
- **Zicsr instructions:** `csrrw`, `csrrs`, `csrrc`
- **Traps:** `ecall` and `ebreak` save the PC and cause, then jump to the handler at `mtvec`. `mret` restores the PC from `mepc`
- **Address decoder** in front of memory. Stores to `0x10000000` go to a simulated UART instead of RAM, and the UART prints each byte to the simulator console
- **Hello World demo:** a test program sets `mtvec`, then does `li a0, <char>` + `ecall` for each letter. The trap handler writes `a0` to the UART, advances `mepc` by 4, and executes `mret`. Twelve ecalls later, `Hello World` appears in the XSim console

## Features

- 32-bit single-cycle datapath (fetch, decode, execute, memory, writeback in one clock)
- 32 x 32-bit register file with `x0` hardwired to zero
- Instruction memory loaded from a `.hex` file at simulation start
- Byte-indexed data memory with `lb/lh/lw/lbu/lhu/sb/sh/sw`
- Immediate generator for I, S, B, U and J encodings
- Branch and jump (`jal`, `jalr`) support with PC redirection
- Machine-mode CSRs and trap entry/return
- Memory-mapped UART (simulation only)

### Supported instructions

| Group | Instructions |
|---|---|
| R-type | `add` `sub` `sll` `slt` `sltu` `xor` `srl` `sra` `or` `and` |
| I-type ALU | `addi` `slti` `sltiu` `xori` `ori` `andi` `slli` `srli` `srai` |
| Load / Store | `lb` `lh` `lw` `lbu` `lhu` `sb` `sh` `sw` |
| Branches | `beq` `bne` `blt` `bge` `bltu` `bgeu` |
| Jumps | `jal` `jalr` |
| Upper immediate | `lui` `auipc` |
| System | `ecall` `ebreak` `mret` |
| Zicsr | `csrrw` `csrrs` `csrrc` |
| Misc | `fence` (decoded as a NOP, which is fine on a single core) |

## Current Status (Honest Version)

**Works**
- `ecall` / `ebreak` trap entry and `mret` return
- CSR read/write/set/clear
- UART output through the address decoder (Hello World demo)

**Not done yet**
- `fence` is not decoded explicitly; it behaves as a NOP
- No illegal-instruction trap
- No misaligned load/store/fetch traps
- Official [`riscv-tests`](https://github.com/riscv-software-src/riscv-tests) have **not** been run yet, so this core is not yet verified as fully compliant
- The UART exists only in simulation, so there is no FPGA build yet

## Memory Map

| Address | Device |
|---|---|
| `0x00000000` and up | Instruction / data RAM |
| `0x10000000` | Simulated UART TX (byte store prints to console) |

## Repository Structure

```
.
├── rtl/                  # Core design
│   ├── top.sv             # Top-level datapath
│   ├── alu.sv
│   ├── control_unit.sv    # Decode / control signals
│   ├── regfile.sv
│   ├── imm_gen.sv
│   ├── instr_mem.sv
│   ├── data_mem.sv
│   ├── pc_reg.sv
│   ├── branch_man.sv      # Branch handling
│   ├── csr_unit.sv        # CSRs + trap logic
│   ├── addr_decoder.sv    # RAM vs UART select
│   ├── uart_sim.sv        # Simulated UART (prints to console)
│   └── cpu_defs.svh       # Shared types (ctrl_t, alu_op_t)
├── tb/                   # Testbenches
├── programs/             # Assembly sources and .hex files
├── Sim/                  # Compiled simulation output
└── Waveform/             # VCD dumps and screenshots
```

> Adjust file names above to match the actual files in `rtl/`.

## Trap Flow

1. `ecall` / `ebreak` is decoded; the control unit raises a trap
2. CSR unit writes `mepc <- PC`, `mcause <- cause` (11 for ecall from M-mode, 3 for ebreak), updates `mstatus`
3. PC jumps to `mtvec`
4. Handler runs (in the demo: write `a0` to UART, `mepc += 4`)
5. `mret` sets `PC <- mepc`

## Demo: Hello World over UART

```asm
    la   t0, handler
    csrw mtvec, t0

    li   a0, 'H'
    ecall
    li   a0, 'e'
    ecall
    # ... one li + ecall per character ...

handler:
    li   t1, 0x10000000
    sb   a0, 0(t1)        # byte goes to the UART, not RAM
    csrr t2, mepc
    addi t2, t2, 4        # skip past the ecall
    csrw mepc, t2
    mret
```

Running it prints `Hello World` in the simulator console.

## Running the Simulation

Developed with Vivado XSim. Icarus Verilog 13.0 chokes on some of the SystemVerilog constructs used here (e.g. the `ctrl_t` / `alu_op_t` typedefs in `cpu_defs.svh`), so use Vivado for the full CPU.

For older iverilog versions, the original flow may still work:

```
iverilog -g2012 -o Sim/phase4_sim rtl/*.sv tb/tb_phase4.sv
vvp Sim/phase4_sim
gtkwave Waveform/phase4_tb.vcd
```

## Known Issues

- **Older testbenches may not compile.** `tb_phase1.sv` through `tb_phase4.sv` were written incrementally and not all were updated as interfaces changed. `tb_alu.sv`, `tb_regfile.sv`, `tb_sum.sv` and `tb_fibonacci.sv` are the most likely to match the current RTL.
- **`instr_mem.sv` hardcodes its `$readmemh` filename.** Swap the filename (or parameterize it) to run a different program.

## Roadmap

1. 5-stage pipeline (hazard detection, forwarding, load-use stalls, flush on taken branches/jumps, and making traps/CSRs behave correctly with instructions in flight)
2. Illegal-instruction and misaligned-access traps
3. Run the official `riscv-tests` suite
4. Real UART and an FPGA build

## Design Overview

1. **Fetch:** `pc_reg` holds the PC; `instr_mem` returns the instruction
2. **Decode:** `control_unit` generates control signals; `imm_gen` builds the immediate; `regfile` reads `rs1`/`rs2`
3. **Execute:** `alu` computes the result; branch logic decides the next PC
4. **Memory:** the address decoder routes the access to `data_mem` or the UART
5. **Writeback:** ALU result, load data, PC+4 or CSR read data is written back
6. **PC update:** `pc+4`, branch/jump target, `mtvec` on a trap, or `mepc` on `mret`
