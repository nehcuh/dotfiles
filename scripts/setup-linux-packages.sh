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

# Utility functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

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
    
    # Remove any cask entries from the Brewfile before installation
    grep -v "^cask " "$brewfile_path" | brew bundle --file=-
    
    log_success "Homebrew packages installed"
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

# Install Visual Studio Code
install_vscode() {
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
    else
        log_error "Failed to install Visual Studio Code"
    fi
}

# Install Zed editor
install_zed() {
    log_info "Installing Zed editor..."
    
    # Zed official installation script for Linux
    curl -f https://zed.dev/install.sh | sh
    
    if command -v zed &> /dev/null; then
        log_success "Zed editor installed successfully"
    else
        log_error "Failed to install Zed editor"
    fi
}

# Install Google Chrome
install_chrome() {
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
            fi
            ;;
        *)
            log_warning "Google Chrome installation not supported for this distribution"
            ;;
    esac
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
    
    echo
    log_success "Linux package installation completed!"
    log_info "Please restart your terminal or run 'source ~/.profile' to apply Homebrew PATH changes"
}

# Run main function
main "$@"
