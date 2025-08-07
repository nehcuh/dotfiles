#!/bin/bash
# Package Management Integration Script
# Integrates intelligent package management into the dotfiles setup

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGE_MANAGEMENT_DIR="$DOTFILES_DIR/stow-packs/package-management"

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}"
}

log_info() {
    log "INFO" "$@"
    echo -e "${BLUE}$@${NC}"
}

log_success() {
    log "SUCCESS" "$@"
    echo -e "${GREEN}$@${NC}"
}

log_warning() {
    log "WARNING" "$@"
    echo -e "${YELLOW}$@${NC}"
}

log_error() {
    log "ERROR" "$@"
    echo -e "${RED}$@${NC}"
}

# Check if package management directory exists
check_package_management_dir() {
    if [ ! -d "$PACKAGE_MANAGEMENT_DIR" ]; then
        log_error "Package management directory not found: $PACKAGE_MANAGEMENT_DIR"
        exit 1
    fi
}

# Apply package management configuration
apply_package_management_config() {
    log_info "Applying package management configuration..."
    
    cd "$DOTFILES_DIR"
    
    # Apply stow configuration
    if stow -d stow-packs -t ~ package-management 2>/dev/null; then
        log_success "Package management configuration applied"
    else
        log_warning "Package management configuration already applied or failed"
    fi
}

# Setup package management environment
setup_package_management_environment() {
    log_info "Setting up package management environment..."
    
    # Source the configuration
    if [ -f "$HOME/.package-manager-config" ]; then
        source "$HOME/.package-manager-config"
        log_success "Package management configuration sourced"
    else
        log_error "Package management configuration file not found"
        return 1
    fi
    
    # Verify script files exist
    local scripts=(
        "$DOTFILES_DIR/scripts/smart-installer.sh"
        "$DOTFILES_DIR/scripts/package-state-manager.sh"
        "$DOTFILES_DIR/scripts/smart-package-manager.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            log_success "Script found: $script"
        else
            log_error "Script not found: $script"
            return 1
        fi
    done
    
    # Make scripts executable
    for script in "${scripts[@]}"; do
        chmod +x "$script" 2>/dev/null || true
    done
    
    log_success "Package management environment setup complete"
}

# Initialize package management state
initialize_package_management_state() {
    log_info "Initializing package management state..."
    
    # Create state directory
    local state_dir="$HOME/.local/state/package-manager"
    mkdir -p "$state_dir"
    
    # Initialize state file
    local state_file="$state_dir/packages.json"
    if [ ! -f "$state_file" ]; then
        echo '{"packages": {}, "last_update": null, "system_info": {}}' > "$state_file"
        log_success "Package state file initialized"
    fi
    
    # Initialize history file
    local history_file="$state_dir/history.log"
    touch "$history_file"
    log_success "Package history file initialized"
}

# Add to shell configuration
add_to_shell_config() {
    log_info "Adding package management to shell configuration..."
    
    # Add to .bashrc if not exists
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "source.*package-manager-config" "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo "# Source package management configuration" >> "$HOME/.bashrc"
            echo "source \"$HOME/.package-manager-config\"" >> "$HOME/.bashrc"
            log_success "Added to .bashrc"
        fi
    fi
    
    # Add to .zshrc if not exists
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "source.*package-manager-config" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# Source package management configuration" >> "$HOME/.zshrc"
            echo "source \"$HOME/.package-manager-config\"" >> "$HOME/.zshrc"
            log_success "Added to .zshrc"
        fi
    fi
}

# Show system status
show_system_status() {
    log_info "System status:"
    
    if command -v show_package_manager_status >/dev/null 2>&1; then
        show_package_manager_status
    else
        log_warning "Package management not fully loaded"
    fi
}

# Install essential packages
install_essential_packages() {
    log_info "Installing essential packages..."
    
    # Essential packages for development
    local essential_packages=(
        "git"
        "curl"
        "wget"
        "jq"
        "tmux"
        "zsh"
        "vim"
        "nvim"
        "ripgrep"
        "fd"
        "exa"
        "bat"
        "htop"
        "tree"
    )
    
    # Check if smart installer is available
    if command -v smart-install >/dev/null 2>&1; then
        log_info "Using smart installer for essential packages..."
        
        for package in "${essential_packages[@]}"; do
            if command -v smart-install >/dev/null 2>&1; then
                smart-install install "$package" || log_warning "Failed to install $package"
            fi
        done
    else
        log_warning "Smart installer not available, skipping essential package installation"
    fi
}

# Setup development environment
setup_development_environment() {
    log_info "Setting up development environment..."
    
    if command -v setup_dev_environment >/dev/null 2>&1; then
        setup_dev_environment
    else
        log_warning "Development environment setup function not available"
    fi
}

# Run package management test
run_package_management_test() {
    log_info "Running package management test..."
    
    # Test basic functionality
    local tests_passed=0
    local tests_failed=0
    
    # Test configuration sourcing
    if [ -f "$HOME/.package-manager-config" ]; then
        source "$HOME/.package-manager-config"
        log_success "Configuration sourcing test passed"
        ((tests_passed++))
    else
        log_error "Configuration sourcing test failed"
        ((tests_failed++))
    fi
    
    # Test script availability
    local scripts=(
        "$DOTFILES_DIR/scripts/smart-installer.sh"
        "$DOTFILES_DIR/scripts/package-state-manager.sh"
        "$DOTFILES_DIR/scripts/smart-package-manager.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            log_success "Script availability test passed: $(basename "$script")"
            ((tests_passed++))
        else
            log_error "Script availability test failed: $(basename "$script")"
            ((tests_failed++))
        fi
    done
    
    # Test function availability
    local functions=(
        "quick_install"
        "batch_install"
        "update_all_packages"
        "clean_all_packages"
        "show_package_status"
    )
    
    for func in "${functions[@]}"; do
        if command -v "$func" >/dev/null 2>&1; then
            log_success "Function availability test passed: $func"
            ((tests_passed++))
        else
            log_error "Function availability test failed: $func"
            ((tests_failed++))
        fi
    done
    
    # Test cache directories
    local cache_dirs=(
        "$HOME/.cache/package-manager"
        "$HOME/.local/state/package-manager"
        "$HOME/.config/package-manager"
    )
    
    for dir in "${cache_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_success "Cache directory test passed: $dir"
            ((tests_passed++))
        else
            log_error "Cache directory test failed: $dir"
            ((tests_failed++))
        fi
    done
    
    # Show test results
    log_info "Test results:"
    log_info "  Passed: $tests_passed"
    log_info "  Failed: $tests_failed"
    log_info "  Total: $((tests_passed + tests_failed))"
    
    if [ $tests_failed -eq 0 ]; then
        log_success "All tests passed!"
    else
        log_warning "Some tests failed"
    fi
}

# Show help
show_help() {
    echo "Package Management Integration Script"
    echo "===================================="
    echo ""
    echo "This script integrates intelligent package management into your dotfiles setup."
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install     Install package management configuration"
    echo "  setup      Setup package management environment"
    echo "  test       Run package management tests"
    echo "  status     Show system status"
    echo "  essential  Install essential packages"
    echo "  dev        Setup development environment"
    echo "  help       Show this help"
    echo ""
    echo "Features:"
    echo "  • Smart package installation with caching"
    echo "  • Package state management and tracking"
    echo "  • Update detection across multiple package managers"
    echo "  • Cross-platform support (macOS, Linux, Windows)"
    echo "  • Privacy-respecting operation"
    echo ""
    echo "Examples:"
    echo "  $0 install"
    echo "  $0 setup"
    echo "  $0 test"
    echo "  $0 essential"
}

# Main function
main() {
    local command="${1:-install}"
    
    case "$command" in
        install)
            log_info "Installing package management integration..."
            check_package_management_dir
            apply_package_management_config
            add_to_shell_config
            log_success "Package management integration complete!"
            echo ""
            echo "Next steps:"
            echo "  1. Restart your shell or run: source ~/.package-manager-config"
            echo "  2. Run: $0 setup"
            echo "  3. Run: $0 test"
            ;;
        setup)
            log_info "Setting up package management..."
            check_package_management_dir
            setup_package_management_environment
            initialize_package_management_state
            log_success "Package management setup complete!"
            ;;
        test)
            log_info "Testing package management..."
            check_package_management_dir
            run_package_management_test
            ;;
        status)
            log_info "Showing package management status..."
            show_system_status
            ;;
        essential)
            log_info "Installing essential packages..."
            install_essential_packages
            ;;
        dev)
            log_info "Setting up development environment..."
            setup_development_environment
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"