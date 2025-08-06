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

# Print header
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Cross-Platform Dotfiles                   ║"
echo "║                    Linux • macOS • Windows                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${BLUE}🚀 Starting installation on $OS${DISTRO:+ ($DISTRO)}...${NC}"

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
            sudo apt update
            sudo apt install -y git stow curl build-essential
            ;;
        arch|manjaro)
            echo -e "${YELLOW}Installing packages for Arch/Manjaro...${NC}"
            sudo pacman -Syu --noconfirm git stow curl base-devel
            ;;
        fedora|centos|rhel)
            echo -e "${YELLOW}Installing packages for Fedora/CentOS...${NC}"
            sudo dnf install -y git stow curl @development-tools
            ;;
        *)
            echo -e "${YELLOW}Installing packages for generic Linux...${NC}"
            if command -v apt >/dev/null 2>&1; then
                sudo apt update
                sudo apt install -y git stow curl build-essential
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -Syu --noconfirm git stow curl base-devel
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y git stow curl @development-tools
            else
                echo -e "${RED}Please install git, stow, curl, and build tools manually${NC}"
                exit 1
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
            sudo apt update && sudo apt install -y git stow curl
        fi
    elif command -v pacman &> /dev/null; then
        echo -e "${YELLOW}Detected MSYS2 environment${NC}"
        # Install stow via pacman
        if ! command -v stow &> /dev/null; then
            pacman -Syu --noconfirm git stow curl
        fi
    else
        echo -e "${RED}Unsupported Windows environment${NC}"
        echo -e "${YELLOW}Please use WSL or MSYS2 for Windows support${NC}"
        exit 1
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
install_packages

# Install dotfiles packages in order
echo -e "${YELLOW}Installing dotfiles packages...${NC}"

# System packages first
echo -e "${BLUE}Installing system packages...${NC}"
./scripts/stow.sh install system

# Platform-specific packages
case "$PLATFORM" in
    macos)
        echo -e "${BLUE}Installing macOS-specific packages...${NC}"
        # macOS specific packages if any
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
    if [ "$PLATFORM" = "macos" ]; then
        sudo chsh -s $(which zsh) $USER
    else
        # On Linux, we need to check if zsh is in /etc/shells
        if ! grep -q "$(which zsh)" /etc/shells; then
            echo "$(which zsh)" | sudo tee -a /etc/shells
        fi
        sudo chsh -s $(which zsh) $USER
    fi
    echo -e "${GREEN}✓ Default shell changed to zsh${NC}"
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