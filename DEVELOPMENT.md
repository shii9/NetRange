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

# Run quick smoke tests
make test

# Run full test suite (40+ tests)
make test-full

# Run performance benchmarks
make bench

# Check syntax
make lint

# Clean artifacts
make clean
```

## Project Structure

```
NetRange/
├── netrange.sh              # Main tool (Bash + embedded Python)
├── install.sh               # Installation script
├── comprehensive_test.py    # Full test suite (40+ test cases)
├── test_large_range.py      # Performance benchmarks
├── test_ranges.sh           # Shell integration tests
├── Makefile                 # Development tasks
├── README.md                # User documentation
├── INSTALL.md               # Installation guide
├── CHANGELOG.md             # Version history
├── CONTRIBUTING.md          # Contributing guide
├── CODE_OF_CONDUCT.md       # Community standards
├── SECURITY.md              # Security policy
├── LICENSE                  # MIT License
├── .gitignore               # Git ignore rules
├── .gitattributes           # Git attributes
├── .editorconfig            # Editor config
└── .github/
    ├── workflows/
    │   └── test.yml         # CI/CD pipeline
    └── ISSUE_TEMPLATE/
        ├── bug_report.md
        └── feature_request.md
```

## Architecture

NetRange uses a **hybrid Bash + Python** architecture:

1. **Bash shell** (`netrange.sh`) handles:
   - Argument parsing and validation
   - IP format validation via regex
   - Dependency checking
   - User-facing logging and help

2. **Embedded Python** (heredoc in `netrange.sh`) handles:
   - CIDR and range expansion via `ipaddress` stdlib
   - IP exclusion filtering
   - Buffered file I/O (8KB chunks)
   - Output formatting (plain, CSV, JSON, nmap)
   - Shuffle and deduplication
   - Progress bar rendering

This architecture lets us use Bash for clean CLI UX and Python for correct, fast IP arithmetic.

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

### Quick Smoke Tests

```bash
make test
```

### Full Test Suite (40+ test cases)

```bash
make test-full
# or
python3 comprehensive_test.py
```

Covers: CIDR, ranges, stdout piping, count-only, CSV/JSON/nmap formats,
exclude ranges, shuffle, append, file input, unique mode, error handling,
and large-range performance.

### Shell Integration Tests

```bash
bash test_ranges.sh
```

### Performance Benchmarks

```bash
make bench
# or
python3 test_large_range.py
```

Tests /24 through /12 ranges and reports IPs/sec throughput.

### Manual Testing

```bash
# Test CIDR notation
bash netrange.sh 127.0.1.0/24 -o /tmp/test.txt
wc -l /tmp/test.txt  # Should be 256

# Test stdout piping
bash netrange.sh 127.0.3.0/28 -q | wc -l  # Should be 16

# Test exclude
bash netrange.sh 127.0.1.0/24 -x 127.0.1.0/28 -q | wc -l  # Should be 240

# Test count-only
bash netrange.sh 127.0.1.0/24 -c -q  # Should be 1,048,576

# Test error handling
bash netrange.sh 127.0.5.0 127.0.5.0 -o /tmp/test.txt  # Should fail
bash netrange.sh invalid -o /tmp/test.txt  # Should fail
```

## Continuous Integration

GitHub Actions runs tests on:
- Ubuntu (latest)
- macOS (latest)
- Python 3.6, 3.9, 3.10, 3.11

All tests must pass before merging.

## Release Process

1. Update version in `netrange.sh` (`VERSION="x.y.z"`)
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
