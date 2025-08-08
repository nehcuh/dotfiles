#!/bin/bash
# Test script for Linux installation
# This helps verify the installation process works correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[TEST]${NC} $1"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[FAIL]${NC} $1"; }

echo "========================================"
echo "     Linux Installation Test           "
echo "========================================"
echo

# Test 1: Check if we're on Linux
log_info "Testing OS detection..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    log_success "Linux OS detected"
else
    log_error "Not running on Linux (OSTYPE: $OSTYPE)"
    exit 1
fi

# Test 2: Check prerequisites
log_info "Checking prerequisites..."
missing_prereqs=()

if ! command -v curl &> /dev/null; then
    missing_prereqs+=("curl")
fi

if ! command -v wget &> /dev/null; then
    missing_prereqs+=("wget")
fi

if ! command -v git &> /dev/null; then
    missing_prereqs+=("git")
fi

if [ ${#missing_prereqs[@]} -gt 0 ]; then
    log_warning "Missing prerequisites: ${missing_prereqs[*]}"
    log_info "Installing missing prerequisites..."
    
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y "${missing_prereqs[@]}"
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y "${missing_prereqs[@]}"
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm "${missing_prereqs[@]}"
    else
        log_error "Unable to install prerequisites automatically"
        exit 1
    fi
else
    log_success "All prerequisites available"
fi

# Test 3: Check if dotfiles directory exists
log_info "Checking dotfiles directory..."
if [ -d "$HOME/.dotfiles" ]; then
    log_warning "Dotfiles directory already exists at $HOME/.dotfiles"
    log_info "Backing up existing directory..."
    mv "$HOME/.dotfiles" "$HOME/.dotfiles.backup.$(date +%Y%m%d-%H%M%S)"
fi

# Test 4: Test remote installation script availability
log_info "Testing remote installation script availability..."
if curl -s --head https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install-linux.sh | head -n 1 | grep -q "200 OK"; then
    log_success "Remote installation script is accessible"
else
    log_error "Remote installation script not accessible"
    exit 1
fi

# Test 5: Show installation command
echo
log_info "To test the installation, run one of these commands:"
echo
echo "# Basic installation:"
echo "curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install-linux.sh | bash"
echo
echo "# Non-interactive installation (for CI/testing):"
echo "NON_INTERACTIVE=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install-linux.sh | bash"
echo
echo "# Installation with development environments:"
echo "DEV_ALL=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install-linux.sh | bash"
echo
echo "# Installation with specific packages:"
echo "INSTALL_PACKAGES=\"git zsh nvim\" curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install-linux.sh | bash"

# Test 6: Optional interactive test
if [ "$NON_INTERACTIVE" != "true" ]; then
    echo
    read -p "Would you like to run a non-interactive test installation now? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Running non-interactive test installation..."
        NON_INTERACTIVE=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install-linux.sh | bash
        
        # Verify installation
        log_info "Verifying installation..."
        if [ -d "$HOME/.dotfiles" ]; then
            log_success "Dotfiles directory created successfully"
            
            # Check for key files
            if [ -f "$HOME/.dotfiles/install.sh" ]; then
                log_success "Install script present"
            else
                log_error "Install script missing"
            fi
            
            if [ -f "$HOME/.dotfiles/scripts/setup-linux-packages.sh" ]; then
                log_success "Linux package script present"
            else
                log_error "Linux package script missing"
            fi
            
            # Check if on Linux branch
            cd "$HOME/.dotfiles"
            current_branch=$(git branch --show-current)
            if [ "$current_branch" = "linux" ]; then
                log_success "On Linux branch as expected"
            else
                log_error "Not on Linux branch (current: $current_branch)"
            fi
            
        else
            log_error "Dotfiles directory not created"
        fi
    else
        log_info "Skipping interactive test"
    fi
fi

echo
log_success "Test completed! The installation should work properly."
log_info "Remember to restart your terminal after installation to apply all changes."
