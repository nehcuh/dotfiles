#!/bin/sh
# Universal Dotfiles Installer - Smart shell detection and execution
# This script automatically detects the best shell and re-executes with it

set -e

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
    
    # Set up dotfiles directory
    DOTFILES_DIR="$HOME/.dotfiles"
    mkdir -p "$DOTFILES_DIR/scripts"
    
    # Download interactive install script
    INTERACTIVE_SCRIPT="$DOTFILES_DIR/scripts/interactive-install.sh"
    if [ ! -f "$INTERACTIVE_SCRIPT" ]; then
        log_info "Downloading interactive install script..."
        
        # Try different methods to download
        if command -v curl >/dev/null 2>&1; then
            # Try with different curl options
            if curl -fsSL "https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh" -o "$INTERACTIVE_SCRIPT" 2>/dev/null; then
                log_success "Download completed"
            elif curl -L "https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh" -o "$INTERACTIVE_SCRIPT" 2>/dev/null; then
                log_success "Download completed (fallback method)"
            else
                log_error "Failed to download script with curl"
                exit 1
            fi
        elif command -v wget >/dev/null 2>&1; then
            if wget -q "https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh" -O "$INTERACTIVE_SCRIPT"; then
                log_success "Download completed"
            else
                log_error "Failed to download script with wget"
                exit 1
            fi
        else
            log_error "Cannot download script - no curl or wget available"
            exit 1
        fi
    else
        log_info "Using existing interactive install script"
    fi
    
    # Make sure it's executable
    chmod +x "$INTERACTIVE_SCRIPT"
    
    # Execute the interactive installer with appropriate shell
    log_info "Starting interactive installer..."
    
    # Check if we're in an interactive environment
    if ! [ -t 0 ]; then
        # If we're in a pipe, try to re-exec in a new terminal session
        if [ -t 1 ] || [ -t 2 ]; then
            # We have some terminal access, try to re-exec with proper terminal
            log_warning "Running from pipe, attempting to start interactive session..."
            
            # Try to start a new interactive session
            if command -v bash >/dev/null 2>&1; then
                exec bash -c "exec bash '$INTERACTIVE_SCRIPT' '$@'"
            elif command -v zsh >/dev/null 2>&1; then
                exec zsh -c "exec zsh '$INTERACTIVE_SCRIPT' '$@'"
            else
                exec sh -c "exec sh '$INTERACTIVE_SCRIPT' '$@'"
            fi
        else
            # No terminal access at all
            log_error "This installer requires an interactive terminal."
            log_warning "Please run this installer directly in your terminal."
            log_info "Alternative: curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/install.sh | sh"
            log_info "Or download and run: curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/universal-install.sh -o install.sh && chmod +x install.sh && ./install.sh"
            exit 1
        fi
    fi
    
    # We have interactive terminal, proceed with execution
    if command -v bash >/dev/null 2>&1; then
        exec bash "$INTERACTIVE_SCRIPT" "$@"
    elif command -v zsh >/dev/null 2>&1; then
        exec zsh "$INTERACTIVE_SCRIPT" "$@"
    else
        # Fallback to sh
        exec sh "$INTERACTIVE_SCRIPT" "$@"
    fi
}

# Run main function
main "$@"