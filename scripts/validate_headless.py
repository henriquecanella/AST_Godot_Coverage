#!/usr/bin/env python3
"""
Automated Headless Engine Verification Script
============================================
Verifies that all 10 benchmark games compile, parse scene hierarchies,
and initialize cleanly without runtime errors using Godot 4.x headless mode:
  Pass 1: godot --headless --path <project_dir> --editor --quit  (imports assets & registers UIDs)
  Pass 2: godot --headless --path <project_dir> --quit          (executes engine initialization)
"""

import os
import sys
import subprocess
import argparse

GAME_DIRS = [
    ("Catburglar", "catburglar/game"),
    ("Chromavescence", "Chromavescence"),
    ("Dead Men Scale No Towers", "dead-men-scale-no-towers"),
    ("Foma", "Foma"),
    ("Get That Bit", "get_that_bit"),
    ("Super Mario 63 Redux", "Legacy_SM63Redux"),
    ("Melon Crusade", "MelonCrusade"),
    ("Papoila's Fairy Rescue", "papoilas_fairy_rescue"),
    ("Platformer 2D Demo", "platformer_2d_demo"),
    ("Shell Jump Go", "Shell_Jump_Go"),
]

def check_godot():
    try:
        res = subprocess.run(["godot", "--version"], capture_output=True, text=True, check=True)
        return res.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None

def validate_suite(suite_path, suite_name):
    print(f"\n========================================================")
    print(f" Validating: {suite_name}")
    print(f" Root: {suite_path}")
    print(f"========================================================")

    results = []
    all_passed = True

    for name, rel_path in GAME_DIRS:
        full_proj = os.path.join(suite_path, rel_path)
        if not os.path.exists(os.path.join(full_proj, "project.godot")):
            print(f"[-] {name:26} : MISSING (project.godot not found at {full_proj})")
            results.append((name, False, "project.godot not found"))
            all_passed = False
            continue

        # Pass 1: Ensure asset imports and UID registry are warm
        try:
            subprocess.run(["godot", "--headless", "--path", full_proj, "--editor", "--quit"],
                           capture_output=True, text=True, timeout=60)
        except subprocess.TimeoutExpired:
            pass

        # Pass 2: Headless game execution verification
        cmd = ["godot", "--headless", "--path", full_proj, "--quit"]
        try:
            p = subprocess.run(cmd, capture_output=True, text=True, timeout=45)
            if p.returncode == 0:
                print(f"[+] {name:26} : PASSED (Exit Code 0)")
                results.append((name, True, "Exit Code 0"))
            else:
                print(f"[-] {name:26} : FAILED (Exit Code {p.returncode})")
                if p.stderr:
                    print(f"    Stderr: {p.stderr.strip()[:200]}")
                results.append((name, False, f"Exit Code {p.returncode}"))
                all_passed = False
        except subprocess.TimeoutExpired:
            print(f"[-] {name:26} : TIMEOUT (>45s)")
            results.append((name, False, "Timeout"))
            all_passed = False
        except Exception as e:
            print(f"[-] {name:26} : ERROR ({e})")
            results.append((name, False, str(e)))
            all_passed = False

    return all_passed

def main():
    parser = argparse.ArgumentParser(description="Headless validation for Godot Platformer benchmark suite.")
    parser.add_argument("--suite", choices=["benchmark", "llm", "all"], default="all",
                        help="Which suite to validate: 'benchmark', 'llm', or 'all' (default: all)")
    args = parser.parse_args()

    godot_ver = check_godot()
    if not godot_ver:
        print("[ERROR] 'godot' command not found in PATH. Please install Godot 4.x.")
        sys.exit(1)

    print(f"Detected Godot Version: {godot_ver}")
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    success = True
    if args.suite in ["benchmark", "all"]:
        bench_dir = os.path.join(base_dir, "benchmark_games")
        if not validate_suite(bench_dir, "Human Ground Truth Suite (benchmark_games)"):
            success = False

    if args.suite in ["llm", "all"]:
        llm_dir = os.path.join(base_dir, "llm_instrumented_games")
        if not validate_suite(llm_dir, "LLM-Instrumented Suite (llm_instrumented_games)"):
            success = False

    print("\n" + "=" * 56)
    if success:
        print("[SUCCESS] All projects validated successfully with code 0!")
        sys.exit(0)
    else:
        print("[FAILURE] Some projects encountered errors during headless run.")
        sys.exit(1)

if __name__ == "__main__":
    main()
