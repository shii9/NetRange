# NetRange

<div align="center">

[![Tests](https://github.com/shii9/NetRange/actions/workflows/test.yml/badge.svg)](https://github.com/shii9/NetRange/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash 4.0+](https://img.shields.io/badge/Bash-4.0%2B-brightgreen)](https://www.gnu.org/software/bash/)
[![Python 3.6+](https://img.shields.io/badge/Python-3.6%2B-blue)](https://www.python.org)

**Professional tool for expanding IPv4 address ranges into discrete IP addresses.**

Essential for network reconnaissance, security testing, and infrastructure analysis.

[Installation](#-installation) • [Usage](#-usage) • [Contributing](#-contributing) • [License](#-license)

</div>

---

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
| `netrange: command not found` | Run `bash install.sh` to install, then `source ~/.bashrc` |

## 💡 Use Cases

- **Network Scanning** - Generate IP lists for nmap, masscan, and other scanners
- **Security Testing** - Enumerate targets for vulnerability assessment and penetration testing
- **DNS Reconnaissance** - Bulk reverse DNS lookups to map IP ranges
- **Infrastructure Mapping** - Identify IP ranges for infrastructure documentation
- **Web Scraping** - Generate lists for mass web requests and API testing
- **IT Administration** - Asset discovery and inventory management

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

- ✅ Comprehensive error handling and validation
- ✅ Performance optimized for large ranges
- ✅ Color-coded logging output
- ✅ Integration examples for common tools
- ✅ Extensive documentation and help
- ✅ Continuous integration testing
- ✅ Professional development workflow

---

<div align="center">

**Professional. Focused. Efficient.**

[GitHub](https://github.com/shii9/NetRange) • [Issues](https://github.com/shii9/NetRange/issues) • [Discussions](https://github.com/shii9/NetRange/discussions)

</div>
