# Replication Package: Investigating Test Adequacy Criteria for Platformer Video Games

[![Engine: Godot 4.x](https://img.shields.io/badge/Godot-4.x-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Python: 3.8+](https://img.shields.io/badge/Python-3.8+-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

This repository provides the complete **replication package** for the empirical study:
> **"Investigating Test Coverage Criteria for Platformer Video Games"**  

It contains the standalone Godot 4 coverage instrumentation plugin (`godot_coverage_metrics`), the machine-executable agentic skill specification (`SKILL.md`), all **10 open-source Godot 4 platformer benchmark games** (in both human reference ground-truth and automated LLM-instrumented versions), all empirical CSV datasets, and automated replication scripts.

---

## 📁 Repository Structure

```text
.
├── README.md                           # This comprehensive replication guide
├── LICENSE                             # MIT Open Source License
├── plugin/                             # Standalone Godot 4 TCR Plugin
│   └── godot_coverage_metrics/
│       ├── plugin.cfg                  # Plugin metadata & editor registration
│       ├── plugin.gd                   # Editor lifecycle script
│       ├── plugin_autoload.gd          # Singleton tracking runtime entities & functions
│       └── trackable.gd                # Trackable probe node injecting interaction calls
├── skill/
│   └── SKILL.md                        # Domain-specific LLM agentic skill specification
├── benchmark_games/                    # 10 Reference Games (Human Ground Truth Instrumentation)
│   ├── catburglar/                     # Stealth platformer with item collection
│   ├── Chromavescence/                 # 1-bit dual-world dimension platformer
│   ├── dead-men-scale-no-towers/       # Bouldering precision platformer
│   ├── Foma/                           # Coin collection precision platformer
│   ├── get_that_bit/                   # Puzzle platformer collecting bits
│   ├── Legacy_SM63Redux/               # Super Mario 63 Redux multi-level tribute platformer
│   ├── MelonCrusade/                   # 3D obstacle and climbing platformer
│   ├── papoilas_fairy_rescue/          # Tower maze fairy rescue
│   ├── platformer_2d_demo/             # Official Godot reference platformer demo
│   └── Shell_Jump_Go/                  # Procedural vertical endless jumper
├── llm_instrumented_games/             # 10 Benchmark Games (Automated LLM Skill v2 Output)
│   ├── catburglar/
│   ├── Chromavescence/
│   ├── dead-men-scale-no-towers/
│   ├── Foma/
│   ├── get_that_bit/
│   ├── Legacy_SM63Redux/
│   ├── MelonCrusade/
│   ├── papoilas_fairy_rescue/
│   ├── platformer_2d_demo/
│   └── Shell_Jump_Go/
├── datasets/                           # Empirical CSV datasets
│   ├── benchmark_games_overview.csv                    # Table 1: LOC, scenes, nodes, assets
│   ├── human_ground_truth_instrumentation.csv          # Table 2: Manual instrumentation times & category breakdown
│   ├── gameplay_coverage_results.csv                   # Table 3: Session times, category coverage, Cov_G, Cov_F
│   ├── llm_vs_human_instrumentation_comparison.csv     # Table 4: Recall, Precision, Trackable nodes, LOC deltas
│   ├── instrumentation_comparison_skill_v2.csv         # Full evaluation metrics for Skill v2
│   ├── instrumentation_comparison_skill_v1.csv         # Intermediate ablation run (Skill v1)
│   └── instrumentation_comparison_baseline.csv         # Baseline LLM run without skill
└── scripts/                            # Standalone Python replication & verification scripts
    ├── evaluate_instrumentation.py     # Quantitative evaluation reproducing Table 4
    ├── validate_headless.py            # Automated headless engine verification (Exit Code 0)
    └── summarize_coverage.py           # Summarizes gameplay coverage results reproducing Table 3
```

---

## ⚙️ Prerequisites & Environment Setup

- **Godot Engine 4.x** (v4.2 to v4.7+):
  The executable `godot` must be available in your system `$PATH`:
  ```bash
  godot --version
  # Example output: 4.7.2.stable.fedora.ed1daf0bf
  ```
- **Python 3.8+**:
  All scripts use standard library modules (`csv`, `json`, `os`, `re`, `subprocess`, `argparse`). No third-party pip dependencies are required.

---

## 🚀 Quick Start: Replicating the Empirical Results

### Step 1: Headless Engine Verification (Zero-Error Pre-Flight)

The paper proves that both the human ground-truth and automated LLM-instrumented games compile cleanly, resolve all script dependencies, and initialize without runtime exceptions.

To verify all projects across both suites:
```bash
python3 scripts/validate_headless.py --suite all
```

To validate only the automated LLM-instrumented suite:
```bash
python3 scripts/validate_headless.py --suite llm
```

**Expected Result:**
All 10 benchmark projects compile, parse their scene trees, register global classes, and exit with code `0`.

---

### Step 2: Reproduce Quantitative Instrumentation Comparison (Table 4)

To replicate the quantitative evaluation comparing LLM-driven automated instrumentation against human reference ground truth:
```bash
python3 scripts/evaluate_instrumentation.py
```

This script parses all scene graphs (`.tscn`) and GDScript files (`.gd`) across `benchmark_games/` and `llm_instrumented_games/`, computing:
1. Ground Truth Recall and Precision for scenes and scripts
2. Number of injected `Trackable` probe nodes ($T_c$)
3. Instrumentation Lines of Code (LOC) added to scene and script files
4. Category classification accuracy ($c \in \{0, \dots, 5\}$)

**Benchmark Results Summary (reproducing Table 4):**

| Game | Trackable Nodes (H / LLM) | Diff (%) | Injected LOC (H / LLM) | Diff (%) | Scene Recall / Prec. | Script Recall / Prec. |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Catburglar** | 50 / 54 | +8.0% | 340 / 356 | +4.7% | 100.0% / 100.0% | 100.0% / 100.0% |
| **Chromavescence** | 9 / 10 | +11.1% | 60 / 68 | +13.3% | 100.0% / 100.0% | 100.0% / 80.0% |
| **Dead Men Scale No Towers** | 20 / 39 | +95.0% | 129 / 216 | +67.4% | 100.0% / 90.9% | 100.0% / 70.6% |
| **Foma** | 13 / 14 | +7.7% | 88 / 77 | -12.5% | 100.0% / 92.9% | 100.0% / 100.0% |
| **Get That Bit** | 10 / 11 | +10.0% | 61 / 73 | +19.7% | 100.0% / 85.7% | 100.0% / 90.9% |
| **Super Mario 63 Redux** | 201 / 156 | -22.4% | 1,258 / 1,078 | -14.3% | 100.0% / 100.0% | 100.0% / 100.0% |
| **Melon Crusade** | 12 / 12 | 0.0% | 75 / 72 | -4.0% | 100.0% / 100.0% | 100.0% / 100.0% |
| **Papoila's Fairy Rescue** | 8 / 13 | +62.5% | 55 / 91 | +65.5% | 100.0% / 72.7% | 100.0% / 57.1% |
| **Platformer 2D Demo** | 11 / 11 | 0.0% | 63 / 70 | +11.1% | 100.0% / 100.0% | 100.0% / 100.0% |
| **Shell Jump Go** | 4 / 5 | +25.0% | 25 / 33 | +32.0% | 100.0% / 100.0% | 100.0% / 80.0% |
| **OVERALL / TOTAL** | **338 / 325** | **-3.8%** | **2,154 / 2,134** | **-0.9%** | **100.0% / 97.1%** | **100.0% / 94.8%** |

> **Key Finding**: The automated LLM agent achieved **100.0% Recall** across all 10 benchmark games (matching all 232 human-selected scene files and 271 script files). The deviations in precision in games such as *Dead Men Scale No Towers* and *Papoila's Fairy Rescue* were caused by exhaustive static scene-tree traversal uncovering secondary gameplay mechanisms that human annotators overlooked due to cognitive fatigue.

---

### Step 3: Summarize Gameplay Coverage Logs (Table 3)

To view the category-level coverage metrics extracted from the actual gameplay sessions:
```bash
python3 scripts/summarize_coverage.py
```

Or inspect `datasets/gameplay_coverage_results.csv`.

**Gameplay Coverage Results (Table 3 in paper):**

| Game | Session Time | Player ($Cov_0$) | NPC ($Cov_3$) | Interactable ($Cov_4$) | Hazard ($Cov_5$) | Enemy ($Cov_1$) | Collectable ($Cov_2$) | Gameplay ($Cov_G$) | Function ($Cov_F$) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Get That Bit** | 2 min | 66.7% | N/A | 93.8% | N/A | N/A | 100.0% | 80.7% | 90.7% |
| **Dead Men Scale No Towers** | 27 min | 54.5% | 100.0% | 96.4% | N/A | N/A | 100.0% | 87.8% | 38.6% |
| **Melon Crusade** | 4 min | 100.0% | N/A | 92.3% | 37.5% | N/A | 100.0% | 75.0% | 100.0% |
| **Papoila's Fairy Rescue** | 8 min | 100.0% | N/A | 100.0% | N/A | 46.7% | 81.3% | 76.8% | 100.0% |
| **Catburglar** | 28 min | 100.0% | N/A | 53.7% | 33.3% | 20.0% | 21.4% | 45.5% | 79.5% |
| **Foma** | 8 min | 100.0% | N/A | 100.0% | 2.6% | N/A | 83.9% | 33.0% | 81.4% |
| **Chromavescence** | 5 min | 100.0% | N/A | 80.0% | N/A | N/A | 100.0% | 83.3% | 63.3% |
| **Shell Jump Go** | 10 min | 100.0% | N/A | 100.0% | N/A | N/A | N/A | 100.0% | 100.0% |
| **Platformer 2D Demo** | 6 min | 100.0% | N/A | 100.0% | N/A | 100.0% | 100.0% | 100.0% | 100.0% |
| **Super Mario 63 Redux** | 16 min | 100.0% | 100.0% | 47.6% | 50.0% | 66.7% | 100.0% | 77.4% | 81.5% |
| **Mean / Median** | **11.4 / 8.0 min** | **92.1%** | **100.0%** | **86.4%** | **30.9%** | **58.3%** | **87.4%** | **75.9% / 79.0%** | **83.5% / 86.1%** |

> **Orthogonality of Adequacy Criteria**: Overall Gameplay Coverage ($Cov_G$) and Function Coverage ($Cov_F$) exhibit a Pearson correlation of only $r = 0.092$, confirming that structural code coverage and gameplay adequacy measure fundamentally distinct dimensions of video game quality.

---

## 🧩 The `godot_coverage_metrics` Plugin

The TCR plugin resides in `plugin/godot_coverage_metrics/` and operates via two core components:

### 1. `PluginAutoload` (`plugin_autoload.gd`)
- Registered under `[autoload]` in `project.godot`.
- Tracks registered and interacted entity counts ($T_c, I_c$) partitioned into 6 categories.
- Tracks registered and dynamically executed functions across all tracked scripts.
- Automatically exports telemetry to `res://coverage_report.json` upon pressing **`F12`** or closing the game window (`NOTIFICATION_WM_CLOSE_REQUEST`).

### 2. `Trackable` Probe Node (`trackable.gd`)
- Inherits `Node` (`class_name Trackable`).
- Key properties:
  - `object_id: String`: Human-readable identifier (e.g. `"player"`, `"gem_01"`, `"guard"`).
  - `object_type: int`: Integer category strictly in range `0..5`.
- Rewrites parent script AST in memory upon `_ready()` to prepend function execution monitors.
- Exposes `mark_interacted()` to register gameplay interaction events.

### Category Mapping Guide (`object_type`)

| `object_type` | Enum Name | Description & Heuristics | Examples |
| :---: | :--- | :--- | :--- |
| **`0`** | **`PLAYER`** | Playable avatar and active movement sub-controllers | `Player`, `Character`, `MovementNode`, `Dash` |
| **`1`** | **`ENEMY`** | Hostile characters, turrets, AI threats | `Guard`, `SecurityCamera`, `Ant`, `Bat`, `DemonJr` |
| **`2`** | **`COLLECTABLE`** | Items, pickups, and rewards collected by player | `Coin`, `Gem`, `Bit`, `Melon`, `Treasure` |
| **`3`** | **`NPC`** | Non-hostile interactive characters, rescued entities | `Fairy`, `Rita`, `Toad`, `DialogueTrigger` |
| **`4`** | **`INTERACTABLE`** | Mechanisms, doors, springs, cameras, level triggers, menus | `Door`, `Spring`, `Campfire`, `Piton`, `Lift`, `HUD` |
| **`5`** | **`HAZARD`** | Environmental lethal zones, damaging traps, spikes | `Killbox`, `Killzone`, `Spikes`, `DeathPlane` |

---

## 🤖 Automated Instrumentation via `SKILL.md`

`skill/SKILL.md` contains the complete agentic specification for autonomous game instrumentation. It can be loaded into AI coding assistants (such as Antigravity, Gemini, Claude Code, or OpenAI Codex) to instrument new or existing Godot games:

1. **Plugin Deployment**: Copies `plugin/godot_coverage_metrics` to `res://addons/godot_coverage_metrics/` and updates `project.godot`.
2. **Scene Discovery**: Scans `.tscn` files to attach `Trackable` child nodes beneath scripted root entities and sub-controllers.
3. **Category Disambiguation**: Applies the 6-class taxonomy without out-of-bounds indices.
4. **GDScript Injection**: Adds canonical interaction probes into primary event handlers:
   ```gdscript
   if has_node("Trackable"):
       $Trackable.mark_interacted()
   ```
5. **Defensive Layout Guards**: Adds `if not child is Control: continue` to menu loops to avoid disrupting UI layouts.
6. **Pre-Flight Validation**: Executes `godot --headless --path <project> --quit` to ensure zero compilation errors.

---

## 📊 Dataset Codebook

| File | Description | Source Table |
| :--- | :--- | :--- |
| `benchmark_games_overview.csv` | Lines of code, scene counts, node counts, asset counts, and itch.io/GitHub URLs for all 10 games | Table 1 |
| `human_ground_truth_instrumentation.csv` | Manual instrumentation time (minutes) and Trackable probe node distribution per category | Table 2 |
| `gameplay_coverage_results.csv` | Session durations, category-level gameplay coverage ($Cov_0 \dots Cov_5$), $Cov_G$, and $Cov_F$ | Table 3 |
| `llm_vs_human_instrumentation_comparison.csv` | Trackable node counts, instrumentation LOC deltas, scene/script Recall and Precision | Table 4 |
| `instrumentation_comparison_skill_v2.csv` | Comprehensive raw metrics computed for the final agentic skill (Skill v2) | Section V-B |
| `instrumentation_comparison_skill_v1.csv` | Quantitative ablation data for initial skill without controller deduplication | Section V-B |
| `instrumentation_comparison_baseline.csv` | Quantitative ablation data for raw prompt-only LLM instrumentation | Section V-B |

---

## 🎮 Benchmark Suite Attributions

The ten benchmark games were curated from open-source repositories and itch.io game jams under permissive open licenses:

| Game | Original Author / Source | License | Original URL |
| :--- | :--- | :--- | :--- |
| **Get That Bit** | Dan Waywell | MIT | [itch.io](https://danwaywell.itch.io/get-that-bit) |
| **Dead Men Scale No Towers** | WyvernBW | MIT | [itch.io](https://wyvernbw.itch.io/dead-man-scale-no-towers) |
| **Melon Crusade** | Mechanical Flower | MIT | [itch.io](https://mechanical-flower.itch.io/meloncrusade) |
| **Papoila's Fairy Rescue** | Caio Valente | MIT | [itch.io](https://valentecaio.itch.io/papoilas-fairy-rescue) |
| **Catburglar** | John Gabriel | MIT | [itch.io](https://johngabrieluk.itch.io/catburglar) |
| **Foma** | Sammy-T | CC-BY 4.0 | [itch.io](https://sammy-t.itch.io/foma) |
| **Chromavescence** | MaybeBarney | MIT | [itch.io](https://maybebarney.itch.io/chromavescence) |
| **Shell Jump Go** | Otto P | MIT | [itch.io](https://ottop.itch.io/shell-jump-go) |
| **Platformer 2D Demo** | Godot Engine Community | MIT | [GitHub](https://godotengine.github.io/godot-demo-projects/) |
| **Super Mario 63 Redux** | Creyon & Contributors | Fan Game / Open Source | [itch.io](https://creyon.itch.io/sm63redux) |

