# ALU 4.0 — 32-bit Physical Design

This directory contains the final physical-design artifacts for the 32-bit implementation of the parameterized ALU 4.0 using the **SKY130A** technology.

## Implementation

* **Design:** ALU 4.0
* **Width:** 32-bit
* **PDK:** SKY130A
* **Standard-cell library:** `sky130_fd_sc_hd`
* **Clock period:** 30 ns
* **Core utilization target:** 25%
* **Placement target density:** 35%
* **Global routing adjustment:** 0.2

## Signoff Results

| Check            | Result |
| ---------------- | ------ |
| DRC              | PASS   |
| LVS              | PASS   |
| Antenna          | PASS   |
| GDSII generation | PASS   |

## Timing

The final implementation achieved positive setup slack at the 30 ns clock period.

* **Setup slack:** +4.895714 ns
* **Data arrival time:** 18.854288 ns
* **Required time:** 23.750002 ns

The implementation also had some remaining slew and fanout violations, which are documented in the detailed timing reports.

## Directory Contents

### `final/`

Contains the final physical-design interface files:

* `ALU.lef`
* `ALU.sdc`

### `reports/`

Contains:

* `ALU4.0_32_max.rpt`
* `ALU4.0_32_min.rpt`
* `ANTENNA.rpt`
* `DRC.rpt`
* `LVS.rpt`
* `metrics.csv`
* `metrics.json`

### GDSII

The final `ALU.gds` file is approximately **79.6 MB** and is distributed through the GitHub Release rather than stored directly in the repository.

**Release:** `v4.0-32bit` — ALU 4.0 — 32-bit SKY130 ASIC

The release contains the complete final GDSII layout.

## Flow

The physical-design flow covered:

```text
RTL
 ↓
Synthesis
 ↓
Floorplanning
 ↓
Placement
 ↓
Clock Tree Synthesis
 ↓
Routing
 ↓
DRC / LVS / Antenna Checks
 ↓
GDSII Generation
```

This directory represents the final successful 32-bit physical implementation of ALU 4.0.
