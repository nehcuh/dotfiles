#!/bin/sh
# Smart Universal Installer - Automatically detects and uses appropriate shell
# This script provides better shell detection and compatibility

set -e

# Global variables
PACKAGES_UPDATED=false
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
    
    echo "Detected shell: $CURRENT_SHELL"
    echo "Shell path: $SHELL_PATH"
    
    # If we're not running with the optimal shell, re-exec
    if [ "$CURRENT_SHELL" != "sh" ] && [ "$(basename "$0")" = "sh" ]; then
        echo "Re-executing with $CURRENT_SHELL for better compatibility..."
        exec "$SHELL_PATH" "$DOTFILES_DIR/scripts/smart-universal-install.sh" "$@"
    fi
}

# Colors (compatible with all shells)
setup_colors() {
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
}

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

# Safe sudo wrapper
safe_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        if command -v sudo >/dev/null 2>&1; then
            echo "Requesting sudo access for: $*"
            sudo "$@"
        else
            log_error "sudo is required but not available"
            return 1
        fi
    fi
}

# Detect platform
detect_platform() {
    OS="$(uname -s)"
    case "$OS" in
        Linux)
            if [ -f /etc/os-release ]; then
                DISTRO=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
            elif command -v lsb_release >/dev/null 2>&1; then
                DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
            else
                DISTRO="unknown"
            fi
            PLATFORM="linux"
            ;;
        Darwin)
            PLATFORM="macos"
            DISTRO="macos"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            PLATFORM="windows"
            DISTRO="windows"
            ;;
        *)
            PLATFORM="unknown"
            DISTRO="unknown"
            ;;
    esac
    
    echo "Detected platform: $PLATFORM ($DISTRO)"
}

# Check and install required packages
install_required_packages() {
    log_info "Checking required packages..."
    
    case "$PLATFORM" in
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                log_warning "Homebrew not found. Installing..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            
            # Install required packages
            local packages="git stow curl"
            for package in $packages; do
                if ! command -v "$package" >/dev/null 2>&1; then
                    log_info "Installing $package..."
                    brew install "$package"
                fi
            done
            ;;
        linux)
            # Update package lists if needed
            if [ "$PACKAGES_UPDATED" = false ]; then
                case "$DISTRO" in
                    ubuntu|debian)
                        if ! safe_sudo apt update; then
                            log_warning "Failed to update package lists. Continuing anyway..."
                        fi
                        PACKAGES_UPDATED=true
                        ;;
                    fedora|centos|rhel)
                        if ! safe_sudo dnf check-update; then
                            log_warning "Failed to check package updates. Continuing anyway..."
                        fi
                        PACKAGES_UPDATED=true
                        ;;
                    arch)
                        if ! safe_sudo pacman -Sy; then
                            log_warning "Failed to sync package databases. Continuing anyway..."
                        fi
                        PACKAGES_UPDATED=true
                        ;;
                esac
            fi
            
            # Install required packages
            case "$DISTRO" in
                ubuntu|debian)
                    if ! safe_sudo apt install -y git stow curl build-essential; then
                        log_warning "Failed to install some required packages. Continuing with limited functionality..."
                    fi
                    ;;
                fedora|centos|rhel)
                    if ! safe_sudo dnf install -y git stow curl @development-tools; then
                        log_warning "Failed to install some required packages. Continuing with limited functionality..."
                    fi
                    ;;
                arch)
                    if ! safe_sudo pacman -S --noconfirm git stow curl base-devel; then
                        log_warning "Failed to install some required packages. Continuing with limited functionality..."
                    fi
                    ;;
                *)
                    log_warning "Please install git, stow, curl, and build tools manually"
                    log_warning "Continuing with limited functionality..."
                    ;;
            esac
            ;;
        windows)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                # WSL environment
                log_warning "Installing required packages in WSL..."
                if ! safe_sudo apt update; then
                    log_warning "Failed to update package lists in WSL. Continuing anyway..."
                fi
                if ! safe_sudo apt install -y git stow curl; then
                    log_warning "Failed to install some required packages in WSL. Continuing with limited functionality..."
                fi
            else
                log_warning "Please install Git for Windows and ensure it's in PATH"
                log_warning "Continuing with limited functionality..."
            fi
            ;;
        *)
            log_warning "Unknown platform. Please install git, stow, and curl manually"
            log_warning "Continuing with limited functionality..."
            ;;
    esac
}

# Clone or update dotfiles repository
setup_dotfiles() {
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        log_error "Not a git repository. Please clone the dotfiles repository first."
        exit 1
    fi
    
    log_info "Updating dotfiles repository..."
    cd "$DOTFILES_DIR"
    git pull origin main || log_warning "Failed to update repository. Continuing with local version..."
}

# Interactive installation menu
interactive_menu() {
    echo ""
    echo "Dotfiles Installation Menu"
    echo "========================="
    echo ""
    echo "1. Full Installation (Recommended)"
    echo "2. Custom Installation"
    echo "3. Shell Configuration Only"
    echo "4. Development Tools Only"
    echo "5. Privacy Protection Only"
    echo "6. Package Management Only"
    echo "7. System Information"
    echo "8. Exit"
    echo ""
    
    while true; do
        read -p "Please select an option (1-8): " choice
        case "$choice" in
            1|2|3|4|5|6|7|8)
                break
                ;;
            *)
                echo "Invalid option. Please select a number between 1 and 8."
                ;;
        esac
    done
    
    case "$choice" in
        1)
            log_info "Starting full installation..."
            full_installation
            ;;
        2)
            log_info "Starting custom installation..."
            custom_installation
            ;;
        3)
            log_info "Installing shell configuration..."
            shell_installation
            ;;
        4)
            log_info "Installing development tools..."
            dev_tools_installation
            ;;
        5)
            log_info "Installing privacy protection..."
            privacy_installation
            ;;
        6)
            log_info "Installing package management..."
            package_management_installation
            ;;
        7)
            show_system_info
            interactive_menu
            ;;
        8)
            log_info "Exiting installation..."
            exit 0
            ;;
    esac
}

# Full installation
full_installation() {
    log_info "Running full installation..."
    
    # Install required packages
    install_required_packages
    
    # Apply shell configuration
    shell_installation
    
    # Install development tools
    dev_tools_installation
    
    # Install privacy protection
    privacy_installation
    
    # Install package management
    package_management_installation
    
    log_success "Full installation completed!"
    show_next_steps
}

# Shell configuration installation
shell_installation() {
    log_info "Installing shell configuration..."
    
    cd "$DOTFILES_DIR"
    
    # Apply stow packages for shell
    local shell_packages="zsh tmux user-home"
    for package in $shell_packages; do
        if [ -d "stow-packs/$package" ]; then
            log_info "Applying $package configuration..."
            if stow -d stow-packs -t ~ "$package"; then
                log_success "$package configuration applied"
            else
                log_warning "Failed to apply $package configuration"
            fi
        fi
    done
    
    # Install oh-my-zsh if not present
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# Development tools installation
dev_tools_installation() {
    log_info "Installing development tools..."
    
    cd "$DOTFILES_DIR"
    
    # Apply stow packages for development
    local dev_packages="git nvim vim vscode zed tools"
    for package in $dev_packages; do
        if [ -d "stow-packs/$package" ]; then
            log_info "Applying $package configuration..."
            if stow -d stow-packs -t ~ "$package"; then
                log_success "$package configuration applied"
            else
                log_warning "Failed to apply $package configuration"
            fi
        fi
    done
    
    # Run development tools setup script if available
    if [ -f "scripts/setup-dev-tools.sh" ]; then
        log_info "Running development tools setup..."
        ./scripts/setup-dev-tools.sh
    fi
}

# Privacy protection installation
privacy_installation() {
    log_info "Installing privacy protection..."
    
    cd "$DOTFILES_DIR"
    
    # Apply privacy protection packages
    local privacy_packages="shell-history vscode-privacy zed-privacy nvim-privacy vim-privacy privacy-template"
    for package in $privacy_packages; do
        if [ -d "stow-packs/$package" ]; then
            log_info "Applying $package privacy configuration..."
            if stow -d stow-packs -t ~ "$package"; then
                log_success "$package privacy configuration applied"
            else
                log_warning "Failed to apply $package privacy configuration"
            fi
        fi
    done
    
    # Run privacy migration scripts
    local privacy_scripts="migrate-history.sh migrate-vscode-privacy.sh migrate-zed-privacy.sh migrate-nvim-privacy.sh migrate-vim-privacy.sh"
    for script in $privacy_scripts; do
        if [ -f "scripts/$script" ]; then
            log_info "Running $script..."
            ./scripts/"$script"
        fi
    done
}

# Package management installation
package_management_installation() {
    log_info "Installing package management..."
    
    cd "$DOTFILES_DIR"
    
    # Apply package management configuration
    if [ -d "stow-packs/package-management" ]; then
        log_info "Applying package management configuration..."
        if stow -d stow-packs -t ~ package-management; then
            log_success "Package management configuration applied"
        else
            log_warning "Failed to apply package management configuration"
        fi
    fi
    
    # Run package management integration
    if [ -f "scripts/package-management-integration.sh" ]; then
        log_info "Running package management integration..."
        ./scripts/package-management-integration.sh install
    fi
}

# Custom installation
custom_installation() {
    log_info "Starting custom installation..."
    
    cd "$DOTFILES_DIR"
    
    # List available packages
    echo ""
    echo "Available packages:"
    echo "=================="
    
    local package_count=0
    for package in stow-packs/*; do
        if [ -d "$package" ]; then
            package_name=$(basename "$package")
            echo "  $package_count. $package_name"
            package_count=$((package_count + 1))
        fi
    done
    
    echo ""
    echo "Enter package numbers to install (comma-separated, or 'all' for all packages):"
    read -p "Selection: " selection
    
    if [ "$selection" = "all" ]; then
        # Install all packages
        for package in stow-packs/*; do
            if [ -d "$package" ]; then
                package_name=$(basename "$package")
                log_info "Applying $package_name..."
                if stow -d stow-packs -t ~ "$package_name"; then
                    log_success "$package_name applied"
                else
                    log_warning "Failed to apply $package_name"
                fi
            fi
        done
    else
        # Install selected packages
        IFS=',' read -ra selected_indices <<< "$selection"
        local packages=()
        for package in stow-packs/*; do
            if [ -d "$package" ]; then
                packages+=("$(basename "$package")")
            fi
        done
        
        for index in "${selected_indices[@]}"; do
            index=$((index))  # Convert to 0-based index
            if [ "$index" -ge 0 ] && [ "$index" -lt "${#packages[@]}" ]; then
                package_name="${packages[$index]}"
                log_info "Applying $package_name..."
                if stow -d stow-packs -t ~ "$package_name"; then
                    log_success "$package_name applied"
                else
                    log_warning "Failed to apply $package_name"
                fi
            fi
        done
    fi
    
    log_success "Custom installation completed!"
    show_next_steps
}

# Show system information
show_system_info() {
    echo ""
    echo "System Information"
    echo "=================="
    echo "OS: $OS"
    echo "Platform: $PLATFORM"
    echo "Distribution: $DISTRO"
    echo "Shell: $CURRENT_SHELL"
    echo "Shell Path: $SHELL_PATH"
    echo "Dotfiles Directory: $DOTFILES_DIR"
    echo ""
    
    # Check required commands
    echo "Required Commands:"
    echo "==================="
    local required_commands="git stow curl"
    for cmd in $required_commands; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "  ✓ $cmd: $(command -v "$cmd")"
        else
            echo "  ✗ $cmd: Not found"
        fi
    done
    
    echo ""
    
    # Check optional commands
    echo "Optional Commands:"
    echo "=================="
    local optional_commands="zsh bash vim nvim vscode zed tmux"
    for cmd in $optional_commands; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "  ✓ $cmd: $(command -v "$cmd")"
        else
            echo "  ✗ $cmd: Not found"
        fi
    done
}

# Show next steps
show_next_steps() {
    echo ""
    echo "Next Steps"
    echo "=========="
    echo "1. Restart your shell or run: source ~/.zshrc (or source ~/.bashrc)"
    echo "2. Check that all configurations are working properly"
    echo "3. Run 'stow -d stow-packs -t ~ <package>' to apply specific configurations"
    echo "4. Refer to the README files for more information"
    echo ""
    echo "Useful Commands:"
    echo "==============="
    echo "- Show package status: package-state status-all"
    echo "- Check for updates: package-state check-updates"
    echo "- Install packages: smart-install <package>"
    echo "- Clean cache: clean_all_packages"
    echo ""
}

# Main function
main() {
    echo "Smart Universal Dotfiles Installer"
    echo "=================================="
    echo ""
    
    # Detect shell and platform
    smart_shell_detection
    setup_colors
    detect_platform
    
    # Show system info
    show_system_info
    
    # Check if we have the required tools
    if ! command -v git >/dev/null 2>&1 || ! command -v stow >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
        log_warning "Some required tools are missing. Installing them..."
        install_required_packages
    fi
    
    # Setup dotfiles
    setup_dotfiles
    
    # Show interactive menu
    interactive_menu
}

# Run main function
main "$@"