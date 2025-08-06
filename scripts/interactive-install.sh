#!/bin/bash
# Interactive installation script for cross-platform dotfiles
# Provides a user-friendly interface for selective installation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Detect platform
OS="$(uname -s)"
DISTRO=""
PLATFORM=""

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

# Configuration variables
DOTFILES_DIR="$HOME/.dotfiles"
INSTALL_SYSTEM_PACKAGES=false
INSTALL_SHELL_CONFIG=false
INSTALL_DEV_TOOLS=false
INSTALL_EDITORS=false
INSTALL_PYTHON_ENV=false
INSTALL_NODE_ENV=false
INSTALL_DOCKER_ENV=false
SETUP_GIT_CONFIG=false

# Print header
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Cross-Platform Dotfiles                   ║"
    echo "║                Interactive Installation Wizard               ║"
    echo "║                    Linux • macOS • Windows                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${BLUE}🚀 Platform detected: $OS${DISTRO:+ ($DISTRO)}${NC}"
    echo ""
}

# Show menu
show_menu() {
    echo -e "${YELLOW}Please select what you want to install:${NC}"
    echo ""
    echo -e "${GREEN}Core Components:${NC}"
    echo "  1) System packages (essential tools)"
    echo "  2) Shell configuration (Zsh + Zinit)"
    echo "  3) Development tools (Git, modern CLI tools)"
    echo "  4) Editors (Vim, Neovim, Tmux)"
    echo ""
    echo -e "${GREEN}Development Environments:${NC}"
    echo "  5) Python environment (Pyenv + Anaconda + uv + direnv)"
    echo "  6) Node.js environment (NVM + LTS Node)"
    echo "  7) Docker development environment (Ubuntu 24.04.2 LTS)"
    echo ""
    echo -e "${GREEN}Configuration:${NC}"
    echo "  8) Git configuration setup"
    echo ""
    echo -e "${GREEN}Quick Options:${NC}"
    echo "  a) Install all components"
    echo "  c) Core only (1-4)"
    echo "  d) Development environments only (5-7)"
    echo ""
    echo -e "${GREEN}Actions:${NC}"
    echo "  s) Show current selections"
    echo "  i) Start installation"
    echo "  q) Quit"
    echo ""
}

# Toggle selection
toggle_selection() {
    case $1 in
        1) INSTALL_SYSTEM_PACKAGES=$([[ $INSTALL_SYSTEM_PACKAGES == true ]] && echo false || echo true) ;;
        2) INSTALL_SHELL_CONFIG=$([[ $INSTALL_SHELL_CONFIG == true ]] && echo false || echo true) ;;
        3) INSTALL_DEV_TOOLS=$([[ $INSTALL_DEV_TOOLS == true ]] && echo false || echo true) ;;
        4) INSTALL_EDITORS=$([[ $INSTALL_EDITORS == true ]] && echo false || echo true) ;;
        5) INSTALL_PYTHON_ENV=$([[ $INSTALL_PYTHON_ENV == true ]] && echo false || echo true) ;;
        6) INSTALL_NODE_ENV=$([[ $INSTALL_NODE_ENV == true ]] && echo false || echo true) ;;
        7) INSTALL_DOCKER_ENV=$([[ $INSTALL_DOCKER_ENV == true ]] && echo false || echo true) ;;
        8) SETUP_GIT_CONFIG=$([[ $SETUP_GIT_CONFIG == true ]] && echo false || echo true) ;;
        a) 
            INSTALL_SYSTEM_PACKAGES=true
            INSTALL_SHELL_CONFIG=true
            INSTALL_DEV_TOOLS=true
            INSTALL_EDITORS=true
            INSTALL_PYTHON_ENV=true
            INSTALL_NODE_ENV=true
            INSTALL_DOCKER_ENV=true
            SETUP_GIT_CONFIG=true
            ;;
        c)
            INSTALL_SYSTEM_PACKAGES=true
            INSTALL_SHELL_CONFIG=true
            INSTALL_DEV_TOOLS=true
            INSTALL_EDITORS=true
            ;;
        d)
            INSTALL_PYTHON_ENV=true
            INSTALL_NODE_ENV=true
            INSTALL_DOCKER_ENV=true
            ;;
    esac
}

# Show current selections
show_selections() {
    echo -e "${CYAN}Current Selections:${NC}"
    echo -e "  System packages: $([[ $INSTALL_SYSTEM_PACKAGES == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  Shell configuration: $([[ $INSTALL_SHELL_CONFIG == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  Development tools: $([[ $INSTALL_DEV_TOOLS == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  Editors: $([[ $INSTALL_EDITORS == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  Python environment: $([[ $INSTALL_PYTHON_ENV == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  Node.js environment: $([[ $INSTALL_NODE_ENV == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  Docker environment: $([[ $INSTALL_DOCKER_ENV == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  Git configuration: $([[ $SETUP_GIT_CONFIG == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo ""
}

# Install prerequisites
install_prerequisites() {
    echo -e "${YELLOW}Installing prerequisites...${NC}"
    
    case "$PLATFORM" in
        macos)
            # Check if Xcode Command Line Tools are installed
            if ! command -v xcode-select &> /dev/null; then
                echo -e "${YELLOW}Installing Xcode Command Line Tools...${NC}"
                xcode-select --install
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
            fi

            # Install GNU Stow
            if ! command -v stow &> /dev/null; then
                brew install stow
            fi
            ;;
        linux)
            case "$DISTRO" in
                ubuntu|debian|linuxmint)
                    sudo apt update
                    sudo apt install -y git stow curl build-essential
                    ;;
                arch|manjaro)
                    sudo pacman -Syu --noconfirm git stow curl base-devel
                    ;;
                fedora|centos|rhel)
                    sudo dnf install -y git stow curl @development-tools
                    ;;
                *)
                    if command -v apt >/dev/null 2>&1; then
                        sudo apt update
                        sudo apt install -y git stow curl build-essential
                    elif command -v pacman >/dev/null 2>&1; then
                        sudo pacman -Syu --noconfirm git stow curl base-devel
                    elif command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y git stow curl @development-tools
                    fi
                    ;;
            esac
            ;;
        windows)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                sudo apt update && sudo apt install -y git stow curl
            elif command -v pacman &> /dev/null; then
                pacman -Syu --noconfirm git stow curl
            fi
            ;;
    esac
    
    echo -e "${GREEN}✓ Prerequisites installed${NC}"
}

# Clone dotfiles if not exists
clone_dotfiles() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo -e "${YELLOW}Cloning dotfiles...${NC}"
        git clone https://github.com/nehcuh/dotfiles.git "$DOTFILES_DIR"
        echo -e "${GREEN}✓ Dotfiles cloned${NC}"
    fi
    cd "$DOTFILES_DIR"
}

# Installation functions
install_system_packages() {
    if [[ $INSTALL_SYSTEM_PACKAGES == true ]]; then
        echo -e "${BLUE}Installing system packages...${NC}"
        ./scripts/stow.sh install system
        echo -e "${GREEN}✓ System packages installed${NC}"
    fi
}

install_shell_config() {
    if [[ $INSTALL_SHELL_CONFIG == true ]]; then
        echo -e "${BLUE}Installing shell configuration...${NC}"
        ./scripts/stow.sh install zsh
        
        # Install Zinit if not exists
        if [ ! -d "$HOME/.local/share/zinit" ]; then
            echo -e "${YELLOW}Installing Zinit...${NC}"
            sh -c "$(curl -fsSL https://git.io/zinit-install)"
        fi
        
        echo -e "${GREEN}✓ Shell configuration installed${NC}"
    fi
}

install_dev_tools() {
    if [[ $INSTALL_DEV_TOOLS == true ]]; then
        echo -e "${BLUE}Installing development tools...${NC}"
        ./scripts/stow.sh install git tools
        echo -e "${GREEN}✓ Development tools installed${NC}"
    fi
}

install_editors() {
    if [[ $INSTALL_EDITORS == true ]]; then
        echo -e "${BLUE}Installing editors...${NC}"
        ./scripts/stow.sh install vim nvim tmux
        
        # Install Oh My Tmux if not exists
        if [ ! -d "$HOME/.tmux" ]; then
            echo -e "${YELLOW}Installing Oh My Tmux...${NC}"
            git clone https://github.com/gpakosz/.tmux.git ~/.tmux
            ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
            cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
        fi
        
        # Install Zed configuration if Zed is available
        if command -v zed >/dev/null 2>&1; then
            ./scripts/stow.sh install zed
        fi
        
        echo -e "${GREEN}✓ Editors installed${NC}"
    fi
}

install_python_env() {
    if [[ $INSTALL_PYTHON_ENV == true ]]; then
        echo -e "${BLUE}Setting up Python environment...${NC}"
        ./scripts/setup-python-env.sh
        echo -e "${GREEN}✓ Python environment configured${NC}"
    fi
}

install_node_env() {
    if [[ $INSTALL_NODE_ENV == true ]]; then
        echo -e "${BLUE}Setting up Node.js environment...${NC}"
        ./scripts/setup-node-env.sh
        echo -e "${GREEN}✓ Node.js environment configured${NC}"
    fi
}

install_docker_env() {
    if [[ $INSTALL_DOCKER_ENV == true ]]; then
        echo -e "${BLUE}Setting up Docker development environment...${NC}"
        
        # Install OrbStack on macOS
        if [[ $PLATFORM == "macos" ]] && ! command -v orbstack >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing OrbStack...${NC}"
            brew install --cask orbstack
        fi
        
        # Build Docker development environment
        if [ -f "docker/docker-compose.ubuntu-dev.yml" ]; then
            echo -e "${YELLOW}Building Ubuntu development environment...${NC}"
            docker-compose -f docker/docker-compose.ubuntu-dev.yml build
            echo -e "${GREEN}✓ Docker development environment ready${NC}"
            echo -e "${CYAN}You can start it with: docker-compose -f docker/docker-compose.ubuntu-dev.yml up -d${NC}"
        fi
    fi
}

setup_git_config() {
    if [[ $SETUP_GIT_CONFIG == true ]]; then
        echo -e "${BLUE}Setting up Git configuration...${NC}"
        ./scripts/setup-git-config.sh
        echo -e "${GREEN}✓ Git configuration setup${NC}"
    fi
}

# Platform-specific installations
platform_specific_install() {
    case "$PLATFORM" in
        macos)
            if command -v brew >/dev/null 2>&1; then
                echo -e "${YELLOW}Installing Homebrew packages...${NC}"
                brew bundle --global
            fi
            ;;
        linux)
            if command -v brew >/dev/null 2>&1; then
                echo -e "${YELLOW}Installing Linux Homebrew packages...${NC}"
                if [ -f "stow-packs/system/Brewfile.linux" ]; then
                    HOMEBREW_BUNDLE_FILE="stow-packs/system/Brewfile.linux" brew bundle --global
                else
                    brew bundle --global
                fi
            fi
            ;;
        windows)
            if [ -d "stow-packs/windows" ]; then
                ./scripts/stow.sh install windows
            fi
            ;;
    esac
}

# Change default shell
change_default_shell() {
    if [[ $INSTALL_SHELL_CONFIG == true ]] && [ "$PLATFORM" != "windows" ] && [ "$SHELL" != "$(which zsh)" ]; then
        echo -e "${YELLOW}Changing default shell to zsh...${NC}"
        if [ "$PLATFORM" = "macos" ]; then
            sudo chsh -s $(which zsh) $USER
        else
            if ! grep -q "$(which zsh)" /etc/shells; then
                echo "$(which zsh)" | sudo tee -a /etc/shells
            fi
            sudo chsh -s $(which zsh) $USER
        fi
        echo -e "${GREEN}✓ Default shell changed to zsh${NC}"
    fi
}

# Main installation process
run_installation() {
    echo -e "${CYAN}Starting installation...${NC}"
    echo ""
    
    install_prerequisites
    clone_dotfiles
    install_system_packages
    install_shell_config
    install_dev_tools
    install_editors
    install_python_env
    install_node_env
    install_docker_env
    setup_git_config
    platform_specific_install
    change_default_shell
    
    echo ""
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                      Installation Complete!                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${YELLOW}Please restart your terminal to apply all changes.${NC}"
    echo -e "${BLUE}You can manage your dotfiles with:${NC}"
    echo -e "${CYAN}  cd ~/.dotfiles && ./scripts/stow.sh [install|remove|list|status]${NC}"
    echo ""
    echo -e "${GREEN}🎉 Happy coding!${NC}"
}

# Main interactive loop
main() {
    while true; do
        print_header
        show_selections
        show_menu
        
        echo -n "Enter your choice: "
        read -r choice
        
        case $choice in
            [1-8]) toggle_selection $choice ;;
            a|A) toggle_selection a ;;
            c|C) toggle_selection c ;;
            d|D) toggle_selection d ;;
            s|S) 
                print_header
                show_selections
                echo -n "Press Enter to continue..."
                read -r
                ;;
            i|I) 
                if [[ $INSTALL_SYSTEM_PACKAGES == false ]] && [[ $INSTALL_SHELL_CONFIG == false ]] && 
                   [[ $INSTALL_DEV_TOOLS == false ]] && [[ $INSTALL_EDITORS == false ]] && 
                   [[ $INSTALL_PYTHON_ENV == false ]] && [[ $INSTALL_NODE_ENV == false ]] && 
                   [[ $INSTALL_DOCKER_ENV == false ]] && [[ $SETUP_GIT_CONFIG == false ]]; then
                    echo -e "${RED}No components selected for installation!${NC}"
                    echo -n "Press Enter to continue..."
                    read -r
                else
                    run_installation
                    exit 0
                fi
                ;;
            q|Q) 
                echo -e "${YELLOW}Installation cancelled.${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Run the interactive installer
main