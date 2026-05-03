# Development

For developers interested in contributing to NetRange.

## Setting Up Development Environment

### Prerequisites
- Bash 4.0+
- Python 3.6+
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/shii9/NetRange.git
cd NetRange

# Install locally for testing
bash install.sh --local

# Verify installation
netrange --version
```

## Development Tasks

### Using Make

```bash
# Show available tasks
make help

# Run tests
make test

# Check syntax
make lint

# Clean artifacts
make clean
```

### Manual Testing

```bash
# Test with different range sizes
bash netrange.sh 0.0.0.0 0.0.0.255 -o /tmp/test_256.txt
bash netrange.sh 10.0.0.0 10.0.255.255 -o /tmp/test_65k.txt

# Test error handling
bash netrange.sh invalid invalid -o /tmp/test.txt  # Should fail
bash netrange.sh 192.168.1.255 192.168.1.0 -o /tmp/test.txt  # Should fail

# Test piping
bash netrange.sh 192.168.1.0 192.168.1.10 -o /tmp/ips.txt
cat /tmp/ips.txt | wc -l  # Should be 11
```

## Project Structure

```
NetRange/
├── netrange.sh           # Main tool
├── install.sh            # Installation script
├── README.md             # User documentation
├── INSTALL.md            # Installation guide
├── CHANGELOG.md          # Version history
├── CONTRIBUTING.md       # Contributing guide
├── CODE_OF_CONDUCT.md    # Community standards
├── SECURITY.md           # Security policy
├── LICENSE               # MIT License
├── Makefile              # Development tasks
├── .gitignore            # Git ignore rules
├── .gitattributes        # Git attributes
├── .editorconfig         # Editor config
└── .github/
    ├── workflows/
    │   └── test.yml      # CI/CD pipeline
    └── ISSUE_TEMPLATE/
        ├── bug_report.md
        └── feature_request.md
```

## Coding Standards

### Shell Scripts
- Use `set -euo pipefail` for safety
- Follow existing code style (2-space indentation)
- Include helpful comments
- Test on multiple systems

### Python Code
- Follow PEP 8
- Use type hints where applicable
- Keep it simple and maintainable

### Documentation
- Use clear, professional language
- Include practical examples
- Keep formatting consistent

## Testing

Before submitting a pull request:

1. **Syntax check**
   ```bash
   bash -n netrange.sh
   bash -n install.sh
   ```

2. **Functional testing**
   ```bash
   make test
   ```

3. **Manual edge cases**
   - Single IP ranges
   - Large ranges (test performance)
   - Invalid inputs
   - Error conditions

4. **Installation testing**
   ```bash
   # System-wide
   bash install.sh
   netrange --version
   
   # Local
   bash install.sh --uninstall
   bash install.sh --local
   ~/.local/bin/netrange --version
   ```

## Continuous Integration

GitHub Actions runs tests on:
- Ubuntu (latest)
- macOS (latest)
- Python 3.6, 3.9, 3.10, 3.11

All tests must pass before merging.

## Release Process

1. Update version in `netrange.sh` (`-v|--version`)
2. Update `CHANGELOG.md` with changes
3. Update `README.md` if needed
4. Commit with message: `Release v1.x.x`
5. Tag: `git tag -a v1.x.x -m "Release version 1.x.x"`
6. Push: `git push origin main --tags`

## Need Help?

- Check [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines
- Read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community standards
- Open an issue on GitHub
- See [SECURITY.md](SECURITY.md) for security matters
