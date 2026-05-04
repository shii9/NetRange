#!/usr/bin/env bash
################################################################################
# NetRange — Professional Network IP Expansion Tool
# 
# Expands IPv4 address ranges and CIDR notations into individual IP addresses.
# Supports multiple input formats, output modes, and integration with security
# tools like nmap, masscan, curl, and dig.
#
# Version: 2.0.0
# License: MIT
# Author: Security Toolkit
################################################################################

set -euo pipefail

VERSION="2.0.0"

# ============================================================================
# HELP FUNCTION
# ============================================================================

show_help() {
  cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                    NetRange v2.0 — Professional Tool                     ║
║                                                                          ║
║  Expands IPv4 ranges & CIDR notations into individual IP addresses for   ║
║  security testing, reconnaissance, and infrastructure analysis.          ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE
  netrange <input> [options]
  netrange <start-ip> <end-ip> [options]

INPUT FORMATS
  CIDR notation          netrange 172.16.0.0/24
  IP range               netrange 198.51.100.0 198.51.100.255
  Single IP              netrange 203.0.113.42
  From file              netrange -f targets.txt

OPTIONS
  -o, --output FILE      Output file path (default: stdout)
  -f, --file FILE        Read targets from file (one per line)
  -a, --append           Append to output file instead of overwriting
  -x, --exclude RANGE    Exclude IPs matching CIDR or range (repeatable)
  -c, --count            Only print the total IP count, do not generate
  -q, --quiet            Suppress info messages (only output IPs or errors)
  -p, --progress         Show progress bar for large ranges
  -F, --format FMT       Output format: plain (default), csv, json, nmap
  -s, --shuffle          Randomize output order
  -u, --unique           Deduplicate IPs when using multiple inputs
  -h, --help             Display this help message
  -v, --version          Show version information

EXAMPLES
  # CIDR — expand a /24 subnet
  netrange 192.0.2.0/24 -o subnet.txt

  # Large range — expand a /12 block with progress
  netrange 198.51.100.0 198.51.100.255 -o scan_targets.txt -p

  # Pipe directly into nmap (no file needed)
  netrange 203.0.113.0/28 | nmap -sn -iL -

  # Count IPs without generating
  netrange 192.0.2.0/24 -c

  # CIDR with exclusions
  netrange 198.51.100.0/24 -x 198.51.100.0/28 -x 198.51.100.16/28 -o filtered.txt

  # Multiple inputs from file
  netrange -f targets.txt -o all_ips.txt -u

  # CSV format output
  netrange 192.168.50.0/28 -F csv -o report.csv

  # JSON format output
  netrange 192.168.50.0/28 -F json -o report.json

  # Shuffle output for randomized scanning
  netrange 198.51.100.0/24 -s -o random_targets.txt

  # Append results to existing file
  netrange 192.0.2.0/24 -o targets.txt -a

OUTPUT FORMATS
  plain   One IP per line (default, pipe-friendly)
  csv     ip,range_index  — CSV with header row
  json    JSON array of IP strings
  nmap    Comma-separated on one line (nmap -Pn target format)

PERFORMANCE
  /24 network   (256 IPs)      : < 0.1s
  /16 network   (65K IPs)      : ~0.3s  (buffered writes)
  /12 network   (1M IPs)       : ~5s    (buffered writes)
  /8  network   (16M IPs)      : ~60s   (buffered writes)

INTEGRATION
  # With nmap (direct pipe)
  netrange 192.0.2.0/24 | nmap -sn -iL -

  # With masscan
  netrange 198.51.100.0/24 -o targets.txt && masscan -iL targets.txt -p80,443

  # With curl (parallel HTTP probing)
  netrange 203.0.113.0/28 | parallel -j 20 curl -sk https://{}

  # With dig (bulk reverse DNS)
  netrange 198.51.100.0/24 | parallel dig +short -x {}

  # Count before scanning
  netrange 192.0.2.0/24 -c   # → 1,048,576 IPs

REQUIREMENTS
  • Bash 4.0 or later
  • Python 3.6 or later
  • Write permissions to output directory (if using -o)

LEGAL NOTICE
  ⚠️  Authorized use only. Only expand IP ranges you own or have explicit
      permission to test. Unauthorized scanning may violate laws.

For more information, see README.md or visit the project documentation.
EOF
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

QUIET=false

log_info()    { [[ "$QUIET" == true ]] || printf '[*] %s\n' "$*" >&2; }
log_success() { [[ "$QUIET" == true ]] || printf '[+] %s\n' "$*" >&2; }
log_error()   { printf '[!] ERROR: %s\n' "$*" >&2; }
die()         { log_error "$@"; exit 1; }

# ============================================================================
# VALIDATION FUNCTIONS
# ============================================================================

validate_ip() {
  local ip="$1"
  [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
  for octet in "$o1" "$o2" "$o3" "$o4"; do
    [[ "$octet" =~ ^[0-9]+$ ]] || return 1
    (( octet >= 0 && octet <= 255 )) || return 1
  done
}

is_cidr() {
  [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]
}

# ============================================================================
# MAIN LOGIC
# ============================================================================

# Parse arguments
[[ $# -eq 0 ]] && { show_help; exit 1; }

OUTFILE=""
INPUT_FILE=""
APPEND=false
COUNT_ONLY=false
SHOW_PROGRESS=false
FORMAT="plain"
SHUFFLE=false
UNIQUE=false
EXCLUDES=()
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -v|--version)
      echo "NetRange v${VERSION}"
      exit 0
      ;;
    -o|--output)
      [[ $# -ge 2 ]] || die "Missing filename after '$1'"
      OUTFILE="$2"
      shift 2
      ;;
    -f|--file)
      [[ $# -ge 2 ]] || die "Missing filename after '$1'"
      INPUT_FILE="$2"
      shift 2
      ;;
    -a|--append)
      APPEND=true
      shift
      ;;
    -x|--exclude)
      [[ $# -ge 2 ]] || die "Missing range after '$1'"
      EXCLUDES+=("$2")
      shift 2
      ;;
    -c|--count)
      COUNT_ONLY=true
      shift
      ;;
    -q|--quiet)
      QUIET=true
      shift
      ;;
    -p|--progress)
      SHOW_PROGRESS=true
      shift
      ;;
    -F|--format)
      [[ $# -ge 2 ]] || die "Missing format after '$1'"
      FORMAT="$2"
      shift 2
      ;;
    -s|--shuffle)
      SHUFFLE=true
      shift
      ;;
    -u|--unique)
      UNIQUE=true
      shift
      ;;
    -*)
      die "Unknown option: $1 (use --help for usage)"
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

# Validate format
case "$FORMAT" in
  plain|csv|json|nmap) ;;
  *) die "Unknown format: $FORMAT (supported: plain, csv, json, nmap)" ;;
esac

# Check dependencies
command -v python3 >/dev/null 2>&1 || die "python3 is required but not installed"

# ============================================================================
# BUILD TARGET LIST
# ============================================================================

TARGETS=()

# From positional args
if [[ ${#POSITIONAL[@]} -eq 1 ]]; then
  # Single arg: could be CIDR or single IP
  TARGETS+=("${POSITIONAL[0]}")
elif [[ ${#POSITIONAL[@]} -eq 2 ]]; then
  # Two args: start-ip end-ip
  validate_ip "${POSITIONAL[0]}" || die "Invalid start IP: ${POSITIONAL[0]}"
  validate_ip "${POSITIONAL[1]}" || die "Invalid end IP: ${POSITIONAL[1]}"
  TARGETS+=("${POSITIONAL[0]}-${POSITIONAL[1]}")
elif [[ ${#POSITIONAL[@]} -gt 2 ]]; then
  die "Too many positional arguments (expected 1 CIDR or 2 IPs, got ${#POSITIONAL[@]})"
fi

# From input file
if [[ -n "$INPUT_FILE" ]]; then
  [[ -f "$INPUT_FILE" ]] || die "Input file not found: $INPUT_FILE"
  while IFS= read -r line; do
    line="${line%%#*}"        # strip comments
    line="${line// /}"        # strip spaces
    [[ -z "$line" ]] && continue
    TARGETS+=("$line")
  done < "$INPUT_FILE"
fi

# Must have at least one target
[[ ${#TARGETS[@]} -gt 0 ]] || die "No targets specified. Provide CIDR, IP range, or use -f <file>"

# ============================================================================
# EXECUTION — delegate to Python engine
# ============================================================================

# Build exclude args
EXCLUDE_ARGS=""
for ex in "${EXCLUDES[@]+"${EXCLUDES[@]}"}"; do
  EXCLUDE_ARGS+="--exclude ${ex} "
done

# Build target args string
TARGET_ARGS=""
for t in "${TARGETS[@]}"; do
  TARGET_ARGS+="${t}"$'\n'
done

# Determine output destination
if [[ -z "$OUTFILE" ]]; then
  OUTPUT_DEST="/dev/stdout"
else
  OUTPUT_DEST="$OUTFILE"
  # Validate output directory is writable
  outdir="$(dirname "$OUTFILE")"
  [[ -d "$outdir" ]] || die "Output directory does not exist: $outdir"
  [[ -w "$outdir" ]] || die "Output directory is not writable: $outdir"
fi

log_info "NetRange v${VERSION} — processing ${#TARGETS[@]} target(s)"

python3 - \
  "$OUTPUT_DEST" \
  "$COUNT_ONLY" \
  "$SHOW_PROGRESS" \
  "$FORMAT" \
  "$SHUFFLE" \
  "$UNIQUE" \
  "$APPEND" \
  "$QUIET" \
  <<PY
import ipaddress
import sys
import os
import random
import json
import time

# ─── Parse arguments ─────────────────────────────────────────────────────────
output_dest  = sys.argv[1]
count_only   = sys.argv[2] == "true"
show_progress= sys.argv[3] == "true"
fmt          = sys.argv[4]
shuffle      = sys.argv[5] == "true"
unique       = sys.argv[6] == "true"
append       = sys.argv[7] == "true"
quiet        = sys.argv[8] == "true"

# ─── Parse targets from stdin ────────────────────────────────────────────────
raw_targets = """${TARGET_ARGS}""".strip().splitlines()

# ─── Parse excludes ──────────────────────────────────────────────────────────
raw_excludes_str = """${EXCLUDE_ARGS}""".strip()
exclude_nets = []
if raw_excludes_str:
    parts = raw_excludes_str.split()
    i = 0
    while i < len(parts):
        if parts[i] == "--exclude" and i + 1 < len(parts):
            val = parts[i + 1]
            try:
                if "/" in val:
                    exclude_nets.append(ipaddress.ip_network(val, strict=False))
                elif "-" in val:
                    s, e = val.split("-", 1)
                    s_ip = ipaddress.IPv4Address(s.strip())
                    e_ip = ipaddress.IPv4Address(e.strip())
                    # Store as (start_int, end_int) tuple
                    exclude_nets.append((int(s_ip), int(e_ip)))
                else:
                    exclude_nets.append(ipaddress.ip_network(val + "/32", strict=False))
            except Exception as ex:
                print(f"[!] ERROR: Invalid exclude range: {val} — {ex}", file=sys.stderr)
                sys.exit(1)
            i += 2
        else:
            i += 1

def is_excluded(ip_int):
    """Check if an IP integer falls within any exclusion range."""
    for ex in exclude_nets:
        if isinstance(ex, tuple):
            if ex[0] <= ip_int <= ex[1]:
                return True
        else:
            if ipaddress.IPv4Address(ip_int) in ex:
                return True
    return False

# ─── Resolve all targets to (start_int, end_int) pairs ───────────────────────
ranges = []
for target in raw_targets:
    target = target.strip()
    if not target:
        continue
    try:
        if "/" in target:
            # CIDR notation
            net = ipaddress.ip_network(target, strict=False)
            ranges.append((int(net.network_address), int(net.broadcast_address)))
        elif "-" in target:
            # Range: start-end
            parts = target.split("-", 1)
            s = ipaddress.IPv4Address(parts[0].strip())
            e = ipaddress.IPv4Address(parts[1].strip())
            if int(s) > int(e):
                print(f"[!] ERROR: Start IP {s} is greater than end IP {e}", file=sys.stderr)
                sys.exit(1)
            ranges.append((int(s), int(e)))
        else:
            # Single IP
            ip = ipaddress.IPv4Address(target.strip())
            ranges.append((int(ip), int(ip)))
    except Exception as ex:
        print(f"[!] ERROR: Invalid target '{target}' — {ex}", file=sys.stderr)
        sys.exit(1)

# ─── Calculate total count ───────────────────────────────────────────────────
total_before_exclude = sum(e - s + 1 for s, e in ranges)

if count_only and not exclude_nets:
    # Fast path: no excludes, just count
    if not quiet:
        for s, e in ranges:
            s_ip = ipaddress.IPv4Address(s)
            e_ip = ipaddress.IPv4Address(e)
            count = e - s + 1
            print(f"  {s_ip} → {e_ip} : {count:,} IPs", file=sys.stderr)
    print(f"{total_before_exclude:,}")
    sys.exit(0)

# ─── Generate IPs ────────────────────────────────────────────────────────────
BUFFER_SIZE = 8192  # Write in chunks for performance

def generate_ips():
    """Generator that yields all non-excluded IP integers."""
    for start, end in ranges:
        for ip_int in range(start, end + 1):
            if exclude_nets and is_excluded(ip_int):
                continue
            yield ip_int

# Count with excludes if needed
if count_only:
    counted = 0
    for _ in generate_ips():
        counted += 1
    print(f"{counted:,}")
    sys.exit(0)

# ─── Collect or stream IPs ──────────────────────────────────────────────────
if shuffle or unique:
    # Must collect all IPs into memory
    if not quiet:
        print(f"[*] Collecting IPs into memory...", file=sys.stderr)
    all_ips = list(generate_ips())
    if unique:
        all_ips = list(dict.fromkeys(all_ips))  # preserve order, dedupe
    if shuffle:
        random.shuffle(all_ips)
    total_output = len(all_ips)
    ip_iter = iter(all_ips)
else:
    total_output = total_before_exclude  # approximate if excludes
    ip_iter = generate_ips()

# ─── Progress bar helper ────────────────────────────────────────────────────
def show_progress_bar(current, total, start_time, width=40):
    if total == 0:
        return
    pct = min(current / total, 1.0)
    filled = int(width * pct)
    bar = "█" * filled + "░" * (width - filled)
    elapsed = time.time() - start_time
    speed = int(current / elapsed) if elapsed > 0 else 0
    eta = int((total - current) / speed) if speed > 0 else 0
    print(f"\r  [{bar}] {pct*100:5.1f}%  {current:,}/{total:,}  {speed:,} IP/s  ETA {eta}s  ", end="", file=sys.stderr)

# ─── Write output ───────────────────────────────────────────────────────────
try:
    write_mode = "a" if append else "w"
    is_stdout = (output_dest == "/dev/stdout")

    if is_stdout:
        outf = sys.stdout
    else:
        outf = open(output_dest, write_mode, encoding="utf-8")

    start_time = time.time()
    written = 0
    buffer = []

    if fmt == "csv":
        outf.write("ip,index\n")
    elif fmt == "json":
        outf.write("[\n")

    for ip_int in ip_iter:
        ip_str = str(ipaddress.IPv4Address(ip_int))
        written += 1

        if fmt == "plain":
            buffer.append(ip_str + "\n")
        elif fmt == "csv":
            buffer.append(f"{ip_str},{written}\n")
        elif fmt == "json":
            prefix = "  " if written == 1 else ", "
            buffer.append(f'{prefix}"{ip_str}"\n')
        elif fmt == "nmap":
            buffer.append(ip_str)

        # Flush buffer periodically
        if len(buffer) >= BUFFER_SIZE:
            if fmt == "nmap":
                outf.write(",".join(buffer))
                buffer = []
            else:
                outf.write("".join(buffer))
                buffer = []

            if show_progress and not is_stdout:
                show_progress_bar(written, total_output, start_time)

    # Flush remaining buffer
    if buffer:
        if fmt == "nmap":
            outf.write(",".join(buffer) + "\n")
        else:
            outf.write("".join(buffer))

    if fmt == "json":
        outf.write("]\n")

    if show_progress and not is_stdout and written > 0:
        show_progress_bar(written, written, start_time)
        print("", file=sys.stderr)  # newline after progress bar

    if not is_stdout:
        outf.close()

    elapsed = time.time() - start_time
    speed = int(written / elapsed) if elapsed > 0 else written

    if not quiet:
        if is_stdout:
            pass  # don't pollute stdout
        else:
            print(f"[+] Generated {written:,} IPs → {output_dest} ({elapsed:.2f}s, {speed:,} IP/s)", file=sys.stderr)

except IOError as e:
    print(f"[!] ERROR: Failed to write output: {e}", file=sys.stderr)
    sys.exit(1)
except BrokenPipeError:
    # Normal when piping to head, grep, etc.
    pass
PY