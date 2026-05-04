#!/usr/bin/env python3
"""
NetRange v2.0 — Comprehensive Test Suite

Tests all core features: ranges, CIDR, formats, excludes, shuffle, count, etc.
"""

import ipaddress
import json
import os
import subprocess
import sys
import time
from pathlib import Path

SCRIPT = "bash netrange.sh"
PASS = 0
FAIL = 0

def run(args, expect_fail=False, stdin_data=None):
    """Run netrange.sh with given arguments and return (returncode, stdout, stderr)."""
    cmd = f"{SCRIPT} {args}"
    result = subprocess.run(
        cmd, shell=True, capture_output=True, text=True,
        input=stdin_data, timeout=120
    )
    if expect_fail and result.returncode != 0:
        return result.returncode, result.stdout, result.stderr
    if not expect_fail and result.returncode != 0:
        return result.returncode, result.stdout, result.stderr
    return result.returncode, result.stdout, result.stderr


def test(name, condition, detail=""):
    """Record a test result."""
    global PASS, FAIL
    if condition:
        PASS += 1
        print(f"  ✓ {name}")
    else:
        FAIL += 1
        print(f"  ✗ {name}")
        if detail:
            print(f"    → {detail}")


def cleanup(*files):
    for f in files:
        Path(f).unlink(missing_ok=True)


# ═════════════════════════════════════════════════════════════════════════════
print("\n" + "═" * 65)
print("  NetRange v2.0 — Comprehensive Test Suite")
print("═" * 65)

# ─── Test Group 1: Basic IP Range ────────────────────────────────────────────
print("\n▸ Basic IP Range Expansion")

rc, out, err = run("127.0.1.0 172.16.10.15 -o test_basic.txt -q")
test("Range expansion exits cleanly", rc == 0, err)
if rc == 0:
    lines = Path("test_basic.txt").read_text().strip().splitlines()
    test("Generates correct count (16 IPs)", len(lines) == 16, f"got {len(lines)}")
    test("First IP is 127.0.1.0", lines[0] == "127.0.1.0", lines[0])
    test("Last IP is 172.16.10.15", lines[-1] == "172.16.10.15", lines[-1])
cleanup("test_basic.txt")

# ─── Test Group 2: Single IP ────────────────────────────────────────────────
print("\n▸ Single IP")

rc, out, err = run("127.0.3.42 -o test_single.txt -q")
test("Single IP exits cleanly", rc == 0, err)
if rc == 0:
    lines = Path("test_single.txt").read_text().strip().splitlines()
    test("Generates exactly 1 IP", len(lines) == 1, f"got {len(lines)}")
    test("IP is 127.0.3.42", lines[0] == "127.0.3.42", lines[0])
cleanup("test_single.txt")

# ─── Test Group 3: CIDR Notation ────────────────────────────────────────────
print("\n▸ CIDR Notation")

rc, out, err = run("127.0.2.0/24 -o test_cidr24.txt -q")
test("CIDR /24 exits cleanly", rc == 0, err)
if rc == 0:
    lines = Path("test_cidr24.txt").read_text().strip().splitlines()
    test("/24 generates 256 IPs", len(lines) == 256, f"got {len(lines)}")
    test("First IP is 127.0.2.0", lines[0] == "127.0.2.0", lines[0])
    test("Last IP is 127.0.2.255", lines[-1] == "127.0.2.255", lines[-1])
cleanup("test_cidr24.txt")

rc, out, err = run("127.0.2.0/28 -o test_cidr28.txt -q")
test("CIDR /28 exits cleanly", rc == 0, err)
if rc == 0:
    lines = Path("test_cidr28.txt").read_text().strip().splitlines()
    test("/28 generates 16 IPs", len(lines) == 16, f"got {len(lines)}")
cleanup("test_cidr28.txt")

rc, out, err = run("192.168.50.128/32 -o test_cidr32.txt -q")
test("CIDR /32 exits cleanly", rc == 0, err)
if rc == 0:
    lines = Path("test_cidr32.txt").read_text().strip().splitlines()
    test("/32 generates 1 IP", len(lines) == 1, f"got {len(lines)}")
cleanup("test_cidr32.txt")

# ─── Test Group 4: Stdout Piping ────────────────────────────────────────────
print("\n▸ Stdout Piping (no -o)")

rc, out, err = run("127.0.2.0/30 -q")
test("Stdout piping exits cleanly", rc == 0, err)
lines = out.strip().splitlines()
test("Stdout has 4 IPs", len(lines) == 4, f"got {len(lines)}")

# ─── Test Group 5: Count-Only Mode ──────────────────────────────────────────
print("\n▸ Count-Only Mode (-c)")

rc, out, err = run("127.0.2.0/24 -c -q")
test("Count-only exits cleanly", rc == 0, err)
test("Count is 65,536", out.strip() == "65,536", f"got '{out.strip()}'")

rc, out, err = run("127.0.1.0/24 -c -q")
test("Large CIDR count works", rc == 0, err)
test("Count is 1,048,576", out.strip() == "1,048,576", f"got '{out.strip()}'")

# ─── Test Group 6: CSV Format ───────────────────────────────────────────────
print("\n▸ CSV Format (-F csv)")

rc, out, err = run("127.0.3.0/30 -F csv -o test_csv.txt -q")
test("CSV format exits cleanly", rc == 0, err)
if rc == 0:
    content = Path("test_csv.txt").read_text().strip().splitlines()
    test("CSV has header row", content[0] == "ip,index", content[0])
    test("CSV data row count is 4", len(content) - 1 == 4, f"got {len(content)-1}")
    test("First data row correct", content[1] == "127.0.3.0,1", content[1])
cleanup("test_csv.txt")

# ─── Test Group 7: JSON Format ──────────────────────────────────────────────
print("\n▸ JSON Format (-F json)")

rc, out, err = run("127.0.3.0/30 -F json -o test_json.txt -q")
test("JSON format exits cleanly", rc == 0, err)
if rc == 0:
    data = json.loads(Path("test_json.txt").read_text())
    test("JSON is a list", isinstance(data, list))
    test("JSON has 4 IPs", len(data) == 4, f"got {len(data)}")
    test("First IP in JSON", data[0] == "127.0.3.0", data[0])
cleanup("test_json.txt")

# ─── Test Group 8: Nmap Format ──────────────────────────────────────────────
print("\n▸ Nmap Format (-F nmap)")

rc, out, err = run("127.0.3.0/30 -F nmap -q")
test("Nmap format exits cleanly", rc == 0, err)
ips = out.strip().split(",")
test("Nmap output has 4 IPs", len(ips) == 4, f"got {len(ips)}")

# ─── Test Group 9: Exclude Ranges ───────────────────────────────────────────
print("\n▸ Exclude Ranges (-x)")

rc, out, err = run("127.0.1.0/24 -x 127.0.1.0/28 -o test_excl.txt -q")
test("Exclude exits cleanly", rc == 0, err)
if rc == 0:
    lines = Path("test_excl.txt").read_text().strip().splitlines()
    test("Excluded /28 from /24 → 240 IPs", len(lines) == 240, f"got {len(lines)}")
    test("First excluded IP absent", "10.0.0.0" not in lines)
    test("10.0.0.15 is absent", "10.0.0.15" not in lines)
    test("10.0.0.16 is present", "10.0.0.16" in lines)
cleanup("test_excl.txt")

# ─── Test Group 10: Shuffle ─────────────────────────────────────────────────
print("\n▸ Shuffle Mode (-s)")

rc, out1, err = run("127.0.1.0/24 -o test_shuf.txt -q -s")
test("Shuffle exits cleanly", rc == 0, err)
if rc == 0:
    lines = Path("test_shuf.txt").read_text().strip().splitlines()
    test("Shuffle still has 256 IPs", len(lines) == 256, f"got {len(lines)}")
    # Check that order differs from sequential (very unlikely to match)
    sequential = [str(ipaddress.IPv4Address(int(ipaddress.IPv4Address("127.0.1.0")) + i)) for i in range(256)]
    test("Order is shuffled", lines != sequential)
cleanup("test_shuf.txt")

# ─── Test Group 11: Append Mode ─────────────────────────────────────────────
print("\n▸ Append Mode (-a)")

run("127.0.3.0/30 -o test_append.txt -q")
run("127.0.3.4/30 -o test_append.txt -q -a")
lines = Path("test_append.txt").read_text().strip().splitlines()
test("Append combines both ranges", len(lines) == 8, f"got {len(lines)}")
cleanup("test_append.txt")

# ─── Test Group 12: File Input ───────────────────────────────────────────────
print("\n▸ File Input (-f)")

Path("test_input.txt").write_text("127.0.1.0/30\n# comment line\n127.0.3.0/30\n")
rc, out, err = run("-f test_input.txt -o test_filein.txt -q")
test("File input exits cleanly", rc == 0, err)
if rc == 0:
    lines = Path("test_filein.txt").read_text().strip().splitlines()
    test("File input generates 8 IPs total", len(lines) == 8, f"got {len(lines)}")
cleanup("test_input.txt", "test_filein.txt")

# ─── Test Group 13: Unique Mode ─────────────────────────────────────────────
print("\n▸ Unique Mode (-u)")

Path("test_dupes.txt").write_text("127.0.3.0/30\n127.0.3.0/30\n")
rc, out, err = run("-f test_dupes.txt -o test_uniq.txt -q -u")
test("Unique mode exits cleanly", rc == 0, err)
if rc == 0:
    lines = Path("test_uniq.txt").read_text().strip().splitlines()
    test("Duplicates removed (4 IPs, not 8)", len(lines) == 4, f"got {len(lines)}")
cleanup("test_dupes.txt", "test_uniq.txt")

# ─── Test Group 14: Error Handling ──────────────────────────────────────────
print("\n▸ Error Handling")

rc, out, err = run("192.168.1.255 192.168.1.0 -o test_err.txt -q", expect_fail=True)
test("Reversed range fails correctly", rc != 0)
cleanup("test_err.txt")

rc, out, err = run("999.999.999.999 -o test_err.txt -q", expect_fail=True)
test("Invalid IP fails correctly", rc != 0)
cleanup("test_err.txt")

rc, out, err = run("-o test_err.txt -q", expect_fail=True)
test("No target fails correctly", rc != 0)
cleanup("test_err.txt")

# ─── Test Group 15: Large Range Performance ─────────────────────────────────
print("\n▸ Large Range Performance")

start_time = time.time()
rc, out, err = run("127.0.2.0/24 -o test_perf.txt -q")
elapsed = time.time() - start_time
test("Large /16 range completes", rc == 0, err)
if rc == 0:
    lines_count = sum(1 for _ in open("test_perf.txt"))
    test(f"/16 generates 65,536 IPs", lines_count == 65536, f"got {lines_count}")
    speed = int(lines_count / elapsed) if elapsed > 0 else 0
    test(f"Performance: {elapsed:.2f}s ({speed:,} IP/s)", elapsed < 30, f"took {elapsed:.2f}s")
cleanup("test_perf.txt")

# ═════════════════════════════════════════════════════════════════════════════
print("\n" + "═" * 65)
total = PASS + FAIL
if FAIL == 0:
    print(f"  ✓ ALL {PASS} TESTS PASSED!")
else:
    print(f"  Results: {PASS} passed, {FAIL} failed out of {total}")
print("═" * 65 + "\n")

sys.exit(1 if FAIL > 0 else 0)
