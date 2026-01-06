#!/bin/bash
# One-line remote installer for dotfiles
# Usage: curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/nehcuh/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
INSTALL_PACKAGES="${INSTALL_PACKAGES:-}"  # Empty means default packages
DOTFILES_NON_INTERACTIVE="${DOTFILES_NON_INTERACTIVE:-false}"  # Set to true to skip confirmation prompts
DOTFILES_SKIP_BREWFILE="${DOTFILES_SKIP_BREWFILE:-false}"  # Set to true to skip Brewfile installation
USE_LINUX_BRANCH="${USE_LINUX_BRANCH:-false}"  # Set to true to use the Linux branch

echo "========================================"
echo "      Remote Dotfiles Installer        "
echo "========================================"
echo

log_info "Repository: $DOTFILES_REPO"
log_info "Install directory: $DOTFILES_DIR"

# Check prerequisites
log_info "Checking prerequisites..."

if ! command -v git &> /dev/null; then
    log_error "Git is not installed. Please install Git first."
    exit 1
fi

if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    log_error "Neither curl nor wget is available. Please install one of them."
    exit 1
fi

log_success "Prerequisites check passed"

# Backup existing dotfiles directory if it exists
if [ -d "$DOTFILES_DIR" ]; then
    backup_dir="${DOTFILES_DIR}.backup.$(date +%Y%m%d-%H%M%S)"
    log_warning "Dotfiles directory already exists. Backing up to $backup_dir"
    mv "$DOTFILES_DIR" "$backup_dir"
fi

# Clone the repository
log_info "Cloning dotfiles repository..."
if ! git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
    log_error "Failed to clone repository"
    exit 1
fi

log_success "Repository cloned successfully"

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# Detect OS and potentially switch to Linux branch
if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ "$USE_LINUX_BRANCH" != "false" ]]; then
    log_info "Linux system detected, switching to Linux branch..."
    if git checkout linux 2>/dev/null; then
        log_success "Switched to Linux branch for better Linux support"
    else
        log_warning "Linux branch not available, using main branch"
    fi
elif [[ "$USE_LINUX_BRANCH" == "true" ]]; then
    log_info "Forcing Linux branch usage..."
    if git checkout linux 2>/dev/null; then
        log_success "Switched to Linux branch"
    else
        log_error "Linux branch not available"
        exit 1
    fi
fi

# Make install script executable
chmod +x scripts/install.sh

# Run the installation
log_info "Running installation..."

# Show installation requirements
log_warning "Installation Requirements:"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    log_info "• On Linux: Administrator privileges may be required for package installation"
    log_info "• Homebrew for Linux will be automatically installed if not present"
    log_info "• Native package managers (apt, dnf, pacman) will be used for GUI apps"
else
    log_info "• On macOS: Administrator privileges may be required"
    log_info "• Homebrew will be automatically installed if not present"
fi
log_info "• You may be prompted for your password during installation"
log_info "• Conflicts: install aborts by default; use DOTFILES_CONFLICT_OVERWRITE=true to backup and overwrite conflicts"
echo

if [ "$DOTFILES_NON_INTERACTIVE" != "true" ]; then
    log_info "Press Ctrl+C to cancel, or any key to continue..."
    read -n 1 -s
    echo
else
    log_info "Non-interactive mode: proceeding automatically..."
fi

# When running through pipe (curl | bash), stdin might not be available for prompts
if [ ! -t 0 ] && [ "$DOTFILES_NON_INTERACTIVE" != "true" ]; then
    log_warning "Detected piped input - setting non-interactive mode for prompts"
    export DOTFILES_NON_INTERACTIVE="true"
fi

# Build install command with appropriate options
install_cmd="./scripts/install.sh"

# Add packages if specified
if [ -n "$INSTALL_PACKAGES" ]; then
    install_cmd="$install_cmd $INSTALL_PACKAGES"
fi

# Set environment variables for the install script
export DOTFILES_NON_INTERACTIVE="${DOTFILES_NON_INTERACTIVE}"
export DOTFILES_SKIP_BREWFILE="${DOTFILES_SKIP_BREWFILE}"
export DOTFILES_CONFLICT_OVERWRITE="${DOTFILES_CONFLICT_OVERWRITE:-false}"
export DOTFILES_BREWFILE_INSTALL="${DOTFILES_BREWFILE_INSTALL:-false}"
export DOTFILES_SET_DEFAULT_SHELL="${DOTFILES_SET_DEFAULT_SHELL:-false}"
export DOTFILES_SKIP_MIRROR_DETECT="${DOTFILES_SKIP_MIRROR_DETECT:-}"
export DOTFILES_FORCE_CHINA_MIRROR="${DOTFILES_FORCE_CHINA_MIRROR:-false}"
export DOTFILES_FORCE_NO_MIRROR="${DOTFILES_FORCE_NO_MIRROR:-false}"
export DOTFILES_HOMEBREW_USE_CHINA_INSTALLER="${DOTFILES_HOMEBREW_USE_CHINA_INSTALLER:-false}"
export DOTFILES_HOMEBREW_TAP_CHINA_MIRRORS="${DOTFILES_HOMEBREW_TAP_CHINA_MIRRORS:-false}"

# Run installation
log_info "Running installation command: $install_cmd"
eval "$install_cmd"

echo
log_success "Remote installation completed!"
log_info "Dotfiles are now installed in: $DOTFILES_DIR"
log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
echo
echo "To customize your installation:"
echo "  cd $DOTFILES_DIR"
echo "  ./scripts/install.sh --help      # Show available packages"
echo "  make help               # Show all available commands"
