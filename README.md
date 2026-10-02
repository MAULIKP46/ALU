# Parameterized ASIC ALU — From RTL to GDSII

A multi-generation ASIC design project exploring the complete journey of an **Arithmetic Logic Unit (ALU)** from RTL development and simulation to synthesis, physical implementation, signoff, and GDSII generation.

The project evolved through several generations. Each version was developed to address limitations observed in the previous one — including arithmetic architecture, synthesized hardware complexity, timing, physical implementation, and scalability.

The **final successful ASIC implementation is ALU 4.0 at 32-bit**, which was taken through the complete physical-design flow and successfully generated as a **SKY130 GDSII**.

After completing the 32-bit implementation, the same architecture was scaled to 64 bits as a further experiment. The 64-bit version successfully passed RTL verification and synthesis/technology mapping, while the physical-design attempt exposed significantly greater timing and routing complexity.

---

# Project at a Glance

| Item                            | Details                   |
| ------------------------------- | ------------------------- |
| Project                         | Parameterized ASIC ALU    |
| Final successful implementation | **ALU 4.0 — 32-bit**      |
| Scaling experiment              | ALU 4.0 — 64-bit          |
| Operations                      | 18                        |
| Pipeline                        | 8-stage                   |
| Multiplier                      | Custom radix-16 shift/add |
| Divider                         | Custom radix-16 restoring |
| RTL                             | SystemVerilog             |
| RTL simulation                  | Icarus Verilog            |
| Waveform analysis               | GTKWave                   |
| Early experimentation           | EDA Playground            |
| Development environment         | Windows + WSL             |
| Linux environment               | Ubuntu                    |
| Containerization                | Docker                    |
| Synthesis                       | Yosys                     |
| Technology mapping              | ABC                       |
| ASIC flow                       | LibreLane                 |
| Physical design                 | OpenROAD                  |
| PDK                             | SKY130                    |
| Standard-cell library           | sky130_fd_sc_hd           |
| Final physical output           | GDSII                     |

---

# 1. Project Objective

The initial objective was to design a parameterized ALU and understand how an RTL design behaves throughout an ASIC flow.

The project then evolved into a broader investigation:

> **How can an ALU architecture be progressively improved so that it is not only functionally correct, but also suitable for synthesis and physical implementation?**

Instead of stopping at simulation, the project was taken through multiple stages:

```text
RTL Design
    ↓
Simulation
    ↓
Synthesis
    ↓
Technology Mapping
    ↓
Floorplanning
    ↓
Placement
    ↓
Clock Tree Synthesis
    ↓
Routing
    ↓
Timing Analysis
    ↓
Antenna
    ↓
DRC
    ↓
LVS
    ↓
GDSII
```

The different ALU generations were used to understand what happens at each stage.

---

# 2. Development Journey

The project was not developed as one final design.

It went through several iterations:

```text
ALU 1.0
   ↓
Initial ASIC implementation
   ↓
ALU 2.0
   ↓
Synthesis / architecture exploration
   ↓
ALU 3.0
   ↓
Custom arithmetic architectures
   ↓
ALU 3.0 — 32-bit
   ↓
Physical-design experimentation
   ↓
ALU 4.0
   ↓
8-stage pipeline
+ custom radix-16 multiplier
+ custom radix-16 divider
   ↓
ALU 4.0 — 32-bit
   ↓
FINAL SUCCESSFUL ASIC IMPLEMENTATION
   ↓
GDSII
   ↓
ALU 4.0 — 64-bit
   ↓
Scaling experiment
```

Each generation was important because it exposed a different aspect of ASIC design.

---

# 3. ALU 1.0 — Establishing the Baseline

ALU 1.0 was the first major implementation and was primarily intended to establish a working ALU and understand the RTL-to-ASIC process.

The design included arithmetic and logical operations and was taken beyond simulation into synthesis and physical implementation.

However, the first implementation exposed an important problem:

> A functionally correct ALU can still be extremely difficult to implement physically.

The design produced very large hardware and extremely poor timing characteristics.

The historical implementation reached approximately:

```text
WNS ≈ -192.54 ns
~159K instances
```

This became the first major baseline for improvement.

### What ALU 1.0 taught us

* RTL correctness does not guarantee good synthesis results.
* Large combinational datapaths can become extremely difficult to time.
* Physical implementation must be considered during architecture development.
* The ASIC flow needs to be treated as a complete chain rather than isolated stages.

---

# 4. ALU 2.0 — Exploring Simpler RTL

The next version explored a much simpler RTL description using built-in arithmetic operators.

Operations such as multiplication and division could be described directly using operators such as:

```verilog
A * B
A / B
A % B
```

This produced a much smaller generic representation during synthesis.

However, the physical implementation produced an important lesson:

> **A smaller RTL or generic netlist does not automatically result in a better ASIC.**

Despite the simplified RTL representation, the physical implementation still suffered from very poor timing and signoff problems.

The historical timing result was approximately:

```text
WNS ≈ -367.79 ns
```

The implementation also encountered antenna-related issues.

### What improved

The RTL became much simpler.

### What did not improve

Physical timing and implementation quality did not improve accordingly.

### Main lesson

Cell count and RTL simplicity cannot be considered in isolation.

The actual hardware architecture matters.

---

# 5. ALU 3.0 — Moving Toward Custom Hardware

ALU 3.0 changed the direction of the project.

Instead of relying completely on generic arithmetic operators, the arithmetic datapaths were designed more explicitly.

The major focus became:

* Custom multiplication
* Custom division
* Greater control over the generated hardware
* Better understanding of synthesis
* Better awareness of physical implementation

The question changed from:

> "Can the ALU calculate the result?"

to:

> "What hardware is actually being created to calculate the result?"

This was an important step toward designing an ASIC rather than simply writing functional RTL.

---

# 6. ALU 3.0 — 32-bit Physical Implementation

A 32-bit implementation of ALU 3.0 was then taken through the physical-design flow.

This provided valuable experience with:

* Floorplanning
* Placement
* Clock Tree Synthesis
* Global routing
* Detailed routing
* Antenna analysis
* DRC
* LVS
* GDSII generation

The flow successfully reached the physical implementation stage.

This became an important milestone because it demonstrated that the architecture could move from RTL into a real standard-cell-based physical design.

---

# 7. ALU 4.0 — Major Architectural Improvement

ALU 4.0 was a significant architectural upgrade.

The design introduced three major changes:

### 1. 8-stage internal pipeline

Instead of treating the datapath as one large combinational block, the architecture was divided into multiple sequential stages.

This allowed the datapath to be structured around pipeline boundaries.

### 2. Custom radix-16 multiplier

The multiplier processes:

```text
4 multiplier bits per stage
```

Instead of relying on:

```verilog
A * B
```

the multiplication is implemented using explicit shift/add hardware.

For the 64-bit version:

```text
64 bits / 4 bits per stage = 16 multiplier stages
```

The internal product is:

```text
128 bits
```

### 3. Custom radix-16 restoring divider

The divider processes:

```text
4 dividend bits per stage
```

instead of using:

```verilog
A / B
A % B
```

The divider generates:

* Quotient
* Remainder
* Divide-by-zero indication

This gave much greater visibility and control over the arithmetic hardware.

---

# 8. ALU 4.0 — Supported Operations

The ALU supports 18 operations.

|  Opcode | Operation              |
| ------: | ---------------------- |
| `00000` | ADD                    |
| `00001` | SUB                    |
| `00010` | AND                    |
| `00011` | OR                     |
| `00100` | XOR                    |
| `00101` | NOT A                  |
| `00110` | RIGHT SHIFT            |
| `00111` | LEFT SHIFT             |
| `01000` | ARITHMETIC RIGHT SHIFT |
| `01001` | INC A                  |
| `01010` | DEC A                  |
| `01011` | NAND                   |
| `01100` | NOR                    |
| `01101` | XNOR                   |
| `01110` | SIGNED LESS-THAN       |
| `01111` | PASS B                 |
| `10000` | MUL                    |
| `10001` | DIV                    |

The ALU also generates:

* Carry
* Borrow
* Zero
* Negative
* Overflow
* Divide-by-zero
* Valid

---

# 9. RTL Verification

Before proceeding with physical implementation, the ALU 4.0 architecture was verified using directed and randomized tests.

The final 64-bit RTL verification produced:

```text
SELF TESTS   : TOTAL=28 PASSED=28 FAILED=0
RANDOM TESTS : TOTAL=300 PASSED=300 FAILED=0

TOTAL:
  328 tests passed
  0 tests failed

Result:
  ALL TESTS PASSED
```

### Verification result

**328 / 328 tests passed**

This was an important checkpoint before moving toward synthesis and physical implementation.

---

# 10. ALU 4.0 — Synthesis

The 64-bit ALU 4.0 RTL was synthesized using Yosys.

### RTL synthesis

| Metric    |  Count |
| --------- | -----: |
| Wires     |  1,143 |
| Wire bits | 57,773 |
| RTL cells |    644 |
| `$add`    |    145 |
| `$sub`    |     10 |
| `$mux`    |    207 |
| `$adff`   |    111 |
| `$mul`    |      0 |
| `$div`    |      0 |
| `$mod`    |      0 |

One particularly important result was:

```text
$mul = 0
$div = 0
$mod = 0
```

This confirmed that the custom multiplier and divider were not represented as inferred generic multiplication/division/modulo cells in the synthesized RTL.

---

# 11. Technology Mapping

After synthesis, the design was technology-mapped using ABC.

The 64-bit design was processed into a large gate-level representation.

### ABC input

```text
118,131 gates
116,844 internal signals
2,189 inputs
1,289 outputs
```

### Final mapped netlist

```text
89,775 cells
```

Important mapped components included:

| Cell   |  Count |
| ------ | -----: |
| DFF    |  2,621 |
| MUX    |  3,079 |
| AND    | 22,312 |
| ANDNOT |  2,319 |
| NAND   | 28,139 |
| NOR    |  1,958 |
| OR     |  8,438 |
| ORNOT  |  7,661 |
| XOR    |  4,895 |
| XNOR   |  7,615 |
| NOT    |    738 |

The synthesis and technology-mapping stages therefore completed successfully for the 64-bit architecture.

---

# 12. ALU 4.0 — 32-bit Final ASIC Implementation

After developing and verifying ALU 4.0, the architecture was implemented at **32-bit** for the final physical-design target.

This is the **final successful ASIC implementation of the project**.

The 32-bit version successfully completed:

```text
RTL
 ↓
Synthesis
 ↓
Technology Mapping
 ↓
Floorplanning
 ↓
Placement
 ↓
CTS
 ↓
Global Routing
 ↓
Detailed Routing
 ↓
Antenna
 ↓
DRC
 ↓
LVS
 ↓
GDSII
```

---

# 13. Final 32-bit Signoff Results

The final ALU 4.0 32-bit implementation successfully produced the physical design artifacts.

### Physical implementation

* Placement completed
* CTS completed
* Global routing completed
* Detailed routing completed
* Antenna check passed
* DRC passed
* LVS passed
* GDSII generated

### DRC

```text
DRC violations = 0
```

### LVS

```text
Circuits match uniquely
```

### Timing

Using the final max timing report:

```text
Clock period : 30 ns
Data arrival : 18.854288 ns
Required     : 23.750002 ns
Setup slack  : +4.895714 ns
```

Therefore the final 32-bit implementation achieved approximately:

**+4.90 ns setup slack at a 30 ns clock period.**

The implementation also had some nominal electrical warnings related to slew/fanout. These did not prevent the project from completing the physical implementation and generating the final GDSII, but they are retained in the detailed reports for transparency.

---

# 14. Final Physical Output

The final successful 32-bit implementation contains:

```text
ALU.gds
ALU.lef
ALU.sdc
```

The most important artifact is:

```text
ALU.gds
```

which represents the final physical layout generated by the ASIC flow.

This is the point at which the project reached its final successful physical-design output.

---

# 15. Scaling ALU 4.0 to 64-bit

After successfully completing the 32-bit physical implementation, the architecture was scaled to 64 bits.

The objective was to investigate how a physically successful architecture behaves when its datapath width is doubled.

The 64-bit version successfully completed:

* RTL implementation
* Functional verification
* 328/328 simulation tests
* Yosys synthesis
* ABC technology mapping

However, the physical-design stage revealed a substantially more difficult problem.

---

# 16. 64-bit Physical-Design Experiment

The 64-bit design was submitted to the same ASIC physical-design flow.

The larger design introduced significantly greater:

* Routing demand
* Clock-tree load
* Fanout
* Capacitance
* Timing complexity
* Multi-corner analysis complexity
* Physical-design resource requirements

During post-route timing/signoff, several corners encountered violations including:

* Setup timing violations
* Slew violations
* Fanout violations
* Capacitance violations

The final multi-corner post-PnR STA process did not complete successfully.

Therefore, the 64-bit version is **not presented as a successful GDSII implementation**.

Instead, it is documented as a scaling experiment.

---

# 17. Why the 64-bit Experiment Matters

The 64-bit experiment provided one of the most important lessons of the project:

> **Scaling RTL width is not simply a matter of doubling the number of bits.**

At RTL, going from 32-bit to 64-bit may look straightforward.

At physical level, however, the consequences propagate through the entire design:

```text
Width increases
      ↓
More logic
      ↓
More registers
      ↓
More routing
      ↓
Higher fanout
      ↓
Higher capacitance
      ↓
More clock-tree load
      ↓
Greater congestion
      ↓
Harder timing closure
      ↓
More complex signoff
```

This is why the 32-bit implementation remains the final successful ASIC output, while the 64-bit implementation is retained as a valuable engineering experiment.

---

# 18. What Improved Across the Generations?

The project can be summarized as a sequence of engineering improvements.

| Version              | Focus                                   | Result / Lesson                                                        |
| -------------------- | --------------------------------------- | ---------------------------------------------------------------------- |
| **ALU 1.0**          | Initial architecture                    | Established baseline; very poor physical timing                        |
| **ALU 2.0**          | Simplified RTL / generic arithmetic     | Smaller RTL did not automatically improve physical results             |
| **ALU 3.0**          | Custom arithmetic                       | Greater control over synthesized hardware                              |
| **ALU 3.0 — 32-bit** | Physical implementation                 | Established successful physical-design experience                      |
| **ALU 4.0**          | Pipelining + custom radix-16 arithmetic | More structured and controllable architecture                          |
| **ALU 4.0 — 32-bit** | Final ASIC implementation               | Successful physical implementation and GDSII                           |
| **ALU 4.0 — 64-bit** | Architecture scaling                    | RTL/synthesis successful; physical closure became significantly harder |

The project therefore was not about finding one perfect architecture immediately.

It was about **iterating, measuring, identifying limitations, and improving the design**.

---

# 19. Development Environment

The project was developed using a combination of Windows-based development and Linux-based open-source ASIC infrastructure.

## Windows

The main development machine used Windows, with Linux-based ASIC tools accessed through WSL.

---

## WSL — Windows Subsystem for Linux

**WSL** provided the Linux environment required for the ASIC toolchain.

This allowed the project to use Linux-based EDA tools while working from a Windows host.

---

## Ubuntu

The ASIC development environment was built inside **Ubuntu running through WSL**.

Ubuntu was used for:

* RTL simulation
* Yosys synthesis
* ABC mapping
* LibreLane execution
* OpenROAD physical design
* File and report management
* Shell scripting and automation

---

## Docker

**Docker** was used as part of the LibreLane-based ASIC environment.

It provided a controlled and reproducible environment for running the physical-design tools and associated dependencies.

---

## EDA Playground

**EDA Playground** was used during the earlier stages of RTL development and learning.

It was particularly useful for:

* Testing small RTL modules
* Experimenting with Verilog/SystemVerilog constructs
* Debugging logic
* Quickly testing ideas before integrating them into the larger ALU project

The workflow therefore evolved from rapid RTL experimentation to a complete local ASIC environment.

---

# 20. Complete Development Stack

```text
                     WINDOWS
                        │
                        ▼
              WSL / UBUNTU
                        │
          ┌─────────────┴─────────────┐
          │                           │
          ▼                           ▼
   EDA PLAYGROUND              LOCAL RTL FLOW
   Early experiments                 │
                                     ▼
                             Icarus Verilog
                                     │
                                     ▼
                                  GTKWave
                                     │
                                     ▼
                                   Yosys
                                     │
                                     ▼
                                    ABC
                                     │
                                     ▼
                                  Docker
                                     │
                                     ▼
                                 LibreLane
                                     │
                                     ▼
                                 OpenROAD
                                     │
                                     ▼
                                  SKY130
                                     │
                                     ▼
                                  GDSII
```

---

# 21. ASIC Toolchain

### RTL Design

* SystemVerilog
* EDA Playground

### Simulation

* Icarus Verilog
* GTKWave

### Linux Environment

* WSL
* Ubuntu
* Bash

### Containerization

* Docker

### Synthesis

* Yosys

### Technology Mapping

* ABC

### Physical Design

* LibreLane
* OpenROAD

### Process Design Kit

* SKY130

### Standard Cell Library

* `sky130_fd_sc_hd`

### Final Output

* GDSII

---

# 22. Repository Structure

```text
ALU/
│
├── ALU1.0/
│   └── ...
│
├── ALU2.0/
│   └── ...
│
├── ALU3.0/
│   └── ...
│
├── ALU4.0/
│   │
│   ├── rtl/
│   │   └── ALU.s
│   │
│   ├── verification/
│   │   └── verification_results.txt
│   │
│   ├── synthesis/
│   │   └── synthesis_results.txt
│   │
│   ├── configs/
│   │   └── config_64bit_sky130.json
│   │
│   ├── physical_design_32bit/
│   │   ├── final/
│   │   │   ├── ALU.gds
│   │   │   ├── ALU.lef
│   │   │   └── ALU.sdc
│   │   │
│   │   └── reports/
│   │       ├── DRC.rpt
│   │       ├── LVS.rpt
│   │       └── ANTENNA.rpt
│   │
│   ├── physical_design_64bit/
│   │   └── README.md
│   │
│   └── docs/
│       └── ARCHITECTURE.md
│
└── README.md
```

---

# 23. Key Results

## Final Successful ASIC

**ALU 4.0 — 32-bit**

* 18 operations
* 8-stage pipeline
* Custom arithmetic architectures
* SKY130
* LibreLane/OpenROAD
* Placement completed
* CTS completed
* Routing completed
* Antenna PASS
* DRC: 0 violations
* LVS: PASS
* GDSII generated
* Setup slack: **+4.895714 ns @ 30 ns**

---

## 64-bit Scaling Experiment

**ALU 4.0 — 64-bit**

* 18 operations
* 8-stage pipeline
* Custom radix-16 multiplier
* Custom radix-16 divider
* 328/328 RTL tests passed
* Yosys synthesis completed
* ABC technology mapping completed
* `$mul = 0`
* `$div = 0`
* `$mod = 0`
* Physical implementation attempted
* Post-PnR multi-corner STA did not complete successfully

---

# 24. Engineering Takeaways

This project reinforced several important ASIC-design principles.

### Functional correctness comes first

Simulation establishes whether the architecture behaves correctly.

### Synthesis reveals the real hardware

RTL that looks simple can produce very different hardware after synthesis.

### Architecture matters more than syntax

Using a different RTL expression can dramatically change the resulting implementation.

### Pipelining is an architectural decision

Pipeline stages affect timing, area, clocking and physical implementation.

### Custom arithmetic gives hardware control

Explicit multiplier/divider architectures make the generated hardware more predictable and avoid relying on generic arithmetic inference.

### Physical implementation is a different challenge

A design can pass RTL simulation and synthesis but still fail to achieve physical timing closure.

### Scaling exposes hidden constraints

The 64-bit experiment demonstrated how routing, clocking, fanout, capacitance and timing become increasingly important as the design grows.

---

# 25. Final Project Outcome

The project ultimately produced two important results.

### Final successful ASIC output

**ALU 4.0 — 32-bit**

A complete physical implementation was achieved, including:

```text
RTL
→ Synthesis
→ Placement
→ CTS
→ Routing
→ Antenna
→ DRC
→ LVS
→ GDSII
```

### Further scaling experiment

**ALU 4.0 — 64-bit**

The architecture was successfully verified and synthesized, but its physical implementation demonstrated the additional challenges involved in scaling the design.

The project therefore ends with a successful **32-bit GDSII implementation**, while the 64-bit version serves as a documented exploration of physical-design scalability.

---

# Final Takeaway

What started as an ALU design exercise evolved into a study of the complete ASIC development process.

The project progressed from:

**functional RTL**

to:

**better architecture**

to:

**custom arithmetic hardware**

to:

**pipelined design**

to:

**synthesis and technology mapping**

to:

**physical implementation**

and finally to:

**a successful 32-bit GDSII.**

The subsequent 64-bit experiment showed that ASIC design does not scale linearly with RTL width. Functional correctness is only one part of the problem; timing, routing, clocking, capacitance and signoff ultimately determine whether a design can become a physically realizable chip.

---
