#!/bin/sh
# Universal Dotfiles Installer - Smart shell detection and execution
# This script automatically detects the best shell and re-executes with it

set -e

# Get script directory - handle piped execution
if [ -n "$0" ] && [ "$0" != "sh" ] && [ "$0" != "-sh" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
else
    # Script is being piped, use current directory and assume we're in a temp location
    SCRIPT_DIR="$(pwd)"
    # Create a temporary script file
    TEMP_SCRIPT="/tmp/universal-install.sh"
    if [ ! -f "$TEMP_SCRIPT" ]; then
        # Download the script to temp location
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL "https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/universal-install.sh" -o "$TEMP_SCRIPT"
        elif command -v wget >/dev/null 2>&1; then
            wget -q "https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/universal-install.sh" -O "$TEMP_SCRIPT"
        else
            echo "Error: Cannot download script - no curl or wget available"
            exit 1
        fi
        chmod +x "$TEMP_SCRIPT"
    fi
    # Re-execute the downloaded script
    exec "$TEMP_SCRIPT" "$@"
fi

# Detect current shell
detect_shell() {
    if [ -n "$BASH_VERSION" ]; then
        echo "bash"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    else
        ps -p $$ -o comm= 2>/dev/null | tail -1 | grep -E "(bash|zsh)" || echo "sh"
    fi
}

# Colors (compatible with all shells)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    NC=''
fi

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Main function
main() {
    echo "Universal Dotfiles Installer"
    echo "=========================="
    echo ""
    
    CURRENT_SHELL=$(detect_shell)
    echo "Using shell: $CURRENT_SHELL"
    
    # Set up dotfiles directory
    if [ "$SCRIPT_DIR" = "/tmp" ]; then
        # We're running from temp location, set up in user's home
        DOTFILES_DIR="$HOME/.dotfiles"
        mkdir -p "$DOTFILES_DIR/scripts"
    fi
    
    # Download interactive install script
    INTERACTIVE_SCRIPT="$DOTFILES_DIR/scripts/interactive-install.sh"
    if [ ! -f "$INTERACTIVE_SCRIPT" ]; then
        log_info "Downloading interactive install script..."
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL "https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh" -o "$INTERACTIVE_SCRIPT"
        elif command -v wget >/dev/null 2>&1; then
            wget -q "https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh" -O "$INTERACTIVE_SCRIPT"
        else
            log_error "Cannot download interactive install script - no curl or wget available"
            exit 1
        fi
    fi
    
    # Make sure it's executable
    chmod +x "$INTERACTIVE_SCRIPT"
    
    # Execute the interactive installer
    log_info "Starting interactive installer..."
    exec "$INTERACTIVE_SCRIPT" "$@"
}

# Run main function
main "$@"