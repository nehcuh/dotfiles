#!/bin/bash
# Unified cross-platform dotfiles installer
# Supports Linux, macOS, and Windows (via WSL/MSYS2)

# Check if we're running in bash
if [ -z "$BASH_VERSION" ]; then
    # Try to re-exec with bash
    if command -v bash >/dev/null 2>&1; then
        exec bash "$0" "$@"
    else
        echo "Error: This script requires bash, but bash is not available."
        echo "Please install bash and run: bash $0 $*"
        exit 1
    fi
fi

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

# Function to install editors (VS Code, Zed)
install_editors() {
    echo -e "${BLUE}Installing editors...${NC}"
    
    case "$PLATFORM" in
        macos)
            install_macos_editors
            ;;
        linux)
            install_linux_editors
            ;;
        windows)
            install_windows_editors
            ;;
    esac
}

install_macos_editors() {
    echo -e "${YELLOW}Installing macOS editors...${NC}"
    
    # Use Homebrew Cask for GUI applications
    if command -v brew >/dev/null 2>&1; then
        # Install Zed editor
        if ! command -v zed >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing Zed editor...${NC}"
            if ! brew install --cask zed 2>/dev/null; then
                echo -e "${RED}Failed to install Zed via Homebrew Cask${NC}"
                echo -e "${YELLOW}You can install it manually from: https://zed.dev${NC}"
            else
                echo -e "${GREEN}✓ Zed editor installed${NC}"
            fi
        else
            echo -e "${GREEN}✓ Zed editor already installed${NC}"
        fi
        
        # Install Visual Studio Code
        if ! command -v code >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing Visual Studio Code...${NC}"
            if ! brew install --cask visual-studio-code 2>/dev/null; then
                echo -e "${RED}Failed to install VS Code via Homebrew Cask${NC}"
                echo -e "${YELLOW}You can install it manually from: https://code.visualstudio.com${NC}"
            else
                echo -e "${GREEN}✓ Visual Studio Code installed${NC}"
            fi
        else
            echo -e "${GREEN}✓ Visual Studio Code already installed${NC}"
        fi
    else
        echo -e "${RED}Homebrew not available. Please install editors manually.${NC}"
        echo -e "${YELLOW}Zed: https://zed.dev${NC}"
        echo -e "${YELLOW}VS Code: https://code.visualstudio.com${NC}"
    fi
}

install_linux_editors() {
    echo -e "${YELLOW}Installing Linux editors...${NC}"
    
    # Try to install Zed editor
    if ! command -v zed >/dev/null 2>&1; then
        echo -e "${YELLOW}Installing Zed editor...${NC}"
        
        # Try different installation methods
        if install_zed_linux; then
            echo -e "${GREEN}✓ Zed editor installed${NC}"
        else
            echo -e "${RED}Failed to install Zed editor${NC}"
            echo -e "${YELLOW}You can install it manually from: https://zed.dev${NC}"
        fi
    else
        echo -e "${GREEN}✓ Zed editor already installed${NC}"
    fi
    
    # Try to install VS Code
    if ! command -v code >/dev/null 2>&1; then
        echo -e "${YELLOW}Installing Visual Studio Code...${NC}"
        
        # Try different installation methods
        if install_vscode_linux; then
            echo -e "${GREEN}✓ Visual Studio Code installed${NC}"
        else
            echo -e "${RED}Failed to install VS Code${NC}"
            echo -e "${YELLOW}You can install it manually from: https://code.visualstudio.com${NC}"
        fi
    else
        echo -e "${GREEN}✓ Visual Studio Code already installed${NC}"
    fi
}

install_zed_linux() {
    # Try package managers first
    case "$DISTRO" in
        ubuntu|debian|linuxmint)
            if command -v apt >/dev/null 2>&1; then
                echo -e "${YELLOW}Trying to install Zed via apt...${NC}"
                # Add Zed's official repository
                if ! safe_sudo apt update; then
                    return 1
                fi
                if ! safe_sudo apt install -y curl gpg; then
                    return 1
                fi
                # Add Zed's GPG key and repository
                curl -fsSL https://zed.dev/install.sh | sh
                return $?
            fi
            ;;
        arch|manjaro)
            if command -v pacman >/dev/null 2>&1; then
                echo -e "${YELLOW}Trying to install Zed via pacman...${NC}"
                # Zed is available in AUR
                if command -v yay >/dev/null 2>&1; then
                    yay -S --noconfirm zed
                    return $?
                elif command -v paru >/dev/null 2>&1; then
                    paru -S --noconfirm zed
                    return $?
                else
                    echo -e "${YELLOW}AUR helper not found. Please install yay or paru first.${NC}"
                    return 1
                fi
            fi
            ;;
        fedora|centos|rhel)
            if command -v dnf >/dev/null 2>&1; then
                echo -e "${YELLOW}Trying to install Zed via dnf...${NC}"
                # Use official installation script
                curl -fsSL https://zed.dev/install.sh | sh
                return $?
            fi
            ;;
    esac
    
    # Try official installation script as fallback
    echo -e "${YELLOW}Trying Zed official installation script...${NC}"
    if curl -fsSL https://zed.dev/install.sh | sh; then
        return 0
    fi
    
    return 1
}

install_vscode_linux() {
    # Try package managers first
    case "$DISTRO" in
        ubuntu|debian|linuxmint)
            if command -v apt >/dev/null 2>&1; then
                echo -e "${YELLOW}Trying to install VS Code via apt...${NC}"
                # Add Microsoft's GPG key and repository
                if ! safe_sudo apt update; then
                    return 1
                fi
                if ! safe_sudo apt install -y curl gpg wget; then
                    return 1
                fi
                
                # Add Microsoft GPG key
                curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | safe_sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null
                
                # Add VS Code repository
                echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | safe_sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
                
                # Install VS Code
                if ! safe_sudo apt update; then
                    return 1
                fi
                if safe_sudo apt install -y code; then
                    return 0
                fi
            fi
            ;;
        arch|manjaro)
            if command -v pacman >/dev/null 2>&1; then
                echo -e "${YELLOW}Trying to install VS Code via pacman...${NC}"
                # VS Code is available in AUR
                if command -v yay >/dev/null 2>&1; then
                    yay -S --noconfirm visual-studio-code-bin
                    return $?
                elif command -v paru >/dev/null 2>&1; then
                    paru -S --noconfirm visual-studio-code-bin
                    return $?
                else
                    echo -e "${YELLOW}AUR helper not found. Please install yay or paru first.${NC}"
                    return 1
                fi
            fi
            ;;
        fedora|centos|rhel)
            if command -v dnf >/dev/null 2>&1; then
                echo -e "${YELLOW}Trying to install VS Code via dnf...${NC}"
                # Add Microsoft repository
                safe_sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | safe_sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
                
                # Install VS Code
                if safe_sudo dnf install -y code; then
                    return 0
                fi
            fi
            ;;
    esac
    
    # Try official .deb package for Debian/Ubuntu systems
    if command -v apt >/dev/null 2>&1; then
        echo -e "${YELLOW}Trying VS Code .deb package installation...${NC}"
        if wget -qO- https://packages.microsoft.com/repos/code/pool/main/c/code/code_*_amd64.deb | safe_sudo dpkg -i -; then
            safe_sudo apt install -f -y
            return 0
        fi
    fi
    
    # Try official .rpm package for Fedora/RHEL systems
    if command -v dnf >/dev/null 2>&1; then
        echo -e "${YELLOW}Trying VS Code .rpm package installation...${NC}"
        if wget -qO- https://packages.microsoft.com/repos/code/pool/main/c/code/code-*x86_64.rpm | safe_sudo rpm -i -; then
            return 0
        fi
    fi
    
    # Try official installation script as fallback
    echo -e "${YELLOW}Trying VS Code official installation script...${NC}"
    if curl -fsSL https://code.visualstudio.com/sha/download?build=stable&os=linux-x64 -o vscode.tar.gz; then
        tar -xzf vscode.tar.gz
        if [ -d "VSCode-linux-x64" ]; then
            safe_sudo mv VSCode-linux-x64 /opt/vscode
            safe_sudo ln -sf /opt/vscode/bin/code /usr/local/bin/code
            rm -rf vscode.tar.gz VSCode-linux-x64
            return 0
        fi
        rm -f vscode.tar.gz
    fi
    
    return 1
}

install_windows_editors() {
    echo -e "${YELLOW}Windows editors should be installed via package managers like scoop or winget${NC}"
    echo -e "${YELLOW}For scoop: scoop install vscode zed${NC}"
    echo -e "${YELLOW}For winget: winget install Microsoft.VisualStudioCode Zed.Zed${NC}"
}

# Setup Linux Homebrew with Tsinghua mirror
setup_linux_homebrew() {
    if [ "$PLATFORM" != "linux" ]; then
        return 0
    fi
    
    if command -v brew >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Homebrew already installed${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Setting up Linux Homebrew with Tsinghua mirror...${NC}"
    
    # Install Homebrew with Tsinghua mirror
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    
    # Install Homebrew
    if ! /bin/bash -c "$(curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git/raw/master/install.sh)"; then
        echo -e "${RED}Failed to install Homebrew with Tsinghua mirror${NC}"
        return 1
    fi
    
    # Add Homebrew to PATH
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
    # Configure Tsinghua mirror for existing Homebrew installation
    brew git -C "$(brew --repo)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
    brew git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
    
    # Configure bottle domain
    echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> ~/.zprofile
    
    echo -e "${GREEN}✓ Linux Homebrew installed with Tsinghua mirror${NC}"
    return 0
}

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
    
    # Install Linux Homebrew (for tools not available in package manager)
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Installing Linux Homebrew...${NC}"
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            # Add Homebrew to PATH
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            echo -e "${GREEN}✓ Linux Homebrew installed${NC}"
        else
            echo -e "${RED}Failed to install Linux Homebrew${NC}"
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
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}Git is not installed. Installing git automatically...${NC}"
        
        case "$PLATFORM" in
            macos)
                # Install Xcode Command Line Tools first (includes git)
                echo -e "${YELLOW}Installing Xcode Command Line Tools...${NC}"
                xcode-select --install
                echo -e "${YELLOW}Please press Enter when Xcode installation is complete${NC}"
                read -p ""
                
                # Verify git is installed
                if ! command -v git &> /dev/null; then
                    echo -e "${RED}Error: git installation failed${NC}"
                    echo -e "${YELLOW}Please install git manually: brew install git${NC}"
                    exit 1
                fi
                ;;
            linux)
                case "$DISTRO" in
                    ubuntu|debian|linuxmint)
                        echo -e "${YELLOW}Installing git on Debian/Ubuntu...${NC}"
                        if ! safe_sudo apt update; then
                            echo -e "${RED}Failed to update package lists${NC}"
                            exit 1
                        fi
                        if ! safe_sudo apt install -y git; then
                            echo -e "${RED}Failed to install git${NC}"
                            exit 1
                        fi
                        ;;
                    arch|manjaro)
                        echo -e "${YELLOW}Installing git on Arch/Manjaro...${NC}"
                        if ! safe_sudo pacman -Syu --noconfirm git; then
                            echo -e "${RED}Failed to install git${NC}"
                            exit 1
                        fi
                        ;;
                    fedora|centos|rhel)
                        echo -e "${YELLOW}Installing git on Fedora/CentOS...${NC}"
                        if ! safe_sudo dnf install -y git; then
                            echo -e "${RED}Failed to install git${NC}"
                            exit 1
                        fi
                        ;;
                    *)
                        if command -v apt >/dev/null 2>&1; then
                            echo -e "${YELLOW}Installing git using apt...${NC}"
                            if ! safe_sudo apt update; then
                                echo -e "${RED}Failed to update package lists${NC}"
                                exit 1
                            fi
                            if ! safe_sudo apt install -y git; then
                                echo -e "${RED}Failed to install git${NC}"
                                exit 1
                            fi
                        elif command -v pacman >/dev/null 2>&1; then
                            echo -e "${YELLOW}Installing git using pacman...${NC}"
                            if ! safe_sudo pacman -Syu --noconfirm git; then
                                echo -e "${RED}Failed to install git${NC}"
                                exit 1
                            fi
                        elif command -v dnf >/dev/null 2>&1; then
                            echo -e "${YELLOW}Installing git using dnf...${NC}"
                            if ! safe_sudo dnf install -y git; then
                                echo -e "${RED}Failed to install git${NC}"
                                exit 1
                            fi
                        else
                            echo -e "${RED}Error: No supported package manager found${NC}"
                            echo -e "${YELLOW}Please install git manually using your package manager${NC}"
                            exit 1
                        fi
                        ;;
                esac
                ;;
            windows)
                if grep -q Microsoft /proc/version 2>/dev/null; then
                    echo -e "${YELLOW}Installing git in WSL...${NC}"
                    if ! safe_sudo apt update; then
                        echo -e "${RED}Failed to update package lists in WSL${NC}"
                        exit 1
                    fi
                    if ! safe_sudo apt install -y git; then
                        echo -e "${RED}Failed to install git in WSL${NC}"
                        exit 1
                    fi
                elif command -v pacman &> /dev/null; then
                    echo -e "${YELLOW}Installing git in MSYS2...${NC}"
                    if ! pacman -Syu --noconfirm git; then
                        echo -e "${RED}Failed to install git in MSYS2${NC}"
                        exit 1
                    fi
                else
                    echo -e "${RED}Error: Unsupported Windows environment${NC}"
                    echo -e "${YELLOW}Please install git manually or use WSL/MSYS2${NC}"
                    exit 1
                fi
                ;;
        esac
        
        # Verify git was successfully installed
        if ! command -v git &> /dev/null; then
            echo -e "${RED}Error: git installation failed${NC}"
            echo -e "${YELLOW}Please install git manually and run this script again${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}✓ Git installed successfully${NC}"
    fi
    
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

# Install editors (VS Code, Zed)
install_editors

# Setup Linux Homebrew with Tsinghua mirror (if needed)
if [ "$PLATFORM" = "linux" ]; then
    echo -e "${YELLOW}Installing Linux Homebrew with Tsinghua mirror...${NC}"
    setup_linux_homebrew
fi

# Install editor configurations
if command -v zed >/dev/null 2>&1; then
    echo -e "${BLUE}Installing Zed configuration...${NC}"
    ./scripts/stow.sh install zed
fi

if command -v code >/dev/null 2>&1; then
    echo -e "${BLUE}Installing VS Code configuration...${NC}"
    # Create VS Code config directory if it doesn't exist
    mkdir -p "$HOME/.config/Code/User"
    # Stow VS Code configuration if available
    if [ -d "stow-packs/vscode" ]; then
        ./scripts/stow.sh install vscode
    fi
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
        echo -e "${YELLOW}Zsh not found. Installing zsh...${NC}"
        
        # Install zsh based on platform
        case "$PLATFORM" in
            macos)
                if command -v brew >/dev/null 2>&1; then
                    echo -e "${YELLOW}Installing zsh with Homebrew...${NC}"
                    brew install zsh
                else
                    echo -e "${YELLOW}Installing zsh with Xcode Command Line Tools...${NC}"
                    # On macOS, zsh is usually installed with Xcode CLT
                    if ! command -v xcode-select &> /dev/null; then
                        xcode-select --install
                        echo -e "${YELLOW}Please press Enter when Xcode installation is complete${NC}"
                        read -p ""
                    fi
                fi
                ;;
            linux)
                case "$DISTRO" in
                    ubuntu|debian|linuxmint)
                        echo -e "${YELLOW}Installing zsh on Debian/Ubuntu...${NC}"
                        if ! safe_sudo apt update; then
                            echo -e "${RED}Failed to update package lists${NC}"
                            exit 1
                        fi
                        if ! safe_sudo apt install -y zsh; then
                            echo -e "${RED}Failed to install zsh${NC}"
                            exit 1
                        fi
                        ;;
                    arch|manjaro)
                        echo -e "${YELLOW}Installing zsh on Arch/Manjaro...${NC}"
                        if ! safe_sudo pacman -Syu --noconfirm zsh; then
                            echo -e "${RED}Failed to install zsh${NC}"
                            exit 1
                        fi
                        ;;
                    fedora|centos|rhel)
                        echo -e "${YELLOW}Installing zsh on Fedora/CentOS...${NC}"
                        if ! safe_sudo dnf install -y zsh; then
                            echo -e "${RED}Failed to install zsh${NC}"
                            exit 1
                        fi
                        ;;
                    *)
                        if command -v apt >/dev/null 2>&1; then
                            echo -e "${YELLOW}Installing zsh using apt...${NC}"
                            if ! safe_sudo apt update; then
                                echo -e "${RED}Failed to update package lists${NC}"
                                exit 1
                            fi
                            if ! safe_sudo apt install -y zsh; then
                                echo -e "${RED}Failed to install zsh${NC}"
                                exit 1
                            fi
                        elif command -v pacman >/dev/null 2>&1; then
                            echo -e "${YELLOW}Installing zsh using pacman...${NC}"
                            if ! safe_sudo pacman -Syu --noconfirm zsh; then
                                echo -e "${RED}Failed to install zsh${NC}"
                                exit 1
                            fi
                        elif command -v dnf >/dev/null 2>&1; then
                            echo -e "${YELLOW}Installing zsh using dnf...${NC}"
                            if ! safe_sudo dnf install -y zsh; then
                                echo -e "${RED}Failed to install zsh${NC}"
                                exit 1
                            fi
                        else
                            echo -e "${RED}Error: No supported package manager found${NC}"
                            echo -e "${YELLOW}Please install zsh manually using your package manager${NC}"
                            exit 1
                        fi
                        ;;
                esac
                ;;
            windows)
                # Windows doesn't need zsh shell change
                echo -e "${YELLOW}Skipping zsh shell change on Windows${NC}"
                ;;
        esac
        
        # Verify zsh was installed and get its path
        ZSH_PATH=$(which zsh)
        if [ -z "$ZSH_PATH" ]; then
            echo -e "${RED}Error: Failed to install zsh${NC}"
            echo -e "${YELLOW}Please install zsh manually and run this script again${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}✓ Zsh installed successfully${NC}"
    fi
    
    # Now change the default shell
    if [ "$PLATFORM" != "windows" ]; then
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