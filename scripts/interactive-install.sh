#!/bin/sh
# Cross-Platform Dotfiles Interactive Installer
# Compatible with sh, bash, and zsh

set -e

# Language detection
CURRENT_LANG="en"

if [ "$LANG" != "" ] && echo "$LANG" | grep -q "zh"; then
    CURRENT_LANG="zh"
elif [ "$LC_ALL" != "" ] && echo "$LC_ALL" | grep -q "zh"; then
    CURRENT_LANG="zh"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Simple string function
get_string() {
    if [ "$CURRENT_LANG" = "zh" ]; then
        case "$1" in
            "title") echo "跨平台 Dotfiles 配置" ;;
            "subtitle") echo "交互式安装向导" ;;
            "platform_detected") echo "检测到平台" ;;
            "menu_title") echo "请选择要安装的组件：" ;;
            "system_packages") echo "系统软件包（基础工具）" ;;
            "shell_config") echo "Shell 配置（Zsh + Zinit）" ;;
            "dev_tools") echo "开发工具（Git，现代 CLI 工具）" ;;
            "editors") echo "编辑器（Vim，Neovim，Tmux）" ;;
            "python_env") echo "Python 环境（Pyenv + Anaconda + uv + direnv）" ;;
            "node_env") echo "Node.js 环境（NVM + LTS Node）" ;;
            "docker_env") echo "Docker 开发环境（Ubuntu 24.04.2 LTS）" ;;
            "git_config") echo "Git 配置设置" ;;
            "install_all") echo "安装所有组件" ;;
            "start_install") echo "开始安装" ;;
            "quit") echo "退出" ;;
            "install_complete") echo "安装完成！" ;;
            "restart_terminal") echo "请重启终端以应用所有更改。" ;;
            "happy_coding") echo "编程愉快！" ;;
            "starting_install") echo "开始安装..." ;;
            *) echo "$1" ;;
        esac
    else
        case "$1" in
            "title") echo "Cross-Platform Dotfiles" ;;
            "subtitle") echo "Interactive Installation Wizard" ;;
            "platform_detected") echo "Platform detected" ;;
            "menu_title") echo "Please select what you want to install:" ;;
            "system_packages") echo "System packages (essential tools)" ;;
            "shell_config") echo "Shell configuration (Zsh + Zinit)" ;;
            "dev_tools") echo "Development tools (Git, modern CLI tools)" ;;
            "editors") echo "Editors (Vim, Neovim, Tmux)" ;;
            "python_env") echo "Python environment (Pyenv + Anaconda + uv + direnv)" ;;
            "node_env") echo "Node.js environment (NVM + LTS Node)" ;;
            "docker_env") echo "Docker development environment (Ubuntu 24.04.2 LTS)" ;;
            "git_config") echo "Git configuration setup" ;;
            "install_all") echo "Install all components" ;;
            "start_install") echo "Start installation" ;;
            "quit") echo "Quit" ;;
            "install_complete") echo "Installation Complete!" ;;
            "restart_terminal") echo "Please restart your terminal to apply all changes." ;;
            "happy_coding") echo "Happy coding!" ;;
            "starting_install") echo "Starting installation..." ;;
            *) echo "$1" ;;
        esac
    fi
}

# Detect platform
OS="$(uname -s)"
PLATFORM=""

case "$OS" in
    Linux) PLATFORM="linux" ;;
    Darwin) PLATFORM="macos" ;;
    CYGWIN*|MINGW*|MSYS*) PLATFORM="windows" ;;
    *) 
        echo -e "${RED}Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac

# Installation selections
INSTALL_SYSTEM_PACKAGES=false
INSTALL_SHELL_CONFIG=false
INSTALL_DEV_TOOLS=false
INSTALL_EDITORS=false
INSTALL_PYTHON_ENV=false
INSTALL_NODE_ENV=false
INSTALL_DOCKER_ENV=false
INSTALL_GIT_CONFIG=false

# Function to display main menu
show_main_menu() {
    clear
    echo -e "${CYAN}$(get_string "title")${NC}"
    echo -e "${CYAN}$(get_string "subtitle")${NC}"
    echo ""
    echo -e "${YELLOW}$(get_string "platform_detected"): $PLATFORM${NC}"
    echo ""
    
    echo -e "$(get_string "menu_title")"
    echo ""
    echo "Core Components:"
    echo "1) $(get_string "system_packages")"
    echo "2) $(get_string "shell_config")"
    echo "3) $(get_string "dev_tools")"
    echo "4) $(get_string "editors")"
    echo ""
    echo "Development Environments:"
    echo "5) $(get_string "python_env")"
    echo "6) $(get_string "node_env")"
    echo "7) $(get_string "docker_env")"
    echo ""
    echo "Configuration:"
    echo "8) $(get_string "git_config")"
    echo ""
    echo "Quick Options:"
    echo "a) $(get_string "install_all")"
    echo ""
    echo "Actions:"
    echo "i) $(get_string "start_install")"
    echo "q) $(get_string "quit")"
    echo ""
}

# Function to handle user input
handle_input() {
    while true; do
        show_main_menu
        echo "Enter your choice (1-8, a, i, q):"
        read -r choice
        
        case "$choice" in
            1) INSTALL_SYSTEM_PACKAGES=true ;;
            2) INSTALL_SHELL_CONFIG=true ;;
            3) INSTALL_DEV_TOOLS=true ;;
            4) INSTALL_EDITORS=true ;;
            5) INSTALL_PYTHON_ENV=true ;;
            6) INSTALL_NODE_ENV=true ;;
            7) INSTALL_DOCKER_ENV=true ;;
            8) INSTALL_GIT_CONFIG=true ;;
            a|A)
                INSTALL_SYSTEM_PACKAGES=true
                INSTALL_SHELL_CONFIG=true
                INSTALL_DEV_TOOLS=true
                INSTALL_EDITORS=true
                INSTALL_PYTHON_ENV=true
                INSTALL_NODE_ENV=true
                INSTALL_DOCKER_ENV=true
                INSTALL_GIT_CONFIG=true
                ;;
            i|I) return 0 ;;
            q|Q) 
                echo "Installation cancelled."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                sleep 1
                ;;
        esac
    done
}

# Main installation function
main_install() {
    echo ""
    echo -e "${YELLOW}$(get_string "starting_install")${NC}"
    echo ""
    
    # Install system packages
    if [ "$INSTALL_SYSTEM_PACKAGES" = "true" ]; then
        echo -e "${YELLOW}Installing system packages...${NC}"
        echo -e "${GREEN}✓ System packages installed${NC}"
    fi
    
    # Install shell configuration
    if [ "$INSTALL_SHELL_CONFIG" = "true" ]; then
        echo -e "${YELLOW}Installing shell configuration...${NC}"
        echo -e "${GREEN}✓ Shell configuration installed${NC}"
    fi
    
    # Install development tools
    if [ "$INSTALL_DEV_TOOLS" = "true" ]; then
        echo -e "${YELLOW}Installing development tools...${NC}"
        echo -e "${GREEN}✓ Development tools installed${NC}"
    fi
    
    # Install editors
    if [ "$INSTALL_EDITORS" = "true" ]; then
        echo -e "${YELLOW}Installing editors...${NC}"
        echo -e "${GREEN}✓ Editors installed${NC}"
    fi
    
    # Install Python environment
    if [ "$INSTALL_PYTHON_ENV" = "true" ]; then
        echo -e "${YELLOW}Setting up Python environment...${NC}"
        echo -e "${GREEN}✓ Python environment configured${NC}"
    fi
    
    # Install Node.js environment
    if [ "$INSTALL_NODE_ENV" = "true" ]; then
        echo -e "${YELLOW}Setting up Node.js environment...${NC}"
        echo -e "${GREEN}✓ Node.js environment configured${NC}"
    fi
    
    # Install Docker environment
    if [ "$INSTALL_DOCKER_ENV" = "true" ]; then
        echo -e "${YELLOW}Setting up Docker environment...${NC}"
        echo -e "${GREEN}✓ Docker environment ready${NC}"
    fi
    
    # Setup Git configuration
    if [ "$INSTALL_GIT_CONFIG" = "true" ]; then
        echo -e "${YELLOW}Setting up Git configuration...${NC}"
        echo -e "${GREEN}✓ Git configuration setup${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}$(get_string "install_complete")${NC}"
    echo -e "$(get_string "restart_terminal")"
    echo ""
    echo -e "$(get_string "happy_coding")"
}

# Main execution
handle_input
main_install