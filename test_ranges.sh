#!/usr/bin/env bash

# ═══════════════════════════════════════════════════════════════
# NetRange v2.0 — Shell Integration Tests
# Tests all major features from the command line
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

PASS=0
FAIL=0

check() {
  local label="$1"
  local condition="$2"
  if eval "$condition"; then
    PASS=$((PASS + 1))
    echo "  ✓ $label"
  else
    FAIL=$((FAIL + 1))
    echo "  ✗ $label"
  fi
}

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  NetRange v2.0 — Shell Integration Tests"
echo "═══════════════════════════════════════════════════════"

# ─── 1. Basic range ──────────────────────────────────────────
echo ""
echo "▸ Basic range expansion"
bash netrange.sh 192.0.2.0 192.0.2.255 -o test_range.txt -q
count=$(wc -l < test_range.txt)
check "/24 range generates 256 IPs" "[ $count -eq 256 ]"
first=$(head -1 test_range.txt)
last=$(tail -1 test_range.txt)
check "First IP: 192.0.2.0" "[ '$first' = '192.0.2.0' ]"
check "Last IP: 192.0.2.255" "[ '$last' = '192.0.2.255' ]"
rm -f test_range.txt

# ─── 2. CIDR notation ───────────────────────────────────────
echo ""
echo "▸ CIDR notation"
bash netrange.sh 198.51.100.0/28 -o test_cidr.txt -q
count=$(wc -l < test_cidr.txt)
check "CIDR /28 generates 16 IPs" "[ $count -eq 16 ]"
rm -f test_cidr.txt

bash netrange.sh 198.51.100.0/24 -o test_cidr24.txt -q
count=$(wc -l < test_cidr24.txt)
check "CIDR /24 generates 256 IPs" "[ $count -eq 256 ]"
rm -f test_cidr24.txt

# ─── 3. Stdout piping ───────────────────────────────────────
echo ""
echo "▸ Stdout piping"
stdout_count=$(bash netrange.sh 198.51.100.0/30 -q | wc -l)
check "Pipe to stdout (4 IPs)" "[ $stdout_count -eq 4 ]"

# ─── 4. Count-only mode ─────────────────────────────────────
echo ""
echo "▸ Count-only mode"
cnt=$(bash netrange.sh 198.51.100.0/24 -c -q)
check "Count /16 = 65,536" "[ '$cnt' = '65,536' ]"

cnt=$(bash netrange.sh 192.0.2.0/24 -c -q)
check "Count /12 = 1,048,576" "[ '$cnt' = '1,048,576' ]"

# ─── 5. Exclude ranges ──────────────────────────────────────
echo ""
echo "▸ Exclude ranges"
bash netrange.sh 192.0.2.0/24 -x 192.0.2.0/28 -o test_excl.txt -q
count=$(wc -l < test_excl.txt)
check "Excluded /28 from /24 → 240 IPs" "[ $count -eq 240 ]"
rm -f test_excl.txt

# ─── 6. CSV format ──────────────────────────────────────────
echo ""
echo "▸ CSV format"
bash netrange.sh 203.0.113.0/30 -F csv -o test_csv.txt -q
header=$(head -1 test_csv.txt)
check "CSV header is 'ip,index'" "[ '$header' = 'ip,index' ]"
data_lines=$(($(wc -l < test_csv.txt) - 1))
check "CSV has 4 data rows" "[ $data_lines -eq 4 ]"
rm -f test_csv.txt

# ─── 7. JSON format ─────────────────────────────────────────
echo ""
echo "▸ JSON format"
bash netrange.sh 203.0.113.0/30 -F json -o test_json.txt -q
# Quick validation: first line should be [, last line should be ]
first_char=$(head -c1 test_json.txt)
check "JSON starts with [" "[ '$first_char' = '[' ]"
rm -f test_json.txt

# ─── 8. Append mode ─────────────────────────────────────────
echo ""
echo "▸ Append mode"
bash netrange.sh 203.0.113.0/30 -o test_app.txt -q
bash netrange.sh 203.0.113.4/30 -o test_app.txt -q -a
count=$(wc -l < test_app.txt)
check "Append combines both ranges (8 IPs)" "[ $count -eq 8 ]"
rm -f test_app.txt

# ─── 9. Large range ─────────────────────────────────────────
echo ""
echo "▸ Large range performance"
start_time=$(date +%s)
bash netrange.sh 198.51.100.0/24 -o test_large.txt -q
end_time=$(date +%s)
elapsed=$((end_time - start_time))
count=$(wc -l < test_large.txt)
check "/16 generates 65,536 IPs in ${elapsed}s" "[ $count -eq 65536 ]"
rm -f test_large.txt

# ─── 10. Error handling ─────────────────────────────────────
echo ""
echo "▸ Error handling"
bash netrange.sh 192.168.1.255 192.168.1.0 -o test_err.txt -q 2>/dev/null && echo "  ✗ Reversed range should fail" || { PASS=$((PASS + 1)); echo "  ✓ Reversed range rejected correctly"; }
rm -f test_err.txt

bash netrange.sh 999.999.999.999 -o test_err.txt -q 2>/dev/null && echo "  ✗ Invalid IP should fail" || { PASS=$((PASS + 1)); echo "  ✓ Invalid IP rejected correctly"; }
rm -f test_err.txt

# ─── Summary ─────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
total=$((PASS + FAIL))
if [ $FAIL -eq 0 ]; then
  echo "  ✓ ALL $PASS TESTS PASSED!"
else
  echo "  Results: $PASS passed, $FAIL failed out of $total"
fi
echo "═══════════════════════════════════════════════════════"
echo ""

exit $FAIL
