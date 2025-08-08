#!/bin/bash

# Unified Dotfiles One-Line Installer
# Works on both macOS and Linux with intelligent system detection
# Usage: curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print functions
print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "=================================================="
    echo "🏠 Dotfiles - Unified Cross-Platform Installer"
    echo "=================================================="
    echo -e "${NC}"
    echo -e "${BLUE}Intelligent setup for macOS and Linux${NC}"
    echo
}

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
DEFAULT_REPO="${DOTFILES_REPO:-https://github.com/nehcuh/dotfiles.git}"
DEFAULT_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DEFAULT_BRANCH="${DOTFILES_BRANCH:-main}"

# Environment variables for customization
NON_INTERACTIVE="${NON_INTERACTIVE:-false}"
SKIP_BREWFILE="${SKIP_BREWFILE:-false}"
SKIP_FONTS="${SKIP_FONTS:-false}"
DEV_ENV="${DEV_ENV:-false}"
DEV_ALL="${DEV_ALL:-false}"
INSTALL_PACKAGES="${INSTALL_PACKAGES:-}"

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        print_info "Detected: Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_info "Detected: macOS"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Check for required dependencies
check_dependencies() {
    print_info "Checking system dependencies..."
    
    # Check for git
    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed"
        
        if [[ "$OS" == "linux" ]]; then
            print_info "Installing Git..."
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y git
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y git
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm git
            elif command -v zypper &> /dev/null; then
                sudo zypper install -y git
            else
                print_error "Could not install Git automatically. Please install Git manually."
                exit 1
            fi
        elif [[ "$OS" == "macos" ]]; then
            print_info "Installing Xcode Command Line Tools (includes Git)..."
            xcode-select --install
            print_warning "Please complete the Xcode installation and run this script again."
            exit 1
        fi
    fi
    
    # Check for curl (should be available on most systems)
    if ! command -v curl &> /dev/null; then
        print_warning "curl not found, but proceeding as git is available"
    fi
    
    print_success "Dependencies check completed"
}

# Clone or update dotfiles repository
setup_repository() {
    print_info "Setting up dotfiles repository..."
    
    if [[ -d "$DEFAULT_DIR" ]]; then
        print_warning "Directory $DEFAULT_DIR already exists"
        
        if [[ "$NON_INTERACTIVE" != "true" ]]; then
            echo
            read -p "Do you want to update the existing repository? (y/N): " -n 1 -r
            echo
            
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "Using existing repository"
                cd "$DEFAULT_DIR"
                return
            fi
        else
            print_info "Non-interactive mode: updating existing repository"
        fi
        
        # Update existing repository
        cd "$DEFAULT_DIR"
        if git remote -v | grep -q "$DEFAULT_REPO"; then
            print_info "Updating dotfiles repository..."
            git fetch origin
            git reset --hard "origin/$DEFAULT_BRANCH"
            git clean -fd
        else
            print_warning "Existing directory doesn't match expected repository"
            print_info "Backing up existing directory and cloning fresh"
            
            backup_dir="${DEFAULT_DIR}.backup-$(date +%Y%m%d-%H%M%S)"
            mv "$DEFAULT_DIR" "$backup_dir"
            print_info "Existing directory backed up to: $backup_dir"
            
            git clone "$DEFAULT_REPO" "$DEFAULT_DIR"
            cd "$DEFAULT_DIR"
            git checkout "$DEFAULT_BRANCH"
        fi
    else
        # Fresh clone
        print_info "Cloning dotfiles repository..."
        git clone "$DEFAULT_REPO" "$DEFAULT_DIR"
        cd "$DEFAULT_DIR"
        git checkout "$DEFAULT_BRANCH"
    fi
    
    print_success "Repository setup completed"
}

# Run the main installation
run_installation() {
    print_info "Starting dotfiles installation..."
    
    # Build installation command
    local install_cmd="./install.sh"
    local install_args=()
    
    # Add development environment flags
    if [[ "$DEV_ALL" == "true" ]]; then
        install_args+=(--dev-all)
    elif [[ "$DEV_ENV" == "true" ]]; then
        install_args+=(--dev-env)
    fi
    
    # Add specific packages if specified
    if [[ -n "$INSTALL_PACKAGES" ]]; then
        read -ra packages <<< "$INSTALL_PACKAGES"
        install_args+=("${packages[@]}")
    fi
    
    # Set environment variables for the installation
    local env_vars=()
    
    if [[ "$NON_INTERACTIVE" == "true" ]]; then
        env_vars+=("NON_INTERACTIVE=true")
    fi
    
    if [[ "$SKIP_BREWFILE" == "true" ]]; then
        env_vars+=("SKIP_BREWFILE=true")
    fi
    
    if [[ "$SKIP_FONTS" == "true" ]]; then
        env_vars+=("SKIP_FONTS=true")
    fi
    
    # Execute installation
    local full_cmd="${env_vars[*]} $install_cmd ${install_args[*]}"
    print_info "Running: $full_cmd"
    echo
    
    # Run with environment variables
    env "${env_vars[@]}" "$install_cmd" "${install_args[@]}"
    
    print_success "Installation completed successfully!"
}

# Show usage information
show_help() {
    cat << 'EOF'
Unified Dotfiles One-Line Installer

Usage:
  curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash

Environment Variables:
  NON_INTERACTIVE=true    Skip all confirmation prompts
  SKIP_BREWFILE=true      Skip Homebrew package installation (macOS)
  SKIP_FONTS=true         Skip font installation (Linux)
  DEV_ENV=true            Setup development environments (interactive)
  DEV_ALL=true            Install all development environments
  INSTALL_PACKAGES="..."  Install specific packages only (space-separated)
  DOTFILES_REPO="..."     Custom repository URL
  DOTFILES_DIR="..."      Custom installation directory
  DOTFILES_BRANCH="..."   Custom branch to use

Examples:
  # Basic installation
  curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash

  # Non-interactive installation with all dev environments
  NON_INTERACTIVE=true DEV_ALL=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash

  # Install specific packages only
  INSTALL_PACKAGES="git vim tmux" curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash

  # Skip optional components
  SKIP_BREWFILE=true SKIP_FONTS=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash

Supported Systems:
  - macOS 10.15+ (Catalina or later)
  - Linux (Ubuntu, Fedora, Arch, Debian, etc.)

Features:
  ✅ Intelligent OS detection
  ✅ Automatic dependency installation
  ✅ Cross-platform font support
  ✅ Development environment setup
  ✅ Sensitive file management
  ✅ Conflict resolution with backup

EOF
}

# Show post-installation instructions
show_post_install() {
    echo
    print_success "🎉 Dotfiles installation completed!"
    echo
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Verify installation: ~/dotfiles/scripts/test-dev-config.sh"
    echo "  3. Customize: Edit ~/.zshrc.local, ~/.gitconfig.local"
    echo
    
    if [[ "$OS" == "linux" ]]; then
        print_info "Linux-specific notes:"
        echo "  • Fonts installed to ~/.local/share/fonts"
        echo "  • Run 'fc-list | grep -i nerd' to verify fonts"
    elif [[ "$OS" == "macos" ]]; then
        print_info "macOS-specific notes:"
        echo "  • Applications installed via Homebrew"
        echo "  • Check Applications folder for new apps"
    fi
    
    echo
    print_info "Documentation: https://github.com/nehcuh/dotfiles"
    print_info "Support: Create an issue on GitHub"
    echo
}

# Cleanup function
cleanup() {
    if [[ $? -ne 0 ]]; then
        echo
        print_error "Installation failed!"
        print_info "Check the error messages above for details"
        print_info "You can try running the installation manually:"
        print_info "  git clone $DEFAULT_REPO $DEFAULT_DIR"
        print_info "  cd $DEFAULT_DIR"
        print_info "  ./install.sh"
        echo
    fi
}

# Main execution
main() {
    # Set trap for cleanup
    trap cleanup EXIT
    
    # Show help if requested
    if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
        show_help
        exit 0
    fi
    
    # Main installation flow
    print_banner
    detect_os
    check_dependencies
    setup_repository
    run_installation
    show_post_install
    
    # Remove trap as we succeeded
    trap - EXIT
}

# Execute main function with all arguments
main "$@"
