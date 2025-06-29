# MIPS CPU Project

## Overview

This project involves the design, simulation, and implementation of a simple 32-bit microprocessor inspired by the MIPS architecture. Implemented in VHDL, the CPU supports a subset of the MIPS instruction set and runs test programs provided as memory initialization files.

The project showcases key computer architecture concepts including datapath design, control logic, ALU operations, memory interfacing, and input/output port management.

---

## Project Components

### CPU Architecture

- **32-bit CPU Core:** Implements a MIPS-like instruction set.
- **Datapath Components:**
  - ALU with arithmetic, logic, shift, and branch condition operations.
  - Register file with 32 registers supporting two read ports and one write port.
  - Instruction Register (IR) and Program Counter (PC).
  - Special-purpose registers: Data Memory Register (MDR), RegA, RegB, ALUout, HI, and LO.
  - Sign extension unit for immediate values.
- **Memory Module:**
  - 256-word RAM (32 bits each), initialized from a `.mif` file.
  - Memory-mapped I/O ports:
    - Two 32-bit input ports (`INPORT0` at address `0x0000FFF8`, `INPORT1` at `0x0000FFFC`)
    - One 32-bit output port (`OUTPORT` at address `0x0000FFFC`)

### Control Unit

- Generates control signals for datapath and memory operations.
- Supports instruction fetch, decode, and execute cycle.
- Controls branching, jumping, and register writes.
- Implements control signals such as `PCWrite`, `MemRead`, `MemWrite`, `ALUOp`, `RegWrite`, and others.

---

## Instruction Set

The CPU supports a subset of MIPS instructions, including but not limited to:

- Arithmetic: `addu`, `subu`, `addiu`, `subiu`, `mult`, `multu`
- Logical: `and`, `andi`, `or`, `ori`, `xor`, `xori`
- Shift operations: `sll`, `srl`, `sra`
- Set less than: `slt`, `slti`, `sltu`, `sltiu`
- Move from HI/LO: `mfhi`, `mflo`
- Load/store word: `lw`, `sw`
- Branches: `beq`, `bne`, `blez`, `bgtz`, `bltz`, `bgez`
- Jumps: `j`, `jal`, `jr`
- Halt instruction for testing

Refer to the provided instruction set tables and opcode mappings for details.

---

## Input/Output Ports

- **INPORT0 and INPORT1:** 32-bit inputs controlled via board switches; only 9 bits are switchable at a time, with an additional switch selecting the port.
- **OUTPORT:** 32-bit output connected to 7-segment displays.
- Input ports are loaded using enable signals triggered by buttons.
- CPU and memory reset controlled separately from input ports.

---

## Building and Simulation

- Use Quartus or compatible FPGA design software.
- Simulate using provided testbenches for each deliverable.
- Initialize RAM using `.mif` files containing test programs.
- Verify synthesis results and timing constraints.

---

## Additional Notes

- Memory addresses are word-aligned; lower two bits of addresses are ignored for RAM access.
- Shift amount for shift instructions is taken from bits [10:6] of the instruction.
- Control signals are designed according to the MIPS fetch-decode-execute cycle.
- Separate reset for CPU/memory and input ports to manage switch inputs effectively.

---
