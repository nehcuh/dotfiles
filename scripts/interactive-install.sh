#!/bin/bash
# Interactive installation script for cross-platform dotfiles
# Compatible with bash and zsh

# Check if we're running in a compatible shell
if [ -z "$BASH_VERSION" ] && [ -z "$ZSH_VERSION" ]; then
    echo "This script requires bash or zsh. Detected shell: $0"
    echo "Trying to run with bash..."
    if command -v bash >/dev/null 2>&1; then
        exec bash "$0" "$@"
    elif command -v zsh >/dev/null 2>&1; then
        exec zsh "$0" "$@"
    else
        echo "Error: Neither bash nor zsh is available"
        exit 1
    fi
fi

# Interactive installation script for cross-platform dotfiles
# Provides a user-friendly interface for selective installation

set -e

# Language support
LANG_EN=0
LANG_ZH=1
CURRENT_LANG=$LANG_EN

# Detect system language
if [[ "$LANG" == *"zh"* ]] || [[ "$LC_ALL" == *"zh"* ]]; then
    CURRENT_LANG=$LANG_ZH
fi

# Language strings
declare -A STRINGS_EN=(
    ["title"]="Cross-Platform Dotfiles"
    ["subtitle"]="Interactive Installation Wizard"
    ["platform_detected"]="Platform detected"
    ["select_language"]="Select Language / 选择语言"
    ["english"]="English"
    ["chinese"]="中文"
    ["menu_title"]="Please select what you want to install:"
    ["core_components"]="Core Components:"
    ["system_packages"]="System packages (essential tools)"
    ["shell_config"]="Shell configuration (Zsh + Zinit)"
    ["dev_tools"]="Development tools (Git, modern CLI tools)"
    ["editors"]="Editors (Vim, Neovim, Tmux)"
    ["dev_environments"]="Development Environments:"
    ["python_env"]="Python environment (Pyenv + Anaconda + uv + direnv)"
    ["node_env"]="Node.js environment (NVM + LTS Node)"
    ["docker_env"]="Docker development environment (Ubuntu 24.04.2 LTS)"
    ["configuration"]="Configuration:"
    ["git_config"]="Git configuration setup"
    ["quick_options"]="Quick Options:"
    ["install_all"]="Install all components"
    ["core_only"]="Core only (1-4)"
    ["dev_only"]="Development environments only (5-7)"
    ["actions"]="Actions:"
    ["show_selections"]="Show current selections"
    ["start_install"]="Start installation"
    ["quit"]="Quit"
    ["current_selections"]="Current Selections:"
    ["conflict_detected"]="Configuration conflicts detected!"
    ["backup_option"]="Backup existing configurations"
    ["overwrite_option"]="Overwrite existing configurations"
    ["skip_option"]="Skip conflicting files"
    ["cancel_option"]="Cancel installation"
    ["choose_conflict_action"]="How would you like to handle conflicts?"
    ["installation_cancelled"]="Installation cancelled."
    ["invalid_choice"]="Invalid choice. Please try again."
    ["enter_choice"]="Enter your choice"
    ["press_enter"]="Press Enter to continue..."
    ["starting_install"]="Starting installation..."
    ["install_complete"]="Installation Complete!"
    ["restart_terminal"]="Please restart your terminal to apply all changes."
    ["manage_dotfiles"]="You can manage your dotfiles with:"
    ["happy_coding"]="Happy coding!"
)

declare -A STRINGS_ZH=(
    ["title"]="跨平台 Dotfiles 配置"
    ["subtitle"]="交互式安装向导"
    ["platform_detected"]="检测到平台"
    ["select_language"]="Select Language / 选择语言"
    ["english"]="English"
    ["chinese"]="中文"
    ["menu_title"]="请选择要安装的组件："
    ["core_components"]="核心组件："
    ["system_packages"]="系统软件包（基础工具）"
    ["shell_config"]="Shell 配置（Zsh + Zinit）"
    ["dev_tools"]="开发工具（Git，现代 CLI 工具）"
    ["editors"]="编辑器（Vim，Neovim，Tmux）"
    ["dev_environments"]="开发环境："
    ["python_env"]="Python 环境（Pyenv + Anaconda + uv + direnv）"
    ["node_env"]="Node.js 环境（NVM + LTS Node）"
    ["docker_env"]="Docker 开发环境（Ubuntu 24.04.2 LTS）"
    ["configuration"]="配置："
    ["git_config"]="Git 配置设置"
    ["quick_options"]="快速选项："
    ["install_all"]="安装所有组件"
    ["core_only"]="仅核心组件（1-4）"
    ["dev_only"]="仅开发环境（5-7）"
    ["actions"]="操作："
    ["show_selections"]="显示当前选择"
    ["start_install"]="开始安装"
    ["quit"]="退出"
    ["current_selections"]="当前选择："
    ["conflict_detected"]="检测到配置冲突！"
    ["backup_option"]="备份现有配置"
    ["overwrite_option"]="覆盖现有配置"
    ["skip_option"]="跳过冲突文件"
    ["cancel_option"]="取消安装"
    ["choose_conflict_action"]="如何处理冲突？"
    ["installation_cancelled"]="安装已取消。"
    ["invalid_choice"]="无效选择。请重试。"
    ["enter_choice"]="输入你的选择"
    ["press_enter"]="按 Enter 继续..."
    ["starting_install"]="开始安装..."
    ["install_complete"]="安装完成！"
    ["restart_terminal"]="请重启终端以应用所有更改。"
    ["manage_dotfiles"]="你可以使用以下命令管理 dotfiles："
    ["happy_coding"]="编程愉快！"
)

# Get localized string
get_string() {
    local key="$1"
    if [[ $CURRENT_LANG == $LANG_ZH ]]; then
        echo "${STRINGS_ZH[$key]}"
    else
        echo "${STRINGS_EN[$key]}"
    fi
}

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
CONFLICT_ACTION=""

# Language selection
select_language() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    $(get_string "select_language")                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo "1) $(get_string "english")"
    echo "2) $(get_string "chinese")"
    echo ""
    echo -n "$(get_string "enter_choice") (1-2): "
    read -r choice < /dev/tty
    
    case $choice in
        1) CURRENT_LANG=$LANG_EN ;;
        2) CURRENT_LANG=$LANG_ZH ;;
        *) CURRENT_LANG=$LANG_EN ;;
    esac
}

# Check for configuration conflicts
check_conflicts() {
    local conflicts=()
    local config_files=(
        "$HOME/.zshrc"
        "$HOME/.gitconfig"
        "$HOME/.config/starship.toml"
        "$HOME/.tmux.conf"
        "$HOME/.vimrc"
    )
    
    for file in "${config_files[@]}"; do
        if [ -f "$file" ] && [ ! -L "$file" ]; then
            conflicts+=("$file")
        fi
    done
    
    if [ ${#conflicts[@]} -gt 0 ]; then
        echo -e "${YELLOW}$(get_string "conflict_detected")${NC}"
        echo ""
        for file in "${conflicts[@]}"; do
            echo -e "${RED}  ✗ $file${NC}"
        done
        echo ""
        echo -e "${YELLOW}$(get_string "choose_conflict_action")${NC}"
        echo ""
        echo "1) $(get_string "backup_option")"
        echo "2) $(get_string "overwrite_option")"
        echo "3) $(get_string "skip_option")"
        echo "4) $(get_string "cancel_option")"
        echo ""
        echo -n "$(get_string "enter_choice") (1-4): "
        read -r choice < /dev/tty
        
        case $choice in
            1) CONFLICT_ACTION="backup" ;;
            2) CONFLICT_ACTION="overwrite" ;;
            3) CONFLICT_ACTION="skip" ;;
            4) 
                echo -e "${YELLOW}$(get_string "installation_cancelled")${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}$(get_string "invalid_choice")${NC}"
                check_conflicts
                ;;
        esac
    fi
}

# Handle configuration conflicts
handle_conflicts() {
    if [ "$CONFLICT_ACTION" = "backup" ]; then
        local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$backup_dir"
        
        local config_files=(
            "$HOME/.zshrc"
            "$HOME/.gitconfig"
            "$HOME/.config/starship.toml"
            "$HOME/.tmux.conf"
            "$HOME/.vimrc"
        )
        
        for file in "${config_files[@]}"; do
            if [ -f "$file" ] && [ ! -L "$file" ]; then
                echo -e "${YELLOW}Backing up $file to $backup_dir${NC}"
                cp "$file" "$backup_dir/"
                rm -f "$file"
            fi
        done
        
        echo -e "${GREEN}✓ Backup created at $backup_dir${NC}"
    elif [ "$CONFLICT_ACTION" = "overwrite" ]; then
        local config_files=(
            "$HOME/.zshrc"
            "$HOME/.gitconfig"
            "$HOME/.config/starship.toml"
            "$HOME/.tmux.conf"
            "$HOME/.vimrc"
        )
        
        for file in "${config_files[@]}"; do
            if [ -f "$file" ] && [ ! -L "$file" ]; then
                echo -e "${YELLOW}Removing $file${NC}"
                rm -f "$file"
            fi
        done
    fi
}

# Print header
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    $(get_string "title")                   ║"
    echo "║                $(get_string "subtitle")               ║"
    echo "║                    Linux • macOS • Windows                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${BLUE}🚀 $(get_string "platform_detected"): $OS${DISTRO:+ ($DISTRO)}${NC}"
    echo ""
}

# Show menu
show_menu() {
    echo -e "${YELLOW}$(get_string "menu_title")${NC}"
    echo ""
    echo -e "${GREEN}$(get_string "core_components")${NC}"
    echo "  1) $(get_string "system_packages")"
    echo "  2) $(get_string "shell_config")"
    echo "  3) $(get_string "dev_tools")"
    echo "  4) $(get_string "editors")"
    echo ""
    echo -e "${GREEN}$(get_string "dev_environments")${NC}"
    echo "  5) $(get_string "python_env")"
    echo "  6) $(get_string "node_env")"
    echo "  7) $(get_string "docker_env")"
    echo ""
    echo -e "${GREEN}$(get_string "configuration")${NC}"
    echo "  8) $(get_string "git_config")"
    echo ""
    echo -e "${GREEN}$(get_string "quick_options")${NC}"
    echo "  a) $(get_string "install_all")"
    echo "  c) $(get_string "core_only")"
    echo "  d) $(get_string "dev_only")"
    echo ""
    echo -e "${GREEN}$(get_string "actions")${NC}"
    echo "  s) $(get_string "show_selections")"
    echo "  i) $(get_string "start_install")"
    echo "  q) $(get_string "quit")"
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
    echo -e "${CYAN}$(get_string "current_selections")${NC}"
    echo -e "  $(get_string "system_packages"): $([[ $INSTALL_SYSTEM_PACKAGES == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  $(get_string "shell_config"): $([[ $INSTALL_SHELL_CONFIG == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  $(get_string "dev_tools"): $([[ $INSTALL_DEV_TOOLS == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  $(get_string "editors"): $([[ $INSTALL_EDITORS == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  $(get_string "python_env"): $([[ $INSTALL_PYTHON_ENV == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  $(get_string "node_env"): $([[ $INSTALL_NODE_ENV == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  $(get_string "docker_env"): $([[ $INSTALL_DOCKER_ENV == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo -e "  $(get_string "git_config"): $([[ $SETUP_GIT_CONFIG == true ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
    echo ""
}

# Install prerequisites
install_prerequisites() {
    echo -e "${YELLOW}$(get_string "installing_prerequisites")...${NC}"
    
    case "$PLATFORM" in
        macos)
            # Check if Xcode Command Line Tools are installed
            if ! command -v xcode-select &> /dev/null; then
                echo -e "${YELLOW}$(get_string "installing_xcode")...${NC}"
                xcode-select --install
                echo -e "${YELLOW}$(get_string "xcode_complete")${NC}"
                read -r -p "$(get_string "press_enter")" dummy < /dev/tty
            fi

            # Install Homebrew if not exists
            if ! command -v brew &> /dev/null; then
                echo -e "${YELLOW}$(get_string "installing_homebrew")...${NC}"
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
    
    echo -e "${GREEN}✓ $(get_string "prerequisites_installed")${NC}"
}

# Clone dotfiles if not exists
clone_dotfiles() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo -e "${YELLOW}$(get_string "cloning_dotfiles")...${NC}"
        git clone https://github.com/nehcuh/dotfiles.git "$DOTFILES_DIR"
        echo -e "${GREEN}✓ $(get_string "dotfiles_cloned")${NC}"
    fi
    cd "$DOTFILES_DIR"
}

# Installation functions
install_system_packages() {
    if [[ $INSTALL_SYSTEM_PACKAGES == true ]]; then
        echo -e "${BLUE}$(get_string "installing_system")...${NC}"
        ./scripts/stow.sh install system
        echo -e "${GREEN}✓ $(get_string "system_installed")${NC}"
    fi
}

install_shell_config() {
    if [[ $INSTALL_SHELL_CONFIG == true ]]; then
        echo -e "${BLUE}$(get_string "installing_shell")...${NC}"
        ./scripts/stow.sh install zsh
        
        # Install Zinit if not exists
        if [ ! -d "$HOME/.local/share/zinit" ]; then
            echo -e "${YELLOW}$(get_string "installing_zinit")...${NC}"
            sh -c "$(curl -fsSL https://git.io/zinit-install)"
        fi
        
        echo -e "${GREEN}✓ $(get_string "shell_installed")${NC}"
    fi
}

install_dev_tools() {
    if [[ $INSTALL_DEV_TOOLS == true ]]; then
        echo -e "${BLUE}$(get_string "installing_dev")...${NC}"
        ./scripts/stow.sh install git tools
        echo -e "${GREEN}✓ $(get_string "dev_installed")${NC}"
    fi
}

install_editors() {
    if [[ $INSTALL_EDITORS == true ]]; then
        echo -e "${BLUE}$(get_string "installing_editors")...${NC}"
        ./scripts/stow.sh install vim nvim tmux
        
        # Install Oh My Tmux if not exists
        if [ ! -d "$HOME/.tmux" ]; then
            echo -e "${YELLOW}$(get_string "installing_tmux")...${NC}"
            git clone https://github.com/gpakosz/.tmux.git ~/.tmux
            ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
            cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
        fi
        
        # Install Zed configuration if Zed is available
        if command -v zed >/dev/null 2>&1; then
            ./scripts/stow.sh install zed
        fi
        
        echo -e "${GREEN}✓ $(get_string "editors_installed")${NC}"
    fi
}

install_python_env() {
    if [[ $INSTALL_PYTHON_ENV == true ]]; then
        echo -e "${BLUE}$(get_string "setting_python")...${NC}"
        ./scripts/setup-python-env.sh
        echo -e "${GREEN}✓ $(get_string "python_configured")${NC}"
    fi
}

install_node_env() {
    if [[ $INSTALL_NODE_ENV == true ]]; then
        echo -e "${BLUE}$(get_string "setting_node")...${NC}"
        ./scripts/setup-node-env.sh
        echo -e "${GREEN}✓ $(get_string "node_configured")${NC}"
    fi
}

install_docker_env() {
    if [[ $INSTALL_DOCKER_ENV == true ]]; then
        echo -e "${BLUE}$(get_string "setting_docker")...${NC}"
        
        # Install OrbStack on macOS
        if [[ $PLATFORM == "macos" ]] && ! command -v orbstack >/dev/null 2>&1; then
            echo -e "${YELLOW}$(get_string "installing_orbstack")...${NC}"
            brew install --cask orbstack
        fi
        
        # Build Docker development environment
        if [ -f "docker/docker-compose.ubuntu-dev.yml" ]; then
            echo -e "${YELLOW}$(get_string "building_ubuntu")...${NC}"
            docker-compose -f docker/docker-compose.ubuntu-dev.yml build
            echo -e "${GREEN}✓ $(get_string "docker_ready")${NC}"
            echo -e "${CYAN}$(get_string "docker_start_cmd"): docker-compose -f docker/docker-compose.ubuntu-dev.yml up -d${NC}"
        fi
    fi
}

setup_git_config() {
    if [[ $SETUP_GIT_CONFIG == true ]]; then
        echo -e "${BLUE}$(get_string "setting_git")...${NC}"
        ./scripts/setup-git-config.sh
        echo -e "${GREEN}✓ $(get_string "git_setup")${NC}"
    fi
}

# Platform-specific installations
platform_specific_install() {
    case "$PLATFORM" in
        macos)
            if command -v brew >/dev/null 2>&1; then
                echo -e "${YELLOW}$(get_string "installing_brew")...${NC}"
                brew bundle --global
            fi
            ;;
        linux)
            if command -v brew >/dev/null 2>&1; then
                echo -e "${YELLOW}$(get_string "installing_linux_brew")...${NC}"
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
        echo -e "${YELLOW}$(get_string "changing_shell")...${NC}"
        if [ "$PLATFORM" = "macos" ]; then
            sudo chsh -s $(which zsh) $USER
        else
            if ! grep -q "$(which zsh)" /etc/shells; then
                echo "$(which zsh)" | sudo tee -a /etc/shells
            fi
            sudo chsh -s $(which zsh) $USER
        fi
        echo -e "${GREEN}✓ $(get_string "shell_changed")${NC}"
    fi
}

# Main installation process
run_installation() {
    echo -e "${CYAN}$(get_string "starting_install")${NC}"
    echo ""
    
    # Handle conflicts first
    handle_conflicts
    
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
    echo "║                      $(get_string "install_complete")                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${YELLOW}$(get_string "restart_terminal")${NC}"
    echo -e "${BLUE}$(get_string "manage_dotfiles")${NC}"
    echo -e "${CYAN}  cd ~/.dotfiles && ./scripts/stow.sh [install|remove|list|status]${NC}"
    echo ""
    echo -e "${GREEN}🎉 $(get_string "happy_coding")${NC}"
}

# Main interactive loop
main() {
    # Language selection first
    select_language
    
    # Check for conflicts
    check_conflicts
    
    while true; do
        print_header
        show_selections
        show_menu
        
        echo -n "$(get_string "enter_choice"): "
        read -r choice < /dev/tty
        
        case $choice in
            [1-8]) toggle_selection $choice ;;
            a|A) toggle_selection a ;;
            c|C) toggle_selection c ;;
            d|D) toggle_selection d ;;
            s|S) 
                print_header
                show_selections
                echo -n "$(get_string "press_enter")"
                read -r dummy < /dev/tty
                ;;
            i|I) 
                if [[ $INSTALL_SYSTEM_PACKAGES == false ]] && [[ $INSTALL_SHELL_CONFIG == false ]] && 
                   [[ $INSTALL_DEV_TOOLS == false ]] && [[ $INSTALL_EDITORS == false ]] && 
                   [[ $INSTALL_PYTHON_ENV == false ]] && [[ $INSTALL_NODE_ENV == false ]] && 
                   [[ $INSTALL_DOCKER_ENV == false ]] && [[ $SETUP_GIT_CONFIG == false ]]; then
                    echo -e "${RED}$(get_string "no_components")${NC}"
                    echo -n "$(get_string "press_enter")"
                    read -r dummy < /dev/tty
                else
                    run_installation
                    exit 0
                fi
                ;;
            q|Q) 
                echo -e "${YELLOW}$(get_string "installation_cancelled")${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}$(get_string "invalid_choice")${NC}"
                sleep 1
                ;;
        esac
    done
}

# Run the interactive installer
main