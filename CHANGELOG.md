# Changelog

All notable changes to NetRange will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
