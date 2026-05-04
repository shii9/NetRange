# Contributing to NetRange

Thank you for considering contributing to NetRange! We appreciate all contributions that help improve this tool.

## Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please be respectful and professional in all interactions.

## How to Contribute

### Reporting Bugs

Before creating a bug report, please check the [issues](https://github.com/shii9/NetRange/issues) to ensure it hasn't been reported already.

When creating a bug report, include:
- **Clear description** of what the bug is
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Your environment** (OS, Bash version, Python version)
- **Any additional context** that might help

### Suggesting Enhancements

Enhancement suggestions are welcomed! Please provide:
- **Clear description** of the enhancement
- **Use cases** and motivation
- **Possible implementation** if you have ideas

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit your changes with clear messages (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request with:
   - Clear description of changes
   - Reference to related issues
   - Any breaking changes noted

## Code Style Guidelines

### Shell Scripts
- Use Bash 4.0+ syntax
- Follow the existing code style
- Use 2-space indentation
- Include comments for complex logic
- Use `set -euo pipefail` for safety
- Test your changes on multiple systems (Linux, macOS, WSL)

### Python Code
- Follow PEP 8 style guide
- Use 4-space indentation
- Include docstrings for functions
- Use type hints where applicable

### Documentation
- Use clear, professional language
- Include practical examples
- Keep formatting consistent
- Update README and INSTALL.md as needed

## Testing

Before submitting a pull request:
1. Test on Linux (preferred)
2. Test on macOS if possible
3. Test on Windows (WSL2)
4. Verify both system-wide and local installation modes
5. Test edge cases and error conditions

### Manual Testing Checklist

```bash
# Basic functionality
netrange 127.0.5.0 127.0.5.0 -o test.txt

# CIDR notation
netrange 127.0.5.0/24 -o subnet.txt

# Edge cases
netrange 127.0.1.1 127.0.1.1 -o single.txt     # Single IP
netrange 127.0.5.0 127.0.5.0 -o range.txt # Full /24

# Stdout piping
netrange 127.0.2.0/28 -q | wc -l

# Error handling
netrange 127.0.5.0 127.0.5.0 -o invalid.txt # Reverse range
netrange 256.1.1.1 256.1.1.10 -o badip.txt        # Invalid octets
```

## Commit Message Guidelines

- Use clear, concise commit messages
- Start with a verb (Add, Fix, Update, etc.)
- Reference issues when applicable: `Fix #123`
- Use present tense: "Add feature" not "Added feature"

## Version Strategy

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## Documentation

- Update README.md for user-facing changes
- Update INSTALL.md for installation-related changes
- Add entries to CHANGELOG.md for all changes
- Include examples for new features

## Questions?

Feel free to open an issue with your questions or start a discussion in the repository.

## License

By contributing to NetRange, you agree that your contributions will be licensed under the MIT License.
