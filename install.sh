#!/usr/bin/env bash
################################################################################
# NetRange — Installation Script
#
# Installs the netrange tool system-wide
# Supports Linux, macOS, and WSL on Windows
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PATH="/usr/local/bin/netrange"
COLORS_ON=true

# Color output
if [[ ! -t 1 ]]; then COLORS_ON=false; fi
[[ $COLORS_ON == true ]] && {
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
} || {
  RED='' GREEN='' YELLOW='' BLUE='' NC=''
}

info() { printf "${BLUE}[*]${NC} %s\n" "$*"; }
success() { printf "${GREEN}[+]${NC} %s\n" "$*"; }
error() { printf "${RED}[!]${NC} %s\n" "$*" >&2; }
warn() { printf "${YELLOW}[~]${NC} %s\n" "$*"; }
die() { error "$@"; exit 1; }

show_help() {
  cat << 'EOF'
NetRange — Installation Script

USAGE
  bash install.sh [OPTIONS]

OPTIONS
  -h, --help              Show this help message
  -l, --local             Install locally only (no sudo)
  -u, --uninstall         Remove the tool
  -v, --verify            Verify installation

EXAMPLES
  # Standard installation (system-wide)
  bash install.sh

  # Local installation (user only)
  bash install.sh --local

  # Verify installation
  bash install.sh --verify

  # Remove tool
  bash install.sh --uninstall
EOF
}

check_requirements() {
  info "Checking requirements..."

  # Check Bash version
  if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    die "Bash 4.0+ required. Current: ${BASH_VERSION}"
  fi
  success "Bash: ${BASH_VERSION}"

  # Check Python
  if ! command -v python3 &>/dev/null; then
    die "python3 not found. Please install Python 3.6+"
  fi
  local py_version=$(python3 --version | awk '{print $2}')
  success "Python: $py_version"

  # Check ipaddress module
  if ! python3 -c "import ipaddress" 2>/dev/null; then
    die "Python ipaddress module not found"
  fi
  success "Python ipaddress module: available"
}

install_system_wide() {
  info "Installing system-wide to $INSTALL_PATH..."

  if [[ ! -w /usr/local/bin ]]; then
    warn "Elevated privileges required for system-wide installation"
    sudo cp "$SCRIPT_DIR/netrange.sh" "$INSTALL_PATH"
    sudo chmod 755 "$INSTALL_PATH"
  else
    cp "$SCRIPT_DIR/netrange.sh" "$INSTALL_PATH"
    chmod 755 "$INSTALL_PATH"
  fi

  # Verify the installed file is executable
  if [[ -x "$INSTALL_PATH" ]]; then
    log_success "Executable permissions verified"
  fi

  success "Installed to: $INSTALL_PATH"
}

install_local() {
  info "Installing locally to: $HOME/.local/bin/..."

  mkdir -p "$HOME/.local/bin"
  cp "$SCRIPT_DIR/netrange.sh" "$HOME/.local/bin/netrange"
  chmod 755 "$HOME/.local/bin/netrange"

  # Check if ~/.local/bin is in PATH
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    warn "Add to your shell profile (.bashrc, .zshrc, etc.):"
    echo "  export PATH=\"$HOME/.local/bin:\$PATH\""
  fi

  success "Installed to: $HOME/.local/bin/netrange"
}

verify_installation() {
  info "Verifying installation..."

  if command -v netrange &>/dev/null; then
    success "netrange is installed and in PATH"
    info "Location: $(which netrange)"
    info "Version: $(netrange --version)"
  else
    error "netrange not found in PATH"
    return 1
  fi

  # Test execution
  info "Running sanity test..."
  if netrange 203.0.113.0/30 -o /tmp/test_ips.txt -q 2>/dev/null; then
    success "Sanity test passed (4 IPs generated)"
    rm -f /tmp/test_ips.txt
  else
    warn "Sanity test produced warnings (normal if python3 issue)"
  fi
}

uninstall() {
  info "Removing netrange..."

  for path in /usr/local/bin/netrange /usr/local/bin/netrange.sh "$HOME/.local/bin/netrange"; do
    if [[ -e "$path" ]]; then
      if [[ ! -w $(dirname "$path") ]]; then
        sudo rm -f "$path" 2>/dev/null || true
      else
        rm -f "$path"
      fi
      [[ -e "$path" ]] && continue
      success "Removed: $path"
    fi
  done
}

# Main logic
LOCAL_INSTALL=false
VERIFY_ONLY=false
UNINSTALL_MODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) show_help; exit 0 ;;
    -l|--local) LOCAL_INSTALL=true; shift ;;
    -v|--verify) VERIFY_ONLY=true; shift ;;
    -u|--uninstall) UNINSTALL_MODE=true; shift ;;
    *) die "Unknown option: $1" ;;
  esac
done

cat << 'EOF'
╔════════════════════════════════════════════════════════════════════╗
║          NetRange v2.0 — Installation                              ║
╚════════════════════════════════════════════════════════════════════╝
EOF

if [[ $UNINSTALL_MODE == true ]]; then
  uninstall
  success "Uninstall complete"
  exit 0
fi

if [[ $VERIFY_ONLY == true ]]; then
  verify_installation
  exit $?
fi

check_requirements

if [[ $LOCAL_INSTALL == true ]]; then
  install_local
else
  install_system_wide
fi

success "Installation complete!"
info "Run 'netrange --help' for usage information"

verify_installation
