#!/bin/bash
# Simple dotfiles uninstaller
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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    log_error "Unsupported OS: $OSTYPE"
    exit 1
fi

log_info "Dotfiles directory: $DOTFILES_DIR"
log_info "Operating system: $OS"

# Remove packages
remove_packages() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        # All available packages
        packages=()
        cd "$DOTFILES_DIR/stow-packs" || exit 1
        for dir in */; do
            if [ -d "$dir" ]; then
                packages+=("${dir%/}")
            fi
        done
    fi
    
    log_info "Removing packages: ${packages[*]}"
    
    cd "$DOTFILES_DIR/stow-packs" || exit 1
    
    for package in "${packages[@]}"; do
        if [ -d "$package" ]; then
            log_info "Removing $package..."
            if stow -D -v -t "$HOME" "$package"; then
                log_success "✓ $package removed"
            else
                log_warning "Failed to remove $package (may not be installed)"
            fi
        else
            log_warning "Package $package not found, skipping"
        fi
    done
}

# List installed packages
list_packages() {
    log_info "Available packages in $DOTFILES_DIR/stow-packs:"
    cd "$DOTFILES_DIR/stow-packs" || exit 1
    for dir in */; do
        if [ -d "$dir" ]; then
            echo "  - ${dir%/}"
        fi
    done
}

# Main uninstaller
main() {
    echo "========================================"
    echo "        Dotfiles Uninstaller           "
    echo "========================================"
    echo
    
    case "${1:-}" in
        list)
            list_packages
            ;;
        "")
            log_warning "This will remove all dotfiles symlinks from your home directory"
            read -p "Are you sure? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                remove_packages
                log_success "Uninstallation completed!"
            else
                log_info "Uninstallation cancelled"
            fi
            ;;
        *)
            remove_packages "$@"
            log_success "Selected packages removed!"
            ;;
    esac
}

# Show help
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [packages...]"
    echo ""
    echo "Options:"
    echo "  (no args)     Remove all packages (with confirmation)"
    echo "  list          List available packages"
    echo "  [packages]    Remove specific packages"
    echo ""
    echo "Examples:"
    echo "  $0              # Remove all packages"
    echo "  $0 list         # List packages"  
    echo "  $0 vim nvim     # Remove only vim and nvim"
    exit 0
fi

# Run main function with all arguments
main "$@"
