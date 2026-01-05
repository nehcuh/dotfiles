#!/bin/bash
# Simple dotfiles installer
# Works on Linux and macOS
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source libraries
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/os-detect.sh"
source "$SCRIPT_DIR/lib/stow-wrapper.sh"

# Source installation steps
source "$SCRIPT_DIR/steps/prerequisites.sh"
source "$SCRIPT_DIR/steps/packages.sh"
source "$SCRIPT_DIR/steps/shell.sh"
source "$SCRIPT_DIR/steps/brewfile.sh"
source "$SCRIPT_DIR/steps/terminal-font.sh"

# Show help
show_help() {
    echo "Simple Dotfiles Installer"
    echo "Usage: $0 [packages...]"
    echo ""
    echo "Examples:"
    echo "  $0                  # Install default packages"
    echo "  $0 git vim          # Install only git and vim"
    echo ""
    echo "Available packages:"
    echo "  system, zsh, git, tools, vim, nvim, tmux, vscode, zed, linux, macos"
}

# Main installation
main() {
    local packages=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                packages+=("$1")
                shift
                ;;
        esac
    done

    echo "========================================"
    echo "         Dotfiles Installation          "
    echo "========================================"
    echo

    log_info "Dotfiles directory: $DOTFILES_DIR"
    log_info "Operating system: $OS"
    echo

    # Installation steps (in order)
    check_prerequisites
    install_packages "${packages[@]}"

    # OS-specific steps
    if [[ "$OS" == "macos" ]]; then
        install_brewfile
        configure_terminal_font
    fi

    setup_shell

    echo
    log_success "Installation completed!"
    log_info "Please restart your terminal or run: source ~/.zshrc"
}

main "$@"
