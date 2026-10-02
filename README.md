# Parameterized ASIC ALU — From RTL to GDSII

A multi-generation ASIC design project exploring the complete journey of a **parameterized Arithmetic Logic Unit (ALU)** from RTL development and functional verification to synthesis, technology mapping, physical implementation, signoff, and GDSII generation.

The project evolved through multiple ALU generations. Each version was developed to investigate limitations observed in the previous implementation, including synthesized hardware complexity, arithmetic architecture, timing, physical implementation, and scalability.

The **final successful ASIC implementation is ALU 4.0 at 32-bit**, which was taken through the complete RTL-to-GDSII physical-design flow using the **SKY130A** technology and successfully generated a GDSII layout.

After completing the 32-bit implementation, the same ALU 4.0 architecture was scaled to 64 bits as a further experiment. The 64-bit version successfully passed RTL verification and synthesis/technology mapping, while the physical-design experiment demonstrated the substantially greater timing and routing challenges associated with scaling the design.

---

## Project at a Glance

| Item                            | Details                   |
| ------------------------------- | ------------------------- |
| Project                         | Parameterized ASIC ALU    |
| Final successful implementation | **ALU 4.0 — 32-bit**      |
| Scaling experiment              | ALU 4.0 — 64-bit          |
| Operations                      | 18                        |
| Pipeline                        | 8-stage                   |
| Multiplier                      | Custom radix-16 shift/add |
| Divider                         | Custom radix-16 restoring |
| HDL                             | SystemVerilog             |
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
| PDK                             | SKY130A                   |
| Standard-cell library           | `sky130_fd_sc_hd`         |
| Final physical output           | GDSII                     |

---

# 1. Project Objective

The original objective was to design a parameterized ALU and understand how an RTL design behaves throughout a complete ASIC development flow.

The project gradually evolved into a broader engineering investigation:

> **How can an ALU architecture be progressively improved so that it is not only functionally correct, but also suitable for synthesis and physical implementation?**

Instead of stopping at simulation, the design was taken through multiple stages:

```text
RTL Design
    ↓
Functional Verification
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
Antenna Analysis
    ↓
DRC
    ↓
LVS
    ↓
GDSII
```

The different ALU generations provided an opportunity to study how architectural decisions affect every stage of the ASIC flow.

---

# 2. Development Journey

The project developed through several generations rather than being designed as one final implementation.

```text
ALU 1.0
   ↓
Initial architecture
   ↓
ALU 2.0
   ↓
Simplified RTL / synthesis exploration
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

Each generation exposed different aspects of digital and ASIC design.

---

# 3. ALU 1.0 — Establishing the Baseline

ALU 1.0 was the initial major implementation used to establish a working ALU and gain experience with the RTL-to-ASIC flow.

The design included arithmetic and logical operations and was taken beyond RTL simulation into synthesis and physical implementation.

The first implementation demonstrated an important ASIC-design principle:

> **A functionally correct RTL design can still be extremely difficult to implement physically.**

The historical implementation produced very large hardware and poor timing characteristics, establishing a baseline for subsequent architectural improvements.

### Lessons from ALU 1.0

* RTL correctness does not guarantee good synthesis results.
* Large combinational datapaths can become difficult to time.
* Physical implementation constraints should influence architecture decisions.
* ASIC design must be treated as a complete flow rather than a collection of independent stages.

---

# 4. ALU 2.0 — Exploring Simpler RTL

ALU 2.0 explored a simpler RTL description using built-in arithmetic operators.

Examples included operations represented directly using constructs such as:

```text
A * B
A / B
A % B
```

This produced a simpler generic RTL representation during synthesis.

However, the physical-design results demonstrated another important lesson:

> **Simpler RTL does not automatically mean better physical implementation.**

The experiment showed that generic arithmetic operators can hide significant hardware complexity and that the physical implementation depends heavily on the underlying architecture.

### Main lesson

RTL simplicity, cell count, timing, routing, and physical feasibility must be considered together.

---

# 5. ALU 3.0 — Moving Toward Custom Hardware

ALU 3.0 changed the direction of the project.

Instead of relying entirely on generic arithmetic operators, the arithmetic datapaths were designed more explicitly.

The main focus became:

* Custom multiplication
* Custom division
* Greater control over synthesized hardware
* Understanding the actual hardware produced by synthesis
* Improving awareness of physical-design constraints

The question changed from:

> "Can the ALU calculate the result?"

to:

> "What hardware is actually being created to calculate the result?"

This was an important transition from writing purely functional RTL toward thinking about hardware architecture.

---

# 6. ALU 3.0 — 32-bit Physical Implementation

A 32-bit implementation of ALU 3.0 was taken through the physical-design flow.

This provided practical experience with:

* Floorplanning
* Placement
* Clock Tree Synthesis
* Global routing
* Detailed routing
* Antenna analysis
* Design Rule Checking
* Layout Versus Schematic
* GDSII generation

This became an important milestone because it demonstrated the transition from RTL and synthesized logic into a standard-cell-based physical implementation.

---

# 7. ALU 4.0 — Major Architectural Improvement

ALU 4.0 introduced a significantly more structured architecture.

Three major changes were introduced.

## 7.1 8-stage Pipeline

The datapath was divided into multiple sequential stages instead of treating the entire operation as one large combinational path.

This provided explicit pipeline boundaries and made timing a central architectural consideration.

---

## 7.2 Custom Radix-16 Multiplier

The multiplier processes:

```text
4 multiplier bits per stage
```

Rather than relying on a generic:

```text
A * B
```

operation, multiplication is implemented using explicit shift/add hardware.

For the 64-bit implementation:

```text
64 bits / 4 bits per stage = 16 multiplier stages
```

The internal product width is:

```text
128 bits
```

This approach provides greater visibility and control over the generated arithmetic hardware.

---

## 7.3 Custom Radix-16 Restoring Divider

The divider processes:

```text
4 dividend bits per stage
```

and explicitly implements the division algorithm instead of relying on:

```text
A / B
A % B
```

The divider produces:

* Quotient
* Remainder
* Divide-by-zero indication

---

# 8. ALU 4.0 — Supported Operations

ALU 4.0 supports 18 operations.

| Opcode  | Operation              |
| ------- | ---------------------- |
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

The ALU also generates status information including:

* Carry
* Borrow
* Zero
* Negative
* Overflow
* Divide-by-zero
* Valid

---

# 9. RTL Verification

ALU 4.0 was functionally verified before being taken through the physical-design flow.

The final 64-bit verification consisted of:

```text
Self tests   : 28
Passed       : 28
Failed       : 0

Random tests : 300
Passed       : 300
Failed       : 0
```

### Overall result

```text
TOTAL TESTS : 328
PASSED      : 328
FAILED      : 0
```

**328/328 tests passed successfully.**

The verification covered arithmetic, logical, shift, comparison, arithmetic, and status-flag behavior across the 64-bit implementation.

Detailed verification information is available in:

```text
verification/ALU4.0_64_verification.txt
```

---

# 10. ALU 4.0 — Synthesis

The ALU 4.0 architecture was synthesized using **Yosys**.

For the 64-bit RTL synthesis:

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

A particularly important result was:

```text
$mul = 0
$div = 0
$mod = 0
```

This confirmed that the custom multiplier and divider were not represented as generic inferred multiplication, division, or modulo cells at this synthesis stage.

---

# 11. Technology Mapping

After RTL synthesis, the design was technology-mapped using **ABC**.

The 64-bit design was converted into a large gate-level representation.

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

Representative mapped-cell counts included:

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

# 12. ALU 4.0 — Final 32-bit ASIC Implementation

After developing and verifying ALU 4.0, the architecture was implemented at **32 bits** for the final physical-design target.

This is the **final successful ASIC implementation of the project**.

The 32-bit design completed the complete physical-design flow:

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
Clock Tree Synthesis
 ↓
Global Routing
 ↓
Detailed Routing
 ↓
Antenna Analysis
 ↓
DRC
 ↓
LVS
 ↓
GDSII
```

---

# 13. Final 32-bit Physical-Design Results

The final 32-bit implementation successfully generated the physical-design artifacts.

### Physical implementation

* Floorplanning completed
* Placement completed
* Clock Tree Synthesis completed
* Routing completed
* Antenna verification passed
* DRC passed
* LVS passed
* GDSII generated

### Implementation Configuration

| Parameter                 | Value             |
| ------------------------- | ----------------- |
| Design                    | ALU 4.0           |
| Width                     | 32-bit            |
| PDK                       | SKY130A           |
| Standard-cell library     | `sky130_fd_sc_hd` |
| Clock port                | `clk`             |
| Clock period              | 30 ns             |
| Core utilization          | 25%               |
| Placement target density  | 35%               |
| Global-routing adjustment | 0.2               |

---

# 14. Final Signoff Results

The final ALU 4.0 32-bit implementation achieved:

| Check            | Result   |
| ---------------- | -------- |
| DRC              | **PASS** |
| LVS              | **PASS** |
| Antenna          | **PASS** |
| GDSII generation | **PASS** |

### Timing

From the final max timing report:

```text
Clock period : 30 ns
Data arrival : 18.854288 ns
Required     : 23.750002 ns
Setup slack  : +4.895714 ns
```

Therefore:

**Setup slack = +4.895714 ns at a 30 ns clock period.**

The detailed timing reports also contain electrical warnings, including slew and fanout violations. These are retained in the repository for transparency and further analysis.

---

# 15. Final Physical Artifacts

The final 32-bit physical-design directory contains the key implementation artifacts:

```text
physical_design/
└── ALU4.0_32_FINAL/
    ├── config.json
    ├── README.md
    ├── final/
    │   ├── ALU.lef
    │   └── ALU.sdc
    └── reports/
        ├── ALU4.0_32_max.rpt
        ├── ALU4.0_32_min.rpt
        ├── ANTENNA.rpt
        ├── DRC.rpt
        ├── LVS.rpt
        ├── metrics.csv
        └── metrics.json
```

The final GDSII is distributed separately through the GitHub Release:

```text
Release: v4.0-32bit
Artifact: ALU.gds
Size: approximately 79.6 MB
```

This keeps the large GDSII artifact separate from the normal source tree while still making the final physical output available.

---

# 16. ALU 4.0 — 64-bit Scaling Experiment

After successfully completing the 32-bit physical implementation, ALU 4.0 was scaled to 64 bits.

The objective was to investigate how the architecture behaves when the datapath width is doubled.

The 64-bit implementation successfully completed:

* RTL implementation
* Functional verification
* 328/328 RTL tests
* Yosys synthesis
* ABC technology mapping

However, the physical-design experiment exposed significantly greater implementation challenges.

---

# 17. 64-bit Physical-Design Experiment

The 64-bit design was submitted to the same ASIC physical-design flow.

The larger implementation introduced greater:

* Routing demand
* Clock-tree load
* Fanout
* Capacitance
* Timing complexity
* Physical congestion

The physical-design experiment encountered violations during post-route timing/signoff analysis, including issues associated with:

* Setup timing
* Slew
* Fanout
* Capacitance

The final multi-corner post-PnR timing/signoff process did not complete successfully.

Therefore, the 64-bit implementation is **not presented as a completed ASIC/GDSII result**.

It is documented as a scaling experiment.

---

# 18. Why the 64-bit Experiment Matters

The 64-bit experiment demonstrated an important ASIC-design principle:

> **RTL width does not scale linearly at the physical-design level.**

At RTL, increasing the datapath from 32 bits to 64 bits can appear straightforward.

At the physical level, the consequences propagate through the entire implementation:

```text
Wider datapath
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
Greater clock-tree load
      ↓
Greater congestion
      ↓
More difficult timing closure
      ↓
More difficult signoff
```

This is why the 32-bit implementation remains the final successful ASIC output while the 64-bit implementation is retained as an engineering experiment.

---

# 19. What Improved Across the Generations?

| Version              | Main Focus                              | Engineering Outcome                                                                  |
| -------------------- | --------------------------------------- | ------------------------------------------------------------------------------------ |
| **ALU 1.0**          | Initial architecture                    | Established the baseline and exposed physical-timing limitations                     |
| **ALU 2.0**          | Simplified RTL / generic arithmetic     | Demonstrated that simpler RTL does not automatically produce better physical results |
| **ALU 3.0**          | Custom arithmetic                       | Provided greater control over synthesized hardware                                   |
| **ALU 3.0 — 32-bit** | Physical implementation                 | Established practical physical-design experience                                     |
| **ALU 4.0**          | Pipelining + custom radix-16 arithmetic | Created a more structured and controllable architecture                              |
| **ALU 4.0 — 32-bit** | Final ASIC implementation               | Successfully completed physical implementation and generated GDSII                   |
| **ALU 4.0 — 64-bit** | Architecture scaling                    | RTL and synthesis successful; physical closure became significantly harder           |

The project was therefore developed through **iteration, measurement, analysis, and architectural improvement**.

---

# 20. Repository Structure

The repository is organized according to the different stages of the project:

```text
ALU/
│
├── architecture/
│   └── ARCHITECTURE.md
│
├── docs/
│   ├── ASIC_FLOW.md
│   └── RESULTS.md
│
├── history/
│   ├── alu1.0/
│   │   ├── design.sv
│   │   └── testbench.sv
│   │
│   ├── alu2.0/
│   │   ├── design.sv
│   │   └── testbench.sv
│   │
│   ├── alu3.0/
│   │   ├── design.sv
│   │   └── testbench.sv
│   │
│   └── alu3.0_32/
│       ├── design.sv
│       └── testbench.sv
│
├── physical_design/
│   └── ALU4.0_32_FINAL/
│       ├── config.json
│       ├── README.md
│       ├── final/
│       │   ├── ALU.lef
│       │   └── ALU.sdc
│       └── reports/
│
├── rtl/
│   ├── design.sv
│   └── testbench.sv
│
├── synthesis/
│   ├── alu4.0_32/
│   └── alu4.0_64/
│
├── verification/
│   └── ALU4.0_64_verification.txt
│
├── README.md
└── alu.compressed.zip
```

The major project areas are therefore:

| Directory          | Purpose                               |
| ------------------ | ------------------------------------- |
| `architecture/`    | ALU architecture documentation        |
| `history/`         | Earlier ALU generations               |
| `rtl/`             | Current ALU 4.0 RTL and testbench     |
| `verification/`    | Functional verification results       |
| `synthesis/`       | Yosys synthesis and mapping artifacts |
| `docs/`            | ASIC flow and result documentation    |
| `physical_design/` | Final 32-bit ASIC implementation      |
| `README.md`        | Project overview                      |

---

# 21. Documentation Guide

The repository contains dedicated documentation for the major parts of the project.

### Architecture

```text
architecture/ARCHITECTURE.md
```

Contains the ALU architecture, datapath organization, operations, flags, pipeline structure, and design evolution.

### ASIC Flow

```text
docs/ASIC_FLOW.md
```

Documents the RTL-to-GDSII implementation flow.

### Results

```text
docs/RESULTS.md
```

Contains the important synthesis, timing, and physical-design results.

### Verification

```text
verification/ALU4.0_64_verification.txt
```

Contains the 64-bit RTL verification summary.

### Final Physical Design

```text
physical_design/ALU4.0_32_FINAL/
```

Contains the final 32-bit implementation configuration, LEF/SDC files, physical-design reports, and signoff artifacts.

---

# 22. Development Environment

The project was developed using Windows together with a Linux-based ASIC development environment.

## Windows

The main development machine used Windows, with Linux-based ASIC tools accessed through WSL.

## WSL — Windows Subsystem for Linux

WSL provided the Linux environment required for the open-source ASIC toolchain.

## Ubuntu

Ubuntu running under WSL was used for:

* RTL simulation
* Yosys synthesis
* ABC technology mapping
* LibreLane execution
* OpenROAD physical design
* Report analysis
* Shell scripting
* File management

## Docker

Docker was used as part of the LibreLane-based ASIC environment to provide a controlled tool environment and manage dependencies.

## EDA Playground

EDA Playground was used during earlier stages for:

* RTL experimentation
* Verilog/SystemVerilog learning
* Quick simulations
* Debugging smaller modules

The project therefore progressed from rapid RTL experimentation to a complete local ASIC-development environment.

---

# 23. ASIC Toolchain

### RTL

* SystemVerilog
* EDA Playground

### Simulation

* Icarus Verilog
* GTKWave

### Development Environment

* Windows
* WSL
* Ubuntu
* Bash
* Docker

### Synthesis

* Yosys

### Technology Mapping

* ABC

### Physical Design

* LibreLane
* OpenROAD

### Process Design Kit

* SKY130A

### Standard-Cell Library

* `sky130_fd_sc_hd`

### Final Output

* GDSII

---

# 24. Key Results

## ALU 4.0 — 32-bit Final ASIC

* 18 operations
* 8-stage pipeline
* Custom radix-16 multiplier
* Custom radix-16 divider
* SKY130A
* `sky130_fd_sc_hd`
* 30 ns clock period
* 25% core utilization
* 35% placement target density
* Placement completed
* CTS completed
* Routing completed
* Antenna: **PASS**
* DRC: **PASS**
* LVS: **PASS**
* GDSII generated
* Setup slack: **+4.895714 ns**

---

## ALU 4.0 — 64-bit Scaling Experiment

* 18 operations
* 8-stage pipeline
* Custom radix-16 multiplier
* Custom radix-16 divider
* **328/328 RTL tests passed**
* Yosys synthesis completed
* ABC technology mapping completed
* `$mul = 0`
* `$div = 0`
* `$mod = 0`
* Physical-design experiment performed
* Post-PnR multi-corner signoff did not complete successfully

---

# 25. Engineering Takeaways

### Functional correctness comes first

RTL simulation establishes whether the architecture behaves correctly.

### Synthesis reveals the hardware

RTL that appears simple can produce very different hardware after synthesis.

### Architecture matters

The choice of arithmetic architecture has a direct effect on area, timing, routing, and physical feasibility.

### Pipelining is an architectural decision

Pipeline stages affect timing, latency, registers, clocking, and physical implementation.

### Custom arithmetic provides hardware control

Explicit multiplier and divider architectures provide greater visibility into the resulting hardware and avoid generic `$mul`, `$div`, and `$mod` inference in the synthesis result.

### Physical implementation is a separate challenge

A design can pass RTL verification and synthesis while still encountering timing or routing problems during physical implementation.

### Scaling exposes hidden constraints

The 64-bit experiment demonstrated how routing, clocking, fanout, capacitance, congestion, and timing become increasingly important as the design grows.

---

# 26. Final Project Outcome

The project produced two distinct outcomes.

## Final Successful ASIC

**ALU 4.0 — 32-bit**

The design successfully completed:

```text
RTL
→ Verification
→ Synthesis
→ Technology Mapping
→ Floorplanning
→ Placement
→ CTS
→ Routing
→ Antenna
→ DRC
→ LVS
→ GDSII
```

The final implementation achieved:

```text
Setup Slack = +4.895714 ns
Clock Period = 30 ns

DRC     = PASS
LVS     = PASS
Antenna = PASS
GDSII   = GENERATED
```

The final GDSII is available through the GitHub Release:

```text
v4.0-32bit
```

---

## 64-bit Scaling Experiment

**ALU 4.0 — 64-bit**

The 64-bit architecture successfully passed:

```text
328 / 328 RTL verification tests
```

and completed synthesis and technology mapping.

Its physical-design experiment demonstrated the substantially greater difficulty of achieving timing and routing closure as the architecture scales.

It is therefore documented as a **scaling experiment rather than a final ASIC implementation**.

---

# Final Takeaway

What began as an ALU design exercise evolved into a study of the complete ASIC development process.

The project progressed from:

**functional RTL**

to:

**architectural refinement**

to:

**custom arithmetic hardware**

to:

**pipelined design**

to:

**synthesis and technology mapping**

to:

**physical implementation**

and finally to:

**a successful 32-bit GDSII implementation.**

The subsequent 64-bit experiment demonstrated that ASIC design does not scale linearly with RTL width. Functional correctness is only one part of the problem; timing, routing, clocking, capacitance, congestion, and signoff ultimately determine whether a design can become a physically realizable implementation.

**Designed. Verified. Synthesized. Physically Implemented.**
