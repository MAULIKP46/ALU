# ASIC Physical Design Flow

This document describes the RTL-to-GDSII flow used for the ALU 4.0 ASIC implementation.

The final 32-bit implementation was carried out using the **SKY130A** process design kit and the `sky130_fd_sc_hd` standard-cell library.

---

## 1. Overall Flow

```text
SystemVerilog RTL
       │
       ▼
RTL Verification
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

---

## 2. RTL Design

The ALU is described using SystemVerilog RTL.

The design is parameterized by data width, allowing the same RTL architecture to be used for different operand sizes.

The ALU4.0 RTL contains arithmetic, logical, shift, comparison, and operand-pass operations.

The main RTL source is located in:

```text
rtl/ALU4.0.sv
```

---

## 3. RTL Verification

Before physical implementation, the RTL was functionally verified using a SystemVerilog testbench.

The testbench exercises the supported ALU operations and checks the generated results and status flags.

The verification material is located under:

```text
verification/
```

and the corresponding testbench is:

```text
rtl/testbench.sv
```

---

## 4. Logic Synthesis

The verified RTL is synthesized into a gate-level representation using the target standard-cell library.

For the final 32-bit physical implementation:

```text
PDK:
SKY130A

Standard-cell library:
sky130_fd_sc_hd
```

Synthesis converts the behavioral RTL into a technology-mapped digital circuit made from standard cells.

The synthesis scripts and results are maintained under:

```text
synthesis/
```

---

## 5. Floorplanning

The synthesized netlist is used to create the initial physical layout.

The floorplanning stage determines:

* Core dimensions
* Standard-cell placement area
* I/O locations
* Power distribution planning
* Placement density

The final configuration used:

```text
Core utilization target: 25%
Placement target density: 35%
```

---

## 6. Placement

During placement, the standard cells from the synthesized netlist are positioned within the core area.

The placement stage attempts to:

* Minimize wire length
* Reduce congestion
* Meet timing requirements
* Maintain legal cell placement

The placement result becomes the basis for subsequent clock-tree synthesis and routing.

---

## 7. Clock Tree Synthesis

Clock Tree Synthesis (CTS) creates a clock distribution network for the sequential elements in the design.

The purpose is to distribute the clock while controlling:

* Clock skew
* Clock latency
* Transition time
* Fanout

The final ALU implementation uses:

```text
Clock port: clk
Clock period: 30 ns
```

---

## 8. Routing

Routing connects the placed standard cells and clock network using the available metal layers.

The routing process includes:

1. Global routing
2. Detailed routing
3. Design-rule considerations
4. Timing optimization

The final routing must produce a physically connected design that can be verified for DRC and LVS.

---

## 9. Timing Analysis

Static Timing Analysis (STA) is used to determine whether the implemented circuit can satisfy its timing constraints.

For the final 32-bit implementation, the clock period was:

```text
30 ns
```

The implementation achieved positive setup slack.

Detailed timing reports are available in:

```text
physical_design/ALU4.0_32_FINAL/reports/
```

---

## 10. Design Rule Check (DRC)

DRC checks whether the physical layout follows the manufacturing rules defined by the technology.

Examples of rules checked include:

* Minimum spacing
* Minimum width
* Via requirements
* Metal geometry
* Layer interactions

The final ALU4.0 32-bit implementation:

```text
DRC: PASS
```

---

## 11. Layout Versus Schematic (LVS)

LVS compares the extracted physical circuit against the intended netlist.

Its purpose is to verify that the physical layout represents the correct electrical connectivity.

The final implementation:

```text
LVS: PASS
```

---

## 12. Antenna Check

Antenna checking identifies potential manufacturing problems caused by charge accumulation on long interconnects during fabrication.

The final implementation:

```text
Antenna: PASS
```

---

## 13. GDSII Generation

After successful physical implementation and verification, the final layout is exported as a GDSII file.

The final GDSII file is:

```text
ALU.gds
```

Because the GDSII file is approximately 79.6 MB, it is distributed through the GitHub Release:

```text
v4.0-32bit
```

rather than being stored directly in the normal Git repository.

---

## 14. Final Physical Design Artifacts

The repository contains the smaller physical-design artifacts under:

```text
physical_design/ALU4.0_32_FINAL/
```

The directory contains:

```text
ALU4.0_32_FINAL/
├── README.md
├── config.json
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

The complete GDSII layout is available from the corresponding GitHub Release.

---

## 15. Technology Configuration

The final physical implementation used:

| Parameter                 | Value             |
| ------------------------- | ----------------- |
| PDK                       | SKY130A           |
| Standard-cell library     | `sky130_fd_sc_hd` |
| Design                    | ALU               |
| Data width                | 32-bit            |
| Clock port                | `clk`             |
| Clock period              | 30 ns             |
| Core utilization          | 25%               |
| Placement density         | 35%               |
| Global routing adjustment | 0.2               |

---

## 16. Summary

The ALU4.0 design was taken through the major stages of a digital ASIC implementation flow, from SystemVerilog RTL through synthesis, floorplanning, placement, CTS, routing, physical verification, and GDSII generation.

The final 32-bit implementation successfully generated a verified GDSII layout using the SKY130A technology.
