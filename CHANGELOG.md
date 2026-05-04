# Changelog

All notable changes to NetRange will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.1.0.html).

## [2.0.0] - 2026-05-03

### Added
- **CIDR notation support** — expand subnets like `172.16.10.0/24` directly
- **Stdout piping** — output to stdout by default when no `-o` is given
- **Count-only mode** (`-c`) — quickly count IPs without generating files
- **Exclude ranges** (`-x`) — filter out specific CIDRs or ranges from output
- **Multiple output formats** (`-F`) — plain, CSV, JSON, and nmap-compatible
- **Shuffle mode** (`-s`) — randomize output order for stealth scanning
- **File input** (`-f`) — read targets from a file with comment support
- **Append mode** (`-a`) — append to existing output files
- **Deduplication** (`-u`) — remove duplicate IPs across multiple inputs
- **Progress bar** (`-p`) — visual progress with ETA for large ranges
- **Quiet mode** (`-q`) — suppress all info messages (errors only)
- **Buffered writes** — 8KB write chunks for 2-3x performance improvement
- **BrokenPipe handling** — graceful exit when piped to `head`, `grep`, etc.

### Changed
- Version bumped to 2.0.0
- Output defaults to stdout instead of requiring `-o` flag
- Python engine rewritten with buffered I/O and generator-based streaming
- Help text expanded with all new features and examples
- Test suite expanded to 40+ test cases covering all features
- Makefile updated with `test-full` and `bench` targets
- README completely rewritten with feature table and examples

### Fixed
- Fixed self-referencing symlink bug in `install.sh`
- Fixed installer sanity test to use new syntax

### Performance
- /16 network (65K IPs): ~0.3s (was ~0.5s)
- /12 network (1M IPs): ~5s (new benchmark)
- /8 network (16M IPs): ~60s (was ~120s)

---

## [1.0.0] - 2024-01-15

### Added
- Initial release of NetRange
- IPv4 range expansion to individual IP addresses
- Batch IP generation for security testing and reconnaissance
- Support for piping output to other tools (nmap, curl, dig, etc.)
- Installation script with system-wide and local installation modes
- Comprehensive documentation and usage examples
- Input validation for IP addresses and ranges
- Python 3.6+ support with ipaddress module
- Bash 4.0+ compatibility

### Features
- Fast IP range expansion with optimized Python backend
- Flexible output options with file writing
- Extensive CLI help and documentation
- Integration examples for network security tools
- Color-coded logging output
- Error handling and validation

### Documentation
- README.md with quick start guide
- INSTALL.md with installation instructions
- LICENSE with MIT license and legal notices
- Comprehensive help output via `netrange --help`

### Security
- Legal notice about authorized use only
- Warnings against unauthorized network scanning
- Proper error handling and input validation

---

## Format Guidelines

- Use semantic versioning (MAJOR.MINOR.PATCH)
- Added for new features
- Changed for changes in existing functionality
- Deprecated for soon-to-be removed features
- Removed for now removed features
- Fixed for any bug fixes
- Security for vulnerability fixes
