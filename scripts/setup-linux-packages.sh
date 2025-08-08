#!/bin/bash
# Linux package installation script
# Handles Homebrew, native package managers, and custom app installations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation summary tracking
declare -a INSTALLED_APPS=()
declare -a SKIPPED_APPS=()
declare -a FAILED_APPS=()

# Utility functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Track installation results
track_install() {
    local app=$1
    local status=$2  # "installed", "skipped", "failed"
    
    case $status in
        "installed")
            INSTALLED_APPS+=("$app")
            ;;
        "skipped")
            SKIPPED_APPS+=("$app")
            ;;
        "failed")
            FAILED_APPS+=("$app")
            ;;
    esac
}

# Show installation summary
show_summary() {
    echo
    echo "========================================"
    echo "         Installation Summary           "
    echo "========================================"
    
    if [ ${#INSTALLED_APPS[@]} -gt 0 ]; then
        log_success "Installed/Updated (${#INSTALLED_APPS[@]}):"
        for app in "${INSTALLED_APPS[@]}"; do
            log_info "  ✓ $app"
        done
        echo
    fi
    
    if [ ${#SKIPPED_APPS[@]} -gt 0 ]; then
        log_warning "Skipped (${#SKIPPED_APPS[@]}):"
        for app in "${SKIPPED_APPS[@]}"; do
            log_info "  - $app (already installed)"
        done
        echo
    fi
    
    if [ ${#FAILED_APPS[@]} -gt 0 ]; then
        log_error "Failed (${#FAILED_APPS[@]}):"
        for app in "${FAILED_APPS[@]}"; do
            log_info "  ✗ $app"
        done
        echo
    fi
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
    elif [ -f /etc/debian_version ]; then
        OS="debian"
    else
        OS=$(uname -s)
    fi
    
    log_info "Detected distribution: $OS"
}

# Install Homebrew for Linux
install_homebrew() {
    if command -v brew &> /dev/null; then
        log_info "Homebrew already installed"
        return
    fi
    
    log_info "Installing Homebrew for Linux..."
    
    # Download and run the official Homebrew installation script
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
    # Verify installation
    if command -v brew &> /dev/null; then
        log_success "Homebrew installed successfully"
    else
        log_error "Failed to install Homebrew"
        exit 1
    fi
}

# Install packages via Homebrew (CLI tools only, no cask)
install_homebrew_packages() {
    local brewfile_path="$HOME/.Brewfile.linux"
    
    if [ ! -f "$brewfile_path" ]; then
        log_warning "Linux Brewfile not found at $brewfile_path"
        return
    fi
    
    log_info "Installing Homebrew packages from $brewfile_path..."
    
    # Check if we should skip or update existing packages
    if [ "$NON_INTERACTIVE" != "true" ]; then
        # Count existing packages
        local existing_count=0
        local total_packages=0
        
        while IFS= read -r line; do
            if [[ $line =~ ^brew\s+"([^"]+)" ]]; then
                local package_name="${BASH_REMATCH[1]}"
                ((total_packages++))
                if brew list "$package_name" &>/dev/null; then
                    ((existing_count++))
                fi
            fi
        done < <(grep -v "^cask " "$brewfile_path" | grep -E "^brew\s")
        
        if [ $existing_count -gt 0 ]; then
            log_info "Found $existing_count already installed packages out of $total_packages total packages"
            log_info "What would you like to do with Homebrew packages?"
            log_info "  [i] Install missing packages only"
            log_info "  [u] Update all packages (including existing ones)"
            log_info "  [s] Skip Homebrew package installation"
            read -p "Your choice (i/u/s): " -n 1 -r brew_choice
            echo
            
            case $brew_choice in
                [Ss])
                    log_info "Skipping Homebrew package installation"
                    return
                    ;;
                [Uu])
                    log_info "Updating all Homebrew packages..."
                    ;;
                *)
                    log_info "Installing missing packages only..."
                    ;;
            esac
        fi
    fi
    
    # Remove any cask entries from the Brewfile before installation
    if grep -v "^cask " "$brewfile_path" | brew bundle --file=-; then
        log_success "Homebrew packages processed successfully"
    else
        log_warning "Some Homebrew packages failed to install"
        log_info "You can retry later with: brew bundle --file=$brewfile_path"
    fi
}

# Install packages via native package manager
install_native_packages() {
    log_info "Installing packages via native package manager..."
    
    case $OS in
        ubuntu|debian)
            # Update package list
            sudo apt update
            
            # Install essential packages
            sudo apt install -y \
                curl \
                wget \
                git \
                build-essential \
                software-properties-common \
                apt-transport-https \
                ca-certificates \
                gnupg \
                lsb-release
            ;;
        fedora)
            sudo dnf update -y
            sudo dnf install -y \
                curl \
                wget \
                git \
                @development-tools \
                dnf-plugins-core
            ;;
        arch|manjaro)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm \
                curl \
                wget \
                git \
                base-devel
            ;;
        opensuse|sles)
            sudo zypper refresh
            sudo zypper install -y \
                curl \
                wget \
                git \
                -t pattern devel_basis
            ;;
        *)
            log_warning "Unsupported distribution for native package installation"
            ;;
    esac
}

# Check if software is already installed and offer options
check_software_installed() {
    local software=$1
    local command_name=$2
    local config_paths=("${@:3}")
    
    if command -v "$command_name" &> /dev/null; then
        local version
        case $software in
            "VS Code")
                version=$(code --version 2>/dev/null | head -1 || echo "unknown")
                ;;
            "Zed")
                version=$(zed --version 2>/dev/null || echo "unknown")
                ;;
            "Chrome")
                version=$(google-chrome --version 2>/dev/null || echo "unknown")
                ;;
            *)
                version="unknown"
                ;;
        esac
        
        log_info "$software is already installed (version: $version)"
        
        if [ "$NON_INTERACTIVE" != "true" ]; then
            log_info "What would you like to do?"
            log_info "  [s] Skip installation (keep current version)"
            log_info "  [u] Update/reinstall"
            log_info "  [q] Quit installation"
            read -p "Your choice (s/u/q): " -n 1 -r choice
            echo
            
            case $choice in
                [Uu])
                    log_info "Proceeding with update/reinstall..."
                    return 0  # Continue installation
                    ;;
                [Qq])
                    log_info "Installation cancelled by user"
                    exit 0
                    ;;
                *)
                    log_success "Skipping $software installation"
                    # Check for configuration conflicts
                    check_config_conflicts "$software" "${config_paths[@]}"
                    return 1  # Skip installation
                    ;;
            esac
        else
            log_info "Non-interactive mode: skipping $software installation"
            return 1  # Skip installation
        fi
    fi
    
    return 0  # Proceed with installation
}

# Check for configuration file conflicts
check_config_conflicts() {
    local software=$1
    local config_paths=("${@:2}")
    local has_conflicts=false
    
    for config_path in "${config_paths[@]}"; do
        if [ -e "$config_path" ]; then
            has_conflicts=true
            break
        fi
    done
    
    if [ "$has_conflicts" = "true" ] && [ "$NON_INTERACTIVE" != "true" ]; then
        log_warning "$software configuration files detected:"
        for config_path in "${config_paths[@]}"; do
            if [ -e "$config_path" ]; then
                log_info "  - $config_path"
            fi
        done
        
        log_info "How would you like to handle the configuration?"
        log_info "  [k] Keep existing configuration (no changes)"
        log_info "  [b] Backup existing and install new configuration"
        log_info "  [m] Merge configurations (manual)"
        read -p "Your choice (k/b/m): " -n 1 -r config_choice
        echo
        
        case $config_choice in
            [Bb])
                local backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
                mkdir -p "$backup_dir"
                for config_path in "${config_paths[@]}"; do
                    if [ -e "$config_path" ]; then
                        local rel_path=${config_path#$HOME/}
                        local backup_path="$backup_dir/$rel_path"
                        mkdir -p "$(dirname "$backup_path")"
                        cp -r "$config_path" "$backup_path"
                        log_info "Backed up $config_path to $backup_path"
                    fi
                done
                log_success "Configurations backed up to $backup_dir"
                ;;
            [Mm])
                log_info "Manual merge selected. New configurations will be installed alongside existing ones."
                log_info "You can manually merge them later."
                ;;
            *)
                log_info "Keeping existing configuration"
                return
                ;;
        esac
    fi
}

# Install Visual Studio Code
install_vscode() {
    # Check if VS Code is already installed
    local vscode_configs=(
        "$HOME/.config/Code/User/settings.json"
        "$HOME/.config/Code/User/keybindings.json"
        "$HOME/.vscode"
    )
    
    if ! check_software_installed "VS Code" "code" "${vscode_configs[@]}"; then
        track_install "VS Code" "skipped"
        return 0  # Skip installation
    fi
    
    log_info "Installing Visual Studio Code..."
    
    case $OS in
        ubuntu|debian)
            # Remove old repository if exists
            sudo rm -f /etc/apt/sources.list.d/vscode.list
            
            # Download and install Microsoft GPG key
            wget -qO - https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
            
            # Add Microsoft repository with proper GPG key reference
            echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
            
            # Update package list and install
            if ! sudo apt update; then
                log_warning "Failed to update package list, trying to fix GPG issues..."
                
                # Remove old key and repository
                sudo rm -f /etc/apt/sources.list.d/vscode.list
                sudo rm -f /usr/share/keyrings/microsoft.gpg
                
                # Re-download and install Microsoft GPG key
                wget -qO - https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
                
                # Re-add Microsoft repository
                echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
                
                # Try update again
                sudo apt update && sudo apt upgrade -y
            fi
            
            sudo apt install -y code
            ;;
        fedora)
            # Import Microsoft GPG key
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            
            # Add Microsoft repository
            echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
            
            # Install
            sudo dnf install -y code
            ;;
        arch|manjaro)
            # Install from AUR (using yay if available, otherwise manual)
            # Install from AUR (using yay if available, otherwise manual)
            if command -v yay &> /dev/null; then
                yay -S --noconfirm visual-studio-code-bin
            elif command -v paru &> /dev/null; then
                paru -S --noconfirm visual-studio-code-bin
            else
                log_warning "AUR helper not found. Installing VS Code manually..."
                # Fallback to manual installation
                wget -O /tmp/vscode.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
                sudo tar -xzf /tmp/vscode.tar.gz -C /opt/
                sudo ln -sf /opt/VSCode-linux-x64/code /usr/local/bin/code
                rm /tmp/vscode.tar.gz
            fi
            ;;
        *)
            # Fallback: download and install tarball
            log_info "Using tarball installation for VS Code..."
            wget -O /tmp/vscode.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
            sudo tar -xzf /tmp/vscode.tar.gz -C /opt/
            sudo ln -sf /opt/VSCode-linux-x64/code /usr/local/bin/code
            rm /tmp/vscode.tar.gz
            ;;
    esac
    
    if command -v code &> /dev/null; then
        log_success "Visual Studio Code installed successfully"
        track_install "VS Code" "installed"
    else
        log_error "Failed to install Visual Studio Code"
        track_install "VS Code" "failed"
    fi
}

# Install Zed editor
install_zed() {
    # Check if Zed is already installed
    local zed_configs=(
        "$HOME/.config/zed"
        "$HOME/.local/share/zed"
    )
    
    if ! check_software_installed "Zed" "zed" "${zed_configs[@]}"; then
        track_install "Zed" "skipped"
        return 0  # Skip installation
    fi
    
    log_info "Installing Zed editor..."
    
    # Zed official installation script for Linux
    if curl -f https://zed.dev/install.sh | sh; then
        if command -v zed &> /dev/null; then
            log_success "Zed editor installed successfully"
            track_install "Zed" "installed"
        else
            log_error "Zed installation completed but command not found"
            log_info "You may need to restart your terminal or add ~/.local/bin to PATH"
            track_install "Zed" "installed"  # Consider it installed even if command not immediately available
        fi
    else
        log_error "Failed to install Zed editor"
        track_install "Zed" "failed"
    fi
}

# Install Google Chrome
install_chrome() {
    # Check if Chrome is already installed
    local chrome_configs=(
        "$HOME/.config/google-chrome"
        "$HOME/.cache/google-chrome"
    )
    
    if ! check_software_installed "Chrome" "google-chrome" "${chrome_configs[@]}"; then
        track_install "Chrome" "skipped"
        return 0  # Skip installation
    fi
    
    log_info "Installing Google Chrome..."
    
    case $OS in
        ubuntu|debian)
            # Add Google's signing key
            wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
            
            # Add Google Chrome repository
            echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
            
            # Update and install
            sudo apt update
            sudo apt install -y google-chrome-stable
            ;;
        fedora)
            # Add Google Chrome repository
            cat << EOF | sudo tee /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
            
            # Install
            sudo dnf install -y google-chrome-stable
            ;;
        arch|manjaro)
            if command -v yay &> /dev/null; then
                yay -S --noconfirm google-chrome
            else
                log_warning "AUR helper not found. Please install Google Chrome manually from AUR."
                track_install "Chrome" "failed"
                return
            fi
            ;;
        *)
            log_warning "Google Chrome installation not supported for this distribution"
            track_install "Chrome" "failed"
            return
            ;;
    esac
    
    # Verify Chrome installation
    if command -v google-chrome &> /dev/null; then
        log_success "Google Chrome installed successfully"
        track_install "Chrome" "installed"
    else
        log_error "Google Chrome installation failed"
        track_install "Chrome" "failed"
    fi
}

# Install development tools that might not be available via Homebrew
install_additional_tools() {
    log_info "Installing additional development tools..."
    
    case $OS in
        ubuntu|debian)
            sudo apt install -y \
                fonts-firacode \
                fonts-hack \
                htop \
                tree \
                unzip \
                zip
            ;;
        fedora)
            sudo dnf install -y \
                fira-code-fonts \
                hack-fonts \
                htop \
                tree \
                unzip \
                zip
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm \
                ttc-fira-code \
                ttf-hack \
                htop \
                tree \
                unzip \
                zip
            ;;
        *)
            log_warning "Additional tools installation not supported for this distribution"
            ;;
    esac
}

# Main installation function
main() {
    echo "========================================"
    echo "       Linux Package Installation      "
    echo "========================================"
    echo
    
    detect_distro
    install_native_packages
    install_homebrew
    install_homebrew_packages
    install_vscode
    install_zed
    install_chrome
    install_additional_tools
    
    show_summary
    
    log_success "Linux package installation completed!"
    log_info "Please restart your terminal or run 'source ~/.profile' to apply Homebrew PATH changes"
    
    # Show post-installation tips
    if [ ${#INSTALLED_APPS[@]} -gt 0 ]; then
        echo
        log_info "📝 Post-installation tips:"
        for app in "${INSTALLED_APPS[@]}"; do
            case $app in
                "VS Code")
                    log_info "  • VS Code: Configure with your settings or install extensions"
                    ;;
                "Zed")
                    log_info "  • Zed: Check ~/.local/bin is in your PATH if command not found"
                    ;;
                "Chrome")
                    log_info "  • Chrome: Sign in to sync your bookmarks and settings"
                    ;;
            esac
        done
    fi
}

# Run main function
main "$@"
