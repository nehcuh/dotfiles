#!/bin/bash
# Unified cross-platform dotfiles installer
# Supports Linux, macOS, and Windows (via WSL/MSYS2)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Detect platform
OS="$(uname -s)"
DISTRO=""
PLATFORM=""

# More detailed OS detection
case "$OS" in
    Linux)
        if [ -f /etc/os-release ]; then
            DISTRO=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
        elif command -v lsb_release >/dev/null 2>&1; then
            DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        fi
        PLATFORM="linux"
        ;;
    Darwin)
        PLATFORM="macos"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        PLATFORM="windows"
        ;;
    *)
        echo -e "${RED}Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac

# Dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"
if [ "$PLATFORM" = "windows" ]; then
    DOTFILES_DIR="$HOME/.dotfiles"
fi

# Function to check and request sudo access
check_sudo_access() {
    echo -e "${YELLOW}Checking sudo access...${NC}"
    
    # Check if we already have sudo access
    if sudo -n true 2>/dev/null; then
        echo -e "${GREEN}✓ Sudo access confirmed${NC}"
        return 0
    fi
    
    # Request sudo access
    echo -e "${YELLOW}This script requires sudo access for system-wide changes.${NC}"
    echo -e "${YELLOW}Please enter your password when prompted.${NC}"
    
    if ! sudo -v; then
        echo -e "${RED}Error: Failed to obtain sudo access${NC}"
        echo -e "${RED}Please ensure your user has administrative privileges.${NC}"
        echo -e "${YELLOW}On macOS, you may need to:${NC}"
        echo -e "${YELLOW}1. Add your user to the admin group${NC}"
        echo -e "${YELLOW}2. Enable 'Administrator' privileges in System Preferences > Users & Groups${NC}"
        echo -e "${YELLOW}3. Or run this script with a user that has admin rights${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Sudo access obtained${NC}"
}

# Function to keep sudo session alive
keep_sudo_alive() {
    echo -e "${BLUE}Maintaining sudo session...${NC}"
    # Keep-alive: update existing sudo time stamp until script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Function to safely run sudo commands with error handling
safe_sudo() {
    if ! sudo "$@" 2>/dev/null; then
        echo -e "${RED}Error: Failed to run command with sudo: $*${NC}"
        echo -e "${YELLOW}You may need to run this command manually:${NC}"
        echo -e "${YELLOW}sudo $*${NC}"
        return 1
    fi
    return 0
}

# Print header
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Cross-Platform Dotfiles                   ║"
echo "║                    Linux • macOS • Windows                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${BLUE}🚀 Starting installation on $OS${DISTRO:+ ($DISTRO)}...${NC}"

# Check for sudo access on Unix-like systems
if [ "$PLATFORM" != "windows" ]; then
    check_sudo_access
    keep_sudo_alive
fi

# Function to install packages based on platform
install_packages() {
    case "$PLATFORM" in
        linux)
            install_linux_packages
            ;;
        macos)
            install_macos_packages
            ;;
        windows)
            install_windows_packages
            ;;
    esac
}

install_macos_packages() {
    echo -e "${YELLOW}Installing macOS packages...${NC}"
    
    # Check if Xcode Command Line Tools are installed
    if ! command -v xcode-select &> /dev/null; then
        echo -e "${YELLOW}Installing Xcode Command Line Tools...${NC}"
        xcode-select --install
        echo -e "${GREEN}✓ Xcode Command Line Tools installed${NC}"
        echo -e "${YELLOW}Please press Enter when Xcode installation is complete${NC}"
        read -p ""
    fi

    # Install Homebrew if not exists
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [ -d "/opt/homebrew/bin" ]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        echo -e "${GREEN}✓ Homebrew installed${NC}"
    fi

    # Install GNU Stow
    if ! command -v stow &> /dev/null; then
        echo -e "${YELLOW}Installing GNU Stow...${NC}"
        brew install stow
        echo -e "${GREEN}✓ GNU Stow installed${NC}"
    fi
}

install_linux_packages() {
    echo -e "${YELLOW}Installing Linux packages...${NC}"
    
    # Install stow based on distro
    case "$DISTRO" in
        ubuntu|debian|linuxmint)
            echo -e "${YELLOW}Installing packages for Debian/Ubuntu...${NC}"
            if ! safe_sudo apt update; then
                echo -e "${RED}Failed to update package lists${NC}"
                return 1
            fi
            if ! safe_sudo apt install -y git stow curl build-essential; then
                echo -e "${RED}Failed to install required packages${NC}"
                return 1
            fi
            ;;
        arch|manjaro)
            echo -e "${YELLOW}Installing packages for Arch/Manjaro...${NC}"
            if ! safe_sudo pacman -Syu --noconfirm git stow curl base-devel; then
                echo -e "${RED}Failed to install required packages${NC}"
                return 1
            fi
            ;;
        fedora|centos|rhel)
            echo -e "${YELLOW}Installing packages for Fedora/CentOS...${NC}"
            if ! safe_sudo dnf install -y git stow curl @development-tools; then
                echo -e "${RED}Failed to install required packages${NC}"
                return 1
            fi
            ;;
        *)
            echo -e "${YELLOW}Installing packages for generic Linux...${NC}"
            if command -v apt >/dev/null 2>&1; then
                if ! safe_sudo apt update; then
                    echo -e "${RED}Failed to update package lists${NC}"
                    return 1
                fi
                if ! safe_sudo apt install -y git stow curl build-essential; then
                    echo -e "${RED}Failed to install required packages${NC}"
                    return 1
                fi
            elif command -v pacman >/dev/null 2>&1; then
                if ! safe_sudo pacman -Syu --noconfirm git stow curl base-devel; then
                    echo -e "${RED}Failed to install required packages${NC}"
                    return 1
                fi
            elif command -v dnf >/dev/null 2>&1; then
                if ! safe_sudo dnf install -y git stow curl @development-tools; then
                    echo -e "${RED}Failed to install required packages${NC}"
                    return 1
                fi
            else
                echo -e "${RED}Please install git, stow, curl, and build tools manually${NC}"
                return 1
            fi
            ;;
    esac
    
    # Install Linux Homebrew (optional, for tools not available in package manager)
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Would you like to install Linux Homebrew? (y/N)${NC}"
        read -r install_homebrew
        if [ "$install_homebrew" = "y" ] || [ "$install_homebrew" = "Y" ]; then
            echo -e "${YELLOW}Installing Linux Homebrew...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Add Homebrew to PATH
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            echo -e "${GREEN}✓ Linux Homebrew installed${NC}"
        fi
    fi
}

install_windows_packages() {
    echo -e "${YELLOW}Installing Windows packages...${NC}"
    
    # Check if we're in WSL or MSYS2
    if grep -q Microsoft /proc/version 2>/dev/null; then
        echo -e "${YELLOW}Detected WSL environment${NC}"
        # Install stow via apt
        if ! command -v stow &> /dev/null; then
            echo -e "${YELLOW}Installing packages in WSL...${NC}"
            if ! safe_sudo apt update; then
                echo -e "${RED}Failed to update package lists in WSL${NC}"
                return 1
            fi
            if ! safe_sudo apt install -y git stow curl; then
                echo -e "${RED}Failed to install packages in WSL${NC}"
                return 1
            fi
            echo -e "${GREEN}✓ WSL packages installed${NC}"
        fi
    elif command -v pacman &> /dev/null; then
        echo -e "${YELLOW}Detected MSYS2 environment${NC}"
        # Install stow via pacman
        if ! command -v stow &> /dev/null; then
            echo -e "${YELLOW}Installing packages in MSYS2...${NC}"
            if ! pacman -Syu --noconfirm git stow curl; then
                echo -e "${RED}Failed to install packages in MSYS2${NC}"
                return 1
            fi
            echo -e "${GREEN}✓ MSYS2 packages installed${NC}"
        fi
    else
        echo -e "${RED}Unsupported Windows environment${NC}"
        echo -e "${YELLOW}Please use WSL or MSYS2 for Windows support${NC}"
        return 1
    fi
}

# Clone dotfiles if not exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${YELLOW}Cloning dotfiles...${NC}"
    git clone https://github.com/nehcuh/dotfiles.git "$DOTFILES_DIR"
    echo -e "${GREEN}✓ Dotfiles cloned${NC}"
fi

cd "$DOTFILES_DIR"

# Install packages
if ! install_packages; then
    echo -e "${RED}Error: Failed to install required packages${NC}"
    echo -e "${YELLOW}Please check the error messages above and try again${NC}"
    exit 1
fi

# Install dotfiles packages in order
echo -e "${YELLOW}Installing dotfiles packages...${NC}"

# System packages first
echo -e "${BLUE}Installing system packages...${NC}"
./scripts/stow.sh install system

# Platform-specific packages
case "$PLATFORM" in
    macos)
        echo -e "${BLUE}Installing macOS-specific packages...${NC}"
        ./scripts/stow.sh install macos
        ;;
    linux)
        echo -e "${BLUE}Installing Linux-specific packages...${NC}"
        ./scripts/stow.sh install linux
        ;;
    windows)
        echo -e "${BLUE}Installing Windows-specific packages...${NC}"
        ./scripts/stow.sh install windows
        ;;
esac

# Shell configuration
echo -e "${BLUE}Installing shell configuration...${NC}"
./scripts/stow.sh install zsh

# Development tools
echo -e "${BLUE}Installing development tools...${NC}"
./scripts/stow.sh install git tools

# Editors
echo -e "${BLUE}Installing editors...${NC}"
./scripts/stow.sh install vim nvim tmux

# Zed editor configuration
if command -v zed >/dev/null 2>&1; then
    echo -e "${BLUE}Installing Zed configuration...${NC}"
    ./scripts/stow.sh install zed
fi

# Setup Python environment
echo -e "${BLUE}Setting up Python environment...${NC}"
./scripts/setup-python-env.sh

# Setup Node.js environment
echo -e "${BLUE}Setting up Node.js environment...${NC}"
./scripts/setup-node-env.sh

# Platform-specific installations
case "$PLATFORM" in
    macos)
        echo -e "${YELLOW}Installing Homebrew packages...${NC}"
        if command -v brew >/dev/null 2>&1; then
            brew bundle --global
        fi
        ;;
    linux)
        echo -e "${YELLOW}Installing Linux packages...${NC}"
        
        # Install Homebrew packages if available
        if command -v brew >/dev/null 2>&1; then
            if [ -f "stow-packs/system/Brewfile.linux" ]; then
                HOMEBREW_BUNDLE_FILE="stow-packs/system/Brewfile.linux" brew bundle --global
            else
                brew bundle --global
            fi
        fi
        ;;
    windows)
        echo -e "${YELLOW}Windows-specific setup...${NC}"
        if [ -d "stow-packs/windows" ]; then
            ./scripts/stow.sh install windows
        fi
        ;;
esac

# Install Oh My Tmux if not exists
if [ ! -d "$HOME/.tmux" ]; then
    echo -e "${YELLOW}Installing Oh My Tmux...${NC}"
    git clone https://github.com/gpakosz/.tmux.git ~/.tmux
    ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
    cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
fi

# Install Zinit if not exists
if [ ! -d "$HOME/.local/share/zinit" ]; then
    echo -e "${YELLOW}Installing Zinit...${NC}"
    sh -c "$(curl -fsSL https://git.io/zinit-install)"
fi

# Change default shell to zsh (Unix-like systems only)
if [ "$PLATFORM" != "windows" ] && [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${YELLOW}Changing default shell to zsh...${NC}"
    
    ZSH_PATH=$(which zsh)
    if [ -z "$ZSH_PATH" ]; then
        echo -e "${RED}Error: zsh not found in PATH${NC}"
        echo -e "${YELLOW}Please install zsh first${NC}"
    else
        if [ "$PLATFORM" = "macos" ]; then
            if ! safe_sudo chsh -s "$ZSH_PATH" $USER; then
                echo -e "${YELLOW}Warning: Could not change default shell to zsh${NC}"
                echo -e "${YELLOW}You may need to run manually: sudo chsh -s $ZSH_PATH $USER${NC}"
            else
                echo -e "${GREEN}✓ Default shell changed to zsh${NC}"
            fi
        else
            # On Linux, we need to check if zsh is in /etc/shells
            if ! grep -q "$ZSH_PATH" /etc/shells; then
                echo -e "${YELLOW}Adding zsh to /etc/shells...${NC}"
                if ! echo "$ZSH_PATH" | safe_sudo tee -a /etc/shells >/dev/null; then
                    echo -e "${YELLOW}Warning: Could not add zsh to /etc/shells${NC}"
                    echo -e "${YELLOW}You may need to run manually: echo '$ZSH_PATH' | sudo tee -a /etc/shells${NC}"
                fi
            fi
            
            if ! safe_sudo chsh -s "$ZSH_PATH" $USER; then
                echo -e "${YELLOW}Warning: Could not change default shell to zsh${NC}"
                echo -e "${YELLOW}You may need to run manually: sudo chsh -s $ZSH_PATH $USER${NC}"
            else
                echo -e "${GREEN}✓ Default shell changed to zsh${NC}"
            fi
        fi
    fi
fi

# Setup git configuration
echo -e "${BLUE}Setting up git configuration...${NC}"
./scripts/setup-git-config.sh

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                      Installation Complete!                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${YELLOW}Please restart your terminal to apply all changes.${NC}"
echo -e "${BLUE}You can manage your dotfiles with:${NC}"
echo -e "${CYAN}  cd ~/.dotfiles && ./stow.sh [install|remove|list|status]${NC}"
echo ""
echo -e "${GREEN}🎉 Happy coding!${NC}"