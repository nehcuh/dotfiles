#!/bin/sh
# Universal Dotfiles Installer - Smart shell detection and execution
# This script automatically detects the best shell and re-executes with it

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Smart shell detection and re-execution
smart_shell_detection() {
    # Detect current shell environment
    if [ -n "$BASH_VERSION" ]; then
        CURRENT_SHELL="bash"
        SHELL_PATH="$(command -v bash)"
    elif [ -n "$ZSH_VERSION" ]; then
        CURRENT_SHELL="zsh"
        SHELL_PATH="$(command -v zsh)"
    else
        # Try to detect from process
        CURRENT_SHELL=$(ps -p $$ -o comm= 2>/dev/null | tail -1)
        case "$CURRENT_SHELL" in
            *bash*)
                CURRENT_SHELL="bash"
                SHELL_PATH="$(command -v bash)"
                ;;
            *zsh*)
                CURRENT_SHELL="zsh"
                SHELL_PATH="$(command -v zsh)"
                ;;
            *)
                # Default to bash if available, otherwise use sh
                if command -v bash >/dev/null 2>&1; then
                    CURRENT_SHELL="bash"
                    SHELL_PATH="$(command -v bash)"
                elif command -v zsh >/dev/null 2>&1; then
                    CURRENT_SHELL="zsh"
                    SHELL_PATH="$(command -v zsh)"
                else
                    CURRENT_SHELL="sh"
                    SHELL_PATH="$(command -v sh)"
                fi
                ;;
        esac
    fi
    
    # If we're running with sh but have a better shell available, re-exec
    if [ "$CURRENT_SHELL" = "sh" ] && [ -n "$SHELL_PATH" ] && [ "$SHELL_PATH" != "$(command -v sh)" ]; then
        echo "Re-executing with $CURRENT_SHELL for better compatibility..."
        exec "$SHELL_PATH" "$DOTFILES_DIR/scripts/interactive-install.sh" "$@"
    fi
    
    echo "Using shell: $CURRENT_SHELL"
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
    
    # Detect and use appropriate shell
    smart_shell_detection
    
    # Check if interactive-install.sh exists
    if [ ! -f "$DOTFILES_DIR/scripts/interactive-install.sh" ]; then
        log_error "Interactive install script not found: $DOTFILES_DIR/scripts/interactive-install.sh"
        exit 1
    fi
    
    # Make sure it's executable
    chmod +x "$DOTFILES_DIR/scripts/interactive-install.sh"
    
    # Execute the interactive installer
    log_info "Starting interactive installer..."
    exec "$DOTFILES_DIR/scripts/interactive-install.sh" "$@"
}

# Run main function
main "$@"