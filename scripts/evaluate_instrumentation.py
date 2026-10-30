#!/usr/bin/env python3
"""
Quantitative Instrumentation Evaluation Script
==============================================
Compares automated instrumentation against human reference ground truth.
Computes:
  - Scene Recall, Precision, and F1 (.tscn)
  - Script Recall, Precision, and F1 (.gd)
  - Trackable Node Counts and Percentage Delta
  - Injected Instrumentation Lines of Code (LOC) and Percentage Delta
  - Object Type Classification Match Percentage

Reproduces Table 4 and datasets/instrumentation_comparison_skill_v2.csv
"""

import os
import re
import csv
import argparse

GAME_SPECS = [
    ("catburglar", "catburglar/game", "Catburglar"),
    ("Chromavescence", "Chromavescence", "Chromavescence"),
    ("dead-men-scale-no-towers", "dead-men-scale-no-towers", "Dead Men Scale No Towers"),
    ("Foma", "Foma", "Foma"),
    ("get_that_bit", "get_that_bit", "Get That Bit"),
    ("Legacy_SM63Redux", "Legacy_SM63Redux", "Super Mario 63 Redux"),
    ("MelonCrusade", "MelonCrusade", "Melon Crusade"),
    ("papoilas_fairy_rescue", "papoilas_fairy_rescue", "Papoila's Fairy Rescue"),
    ("platformer_2d_demo", "platformer_2d_demo", "Platformer 2D Demo"),
    ("Shell_Jump_Go", "Shell_Jump_Go", "Shell Jump Go"),
]

EXCLUDED_DIRS = {".git", ".godot", "addons"}

def analyze_directory(base_dir):
    tscn_files = {}
    gd_files = {}
    total_gd_loc = 0
    total_tscn_loc = 0

    for root, dirs, files in os.walk(base_dir):
        dirs[:] = [d for d in dirs if d not in EXCLUDED_DIRS]
        for fn in sorted(files):
            full_path = os.path.join(root, fn)
            rel_path = os.path.relpath(full_path, base_dir)

            if fn.endswith(".tscn"):
                with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                    txt = f.read()
                lines = txt.splitlines()
                total_tscn_loc += len(lines)
                ext_lines = [l for l in lines if "trackable.gd" in l and l.strip().startswith("[ext_resource")]
                nodes = re.findall(r"\[node name=\"Trackable\"[^\[]*", txt)
                if nodes:
                    parsed_nodes = []
                    inst_loc = len(ext_lines)
                    for n in nodes:
                        n_lines = [l for l in n.strip().splitlines() if l.strip()]
                        inst_loc += len(n_lines)
                        pm = re.search(r"parent=\"([^\"]+)\"", n)
                        parent = pm.group(1) if pm else "."
                        tm = re.search(r"object_type\s*=\s*(\d+)", n)
                        otype = int(tm.group(1)) if tm else 0
                        idm = re.search(r"object_id\s*=\s*\"([^\"]*)\"", n)
                        oid = idm.group(1) if idm else ""
                        parsed_nodes.append((parent, otype, oid))
                    tscn_files[rel_path] = {
                        "nodes": parsed_nodes,
                        "inst_loc": inst_loc
                    }

            elif fn.endswith(".gd"):
                with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                    txt = f.read()
                lines = txt.splitlines()
                total_gd_loc += len(lines)
                calls = re.findall(r"\.(?:mark_interacted|setup_coverage)\(\)", txt)
                inst_lines = [l for l in lines if "Trackable" in l or "mark_interacted" in l or "setup_coverage" in l]
                cur_func = "<top>"
                funcs_called = set()
                for l in lines:
                    s = l.strip()
                    if s.startswith("func "):
                        cur_func = s.split("(")[0].replace("func ", "").strip()
                    if "mark_interacted()" in s or "setup_coverage()" in s:
                        funcs_called.add(cur_func)
                if calls:
                    gd_files[rel_path] = {
                        "calls": len(calls),
                        "funcs": funcs_called,
                        "inst_loc": len(inst_lines),
                        "total_loc": len(lines)
                    }

    return tscn_files, gd_files, total_tscn_loc, total_gd_loc

def evaluate(human_root, target_root, output_csv=None):
    results = []

    print("\n" + "=" * 105)
    print(f"{'Game':26} | {'Nodes (H/T)':12} | {'LOC (H/T)':12} | {'Scene R/P':14} | {'Script R/P':14} | {'Type Match':10}")
    print("=" * 105)

    tot_hn, tot_tn = 0, 0
    tot_hloc, tot_tloc = 0, 0
    tot_htscn, tot_ttscn, tot_shared_tscn = 0, 0, 0
    tot_hgd, tot_tgd, tot_shared_gd = 0, 0, 0

    for code_name, subpath, display_name in GAME_SPECS:
        h_dir = os.path.join(human_root, subpath)
        t_dir = os.path.join(target_root, subpath)

        if not os.path.exists(h_dir):
            print(f"Warning: Reference dir not found: {h_dir}")
            continue
        if not os.path.exists(t_dir):
            print(f"Warning: Target dir not found: {t_dir}")
            continue

        h_tscn, h_gd, h_tloc, h_gloc = analyze_directory(h_dir)
        t_tscn, t_gd, t_tloc, t_gloc = analyze_directory(t_dir)

        shared_tscn = set(h_tscn.keys()) & set(t_tscn.keys())
        union_tscn = set(h_tscn.keys()) | set(t_tscn.keys())
        shared_gd = set(h_gd.keys()) & set(t_gd.keys())
        union_gd = set(h_gd.keys()) | set(t_gd.keys())

        h_nodes = sum(len(v["nodes"]) for v in h_tscn.values())
        t_nodes = sum(len(v["nodes"]) for v in t_tscn.values())
        h_calls = sum(v["calls"] for v in h_gd.values())
        t_calls = sum(v["calls"] for v in t_gd.values())

        h_tscn_inst_loc = sum(v["inst_loc"] for v in h_tscn.values())
        t_tscn_inst_loc = sum(v["inst_loc"] for v in t_tscn.values())
        h_gd_inst_loc = sum(v["inst_loc"] for v in h_gd.values())
        t_gd_inst_loc = sum(v["inst_loc"] for v in t_gd.values())

        h_total_inst_loc = h_tscn_inst_loc + h_gd_inst_loc
        t_total_inst_loc = t_tscn_inst_loc + t_gd_inst_loc

        tscn_recall = (len(shared_tscn) / len(h_tscn) * 100.0) if h_tscn else 100.0
        tscn_precision = (len(shared_tscn) / len(t_tscn) * 100.0) if t_tscn else 100.0
        tscn_f1 = (2 * tscn_precision * tscn_recall / (tscn_precision + tscn_recall)) if (tscn_precision + tscn_recall) else 0.0
        tscn_distance = 100.0 - (len(shared_tscn) / len(union_tscn) * 100.0) if union_tscn else 0.0

        gd_recall = (len(shared_gd) / len(h_gd) * 100.0) if h_gd else 100.0
        gd_precision = (len(shared_gd) / len(t_gd) * 100.0) if t_gd else 100.0
        gd_f1 = (2 * gd_precision * gd_recall / (gd_precision + gd_recall)) if (gd_precision + gd_recall) else 0.0
        gd_distance = 100.0 - (len(shared_gd) / len(union_gd) * 100.0) if union_gd else 0.0

        diff_nodes = t_nodes - h_nodes
        diff_nodes_pct = (diff_nodes / h_nodes * 100.0) if h_nodes else 0.0

        diff_calls = t_calls - h_calls
        diff_calls_pct = (diff_calls / h_calls * 100.0) if h_calls else 0.0

        diff_total_inst_loc = t_total_inst_loc - h_total_inst_loc
        inst_loc_diff_pct = (diff_total_inst_loc / h_total_inst_loc * 100.0) if h_total_inst_loc else 0.0

        matching_types = 0
        total_eval_nodes = 0
        for f in shared_tscn:
            hn_map = {n[2]: n[1] for n in h_tscn[f]["nodes"] if n[2]}
            tn_map = {n[2]: n[1] for n in t_tscn[f]["nodes"] if n[2]}
            for oid, ot in hn_map.items():
                total_eval_nodes += 1
                if oid in tn_map and tn_map[oid] == ot:
                    matching_types += 1
        type_match_pct = (matching_types / total_eval_nodes * 100.0) if total_eval_nodes else 0.0

        # Accumulators
        tot_hn += h_nodes
        tot_tn += t_nodes
        tot_hloc += h_total_inst_loc
        tot_tloc += t_total_inst_loc
        tot_htscn += len(h_tscn)
        tot_ttscn += len(t_tscn)
        tot_shared_tscn += len(shared_tscn)
        tot_hgd += len(h_gd)
        tot_tgd += len(t_gd)
        tot_shared_gd += len(shared_gd)

        row_str = (f"{display_name:26} | "
                   f"{h_nodes:>3} / {t_nodes:<3} ({diff_nodes_pct:>+5.1f}%) | "
                   f"{h_total_inst_loc:>4} / {t_total_inst_loc:<4} ({inst_loc_diff_pct:>+5.1f}%) | "
                   f"{tscn_recall:>5.1f}% / {tscn_precision:>5.1f}% | "
                   f"{gd_recall:>5.1f}% / {gd_precision:>5.1f}% | "
                   f"{type_match_pct:>6.1f}%")
        print(row_str)

        results.append({
            "game": code_name,
            "display_name": display_name,
            "human_tscn_files": len(h_tscn),
            "target_tscn_files": len(t_tscn),
            "shared_tscn_files": len(shared_tscn),
            "tscn_recall_pct": round(tscn_recall, 2),
            "tscn_precision_pct": round(tscn_precision, 2),
            "tscn_f1_pct": round(tscn_f1, 2),
            "tscn_distance_from_human_pct": round(tscn_distance, 2),
            "human_trackable_nodes": h_nodes,
            "target_trackable_nodes": t_nodes,
            "diff_trackable_nodes": diff_nodes,
            "trackable_nodes_diff_pct": round(diff_nodes_pct, 2),
            "object_type_match_pct": round(type_match_pct, 2),
            "human_gd_files": len(h_gd),
            "target_gd_files": len(t_gd),
            "shared_gd_files": len(shared_gd),
            "gd_recall_pct": round(gd_recall, 2),
            "gd_precision_pct": round(gd_precision, 2),
            "gd_f1_pct": round(gd_f1, 2),
            "gd_distance_from_human_pct": round(gd_distance, 2),
            "human_interaction_calls": h_calls,
            "target_interaction_calls": t_calls,
            "diff_interaction_calls": diff_calls,
            "interaction_calls_diff_pct": round(diff_calls_pct, 2),
            "human_tscn_inst_loc": h_tscn_inst_loc,
            "target_tscn_inst_loc": t_tscn_inst_loc,
            "diff_tscn_inst_loc": t_tscn_inst_loc - h_tscn_inst_loc,
            "human_gd_inst_loc": h_gd_inst_loc,
            "target_gd_inst_loc": t_gd_inst_loc,
            "diff_gd_inst_loc": t_gd_inst_loc - h_gd_inst_loc,
            "human_total_inst_loc": h_total_inst_loc,
            "target_total_inst_loc": t_total_inst_loc,
            "diff_total_inst_loc": diff_total_inst_loc,
            "inst_loc_diff_pct": round(inst_loc_diff_pct, 2),
            "human_total_gd_loc": h_gloc,
            "target_total_gd_loc": t_gloc,
            "diff_total_gd_loc": t_gloc - h_gloc
        })

    print("-" * 105)
    overall_node_diff = tot_tn - tot_hn
    overall_node_pct = (overall_node_diff / tot_hn * 100.0) if tot_hn else 0.0
    overall_loc_diff = tot_tloc - tot_hloc
    overall_loc_pct = (overall_loc_diff / tot_hloc * 100.0) if tot_hloc else 0.0
    overall_tscn_rec = (tot_shared_tscn / tot_htscn * 100.0) if tot_htscn else 0.0
    overall_tscn_prec = (tot_shared_tscn / tot_ttscn * 100.0) if tot_ttscn else 0.0
    overall_gd_rec = (tot_shared_gd / tot_hgd * 100.0) if tot_hgd else 0.0
    overall_gd_prec = (tot_shared_gd / tot_tgd * 100.0) if tot_tgd else 0.0

    print(f"{'OVERALL / TOTAL':26} | "
          f"{tot_hn:>3} / {tot_tn:<3} ({overall_node_pct:>+5.1f}%) | "
          f"{tot_hloc:>4} / {tot_tloc:<4} ({overall_loc_pct:>+5.1f}%) | "
          f"{overall_tscn_rec:>5.1f}% / {overall_tscn_prec:>5.1f}% | "
          f"{overall_gd_rec:>5.1f}% / {overall_gd_prec:>5.1f}% |")
    print("=" * 105)

    if output_csv and results:
        fieldnames = list(results[0].keys())
        with open(output_csv, "w", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=fieldnames)
            w.writeheader()
            w.writerows(results)
        print(f"\n[INFO] Detailed evaluation CSV written to: {output_csv}")

    return results

def main():
    parser = argparse.ArgumentParser(description="Evaluate automated game instrumentation against human reference.")
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    parser.add_argument("--human-root", default=os.path.join(base_dir, "benchmark_games"),
                        help="Path to human reference ground truth projects")
    parser.add_argument("--target-root", default=os.path.join(base_dir, "llm_instrumented_games"),
                        help="Path to automated / LLM instrumented projects")
    parser.add_argument("--output-csv", default=None,
                        help="Optional path to output evaluation metrics CSV")
    args = parser.parse_args()

    evaluate(args.human_root, args.target_root, args.output_csv)

if __name__ == "__main__":
    main()
