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
    ["no_components"]="No components selected!"
    ["installing_prerequisites"]="Installing prerequisites"
    ["prerequisites_installed"]="Prerequisites installed"
    ["cloning_dotfiles"]="Cloning dotfiles"
    ["dotfiles_cloned"]="Dotfiles cloned"
    ["installing_system"]="Installing system packages"
    ["system_installed"]="System packages installed"
    ["installing_shell"]="Installing shell configuration"
    ["installing_zinit"]="Installing Zinit"
    ["shell_installed"]="Shell configuration installed"
    ["installing_dev"]="Installing development tools"
    ["dev_installed"]="Development tools installed"
    ["installing_editors"]="Installing editors"
    ["installing_tmux"]="Installing Oh My Tmux"
    ["editors_installed"]="Editors installed"
    ["setting_python"]="Setting up Python environment"
    ["python_configured"]="Python environment configured"
    ["setting_node"]="Setting up Node.js environment"
    ["node_configured"]="Node.js environment configured"
    ["setting_docker"]="Setting up Docker environment"
    ["installing_orbstack"]="Installing OrbStack"
    ["building_ubuntu"]="Building Ubuntu development environment"
    ["docker_ready"]="Docker environment ready"
    ["docker_start_cmd"]="Start command"
    ["setting_git"]="Setting up Git configuration"
    ["git_setup"]="Git configuration setup"
    ["installing_brew"]="Installing Homebrew packages"
    ["installing_linux_brew"]="Installing Linux Homebrew packages"
    ["changing_shell"]="Changing default shell"
    ["shell_changed"]="Default shell changed"
    ["installing_xcode"]="Installing Xcode Command Line Tools"
    ["xcode_complete"]="Please press Enter when Xcode installation is complete"
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

# Function to check and request sudo access
check_sudo_access() {
    echo -e "${YELLOW}Checking sudo access...${NC}"
    
    # Check if sudo is available on the system
    if ! command -v sudo >/dev/null 2>&1; then
        echo -e "${YELLOW}Sudo command not found on this system.${NC}"
        echo -e "${YELLOW}Some features may not work correctly.${NC}"
        return 0
    fi
    
    # Check if we already have sudo access
    if sudo -n true 2>/dev/null; then
        echo -e "${GREEN}✓ Sudo access confirmed${NC}"
        return 0
    fi
    
    # Request sudo access
    echo -e "${YELLOW}This script requires sudo access for system-wide changes.${NC}"
    echo -e "${YELLOW}Please enter your password when prompted.${NC}"
    
    # Try to get sudo access
    if ! sudo -v; then
        echo -e "${RED}Failed to obtain sudo access.${NC}"
        echo -e "${YELLOW}Would you like to continue anyway? Some features may not work correctly. (y/n)${NC}"
        read -r continue_anyway < /dev/tty
        if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
            echo -e "${RED}Installation aborted.${NC}"
            exit 1
        fi
        echo -e "${YELLOW}Continuing with limited functionality...${NC}"
    else
        echo -e "${GREEN}✓ Sudo access obtained${NC}"
    fi
    
    return 0
}

# Function to keep sudo session alive
keep_sudo_alive() {
    echo -e "${BLUE}Maintaining sudo session...${NC}"
    # Keep-alive: update existing sudo time stamp until script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Function to safely run sudo commands with error handling
safe_sudo() {
    # First try without redirecting stderr to see if we get a password prompt
    if ! sudo -v >/dev/null 2>&1; then
        echo -e "${YELLOW}Sudo requires a password. Please enter your password when prompted.${NC}"
    fi
    
    # Try the command with proper error output
    if ! sudo "$@"; then
        echo -e "${RED}Error: Failed to run command with sudo: $*${NC}"
        echo -e "${YELLOW}This could be due to:${NC}"
        echo -e "${YELLOW}1. You don't have sudo privileges${NC}"
        echo -e "${YELLOW}2. The command itself failed${NC}"
        echo -e "${YELLOW}3. Your system doesn't have the required package manager${NC}"
        echo -e ""
        echo -e "${YELLOW}Would you like to try again? (y/n)${NC}"
        read -r try_again < /dev/tty
        if [[ $try_again =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Trying again...${NC}"
            if sudo "$@"; then
                return 0
            else
                echo -e "${RED}Command failed again. Continuing with installation.${NC}"
                echo -e "${YELLOW}Some components may not be installed correctly.${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}Continuing with installation, but some components may not be installed correctly.${NC}"
            return 1
        fi
    fi
    return 0
}

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
        1) 
            INSTALL_SYSTEM_PACKAGES=$([[ $INSTALL_SYSTEM_PACKAGES == true ]] && echo false || echo true)
            ;;
        2) 
            INSTALL_SHELL_CONFIG=$([[ $INSTALL_SHELL_CONFIG == true ]] && echo false || echo true)
            ;;
        3) 
            INSTALL_DEV_TOOLS=$([[ $INSTALL_DEV_TOOLS == true ]] && echo false || echo true)
            ;;
        4) 
            INSTALL_EDITORS=$([[ $INSTALL_EDITORS == true ]] && echo false || echo true)
            ;;
        5) 
            INSTALL_PYTHON_ENV=$([[ $INSTALL_PYTHON_ENV == true ]] && echo false || echo true)
            ;;
        6) 
            INSTALL_NODE_ENV=$([[ $INSTALL_NODE_ENV == true ]] && echo false || echo true)
            ;;
        7) 
            INSTALL_DOCKER_ENV=$([[ $INSTALL_DOCKER_ENV == true ]] && echo false || echo true)
            ;;
        8) 
            SETUP_GIT_CONFIG=$([[ $SETUP_GIT_CONFIG == true ]] && echo false || echo true)
            ;;
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
            # Check if we have sudo access
            if [ "${NO_SUDO:-0}" -eq 1 ]; then
                echo -e "${YELLOW}No sudo access detected. Checking for required packages...${NC}"
                missing_packages=""
                
                # Check for required packages
                for pkg in git stow curl; do
                    if ! command -v $pkg >/dev/null 2>&1; then
                        missing_packages="$missing_packages $pkg"
                    fi
                done
                
                if [ -n "$missing_packages" ]; then
                    echo -e "${YELLOW}The following packages are missing and cannot be installed without sudo:${NC}"
                    echo -e "${YELLOW}$missing_packages${NC}"
                    echo -e "${YELLOW}Please install them manually and run this script again.${NC}"
                    echo -e "${YELLOW}Continuing with limited functionality...${NC}"
                else
                    echo -e "${GREEN}Required packages are already installed.${NC}"
                fi
            else
                # Normal installation with sudo
                case "$DISTRO" in
                    ubuntu|debian|linuxmint)
                        if ! safe_sudo apt update; then
                            echo -e "${YELLOW}Failed to update package lists. Continuing anyway...${NC}"
                        fi
                        if ! safe_sudo apt install -y git stow curl build-essential; then
                            echo -e "${YELLOW}Failed to install some required packages. Continuing with limited functionality...${NC}"
                        fi
                        ;;
                    arch|manjaro)
                        if ! safe_sudo pacman -Syu --noconfirm git stow curl base-devel; then
                            echo -e "${YELLOW}Failed to install some required packages. Continuing with limited functionality...${NC}"
                        fi
                        ;;
                    fedora|centos|rhel)
                        if ! safe_sudo dnf install -y git stow curl @development-tools; then
                            echo -e "${YELLOW}Failed to install some required packages. Continuing with limited functionality...${NC}"
                        fi
                        ;;
                    *)
                        if command -v apt >/dev/null 2>&1; then
                            if ! safe_sudo apt update; then
                                echo -e "${YELLOW}Failed to update package lists. Continuing anyway...${NC}"
                            fi
                            if ! safe_sudo apt install -y git stow curl build-essential; then
                                echo -e "${YELLOW}Failed to install some required packages. Continuing with limited functionality...${NC}"
                            fi
                        elif command -v pacman >/dev/null 2>&1; then
                            if ! safe_sudo pacman -Syu --noconfirm git stow curl base-devel; then
                                echo -e "${YELLOW}Failed to install some required packages. Continuing with limited functionality...${NC}"
                            fi
                        elif command -v dnf >/dev/null 2>&1; then
                            if ! safe_sudo dnf install -y git stow curl @development-tools; then
                                echo -e "${YELLOW}Failed to install some required packages. Continuing with limited functionality...${NC}"
                            fi
                        else
                            echo -e "${YELLOW}Please install git, stow, curl, and build tools manually${NC}"
                            echo -e "${YELLOW}Continuing with limited functionality...${NC}"
                        fi
                    ;;
            esac
        windows)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                # WSL environment
                echo -e "${YELLOW}Installing required packages in WSL...${NC}"
                if ! safe_sudo apt update; then
                    echo -e "${YELLOW}Failed to update package lists in WSL. Continuing anyway...${NC}"
                fi
                if ! safe_sudo apt install -y git stow curl; then
                    echo -e "${YELLOW}Failed to install some required packages in WSL. Continuing with limited functionality...${NC}"
                fi
            elif command -v pacman &> /dev/null; then
                # MSYS2 environment
                if ! pacman -Syu --noconfirm git stow curl; then
                    echo -e "${YELLOW}Failed to install some packages in MSYS2. Continuing with limited functionality...${NC}"
                fi
            else
                echo -e "${YELLOW}On Windows, please install Git for Windows and other tools manually${NC}"
                echo -e "${YELLOW}Visit https://gitforwindows.org/ to download Git for Windows${NC}"
                echo -e "${YELLOW}Continuing with limited functionality...${NC}"
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
    if [ ! -d "$DOTFILES_DIR" ]; then
        clone_dotfiles
    fi
    echo -e "${YELLOW}正在安装系统软件包...${NC}"
    cd "$DOTFILES_DIR"
    ./scripts/stow.sh install system
    echo -e "${GREEN}✓ 系统软件包安装完成${NC}"
}

install_shell_config() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        clone_dotfiles
    fi
    echo -e "${YELLOW}正在安装 Shell 配置...${NC}"
    cd "$DOTFILES_DIR"
    ./scripts/stow.sh install zsh
    
    # Install Zinit if not exists
    if [ ! -d "$HOME/.local/share/zinit" ]; then
        echo -e "${YELLOW}正在安装 Zinit...${NC}"
        sh -c "$(curl -fsSL https://git.io/zinit-install)"
    fi
    
    echo -e "${GREEN}✓ Shell 配置安装完成${NC}"
}

install_dev_tools() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        clone_dotfiles
    fi
    echo -e "${YELLOW}正在安装开发工具...${NC}"
    cd "$DOTFILES_DIR"
    ./scripts/stow.sh install git tools
    echo -e "${GREEN}✓ 开发工具安装完成${NC}"
}

install_editors() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        clone_dotfiles
    fi
    echo -e "${YELLOW}正在安装编辑器...${NC}"
    cd "$DOTFILES_DIR"
    ./scripts/stow.sh install vim nvim tmux
    
    # Install Oh My Tmux if not exists
    if [ ! -d "$HOME/.tmux" ]; then
        echo -e "${YELLOW}正在安装 Oh My Tmux...${NC}"
        git clone https://github.com/gpakosz/.tmux.git ~/.tmux
        ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
        cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
    fi
    
    # Install VS Code and Zed editors
    install_vs_code_and_zed
    
    # Install Zed configuration if Zed is available
    if command -v zed >/dev/null 2>&1; then
        # Handle Zed config conflicts
        if [ -f "$HOME/.config/zed/settings.json" ] && [ ! -L "$HOME/.config/zed/settings.json" ]; then
            echo -e "${YELLOW}备份现有的 Zed 设置...${NC}"
            backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
            mkdir -p "$backup_dir/.config/zed"
            cp "$HOME/.config/zed/settings.json" "$backup_dir/.config/zed/"
            rm -f "$HOME/.config/zed/settings.json"
        fi
        ./scripts/stow.sh install zed
    fi
    
    # Install VS Code configuration if VS Code is available
    if command -v code >/dev/null 2>&1; then
        echo -e "${YELLOW}安装 VS Code 配置...${NC}"
        # Create VS Code config directory if it doesn't exist
        mkdir -p "$HOME/.config/Code/User"
        # Stow VS Code configuration if available
        if [ -d "stow-packs/vscode" ]; then
            ./scripts/stow.sh install vscode
        fi
    fi
    
    echo -e "${GREEN}✓ 编辑器安装完成${NC}"
}

# Install VS Code and Zed editors
install_vs_code_and_zed() {
    echo -e "${YELLOW}正在安装 VS Code 和 Zed 编辑器...${NC}"
    
    # Detect platform
    if [ "$(uname)" = "Darwin" ]; then
        install_macos_editors_interactive
    elif [ "$(uname)" = "Linux" ]; then
        install_linux_editors_interactive
    else
        echo -e "${RED}不支持的平台${NC}"
    fi
}

install_macos_editors_interactive() {
    # Use Homebrew Cask for GUI applications
    if command -v brew >/dev/null 2>&1; then
        # Install Zed editor
        if ! command -v zed >/dev/null 2>&1; then
            echo -e "${YELLOW}正在安装 Zed 编辑器...${NC}"
            if ! brew install --cask zed 2>/dev/null; then
                echo -e "${RED}通过 Homebrew Cask 安装 Zed 失败${NC}"
                echo -e "${YELLOW}您可以手动安装：https://zed.dev${NC}"
            else
                echo -e "${GREEN}✓ Zed 编辑器安装完成${NC}"
            fi
        else
            echo -e "${GREEN}✓ Zed 编辑器已安装${NC}"
        fi
        
        # Install Visual Studio Code
        if ! command -v code >/dev/null 2>&1; then
            echo -e "${YELLOW}正在安装 Visual Studio Code...${NC}"
            if ! brew install --cask visual-studio-code 2>/dev/null; then
                echo -e "${RED}通过 Homebrew Cask 安装 VS Code 失败${NC}"
                echo -e "${YELLOW}您可以手动安装：https://code.visualstudio.com${NC}"
            else
                echo -e "${GREEN}✓ Visual Studio Code 安装完成${NC}"
            fi
        else
            echo -e "${GREEN}✓ Visual Studio Code 已安装${NC}"
        fi
    else
        echo -e "${RED}Homebrew 不可用。请手动安装编辑器。${NC}"
        echo -e "${YELLOW}Zed: https://zed.dev${NC}"
        echo -e "${YELLOW}VS Code: https://code.visualstudio.com${NC}"
    fi
}

install_linux_editors_interactive() {
    # Detect Linux distribution
    if [ -f /etc/os-release ]; then
        DISTRO=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
    elif command -v lsb_release >/dev/null 2>&1; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    else
        DISTRO="unknown"
    fi
    
    # Try to install Zed editor
    if ! command -v zed >/dev/null 2>&1; then
        echo -e "${YELLOW}正在安装 Zed 编辑器...${NC}"
        
        # Try official installation script
        if curl -fsSL https://zed.dev/install.sh | sh; then
            echo -e "${GREEN}✓ Zed 编辑器安装完成${NC}"
        else
            echo -e "${RED}安装 Zed 编辑器失败${NC}"
            echo -e "${YELLOW}您可以手动安装：https://zed.dev${NC}"
        fi
    else
        echo -e "${GREEN}✓ Zed 编辑器已安装${NC}"
    fi
    
    # Try to install VS Code
    if ! command -v code >/dev/null 2>&1; then
        echo -e "${YELLOW}正在安装 Visual Studio Code...${NC}"
        
        # Try different installation methods based on distribution
        case "$DISTRO" in
            ubuntu|debian|linuxmint)
                if command -v apt >/dev/null 2>&1; then
                    # Add Microsoft's GPG key and repository
                    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null
                    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
                    
                    if sudo apt update && sudo apt install -y code; then
                        echo -e "${GREEN}✓ Visual Studio Code 安装完成${NC}"
                    else
                        echo -e "${RED}安装 VS Code 失败${NC}"
                        echo -e "${YELLOW}您可以手动安装：https://code.visualstudio.com${NC}"
                    fi
                else
                    echo -e "${RED}apt 不可用${NC}"
                    echo -e "${YELLOW}您可以手动安装：https://code.visualstudio.com${NC}"
                fi
                ;;
            arch|manjaro)
                if command -v yay >/dev/null 2>&1; then
                    if yay -S --noconfirm visual-studio-code-bin; then
                        echo -e "${GREEN}✓ Visual Studio Code 安装完成${NC}"
                    else
                        echo -e "${RED}安装 VS Code 失败${NC}"
                        echo -e "${YELLOW}您可以手动安装：https://code.visualstudio.com${NC}"
                    fi
                elif command -v paru >/dev/null 2>&1; then
                    if paru -S --noconfirm visual-studio-code-bin; then
                        echo -e "${GREEN}✓ Visual Studio Code 安装完成${NC}"
                    else
                        echo -e "${RED}安装 VS Code 失败${NC}"
                        echo -e "${YELLOW}您可以手动安装：https://code.visualstudio.com${NC}"
                    fi
                else
                    echo -e "${RED}AUR 助手不可用${NC}"
                    echo -e "${YELLOW}您可以手动安装：https://code.visualstudio.com${NC}"
                fi
                ;;
            fedora|centos|rhel)
                if command -v dnf >/dev/null 2>&1; then
                    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
                    
                    if sudo dnf install -y code; then
                        echo -e "${GREEN}✓ Visual Studio Code 安装完成${NC}"
                    else
                        echo -e "${RED}安装 VS Code 失败${NC}"
                        echo -e "${YELLOW}您可以手动安装：https://code.visualstudio.com${NC}"
                    fi
                else
                    echo -e "${RED}dnf 不可用${NC}"
                    echo -e "${YELLOW}您可以手动安装：https://code.visualstudio.com${NC}"
                fi
                ;;
            *)
                echo -e "${RED}不支持的 Linux 发行版${NC}"
                echo -e "${YELLOW}您可以手动安装：${NC}"
                echo -e "${YELLOW}VS Code: https://code.visualstudio.com${NC}"
                echo -e "${YELLOW}Zed: https://zed.dev${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}✓ Visual Studio Code 已安装${NC}"
    fi
}

install_python_env() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        clone_dotfiles
    fi
    echo -e "${YELLOW}正在设置 Python 环境...${NC}"
    cd "$DOTFILES_DIR"
    ./scripts/setup-python-env.sh
    echo -e "${GREEN}✓ Python 环境设置完成${NC}"
}

install_node_env() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        clone_dotfiles
    fi
    echo -e "${YELLOW}正在设置 Node.js 环境...${NC}"
    cd "$DOTFILES_DIR"
    ./scripts/setup-node-env.sh
    echo -e "${GREEN}✓ Node.js 环境设置完成${NC}"
}

install_docker_env() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        clone_dotfiles
    fi
    echo -e "${YELLOW}正在设置 Docker 环境...${NC}"
    cd "$DOTFILES_DIR"
    
    # Install OrbStack on macOS
    if [[ $PLATFORM == "macos" ]] && ! command -v orbstack >/dev/null 2>&1; then
        echo -e "${YELLOW}正在安装 OrbStack...${NC}"
        brew install --cask orbstack
    fi
    
    # Build Docker development environment
    if [ -f "docker/docker-compose.ubuntu-dev.yml" ]; then
        echo -e "${YELLOW}正在构建 Ubuntu 开发环境...${NC}"
        docker-compose -f docker/docker-compose.ubuntu-dev.yml build
        echo -e "${GREEN}✓ Docker 环境准备就绪${NC}"
        echo -e "${CYAN}启动命令: docker-compose -f docker/docker-compose.ubuntu-dev.yml up -d${NC}"
    fi
    
    echo -e "${GREEN}✓ Docker 环境设置完成${NC}"
}

setup_git_config() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        clone_dotfiles
    fi
    echo -e "${YELLOW}正在设置 Git 配置...${NC}"
    cd "$DOTFILES_DIR"
    ./scripts/setup-git-config.sh
    echo -e "${GREEN}✓ Git 配置设置完成${NC}"
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
                            read -r -p "$(get_string "press_enter")" dummy < /dev/tty
                        fi
                    fi
                    ;;
                linux)
                    case "$DISTRO" in
                        ubuntu|debian|linuxmint)
                            echo -e "${YELLOW}Installing zsh on Debian/Ubuntu...${NC}"
                            safe_sudo apt update
                            safe_sudo apt install -y zsh
                            ;;
                        arch|manjaro)
                            echo -e "${YELLOW}Installing zsh on Arch/Manjaro...${NC}"
                            safe_sudo pacman -Syu --noconfirm zsh
                            ;;
                        fedora|centos|rhel)
                            echo -e "${YELLOW}Installing zsh on Fedora/CentOS...${NC}"
                            safe_sudo dnf install -y zsh
                            ;;
                        *)
                            if command -v apt >/dev/null 2>&1; then
                                echo -e "${YELLOW}Installing zsh using apt...${NC}"
                                safe_sudo apt update
                                safe_sudo apt install -y zsh
                            elif command -v pacman >/dev/null 2>&1; then
                                echo -e "${YELLOW}Installing zsh using pacman...${NC}"
                                safe_sudo pacman -Syu --noconfirm zsh
                            elif command -v dnf >/dev/null 2>&1; then
                                echo -e "${YELLOW}Installing zsh using dnf...${NC}"
                                safe_sudo dnf install -y zsh
                            else
                                echo -e "${RED}Error: No supported package manager found${NC}"
                                echo -e "${YELLOW}Please install zsh manually using your package manager${NC}"
                                return 1
                            fi
                            ;;
                    esac
                    ;;
                windows)
                    # Windows doesn't need zsh shell change
                    echo -e "${YELLOW}Skipping zsh shell change on Windows${NC}"
                    return 0
                    ;;
            esac
            
            # Verify zsh was installed and get its path
            ZSH_PATH=$(which zsh)
            if [ -z "$ZSH_PATH" ]; then
                echo -e "${RED}Error: Failed to install zsh${NC}"
                echo -e "${YELLOW}Please install zsh manually and run this script again${NC}"
                return 1
            fi
            
            echo -e "${GREEN}✓ Zsh installed successfully${NC}"
        fi
        
        # Now change the default shell
        if [ "$PLATFORM" = "macos" ]; then
            if ! safe_sudo chsh -s "$ZSH_PATH" $USER; then
                echo -e "${YELLOW}Warning: Could not change default shell to zsh${NC}"
                echo -e "${YELLOW}You may need to run manually: sudo chsh -s $ZSH_PATH $USER${NC}"
            else
                echo -e "${GREEN}✓ $(get_string "shell_changed")${NC}"
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
                echo -e "${GREEN}✓ $(get_string "shell_changed")${NC}"
            fi
        fi
        fi
    fi
}

# Main installation process
run_installation() {
    echo -e "${CYAN}$(get_string "starting_install")${NC}"
    echo ""
    
    # Check for sudo access on Unix-like systems
    if [ "$PLATFORM" != "windows" ]; then
        # Check for sudo access
        check_sudo_access
        
        # Keep sudo alive
        keep_sudo_alive
    fi
    
    # Handle conflicts first
    handle_conflicts
    
    # Install prerequisites first
    install_prerequisites
    clone_dotfiles
    
    # Make sure we're in the dotfiles directory
    cd "$DOTFILES_DIR"
    
    # Make scripts executable
    chmod +x scripts/*.sh 2>/dev/null || true
    
    # Install selected components
    if [[ $INSTALL_SYSTEM_PACKAGES == true ]]; then
        echo -e "${BLUE}Installing system packages...${NC}"
        if [ -f "scripts/stow.sh" ]; then
            # Check for conflicts first
            if [ -f "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
                echo -e "${YELLOW}Backing up existing starship.toml...${NC}"
                backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
                mkdir -p "$backup_dir/.config"
                cp "$HOME/.config/starship.toml" "$backup_dir/.config/"
                rm -f "$HOME/.config/starship.toml"
            fi
            
            # Check if system packages are already installed
            if [ -L "$HOME/.config/starship.toml" ]; then
                echo -e "${YELLOW}System packages appear to be already installed. Reinstalling...${NC}"
            fi
            
            ./scripts/stow.sh install system
        else
            echo -e "${RED}Error: stow.sh script not found${NC}"
        fi
        echo -e "${GREEN}✓ System packages installed${NC}"
    fi
    
    if [[ $INSTALL_SHELL_CONFIG == true ]]; then
        echo -e "${BLUE}Installing shell configuration...${NC}"
        if [ -f "scripts/stow.sh" ]; then
            # Check if zsh config is already installed
            if [ -L "$HOME/.zshrc" ]; then
                echo -e "${YELLOW}Shell configuration appears to be already installed. Reinstalling...${NC}"
            fi
            
            ./scripts/stow.sh install zsh
        fi
        
        # Install Zinit if not exists
        if [ ! -d "$HOME/.local/share/zinit" ]; then
            echo -e "${YELLOW}Installing Zinit...${NC}"
            sh -c "$(curl -fsSL https://git.io/zinit-install)"
        else
            echo -e "${YELLOW}Zinit already installed. Skipping...${NC}"
        fi
        echo -e "${GREEN}✓ Shell configuration installed${NC}"
    fi
    
    if [[ $INSTALL_DEV_TOOLS == true ]]; then
        echo -e "${BLUE}Installing development tools...${NC}"
        if [ -f "scripts/stow.sh" ]; then
            # Check if dev tools are already installed
            if [ -L "$HOME/.gitconfig" ] || [ -d "$HOME/.config/bat" ]; then
                echo -e "${YELLOW}Development tools appear to be already installed. Reinstalling...${NC}"
            fi
            
            ./scripts/stow.sh install git tools
        fi
        echo -e "${GREEN}✓ Development tools installed${NC}"
    fi
    
    if [[ $INSTALL_EDITORS == true ]]; then
        echo -e "${BLUE}Installing editors...${NC}"
        if [ -f "scripts/stow.sh" ]; then
            # Check if editors are already installed
            if [ -L "$HOME/.vimrc" ] || [ -L "$HOME/.config/nvim/init.vim" ]; then
                echo -e "${YELLOW}Editors appear to be already installed. Reinstalling...${NC}"
            fi
            
            ./scripts/stow.sh install vim nvim tmux
        fi
        
        # Install Oh My Tmux if not exists
        if [ ! -d "$HOME/.tmux" ]; then
            echo -e "${YELLOW}Installing Oh My Tmux...${NC}"
            git clone https://github.com/gpakosz/.tmux.git ~/.tmux
            ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
            cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
        else
            echo -e "${YELLOW}Oh My Tmux already installed. Skipping...${NC}"
        fi
        
        # Install Zed configuration if Zed is available
        if command -v zed >/dev/null 2>&1; then
            # Check if Zed config is already installed
            if [ -L "$HOME/.config/zed/settings.json" ]; then
                echo -e "${YELLOW}Zed configuration appears to be already installed. Reinstalling...${NC}"
            else
                # Handle Zed config conflicts
                if [ -f "$HOME/.config/zed/settings.json" ] && [ ! -L "$HOME/.config/zed/settings.json" ]; then
                    echo -e "${YELLOW}Backing up existing Zed settings...${NC}"
                    backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
                    mkdir -p "$backup_dir/.config/zed"
                    cp "$HOME/.config/zed/settings.json" "$backup_dir/.config/zed/"
                    rm -f "$HOME/.config/zed/settings.json"
                fi
            fi
            ./scripts/stow.sh install zed
        fi
        echo -e "${GREEN}✓ Editors installed${NC}"
    fi
    
    if [[ $INSTALL_PYTHON_ENV == true ]]; then
        echo -e "${BLUE}Setting up Python environment...${NC}"
        if [ -f "scripts/setup-python-env.sh" ]; then
            ./scripts/setup-python-env.sh
        fi
        echo -e "${GREEN}✓ Python environment configured${NC}"
    fi
    
    if [[ $INSTALL_NODE_ENV == true ]]; then
        echo -e "${BLUE}Setting up Node.js environment...${NC}"
        if [ -f "scripts/setup-node-env.sh" ]; then
            ./scripts/setup-node-env.sh
        fi
        echo -e "${GREEN}✓ Node.js environment configured${NC}"
    fi
    
    if [[ $INSTALL_DOCKER_ENV == true ]]; then
        echo -e "${BLUE}Setting up Docker environment...${NC}"
        
        # Install OrbStack on macOS
        if [[ $PLATFORM == "macos" ]] && ! command -v orbstack >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing OrbStack...${NC}"
            if command -v brew >/dev/null 2>&1; then
                brew install --cask orbstack
            fi
        fi
        
        # Build Docker development environment
        if [ -f "docker/docker-compose.ubuntu-dev.yml" ]; then
            echo -e "${YELLOW}Building Ubuntu development environment...${NC}"
            if command -v docker-compose >/dev/null 2>&1; then
                docker-compose -f docker/docker-compose.ubuntu-dev.yml build
                echo -e "${GREEN}✓ Docker environment ready${NC}"
                echo -e "${CYAN}Start command: docker-compose -f docker/docker-compose.ubuntu-dev.yml up -d${NC}"
            else
                echo -e "${YELLOW}Docker Compose not available, skipping Docker environment setup${NC}"
            fi
        fi
        echo -e "${GREEN}✓ Docker environment configured${NC}"
    fi
    
    if [[ $SETUP_GIT_CONFIG == true ]]; then
        echo -e "${BLUE}Setting up Git configuration...${NC}"
        if [ -f "scripts/setup-git-config.sh" ]; then
            ./scripts/setup-git-config.sh
        fi
        echo -e "${GREEN}✓ Git configuration setup complete${NC}"
    fi
    
    # Platform-specific installations
    platform_specific_install
    
    # Change default shell to zsh if shell config was installed
    if [[ $INSTALL_SHELL_CONFIG == true ]] && [ "$PLATFORM" != "windows" ] && [ "$SHELL" != "$(which zsh)" ]; then
        change_default_shell
    fi
    
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
            [1-8]) 
                toggle_selection $choice 
                echo ""
                echo -n "$(get_string "press_enter")"
                read -r dummy < /dev/tty
                ;;
            a|A) 
                toggle_selection a
                echo ""
                echo -n "$(get_string "press_enter")"
                read -r dummy < /dev/tty
                ;;
            c|C) 
                toggle_selection c
                echo ""
                echo -n "$(get_string "press_enter")"
                read -r dummy < /dev/tty
                ;;
            d|D) 
                toggle_selection d
                echo ""
                echo -n "$(get_string "press_enter")"
                read -r dummy < /dev/tty
                ;;
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
                    # Execute actual installation
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
                echo -n "$(get_string "press_enter")"
                read -r dummy < /dev/tty
                ;;
        esac
    done
}

# Run the interactive installer
main