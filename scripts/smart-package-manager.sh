#!/bin/bash
# Smart Package Manager - Intelligent software download and update management
# Avoids redundant downloads by checking existing installations and provides smart updates

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CACHE_DIR="$HOME/.cache/package-manager"
STATE_DIR="$HOME/.local/state/package-manager"
CONFIG_DIR="$HOME/.config/package-manager"
LOG_FILE="$STATE_DIR/package-manager.log"

# Create necessary directories
mkdir -p "$CACHE_DIR" "$STATE_DIR" "$CONFIG_DIR"

# Initialize log file
touch "$LOG_FILE"

# Package definitions
declare -A PACKAGES=(
    # Development Tools
    ["git"]="https://git-scm.com"
    ["node"]="https://nodejs.org"
    ["python"]="https://python.org"
    ["go"]="https://golang.org"
    ["rust"]="https://rust-lang.org"
    
    # Editors
    ["vim"]="https://www.vim.org"
    ["nvim"]="https://neovim.io"
    ["vscode"]="https://code.visualstudio.com"
    ["zed"]="https://zed.dev"
    
    # Browsers
    ["firefox"]="https://www.mozilla.org/firefox"
    ["chrome"]="https://www.google.com/chrome"
    ["brave"]="https://brave.com"
    
    # Containers and Virtualization
    ["docker"]="https://www.docker.com"
    ["virtualbox"]="https://www.virtualbox.org"
    ["vmware"]="https://www.vmware.com"
    
    # System Tools
    ["tmux"]="https://github.com/tmux/tmux"
    ["zsh"]="https://www.zsh.org"
    ["bash"]="https://www.gnu.org/software/bash"
    ["fish"]="https://fishshell.com"
    
    # Utilities
    ["curl"]="https://curl.se"
    ["wget"]="https://www.gnu.org/software/wget"
    ["jq"]="https://stedolan.github.io/jq"
    ["ripgrep"]="https://github.com/BurntSushi/ripgrep"
    ["fd"]="https://github.com/sharkdp/fd"
    ["exa"]="https://the.exa.website"
    ["bat"]="https://github.com/sharkdp/bat"
)

# Package manager commands for different systems
declare -A PACKAGE_MANAGERS=(
    ["macos_brew"]="brew"
    ["linux_apt"]="apt"
    ["linux_apt-get"]="apt-get"
    ["linux_dnf"]="dnf"
    ["linux_yum"]="yum"
    ["linux_pacman"]="pacman"
    ["linux_zypper"]="zypper"
    ["linux_emerge"]="emerge"
    ["windows_scoop"]="scoop"
    ["windows_choco"]="choco"
)

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
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

# Detect system and package manager
detect_system() {
    local OS="$(uname -s)"
    local PACKAGE_MANAGER=""
    local INSTALL_CMD=""
    local UPDATE_CMD=""
    local UPGRADE_CMD=""
    
    case "$OS" in
        Darwin)
            if command -v brew >/dev/null 2>&1; then
                PACKAGE_MANAGER="brew"
                INSTALL_CMD="brew install"
                UPDATE_CMD="brew update"
                UPGRADE_CMD="brew upgrade"
            fi
            ;;
        Linux)
            if command -v apt >/dev/null 2>&1; then
                PACKAGE_MANAGER="apt"
                INSTALL_CMD="sudo apt install -y"
                UPDATE_CMD="sudo apt update"
                UPGRADE_CMD="sudo apt upgrade -y"
            elif command -v apt-get >/dev/null 2>&1; then
                PACKAGE_MANAGER="apt-get"
                INSTALL_CMD="sudo apt-get install -y"
                UPDATE_CMD="sudo apt-get update"
                UPGRADE_CMD="sudo apt-get upgrade -y"
            elif command -v dnf >/dev/null 2>&1; then
                PACKAGE_MANAGER="dnf"
                INSTALL_CMD="sudo dnf install -y"
                UPDATE_CMD="sudo dnf check-update"
                UPGRADE_CMD="sudo dnf upgrade -y"
            elif command -v yum >/dev/null 2>&1; then
                PACKAGE_MANAGER="yum"
                INSTALL_CMD="sudo yum install -y"
                UPDATE_CMD="sudo yum check-update"
                UPGRADE_CMD="sudo yum upgrade -y"
            elif command -v pacman >/dev/null 2>&1; then
                PACKAGE_MANAGER="pacman"
                INSTALL_CMD="sudo pacman -S --noconfirm"
                UPDATE_CMD="sudo pacman -Sy"
                UPGRADE_CMD="sudo pacman -Su --noconfirm"
            elif command -v zypper >/dev/null 2>&1; then
                PACKAGE_MANAGER="zypper"
                INSTALL_CMD="sudo zypper install -y"
                UPDATE_CMD="sudo zypper refresh"
                UPGRADE_CMD="sudo zypper update -y"
            elif command -v emerge >/dev/null 2>&1; then
                PACKAGE_MANAGER="emerge"
                INSTALL_CMD="sudo emerge"
                UPDATE_CMD="sudo emerge --sync"
                UPGRADE_CMD="sudo emerge -uDU @world"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            if command -v scoop >/dev/null 2>&1; then
                PACKAGE_MANAGER="scoop"
                INSTALL_CMD="scoop install"
                UPDATE_CMD="scoop update"
                UPGRADE_CMD="scoop update *"
            elif command -v choco >/dev/null 2>&1; then
                PACKAGE_MANAGER="choco"
                INSTALL_CMD="choco install -y"
                UPDATE_CMD="choco upgrade all -y"
                UPGRADE_CMD="choco upgrade all -y"
            fi
            ;;
    esac
    
    echo "$PACKAGE_MANAGER:$INSTALL_CMD:$UPDATE_CMD:$UPGRADE_CMD"
}

# Check if package is installed
is_package_installed() {
    local package="$1"
    local package_manager_info=$(detect_system)
    local package_manager=$(echo "$package_manager_info" | cut -d: -f1)
    
    case "$package_manager" in
        brew)
            brew list --formula | grep -q "^${package}$"
            ;;
        apt|apt-get)
            dpkg -l | grep -q "^ii  $package"
            ;;
        dnf|yum)
            rpm -q "$package" >/dev/null 2>&1
            ;;
        pacman)
            pacman -Q "$package" >/dev/null 2>&1
            ;;
        zypper)
            zypper se -i "$package" | grep -q "^i.*$package"
            ;;
        emerge)
            qlist -I "$package" >/dev/null 2>&1
            ;;
        scoop)
            scoop list | grep -q "^ $package "
            ;;
        choco)
            choco list --local-only | grep -q "^$package "
            ;;
        *)
            # Fallback: check if command exists
            command -v "$package" >/dev/null 2>&1
            ;;
    esac
}

# Get package version
get_package_version() {
    local package="$1"
    local package_manager_info=$(detect_system)
    local package_manager=$(echo "$package_manager_info" | cut -d: -f1)
    
    case "$package_manager" in
        brew)
            brew list --formula --versions "$package" | awk '{print $2}'
            ;;
        apt|apt-get)
            apt-cache policy "$package" | grep 'Installed:' | awk '{print $2}'
            ;;
        dnf|yum)
            rpm -q --queryformat '%{VERSION}-%{RELEASE}' "$package" 2>/dev/null
            ;;
        pacman)
            pacman -Q "$package" | awk '{print $2}'
            ;;
        zypper)
            zypper info "$package" | grep 'Version' | awk '{print $3}'
            ;;
        emerge)
            emerge -p "$package" | grep -o '\[[0-9].*\]' | tr -d '[]'
            ;;
        scoop)
            scoop list | grep "^ $package " | awk '{print $2}'
            ;;
        choco)
            choco list --local-only | grep "^$package " | awk '{print $2}'
            ;;
        *)
            # Fallback: use command version
            if command -v "$package" >/dev/null 2>&1; then
                "$package" --version 2>/dev/null | head -1 || echo "unknown"
            else
                echo "not-installed"
            fi
            ;;
    esac
}

# Check for package updates
check_package_updates() {
    local package="$1"
    local package_manager_info=$(detect_system)
    local package_manager=$(echo "$package_manager_info" | cut -d: -f1)
    
    case "$package_manager" in
        brew)
            brew outdated | grep -q "^$package "
            ;;
        apt|apt-get)
            apt list --upgradable 2>/dev/null | grep -q "^$package/"
            ;;
        dnf|yum)
            dnf check-update "$package" 2>/dev/null | grep -q "^$package"
            ;;
        pacman)
            pacman -Qu "$package" >/dev/null 2>&1
            ;;
        zypper)
            zypper list-updates | grep -q "$package"
            ;;
        emerge)
            emerge -pu "$package" | grep -q '^\[ebuild'
            ;;
        scoop)
            scoop status | grep -q "$package.*outdated"
            ;;
        choco)
            choco outdated | grep -q "^$package "
            ;;
        *)
            false
            ;;
    esac
}

# Install package
install_package() {
    local package="$1"
    local package_manager_info=$(detect_system)
    local package_manager=$(echo "$package_manager_info" | cut -d: -f1)
    local install_cmd=$(echo "$package_manager_info" | cut -d: -f2)
    
    if [ -z "$package_manager" ]; then
        log_error "No package manager found. Please install one manually."
        return 1
    fi
    
    log_info "Installing $package using $package_manager..."
    
    if eval "$install_cmd $package"; then
        log_success "$package installed successfully"
        return 0
    else
        log_error "Failed to install $package"
        return 1
    fi
}

# Update package
update_package() {
    local package="$1"
    local package_manager_info=$(detect_system)
    local package_manager=$(echo "$package_manager_info" | cut -d: -f1)
    local upgrade_cmd=$(echo "$package_manager_info" | cut -d: -f4)
    
    if [ -z "$package_manager" ]; then
        log_error "No package manager found."
        return 1
    fi
    
    log_info "Updating $package using $package_manager..."
    
    case "$package_manager" in
        brew)
            brew upgrade "$package"
            ;;
        apt|apt-get)
            sudo apt upgrade -y "$package"
            ;;
        dnf|yum)
            sudo dnf upgrade -y "$package"
            ;;
        pacman)
            sudo pacman -Su --noconfirm "$package"
            ;;
        zypper)
            sudo zypper update -y "$package"
            ;;
        emerge)
            sudo emerge -u "$package"
            ;;
        scoop)
            scoop update "$package"
            ;;
        choco)
            choco upgrade -y "$package"
            ;;
        *)
            log_error "Update not supported for $package_manager"
            return 1
            ;;
    esac
}

# Save package state
save_package_state() {
    local package="$1"
    local state="$2"
    local version="$3"
    
    echo "$package:$state:$version:$(date '+%Y-%m-%d %H:%M:%S')" >> "$STATE_DIR/packages.txt"
}

# Get package state
get_package_state() {
    local package="$1"
    local state_file="$STATE_DIR/packages.txt"
    
    if [ -f "$state_file" ]; then
        grep "^$package:" "$state_file" | tail -1 | cut -d: -f2
    else
        echo "unknown"
    fi
}

# Show package status
show_package_status() {
    local package="$1"
    
    if is_package_installed "$package"; then
        local version=$(get_package_version "$package")
        local state=$(get_package_state "$package")
        
        if check_package_updates "$package"; then
            echo -e "${GREEN}✓${NC} $package (${version}) - ${YELLOW}Update available${NC}"
        else
            echo -e "${GREEN}✓${NC} $package (${version}) - ${GREEN}Up to date${NC}"
        fi
        
        echo "  State: $state"
        echo "  Last checked: $(grep "^$package:" "$STATE_DIR/packages.txt" | tail -1 | cut -d: -f4)"
    else
        echo -e "${RED}✗${NC} $package - ${RED}Not installed${NC}"
    fi
}

# Show all packages status
show_all_packages_status() {
    echo "Package Status:"
    echo "==============="
    
    for package in "${!PACKAGES[@]}"; do
        show_package_status "$package"
        echo ""
    done
}

# Smart install package
smart_install() {
    local package="$1"
    
    log_info "Smart installing $package..."
    
    # Check if already installed
    if is_package_installed "$package"; then
        local version=$(get_package_version "$package")
        log_success "$package is already installed (version: $version)"
        
        # Check for updates
        if check_package_updates "$package"; then
            log_warning "Update available for $package"
            read -p "Do you want to update $package? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if update_package "$package"; then
                    save_package_state "$package" "updated" "$(get_package_version "$package")"
                fi
            fi
        else
            log_success "$package is up to date"
        fi
    else
        # Install package
        if install_package "$package"; then
            save_package_state "$package" "installed" "$(get_package_version "$package")"
        fi
    fi
}

# Update all packages
update_all_packages() {
    local package_manager_info=$(detect_system)
    local package_manager=$(echo "$package_manager_info" | cut -d: -f1)
    local update_cmd=$(echo "$package_manager_info" | cut -d: -f3)
    local upgrade_cmd=$(echo "$package_manager_info" | cut -d: -f4)
    
    if [ -z "$package_manager" ]; then
        log_error "No package manager found."
        return 1
    fi
    
    log_info "Updating package manager..."
    eval "$update_cmd"
    
    log_info "Upgrading all packages..."
    if eval "$upgrade_cmd"; then
        log_success "All packages updated successfully"
        
        # Update state for all packages
        for package in "${!PACKAGES[@]}"; do
            if is_package_installed "$package"; then
                save_package_state "$package" "updated" "$(get_package_version "$package")"
            fi
        done
    else
        log_error "Failed to update packages"
        return 1
    fi
}

# Clean package cache
clean_package_cache() {
    log_info "Cleaning package cache..."
    
    local package_manager_info=$(detect_system)
    local package_manager=$(echo "$package_manager_info" | cut -d: -f1)
    
    case "$package_manager" in
        brew)
            brew cleanup
            ;;
        apt|apt-get)
            sudo apt autoremove -y
            sudo apt clean
            ;;
        dnf|yum)
            sudo dnf autoremove -y
            sudo dnf clean all
            ;;
        pacman)
            sudo pacman -Scc --noconfirm
            ;;
        zypper)
            sudo zypper clean --all
            ;;
        emerge)
            sudo emerge --depclean
            sudo eclean-dist
            ;;
        scoop)
            scoop cleanup *
            ;;
        choco)
            choco cleanup
            ;;
        *)
            log_warning "Cache cleaning not supported for $package_manager"
            ;;
    esac
    
    # Clean our own cache
    rm -rf "$CACHE_DIR"/*
    
    log_success "Package cache cleaned"
}

# Show help
show_help() {
    echo "Smart Package Manager - Intelligent software download and update management"
    echo ""
    echo "Usage: $0 [command] [package]"
    echo ""
    echo "Commands:"
    echo "  install <package>   Smart install a package"
    echo "  update <package>    Update a specific package"
    echo "  update-all           Update all packages"
    echo "  status <package>    Show package status"
    echo "  status-all          Show all packages status"
    echo "  clean-cache         Clean package cache"
    echo "  list                List available packages"
    echo "  help                Show this help"
    echo ""
    echo "Available packages:"
    for package in "${!PACKAGES[@]}"; do
        echo "  $package - ${PACKAGES[$package]}"
    done
}

# List available packages
list_packages() {
    echo "Available packages:"
    echo "==================="
    
    for package in "${!PACKAGES[@]}"; do
        if is_package_installed "$package"; then
            echo -e "${GREEN}✓${NC} $package - ${PACKAGES[$package]}"
        else
            echo -e "${RED}✗${NC} $package - ${PACKAGES[$package]}"
        fi
    done
}

# Main function
main() {
    local command="${1:-help}"
    local package="$2"
    
    case "$command" in
        install)
            if [ -z "$package" ]; then
                log_error "Please specify a package to install"
                exit 1
            fi
            smart_install "$package"
            ;;
        update)
            if [ -z "$package" ]; then
                log_error "Please specify a package to update"
                exit 1
            fi
            update_package "$package"
            ;;
        update-all)
            update_all_packages
            ;;
        status)
            if [ -z "$package" ]; then
                log_error "Please specify a package to check"
                exit 1
            fi
            show_package_status "$package"
            ;;
        status-all)
            show_all_packages_status
            ;;
        clean-cache)
            clean_package_cache
            ;;
        list)
            list_packages
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