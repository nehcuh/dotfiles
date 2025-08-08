#!/bin/bash
# One-line remote installer for dotfiles (Linux-optimized)
# Usage: curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install-linux.sh | bash

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
NON_INTERACTIVE="${NON_INTERACTIVE:-false}"  # Set to true to skip confirmation prompts
DEV_ENV="${DEV_ENV:-false}"  # Set to true to setup development environments
DEV_ALL="${DEV_ALL:-false}"  # Set to true to setup all development environments

echo "=========================================="
echo "    Linux Dotfiles Remote Installer      "
echo "=========================================="
echo

log_info "🐧 This installer is optimized for Linux systems"
log_info "Repository: $DOTFILES_REPO"
log_info "Install directory: $DOTFILES_DIR"
log_info "Branch: linux (for Linux-specific optimizations)"

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    log_warning "This installer is designed for Linux systems."
    log_warning "Detected OS: $OSTYPE"
    log_info "For macOS, use: curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash"
    
    if [ "$NON_INTERACTIVE" != "true" ]; then
        log_info "Continue anyway? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled."
            exit 0
        fi
    else
        log_warning "Non-interactive mode: continuing on non-Linux system"
    fi
fi

# Check prerequisites
log_info "Checking prerequisites..."

if ! command -v git &> /dev/null; then
    log_error "Git is not installed. Please install Git first:"
    log_info "  • Ubuntu/Debian: sudo apt install git"
    log_info "  • Fedora: sudo dnf install git"
    log_info "  • Arch: sudo pacman -S git"
    exit 1
fi

if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    log_error "Neither curl nor wget is available. Please install one of them:"
    log_info "  • Ubuntu/Debian: sudo apt install curl"
    log_info "  • Fedora: sudo dnf install curl"
    log_info "  • Arch: sudo pacman -S curl"
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

# Switch to Linux branch
log_info "Switching to Linux branch for Linux-specific optimizations..."
if git checkout linux 2>/dev/null; then
    log_success "✅ Switched to Linux branch"
    log_info "Linux branch provides:"
    log_info "  • Homebrew for Linux (CLI tools only)"
    log_info "  • Native package manager integration (apt/dnf/pacman)"
    log_info "  • Official application installations (VS Code, Zed, Chrome)"
    log_info "  • Linux-specific configurations and optimizations"
else
    log_error "❌ Linux branch not available"
    log_error "Please ensure the repository has a 'linux' branch with Linux support"
    exit 1
fi

# Make install script executable
chmod +x install.sh

# Run the installation
log_info "Running Linux installation..."

# Show Linux-specific installation requirements
log_warning "Linux Installation Requirements:"
log_info "• Administrator privileges will be required for:"
log_info "  - Installing system packages via apt/dnf/pacman"
log_info "  - Installing Homebrew for Linux"
log_info "  - Installing VS Code, Zed, Chrome via official repositories"
log_info "• Supported distributions: Ubuntu, Debian, Fedora, Arch, Manjaro"
log_info "• The installation will backup any conflicting files automatically"
echo

if [ "$NON_INTERACTIVE" != "true" ]; then
    log_info "🚀 Ready to install Linux-optimized dotfiles!"
    log_info "Press Ctrl+C to cancel, or Enter to continue..."
    read -r
else
    log_info "Non-interactive mode: proceeding automatically..."
fi

# For piped input, ensure non-interactive mode
if [ ! -t 0 ] && [ "$NON_INTERACTIVE" != "true" ]; then
    log_warning "Detected piped input - enabling non-interactive mode"
    export NON_INTERACTIVE="true"
fi

# Build install command with appropriate options
install_cmd="./install.sh"

# Add packages if specified
if [ -n "$INSTALL_PACKAGES" ]; then
    install_cmd="$install_cmd $INSTALL_PACKAGES"
fi

# Add development environment options
if [ "$DEV_ALL" = "true" ]; then
    install_cmd="$install_cmd --dev-all"
elif [ "$DEV_ENV" = "true" ]; then
    install_cmd="$install_cmd --dev-env"
fi

# Set environment variables for the install script
export NON_INTERACTIVE="$NON_INTERACTIVE"

# Run installation
log_info "Running installation command: $install_cmd"
eval "$install_cmd"

echo
log_success "🎉 Linux dotfiles installation completed!"
log_info "Dotfiles are now installed in: $DOTFILES_DIR"
log_info "Branch: linux (Linux-optimized)"
log_info ""
log_info "🔄 To apply changes:"
log_info "  source ~/.zshrc"
log_info "  # OR restart your terminal"
log_info ""
log_info "📚 For documentation:"
log_info "  cat $DOTFILES_DIR/README-Linux.md"
echo
echo "🛠️  To customize your installation:"
echo "  cd $DOTFILES_DIR"
echo "  ./install.sh --help                    # Show available packages"
echo "  ./scripts/setup-linux-packages.sh     # Re-run Linux package installation"
echo "  make help                              # Show all available commands"
echo ""
log_success "Enjoy your Linux-optimized development environment! 🐧"
