# ALU 4.0 Architecture

## 1. Overview

ALU 4.0 is a parameterized Arithmetic Logic Unit designed in SystemVerilog.

The design supports configurable data widths, allowing the same RTL architecture to be used for different operand sizes. The ALU accepts two input operands, `A` and `B`, together with a 4-bit operation code (`opcode`) that selects the required operation.

The design produces the main ALU result along with status flags such as carry, borrow, zero, negative, and overflow.

The ALU was developed incrementally, with earlier versions preserved in the `history/` directory.

---

## 2. Basic Architecture

The ALU can be viewed as a collection of functional units controlled by the opcode:

```text
                    ┌─────────────────────┐
       A ──────────►│                     │
                    │  Arithmetic Unit    │
       B ──────────►│  ADD / SUB / INC    │
                    │  DEC               │
                    └──────────┬──────────┘
                               │
                               │
                    ┌──────────▼──────────┐
       A ──────────►│                     │
       B ──────────►│   Logic Unit        │
                    │ AND / OR / XOR      │
                    │ NOT / NAND / NOR    │
                    │ XNOR                │
                    └──────────┬──────────┘
                               │
                               │
                    ┌──────────▼──────────┐
       A ──────────►│                     │
       B ──────────►│   Shift Unit        │
                    │ Logical / Arithmetic│
                    │ Left / Right        │
                    └──────────┬──────────┘
                               │
                               │
                    ┌──────────▼──────────┐
                    │   Comparison /      │
                    │   Pass Operations   │
                    │       SLT / PASS_B  │
                    └──────────┬──────────┘
                               │
                         ┌─────▼─────┐
                         │   MUX /   │
                         │ Operation │
                         │ Selection │
                         └─────┬─────┘
                               │
                               ▼
                         ALU Result
```

The opcode determines which operation is selected and therefore which value is driven to the result output.

---

## 3. Parameterized Data Width

The ALU is parameterized using a `WIDTH` parameter.

Conceptually:

```systemverilog
module ALU #(
    parameter WIDTH = 64
);
```

This allows the same design to operate on different operand widths without rewriting the ALU architecture.

For example:

```text
WIDTH = 32  → 32-bit ALU
WIDTH = 64  → 64-bit ALU
```

The final physical-design implementation documented in `physical_design/ALU4.0_32_FINAL/` uses the 32-bit configuration.

---

## 4. Inputs and Outputs

### Inputs

| Signal   | Description                                      |
| -------- | ------------------------------------------------ |
| `A`      | First ALU operand                                |
| `B`      | Second ALU operand                               |
| `opcode` | 4-bit operation selector                         |
| `clk`    | Clock input for the pipelined ALU implementation |

### Outputs

| Signal     | Description                                |
| ---------- | ------------------------------------------ |
| `result`   | Result of the selected ALU operation       |
| `carry`    | Carry indication for arithmetic operations |
| `borrow`   | Borrow indication for subtraction          |
| `zero`     | Indicates that the result is zero          |
| `negative` | Indicates a negative signed result         |
| `overflow` | Indicates signed arithmetic overflow       |

---

## 5. Operation Selection

The ALU uses a 4-bit opcode, providing 16 possible opcode values.

| Opcode | Operation              | Description              |
| ------ | ---------------------- | ------------------------ |
| `0000` | ADD                    | Adds `A` and `B`         |
| `0001` | SUB                    | Subtracts `B` from `A`   |
| `0010` | AND                    | Bitwise AND              |
| `0011` | OR                     | Bitwise OR               |
| `0100` | XOR                    | Bitwise XOR              |
| `0101` | NOT_A                  | Bitwise inversion of `A` |
| `0110` | RIGHT_SHIFT            | Logical right shift      |
| `0111` | LEFT_SHIFT             | Logical left shift       |
| `1000` | ARITHMETIC_RIGHT_SHIFT | Arithmetic right shift   |
| `1001` | INC_A                  | Increment `A`            |
| `1010` | DEC_A                  | Decrement `A`            |
| `1011` | NAND                   | Bitwise NAND             |
| `1100` | NOR                    | Bitwise NOR              |
| `1101` | XNOR                   | Bitwise XNOR             |
| `1110` | SLT                    | Set Less Than            |
| `1111` | PASS_B                 | Passes `B` to the result |

---

## 6. Arithmetic Operations

### Addition

For the ADD operation:

```text
result = A + B
```

The arithmetic operation also generates a carry indication.

The addition is implemented using an extended operand so that the carry-out can be captured.

Conceptually:

```text
       A
       │
       ├──────┐
       │      │
       │    Adder ──────► Result
       │      │
       B ─────┘
              │
              └──────────► Carry
```

### Subtraction

For subtraction:

```text
result = A - B
```

The ALU also generates a borrow indication.

### Increment

```text
result = A + 1
```

### Decrement

```text
result = A - 1
```

---

## 7. Logical Operations

The ALU provides several bitwise logical operations.

### AND

Each corresponding pair of bits is ANDed:

```text
A = 1010
B = 1100

A AND B = 1000
```

### OR

```text
A OR B
```

### XOR

```text
A XOR B
```

### NOT

The `NOT_A` operation inverts every bit of `A`.

### NAND

NAND is the inverse of AND:

```text
NAND(A,B) = ~(A & B)
```

### NOR

NOR is the inverse of OR:

```text
NOR(A,B) = ~(A | B)
```

### XNOR

XNOR is the inverse of XOR:

```text
XNOR(A,B) = ~(A ^ B)
```

---

## 8. Shift Operations

The ALU supports three shift operations.

### Logical Right Shift

Bits are shifted toward the least-significant-bit side and zeros are introduced from the left.

```text
A >> B
```

### Logical Left Shift

Bits are shifted toward the most-significant-bit side and zeros are introduced from the right.

```text
A << B
```

### Arithmetic Right Shift

Arithmetic right shift preserves the sign of a signed value by replicating the most-significant bit.

```text
A >>> B
```

This is particularly important when the operand is interpreted as a signed two's-complement number.

---

## 9. Comparison Operation

### Set Less Than — SLT

The `SLT` operation compares the operands.

Conceptually:

```text
if A < B
    result = 1
else
    result = 0
```

The comparison is performed using the signed interpretation required by the implementation.

---

## 10. PASS_B Operation

The `PASS_B` operation directly transfers operand `B` to the ALU result.

```text
result = B
```

This operation is useful when the ALU needs to forward an operand without performing an arithmetic or logical transformation.

---

## 11. Status Flags

In addition to the main result, the ALU generates several status flags.

### Zero Flag

The zero flag indicates that the result contains all zeros.

```text
result = 0 → zero = 1
result ≠ 0 → zero = 0
```

### Negative Flag

The negative flag is derived from the most-significant bit of the result.

For a two's-complement signed representation:

```text
MSB = 1 → negative
MSB = 0 → non-negative
```

### Carry Flag

The carry flag indicates a carry-out from unsigned addition.

### Borrow Flag

The borrow flag indicates that subtraction requires a borrow.

### Overflow Flag

The overflow flag indicates signed arithmetic overflow.

Overflow is different from carry.

For example, in two's-complement arithmetic, adding two positive numbers can produce a negative result when the representable signed range is exceeded. This is a signed overflow condition.

---

## 12. Pipelined Architecture

ALU 4.0 is implemented as a pipelined design to support the larger and more complex ALU functionality.

The processing can be conceptually divided into multiple stages:

```text
Inputs
  │
  ▼
Input / Control
  │
  ▼
Operation Processing
  │
  ▼
Arithmetic / Logic / Shift
  │
  ▼
Result Selection
  │
  ▼
Flag Generation
  │
  ▼
Output
```

The pipeline allows the datapath to be divided into smaller timing sections rather than requiring the complete operation to propagate through a single long combinational path.

---

## 13. RTL-to-ASIC Flow

The ALU4.0 RTL was taken through a digital ASIC implementation flow.

```text
SystemVerilog RTL
       │
       ▼
Functional Verification
       │
       ▼
Logic Synthesis
       │
       ▼
Technology Mapping
       │
       ▼
Floorplanning
       │
       ▼
Placement
       │
       ▼
Clock Tree Synthesis
       │
       ▼
Routing
       │
       ▼
Physical Verification
       │
       ├── DRC
       ├── LVS
       └── Antenna
       │
       ▼
GDSII Generation
```

The final 32-bit implementation uses the **SKY130A** PDK and `sky130_fd_sc_hd` standard-cell library.

Detailed physical-design results are documented under:

```text
physical_design/ALU4.0_32_FINAL/
```

---

## 14. Project Versions

Earlier ALU versions are preserved in the `history/` directory.

```text
history/
├── ALU1.0/
├── ALU2.0/
├── ALU3.0/
└── ALU3.0_32/
```

This allows the development of the ALU architecture to be tracked from earlier versions through ALU4.0.

---

## 15. Repository Organization

The project is organized into separate sections:

```text
ALU/
├── architecture/       # Architecture documentation
├── docs/               # Project and ASIC-flow documentation
├── history/            # Earlier ALU versions
├── images/             # Architecture and implementation images
├── physical_design/    # ASIC physical-design artifacts
├── rtl/                # Current ALU4.0 RTL
├── synthesis/          # Synthesis scripts and results
└── verification/       # Verification results
```

The separation keeps the RTL, verification, synthesis, physical-design results, and historical versions independently accessible.

---

## 16. Summary

ALU 4.0 is a parameterized SystemVerilog ALU supporting arithmetic, logical, shift, comparison, and operand-pass operations.

The architecture is designed to support multiple data widths while maintaining a common RTL structure. The project also demonstrates the progression from RTL design and verification through synthesis and physical ASIC implementation.

The final 32-bit physical implementation uses SKY130A and includes successful DRC, LVS, antenna checks, and GDSII generation.
