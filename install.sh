#!/usr/bin/env bash
################################################################################
# NetRange — Installation Script
#
# One-liner install:
#   git clone https://github.com/shii9/NetRange.git && cd NetRange && sudo bash install.sh
#
# Supports Linux, macOS, and WSL on Windows
################################################################################

set -euo pipefail

REPO_URL="https://github.com/shii9/NetRange.git"
INSTALL_PATH="/usr/local/bin/netrange"
COLORS_ON=true

# Color output
if [[ ! -t 1 ]]; then COLORS_ON=false; fi
[[ $COLORS_ON == true ]] && {
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  NC='\033[0m'
} || {
  RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
}

info()    { printf "${BLUE}[*]${NC} %s\n" "$*"; }
success() { printf "${GREEN}[+]${NC} %s\n" "$*"; }
error()   { printf "${RED}[!]${NC} %s\n" "$*" >&2; }
warn()    { printf "${YELLOW}[~]${NC} %s\n" "$*"; }
die()     { error "$@"; exit 1; }

show_help() {
  cat << 'EOF'
NetRange — Installation Script

USAGE
  bash install.sh [OPTIONS]

QUICK INSTALL (one-liner)
  git clone https://github.com/shii9/NetRange.git && cd NetRange && sudo bash install.sh

OPTIONS
  -h, --help              Show this help message
  -l, --local             Install locally only (no sudo needed)
  -r, --remote            Clone from GitHub and install (all-in-one)
  -u, --uninstall         Remove the tool
  -v, --verify            Verify installation

EXAMPLES
  # One-liner from GitHub
  git clone https://github.com/shii9/NetRange.git && cd NetRange && sudo bash install.sh

  # Remote install (auto-clones to /tmp)
  curl -sL https://raw.githubusercontent.com/shii9/NetRange/main/install.sh | sudo bash -s -- --remote

  # Standard installation (from cloned repo)
  sudo bash install.sh

  # Local installation (user only, no sudo)
  bash install.sh --local

  # Verify installation
  bash install.sh --verify

  # Remove tool
  sudo bash install.sh --uninstall
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

install_remote() {
  info "Remote install — cloning from GitHub..."

  # Check git
  command -v git &>/dev/null || die "git is required for remote install"

  local tmp_dir
  tmp_dir=$(mktemp -d)
  trap "rm -rf '$tmp_dir'" EXIT

  git clone --depth 1 "$REPO_URL" "$tmp_dir/NetRange" 2>/dev/null || die "Failed to clone $REPO_URL"
  success "Cloned repository"

  # Install from cloned directory
  SCRIPT_DIR="$tmp_dir/NetRange"

  if [[ $LOCAL_INSTALL == true ]]; then
    install_local
  else
    install_system_wide
  fi
}

install_system_wide() {
  local source_file="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}/netrange.sh"

  [[ -f "$source_file" ]] || die "netrange.sh not found at $source_file"

  info "Installing system-wide to $INSTALL_PATH..."

  if [[ ! -w /usr/local/bin ]]; then
    warn "Elevated privileges required for system-wide installation"
    sudo cp "$source_file" "$INSTALL_PATH"
    sudo chmod 755 "$INSTALL_PATH"
  else
    cp "$source_file" "$INSTALL_PATH"
    chmod 755 "$INSTALL_PATH"
  fi

  # Verify the installed file is executable
  if [[ -x "$INSTALL_PATH" ]]; then
    success "Executable permissions verified"
  fi

  success "Installed to: $INSTALL_PATH"
}

install_local() {
  local source_file="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}/netrange.sh"

  [[ -f "$source_file" ]] || die "netrange.sh not found at $source_file"

  info "Installing locally to: $HOME/.local/bin/..."

  mkdir -p "$HOME/.local/bin"
  cp "$source_file" "$HOME/.local/bin/netrange"
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
  if netrange 127.0.4.0/30 -o /tmp/test_ips.txt -q; then
    local count
    count=$(wc -l < /tmp/test_ips.txt)
    success "Sanity test passed ($count IPs generated)"
    rm -f /tmp/test_ips.txt
  else
    warn "Sanity test produced warnings (normal if python3 issue)"
  fi
}

uninstall() {
  info "Removing netrange..."

  for path in /usr/local/bin/netrange "$HOME/.local/bin/netrange"; do
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

# ============================================================================
# MAIN
# ============================================================================

LOCAL_INSTALL=false
VERIFY_ONLY=false
UNINSTALL_MODE=false
REMOTE_INSTALL=false
SCRIPT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) show_help; exit 0 ;;
    -l|--local) LOCAL_INSTALL=true; shift ;;
    -r|--remote) REMOTE_INSTALL=true; shift ;;
    -v|--verify) VERIFY_ONLY=true; shift ;;
    -u|--uninstall) UNINSTALL_MODE=true; shift ;;
    *) die "Unknown option: $1" ;;
  esac
done

printf "${CYAN}╔════════════════════════════════════════════════════════════════════╗\n"
printf "║          ${BOLD}NetRange v2.1${NC}${CYAN} — Installation                              ║\n"
printf "╚════════════════════════════════════════════════════════════════════╝${NC}\n"

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

if [[ $REMOTE_INSTALL == true ]]; then
  install_remote
elif [[ $LOCAL_INSTALL == true ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  install_local
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  install_system_wide
fi

success "Installation complete!"
info "Run 'netrange --help' for usage information"

verify_installation
