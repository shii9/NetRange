# NetRange

Professional tool for expanding IPv4 address ranges into discrete IP addresses. Essential for network reconnaissance, security testing, and infrastructure analysis.

## 🚀 Quick Start

```bash
# Install & verify
bash install.sh

# Expand a network
netrange 192.168.1.0 192.168.1.255 -o output.txt

# View help
netrange --help
```

## 📦 Contents

| File | Purpose |
|------|---------|
| `install.sh` | Installation script |
| `INSTALL.md` | Setup instructions |
| `netrange.sh` | Main tool executable |
| `LICENSE` | MIT License |
| `README.md` | This file |

## 📖 Documentation

### Installation

See [INSTALL.md](INSTALL.md) for:
- System-wide installation
- Local/user installation
- Verification steps
- Troubleshooting

### Usage

#### Basic Usage

```bash
netrange <start-ip> <end-ip> -o <output-file>
```

#### Examples

```bash
# Single /24 network
netrange 192.168.1.0 192.168.1.255 -o subnet.txt

# Larger /16 network
netrange 10.0.0.0 10.0.255.255 -o classb.txt

# Single IP
netrange 8.8.8.8 8.8.8.8 -o single.txt
```

#### With Other Tools

```bash
# Port scanning with nmap
nmap -sn -iL output.txt

# Web testing with curl
cat output.txt | parallel curl -s http://{}

# Reverse DNS with dig
cat output.txt | parallel dig +short -x {}
```

#### Output Format

One IPv4 address per line, perfect for piping:

```
192.168.1.0
192.168.1.1
192.168.1.2
...
192.168.1.255
```

## ⚙️ Requirements

- **Bash** 4.0 or newer
- **Python** 3.6+ with ipaddress module
- Read/write permissions in output directory

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| `Command not found` | Run `bash install.sh` first |
| `python3 not found` | Install Python 3.6+ |
| `Permission denied` | Check write permissions in target directory |
| `Invalid IP error` | Use format: `XXX.XXX.XXX.XXX` |
| `netrange: command not found` | Run `source ~/.bashrc` or install again |

## 💡 Use Cases

- **Network Scanning** - Generate IP lists for nmap, masscan
- **Security Testing** - Enumerate targets for vulnerability assessment
- **DNS Reconnaissance** - Bulk reverse DNS lookups
- **Infrastructure Mapping** - Identify IP ranges for infrastructure
- **Web Scraping** - Generate list for mass web requests

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

---

**Professional. Focused. Efficient.**
