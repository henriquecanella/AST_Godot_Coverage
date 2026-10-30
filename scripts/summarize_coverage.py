#!/usr/bin/env python3
"""
Gameplay Coverage Report Summarizer
==================================
Reads and summarizes gameplay coverage results reproducing Table 3 from the paper.
Can read either from the dataset CSV or from JSON coverage reports generated during playtests.
"""

import os
import csv
import json
import glob
import argparse

GAME_DISPLAY = {
    "get_that_bit": "Get That Bit",
    "dead_men_scale_no_towers": "Dead Men Scale No Towers",
    "MelonCrusade": "Melon Crusade",
    "papoilas_fairy_rescue": "Papoila's Fairy Rescue",
    "catburglar": "Catburglar",
    "Foma": "Foma",
    "Chromavescence": "Chromavescence",
    "Shell_Jump_Go": "Shell Jump Go",
    "platformer_2d_demo": "Platformer 2D Demo",
    "Super_Mario_63_Redux": "Super Mario 63 Redux",
}

def summarize_csv(csv_path):
    if not os.path.exists(csv_path):
        print(f"File not found: {csv_path}")
        return

    print("\n" + "=" * 110)
    print(f"{'Game':26} | {'Player':7} | {'NPC':7} | {'Interact.':9} | {'Hazard':7} | {'Enemy':7} | {'Collect.':8} | {'Cov_G':7} | {'Cov_F':7}")
    print("=" * 110)

    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            game = row.get("game", "")
            p = row.get("player_cov_pct", "N/A")
            npc = row.get("npc_cov_pct", "N/A")
            it = row.get("interactable_cov_pct", "N/A")
            haz = row.get("hazard_cov_pct", "N/A")
            en = row.get("enemy_cov_pct", "N/A")
            col = row.get("collectable_cov_pct", "N/A")
            cov_g = row.get("gameplay_cov_pct", "N/A")
            cov_f = row.get("function_cov_pct", "N/A")

            def fmt(val):
                if val == "N/A":
                    return "  N/A "
                try:
                    return f"{float(val):5.1f}%"
                except ValueError:
                    return f"{val:>6}"

            print(f"{game:26} | {fmt(p):>7} | {fmt(npc):>7} | {fmt(it):>9} | {fmt(haz):>7} | {fmt(en):>7} | {fmt(col):>8} | {fmt(cov_g):>7} | {fmt(cov_f):>7}")

    print("=" * 110)

def summarize_json(report_dir):
    files = sorted(glob.glob(os.path.join(report_dir, "*_coverage_report.json")))
    if not files:
        print(f"No coverage reports found in {report_dir}")
        return

    print("\n" + "=" * 110)
    print(f"{'Game':26} | {'Player':7} | {'NPC':7} | {'Interact.':9} | {'Hazard':7} | {'Enemy':7} | {'Collect.':8} | {'Cov_G':7} | {'Cov_F':7}")
    print("=" * 110)

    for path in files:
        bn = os.path.basename(path).replace("_coverage_report.json", "")
        name = GAME_DISPLAY.get(bn, bn)

        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)

        cats = data.get("category_gameplay_coverage", {})
        
        def fmt(val):
            if val is None or val == "N/A":
                return "  N/A "
            if isinstance(val, (int, float)):
                return f"{val:5.1f}%"
            return str(val)

        p = fmt(cats.get("PLAYER"))
        npc = fmt(cats.get("NPC") if "NPC" in cats and cats.get("NPC") > 0 else "N/A")
        it = fmt(cats.get("INTERACTABLE"))
        haz = fmt(cats.get("HAZARD") if "HAZARD" in cats and cats.get("HAZARD") > 0 else "N/A")
        en = fmt(cats.get("ENEMY") if "ENEMY" in cats and cats.get("ENEMY") > 0 else "N/A")
        col = fmt(cats.get("COLLECTABLE") if "COLLECTABLE" in cats and cats.get("COLLECTABLE") > 0 else "N/A")

        cov_g = fmt(data.get("gameplay_coverage"))
        cov_f = fmt(data.get("function_coverage"))

        print(f"{name:26} | {p:>7} | {npc:>7} | {it:>9} | {haz:>7} | {en:>7} | {col:>8} | {cov_g:>7} | {cov_f:>7}")

    print("=" * 110)

def main():
    parser = argparse.ArgumentParser(description="Summarize gameplay coverage reports.")
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    parser.add_argument("--csv", default=os.path.join(base_dir, "datasets", "gameplay_coverage_results.csv"),
                        help="Path to gameplay_coverage_results.csv")
    parser.add_argument("--json-dir", default=None,
                        help="Optional directory containing *_coverage_report.json files")
    args = parser.parse_args()
    if args.json_dir:
        summarize_json(args.json_dir)
    else:
        summarize_csv(args.csv)

if __name__ == "__main__":
    main()

