# NetRange

<div align="center">

[![Tests](https://github.com/shii9/NetRange/actions/workflows/test.yml/badge.svg)](https://github.com/shii9/NetRange/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash 4.0+](https://img.shields.io/badge/Bash-4.0%2B-brightgreen)](https://www.gnu.org/software/bash/)
[![Python 3.6+](https://img.shields.io/badge/Python-3.6%2B-blue)](https://www.python.org)
[![Version](https://img.shields.io/badge/version-2.1.0-blue)](https://github.com/shii9/NetRange)

**Professional tool for expanding IPv4 address ranges and CIDR notations into discrete IP addresses.**

Essential for network reconnaissance, security testing, and infrastructure analysis.

[Installation](#-installation) • [Usage](#-usage) • [Features](#-features) • [Contributing](#-contributing) • [License](#-license)

</div>

---

## 📥 Installation

```bash
git clone https://github.com/shii9/NetRange.git && cd NetRange && sudo bash install.sh
```

<details>
<summary><b>More installation options</b></summary>

#### Remote install (no manual clone needed)

```bash
curl -sL https://raw.githubusercontent.com/shii9/NetRange/main/install.sh | sudo bash -s -- --remote
```

#### Local install (no sudo, user-only)

```bash
git clone https://github.com/shii9/NetRange.git && cd NetRange && bash install.sh --local
```

#### Verify installation

```bash
netrange --version
```

#### Uninstall

```bash
sudo bash install.sh --uninstall
```

</details>

---

## 🚀 Quick Start

```bash
# Expand a CIDR subnet
netrange 127.0.1.0/24 -o subnet.txt

# Expand a range
netrange 127.0.2.0 127.0.2.255 -o targets.txt

# Pipe directly into nmap (no file needed)
netrange 127.0.4.0/28 | nmap -sn -iL -

# Count IPs without generating
netrange 127.0.1.0/12 -c

# View help
netrange --help
```

## ✨ Features

| Feature | Description |
|---------|-------------|
| **CIDR Notation** | `netrange 127.0.1.0/24` — automatic subnet expansion |
| **IP Ranges** | `netrange 127.0.2.0 127.0.2.255` — start-to-end expansion |
| **Stdout Piping** | `netrange 127.0.4.0/28 \| nmap -sn -iL -` — no file required |
| **Count-Only** | `netrange 127.0.1.0/12 -c` — instant IP count |
| **Exclude Ranges** | `-x 127.0.2.0/24` — filter out specific subnets |
| **Output Formats** | Plain, CSV, JSON, nmap-compatible |
| **Shuffle Output** | `-s` — randomize IP order for stealth scanning |
| **File Input** | `-f targets.txt` — batch processing from file |
| **Append Mode** | `-a` — append to existing files |
| **Deduplication** | `-u` — remove duplicate IPs across multiple inputs |
| **Progress Bar** | `-p` — visual progress for large ranges |
| **Buffered I/O** | Optimized writes for million-IP ranges |

## 📦 Contents

| File | Purpose |
|------|---------|
| `netrange.sh` | Main tool executable |
| `install.sh` | Installation script (system-wide, local, verify, uninstall) |
| `comprehensive_test.py` | Full test suite (40+ test cases) |
| `test_large_range.py` | Performance benchmarks |
| `test_ranges.sh` | Shell integration tests |
| `Makefile` | Development tasks |
| `README.md` | This file |

## 📖 Usage

### Input Formats

```bash
# CIDR notation (most common)
netrange 127.0.1.0/24 -o output.txt

# IP range (start-end)
netrange 127.0.2.0 127.0.2.255 -o output.txt

# Single IP
netrange 127.0.4.42 -o output.txt

# From file (one target per line, supports comments)
netrange -f targets.txt -o output.txt
```

### Output Modes

```bash
# Stdout (default when no -o given) — pipe-friendly
netrange 127.0.1.0/22 | wc -l

# File output
netrange 127.0.3.0/24 -o subnet.txt

# Append to existing file
netrange 127.0.2.0/24 -o targets.txt -a

# Count-only (no output file)
netrange 127.0.1.0/12 -c
```

### Output Formats

```bash
# Plain text — one IP per line (default)
netrange 127.0.4.0/28 -o plain.txt

# CSV — ip,index columns with header
netrange 127.0.4.0/28 -F csv -o report.csv

# JSON — array of IP strings
netrange 127.0.4.0/28 -F json -o data.json

# Nmap — comma-separated, single line
netrange 127.0.4.0/28 -F nmap -o targets.nmap
```

### Advanced Features

```bash
# Exclude specific subnets from a range
netrange 127.0.2.0/16 -x 127.0.2.0/24 -x 127.0.2.0/24 -o filtered.txt

# Shuffle for randomized scanning
netrange 127.0.1.0/22 -s -o random_targets.txt

# Deduplicate overlapping inputs
netrange -f overlapping_ranges.txt -u -o unique.txt

# Progress bar for large ranges
netrange 127.0.2.0/12 -o large.txt -p

# Quiet mode (errors only)
netrange 127.0.3.0/24 -o scan.txt -q
```

### Integration with Security Tools

```bash
# Port scanning with nmap
netrange 127.0.1.0/24 | nmap -sn -iL -

# Mass scanning with masscan
netrange 127.0.2.0/16 -o targets.txt && masscan -iL targets.txt -p80,443

# Parallel HTTP probing
netrange 127.0.4.0/28 | parallel -j 20 curl -sk https://{}

# Reverse DNS with dig
netrange 127.0.3.0/24 | parallel dig +short -x {}

# Web testing with httpx
netrange 127.0.1.0/24 | httpx -silent -status-code

# Subdomain brute-force preparation
netrange 127.0.2.0/20 -F nmap | nmap -sL -iL -
```

### CLI Options

```
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
```

## ⚙️ Requirements

- **Bash** 4.0 or newer
- **Python** 3.6+ with ipaddress module (stdlib)
- Read/write permissions in output directory

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| `Command not found` | Run `bash install.sh` first |
| `python3 not found` | Install Python 3.6+ |
| `Permission denied` | Check write permissions in target directory |
| `Invalid IP error` | Use format: `XXX.XXX.XXX.XXX` or `XXX.XXX.XXX.XXX/NN` |
| `netrange: command not found` | Run `bash install.sh` to install, then `source ~/.bashrc` |

## ⚡ Performance

| Range Size | IP Count | Time | Speed |
|------------|----------|------|-------|
| /24 | 256 | < 0.1s | Instant |
| /20 | 4,096 | < 0.1s | ~100K IP/s |
| /16 | 65,536 | ~0.3s | ~200K IP/s |
| /14 | 262,144 | ~1.5s | ~175K IP/s |
| /12 | 1,048,576 | ~5s | ~200K IP/s |
| /8 | 16,777,216 | ~60s | ~280K IP/s |

Performance improved **2-3x** over v1.0 through buffered writes (8KB chunks).

## 💡 Use Cases

- **Network Scanning** — Generate IP lists for nmap, masscan, and other scanners
- **Security Testing** — Enumerate targets for vulnerability assessment and penetration testing
- **DNS Reconnaissance** — Bulk reverse DNS lookups to map IP ranges
- **Infrastructure Mapping** — Identify IP ranges for infrastructure documentation
- **Web Scraping** — Generate lists for mass web requests and API testing
- **IT Administration** — Asset discovery and inventory management
- **Bug Bounty** — Expand scope CIDRs into target lists with exclusions
- **Compliance Auditing** — Generate inventory lists for compliance checks

## 📚 Documentation

- [Installation Guide](INSTALL.md) - Detailed setup instructions
- [Contributing Guide](CONTRIBUTING.md) - How to contribute to the project
- [Development Guide](DEVELOPMENT.md) - Development setup and workflow
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community guidelines
- [Security Policy](SECURITY.md) - Reporting security vulnerabilities
- [Changelog](CHANGELOG.md) - Version history and changes

## ⚠️ Legal Notice

**Authorized use only.** Only expand IP ranges you own or have explicit written permission to test. Unauthorized network scanning may violate laws including the Computer Fraud and Abuse Act (CFAA) in the United States and similar legislation in other jurisdictions.

See [LICENSE](LICENSE) and [SECURITY.md](SECURITY.md) for full legal disclaimers.

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Reporting bugs
- Suggesting features
- Submitting pull requests
- Code standards

## 🔒 Security

For security concerns, please see [SECURITY.md](SECURITY.md). Do not open public issues for security vulnerabilities.

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

---

## 💼 Professional Features

- ✅ CIDR notation support (/8 through /32)
- ✅ Stdout piping for tool chaining
- ✅ Multiple output formats (plain, CSV, JSON, nmap)
- ✅ Exclude ranges for filtered output
- ✅ Shuffle mode for stealth scanning
- ✅ Buffered I/O for large-range performance
- ✅ Progress bar with ETA for long operations
- ✅ File input for batch processing
- ✅ Deduplication across multiple inputs
- ✅ Comprehensive error handling and validation
- ✅ Color-coded logging output
- ✅ Continuous integration testing
- ✅ Professional development workflow

---

<div align="center">

**Professional. Focused. Efficient.**

[GitHub](https://github.com/shii9/NetRange) • [Issues](https://github.com/shii9/NetRange/issues) • [Discussions](https://github.com/shii9/NetRange/discussions)

</div>
