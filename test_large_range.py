#!/usr/bin/env python3
"""
NetRange v2.0 — Large Range Performance Benchmark

Tests performance with progressively larger IP ranges.
Validates that buffered writes handle millions of IPs correctly.
"""

import subprocess
import sys
import time
from pathlib import Path

SCRIPT = "bash netrange.sh"

benchmarks = [
    ("127.0.1.0/24",   256,         "Small /24"),
    ("127.0.2.0/24",     4_096,       "Medium /20"),
    ("127.0.2.0/24",     65_536,      "/16 network"),
    ("127.0.1.0/24",    262_144,     "Large /14"),
    ("127.0.3.0/24",      1_048_576,   "Very large /12 (1M IPs)"),
]

print("\n" + "═" * 65)
print("  NetRange v2.0 — Performance Benchmark")
print("═" * 65)
print(f"\n  {'Test':<30} {'IPs':>12} {'Time':>8} {'Speed':>14}")
print("  " + "─" * 64)

all_passed = True

for cidr, expected_count, label in benchmarks:
    outfile = f"bench_{label.replace(' ', '_').replace('/', '_')}.txt"

    start = time.time()
    result = subprocess.run(
        f"{SCRIPT} {cidr} -o {outfile} -q",
        shell=True, capture_output=True, text=True, timeout=300
    )
    elapsed = time.time() - start

    if result.returncode != 0:
        print(f"  ✗ {label:<30} FAILED: {result.stderr.strip()}")
        all_passed = False
        continue

    # Count lines
    line_count = sum(1 for _ in open(outfile))
    speed = int(line_count / elapsed) if elapsed > 0 else 0

    ok = line_count == expected_count
    marker = "✓" if ok else "✗"
    print(f"  {marker} {label:<30} {line_count:>10,} {elapsed:>7.2f}s {speed:>12,} IP/s")

    if not ok:
        all_passed = False
        print(f"    → Expected {expected_count:,}, got {line_count:,}")

    Path(outfile).unlink(missing_ok=True)

print()
if all_passed:
    print("  ✓ All benchmarks passed!")
else:
    print("  ✗ Some benchmarks failed.")
print("═" * 65 + "\n")

sys.exit(0 if all_passed else 1)
