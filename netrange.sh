#!/usr/bin/env bash
################################################################################
# NetRange — Professional Tool
# 
# Expands IPv4 address ranges into individual IP addresses
# Perfect for network reconnaissance, security testing, and infrastructure mapping
#
# Version: 1.0.0
# License: MIT
# Author: Security Toolkit
################################################################################

set -euo pipefail

# ============================================================================
# HELP FUNCTION
# ============================================================================

show_help() {
  cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                      NetRange - Professional Tool                          ║
║                                                                            ║
║ Expands IPv4 address ranges into individual IP addresses for security     ║
║ testing, reconnaissance, and infrastructure analysis.                     ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE
  netrange <start-ip> <end-ip> -o <output-file>
  netrange <start-ip> <end-ip> --output <output-file>

ARGUMENTS
  <start-ip>              First IP address in range (e.g., 192.168.1.0)
  <end-ip>                Last IP address in range (e.g., 192.168.1.255)

OPTIONS
  -o, --output FILE       Output file path (REQUIRED)
  -h, --help             Display this help message
  -v, --version          Show version information

EXAMPLES
  # Generate IPs for a /24 network
  netrange 192.168.1.0 192.168.1.255 -o output.txt

  # Generate IPs for a /16 network  
  netrange 10.0.0.0 10.0.255.255 -o network.txt

  # Generate IPs for a /32 (single host)
  netrange 8.8.8.8 8.8.8.8 -o single.txt

OUTPUT
  One IPv4 address per line, suitable for piping to other tools:
    192.168.1.0
    192.168.1.1
    192.168.1.2
    ...

VALIDATION
  • Validates IP format (XXX.XXX.XXX.XXX)
  • Validates octet range (0-255)
  • Validates range order (start ≤ end)
  • Requires python3 and write permissions

PERFORMANCE
  /24 network (256 IPs)    : < 0.1s
  /16 network (65K IPs)    : ~0.5s
  /8 network (16M IPs)     : ~120s

INTEGRATION
  # With nmap
  nmap -sn -iL <(netrange 10.0.0.0 10.0.0.255 -o /dev/stdout)

  # With curl
  cat ips.txt | xargs -I {} curl -s http://{}

  # With dig (reverse DNS)
  cat ips.txt | xargs -I {} dig +short -x {}

REQUIREMENTS
  • Bash 4.0 or later
  • Python 3.6 or later
  • Write permissions to output directory

LEGAL NOTICE
  ⚠️  Authorized use only. Only expand IP ranges you own or have explicit
      permission to test. Unauthorized scanning may violate laws.

For more information, see README.md or visit the project documentation.
EOF
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

info() { printf '[*] %s\n' "$*"; }
success() { printf '[+] %s\n' "$*"; }
error() { printf '[!] ERROR: %s\n' "$*" >&2; }
die() { error "$@"; exit 1; }

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

# ============================================================================
# MAIN LOGIC
# ============================================================================

# Parse arguments
[[ $# -eq 0 ]] && { show_help; exit 1; }

START_IP=""
END_IP=""
OUTFILE=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -v|--version)
      echo "NetRange v1.0.0"
      exit 0
      ;;
    -o|--output)
      [[ $# -ge 2 ]] || die "Missing filename after '$1'"
      OUTFILE="$2"
      shift 2
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

# Validate arguments
[[ ${#POSITIONAL[@]} -eq 2 ]] || { show_help; exit 1; }

START_IP="${POSITIONAL[0]}"
END_IP="${POSITIONAL[1]}"

[[ -n "$OUTFILE" ]] || die "Output file is required. Use: -o <filename>"

# Validate IPs
validate_ip "$START_IP" || die "Invalid start IP: $START_IP"
validate_ip "$END_IP" || die "Invalid end IP: $END_IP"

# Check dependencies
command -v python3 >/dev/null 2>&1 || die "python3 is required but not installed"

# ============================================================================
# EXECUTION
# ============================================================================

info "Expanding range: $START_IP → $END_IP"

python3 - "$START_IP" "$END_IP" "$OUTFILE" <<'PY'
import ipaddress
import sys
from pathlib import Path

start = ipaddress.IPv4Address(sys.argv[1])
end = ipaddress.IPv4Address(sys.argv[2])
outfile = Path(sys.argv[3])

if int(start) > int(end):
    print("[!] ERROR: Start IP must be less than or equal to end IP", file=sys.stderr)
    sys.exit(1)

count = int(end) - int(start) + 1

try:
    with outfile.open("w", encoding="utf-8") as f:
        for ip_int in range(int(start), int(end) + 1):
            f.write(str(ipaddress.IPv4Address(ip_int)) + "\n")
    success(f"Generated {count:,} IP addresses → {outfile}")
except IOError as e:
    print(f"[!] ERROR: Failed to write output file: {e}", file=sys.stderr)
    sys.exit(1)
PY