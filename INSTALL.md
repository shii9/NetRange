# Installation Guide

Complete setup instructions for NetRange.

## 🚀 Quick Install

```bash
bash install.sh
```

Available system-wide immediately.

## 📋 Requirements

- **Bash:** 4.0+
- **Python:** 3.6+
- **OS:** Linux, macOS, Windows (WSL)

## ✅ Verification

```bash
# Verify installation
bash install.sh --verify

# Show help
ip-expander --help
```

## 🔧 Installation Modes

### System-Wide (Default)
```bash
bash install.sh
```
- Installs to `/usr/local/bin/netrange`
- Available to all users
- Requires sudo

### Local Installation (User Only)
```bash
bash install.sh --local
```
- Installs to `~/.local/bin/netrange`
- No sudo required
- For current user only

### Manual Installation
```bash
# Copy and make executable
cp netrange.sh /usr/local/bin/netrange
chmod +x /usr/local/bin/netrange

# Verify
netrange --help
```

## 🐧 Platform Setup

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install bash python3
bash install.sh
```

### macOS
```bash
brew install python3
bash install.sh
```

### Windows (WSL)
```bash
# Install WSL first
wsl --install

# In WSL terminal
sudo apt-get update
sudo apt-get install bash python3
bash install.sh
```

## 🔍 Troubleshooting

**"netrange: command not found"**
```bash
# Option 1: Reload shell
source ~/.bashrc

# Option 2: Use local install
bash install.sh --local

# Option 3: Use full path
/usr/local/bin/netrange --help
```

**"python3: command not found"**
- Ubuntu/Debian: `sudo apt-get install python3`
- macOS: `brew install python3`

**"Permission denied"**
- Use local installation: `bash install.sh --local`
- Or use sudo: `sudo bash install.sh`

## 🗑️ Uninstall

```bash
bash install.sh --uninstall
```

## ✨ After Installation

```bash
# View help
netrange --help

# Test with small range
netrange 127.0.5.0 127.0.5.0 -o test.txt

# Use with other tools
nmap -sn -iL test.txt
```

## 📚 Next Steps

1. Read `README.md`
2. Run `ip-expander --help`
3. Check `LICENSE` for legal information

---

**Version:** 1.0.0 | **License:** MIT
