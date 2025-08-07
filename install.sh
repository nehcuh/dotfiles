#!/bin/bash
# Simple dotfiles installer
# Works on Linux and macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Utility functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    log_error "Unsupported OS: $OSTYPE"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

log_info "Dotfiles directory: $DOTFILES_DIR"
log_info "Operating system: $OS"

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed"
        exit 1
    fi
    
    if ! command -v stow &> /dev/null; then
        log_info "Installing GNU Stow..."
        case $OS in
            linux)
                if command -v apt &> /dev/null; then
                    sudo apt update && sudo apt install -y stow
                elif command -v pacman &> /dev/null; then
                    sudo pacman -S --noconfirm stow
                elif command -v dnf &> /dev/null; then
                    sudo dnf install -y stow
                else
                    log_error "Unable to install stow. Please install it manually."
                    exit 1
                fi
                ;;
            macos)
                if command -v brew &> /dev/null; then
                    log_info "Homebrew found, installing GNU Stow..."
                    brew install stow
                else
                    log_warning "Homebrew not found. Installing Homebrew first..."
                    
                    # Install Homebrew
                    log_info "Installing Homebrew..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    
                    # Add Homebrew to PATH for current session
                    if [ -f "/opt/homebrew/bin/brew" ]; then
                        # Apple Silicon Mac
                        export PATH="/opt/homebrew/bin:$PATH"
                        eval "$(/opt/homebrew/bin/brew shellenv)"
                    elif [ -f "/usr/local/bin/brew" ]; then
                        # Intel Mac
                        export PATH="/usr/local/bin:$PATH"
                        eval "$(/usr/local/bin/brew shellenv)"
                    fi
                    
                    # Verify Homebrew installation
                    if command -v brew &> /dev/null; then
                        log_success "Homebrew installed successfully"
                        log_info "Installing GNU Stow..."
                        brew install stow
                    else
                        log_error "Failed to install Homebrew. Please install it manually:"
                        log_error "Visit: https://brew.sh"
                        exit 1
                    fi
                fi
                ;;
        esac
    fi
    
    log_success "Prerequisites check passed"
}

# Install packages
install_packages() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        # Default packages
        packages=("system" "zsh" "git" "tools" "vim" "nvim" "tmux")
        
        # Add OS-specific packages
        if [ "$OS" = "linux" ]; then
            packages+=("linux")
        elif [ "$OS" = "macos" ]; then
            packages+=("macos")
        fi
    fi
    
    log_info "Installing packages: ${packages[*]}"
    
    cd "$DOTFILES_DIR/stow-packs" || exit 1
    
    for package in "${packages[@]}"; do
        if [ -d "$package" ]; then
            log_info "Installing $package..."
            if stow -v -t "$HOME" "$package"; then
                log_success "✓ $package installed"
            else
log_warning "Failed to install $package (conflicts detected)"
                
                # Create backup directory
                backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
                mkdir -p "$backup_dir"
                log_warning "Backing up conflicting files to $backup_dir"
                
                # Use stow --adopt to take over existing files, then restore from backup
                cd "$DOTFILES_DIR/stow-packs" || exit 1
                
                # First, find files that would be affected
                find "$package" -type f | while IFS= read -r file; do
                    # Convert package file path to home file path
                    home_file=$(echo "$file" | sed "s|^$package/||")
                    
                    if [ -f "$HOME/$home_file" ] && [ ! -L "$HOME/$home_file" ]; then
                        log_info "  Backing up $home_file"
                        # Create directory structure in backup
                        mkdir -p "$backup_dir/$(dirname "$home_file")"
                        cp "$HOME/$home_file" "$backup_dir/$home_file"
                    fi
                done
                
                # Now use stow --adopt to take over the files
                if stow --adopt -v -t "$HOME" "$package"; then
                    log_success "✓ $package installed after resolving conflicts"
                    log_info "  Original files backed up to: $backup_dir"
                else
                    log_error "✗ Failed to install $package even with --adopt"
                fi
            fi
        else
            log_warning "Package $package not found, skipping"
        fi
    done
}

# Setup shell
setup_shell() {
    log_info "Setting up shell..."
    
    if command -v zsh &> /dev/null; then
        if [ "$SHELL" != "$(command -v zsh)" ]; then
            log_info "Changing shell to zsh..."
            chsh -s "$(command -v zsh)"
            log_success "Shell changed to zsh (restart terminal to take effect)"
        fi
    else
        log_warning "Zsh not found, keeping current shell"
    fi
}

# Show help
show_help() {
    echo "Simple Dotfiles Installer"
    echo "Usage: $0 [packages...]"
    echo ""
    echo "Options:"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "Available packages:"
    echo "  system        System-wide configurations"
    echo "  zsh           Zsh shell configuration"
    echo "  git           Git configuration and aliases"
    echo "  tools         CLI tools and utilities"
    echo "  vim           Vim configuration"
    echo "  nvim          Neovim configuration"
    echo "  tmux          Terminal multiplexer configuration"
    echo "  vscode        Visual Studio Code settings"
    echo "  zed           Zed editor configuration"
    echo "  linux         Linux-specific configurations"
    echo "  macos         macOS-specific configurations"
    echo ""
    echo "Examples:"
    echo "  $0              # Install default packages"
    echo "  $0 git vim      # Install only git and vim"
    echo "  $0 zsh tmux     # Install shell and terminal multiplexer"
}

# Main installation
main() {
    # Check for help option
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
        exit 0
    fi
    
    echo "========================================"
    echo "         Dotfiles Installation          "
    echo "========================================"
    echo
    
    check_prerequisites
    install_packages "$@"
    setup_shell
    
    echo
    log_success "Installation completed!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
}

# Run main function with all arguments
main "$@"
