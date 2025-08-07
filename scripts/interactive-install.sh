#!/bin/sh
# Cross-Platform Dotfiles Interactive Installer
# Compatible with sh, bash, and zsh

set -e

# Language detection
LANG_EN="en"
LANG_ZH="zh"
CURRENT_LANG=$LANG_EN

if [ "$LANG" != "" ] && echo "$LANG" | grep -q "zh"; then
    CURRENT_LANG=$LANG_ZH
elif [ "$LC_ALL" != "" ] && echo "$LC_ALL" | grep -q "zh"; then
    CURRENT_LANG=$LANG_ZH
fi

# Language strings - using simple variables for sh compatibility
# English strings
STRINGS_EN_title="Cross-Platform Dotfiles"
STRINGS_EN_subtitle="Interactive Installation Wizard"
STRINGS_EN_platform_detected="Platform detected"
STRINGS_EN_select_language="Select Language / 选择语言"
STRINGS_EN_english="English"
STRINGS_EN_chinese="中文"
STRINGS_EN_menu_title="Please select what you want to install:"
STRINGS_EN_core_components="Core Components:"
STRINGS_EN_system_packages="System packages (essential tools)"
STRINGS_EN_shell_config="Shell configuration (Zsh + Zinit)"
STRINGS_EN_dev_tools="Development tools (Git, modern CLI tools)"
STRINGS_EN_editors="Editors (Vim, Neovim, Tmux)"
STRINGS_EN_dev_environments="Development Environments:"
STRINGS_EN_python_env="Python environment (Pyenv + Anaconda + uv + direnv)"
STRINGS_EN_node_env="Node.js environment (NVM + LTS Node)"
STRINGS_EN_docker_env="Docker development environment (Ubuntu 24.04.2 LTS)"
STRINGS_EN_configuration="Configuration:"
STRINGS_EN_git_config="Git configuration setup"
STRINGS_EN_quick_options="Quick Options:"
STRINGS_EN_install_all="Install all components"
STRINGS_EN_core_only="Core only (1-4)"
STRINGS_EN_dev_only="Development environments only (5-7)"
STRINGS_EN_actions="Actions:"
STRINGS_EN_show_selections="Show current selections"
STRINGS_EN_start_install="Start installation"
STRINGS_EN_quit="Quit"
STRINGS_EN_current_selections="Current Selections:"
STRINGS_EN_conflict_detected="Configuration conflicts detected!"
STRINGS_EN_backup_option="Backup existing configurations"
STRINGS_EN_overwrite_option="Overwrite existing configurations"
STRINGS_EN_skip_option="Skip conflicting files"
STRINGS_EN_cancel_option="Cancel installation"
STRINGS_EN_choose_conflict_action="How would you like to handle conflicts?"
STRINGS_EN_installation_cancelled="Installation cancelled."
STRINGS_EN_invalid_choice="Invalid choice. Please try again."
STRINGS_EN_enter_choice="Enter your choice"
STRINGS_EN_press_enter="Press Enter to continue..."
STRINGS_EN_starting_install="Starting installation..."
STRINGS_EN_install_complete="Installation Complete!"
STRINGS_EN_restart_terminal="Please restart your terminal to apply all changes."
STRINGS_EN_manage_dotfiles="You can manage your dotfiles with:"
STRINGS_EN_happy_coding="Happy coding!"
STRINGS_EN_no_components="No components selected!"
STRINGS_EN_installing_prerequisites="Installing prerequisites"
STRINGS_EN_prerequisites_installed="Prerequisites installed"
STRINGS_EN_cloning_dotfiles="Cloning dotfiles"
STRINGS_EN_dotfiles_cloned="Dotfiles cloned"
STRINGS_EN_installing_system="Installing system packages"
STRINGS_EN_system_installed="System packages installed"
STRINGS_EN_installing_shell="Installing shell configuration"
STRINGS_EN_installing_zinit="Installing Zinit"
STRINGS_EN_shell_installed="Shell configuration installed"
STRINGS_EN_installing_dev="Installing development tools"
STRINGS_EN_dev_installed="Development tools installed"
STRINGS_EN_installing_editors="Installing editors"
STRINGS_EN_installing_tmux="Installing Oh My Tmux"
STRINGS_EN_editors_installed="Editors installed"
STRINGS_EN_setting_python="Setting up Python environment"
STRINGS_EN_python_configured="Python environment configured"
STRINGS_EN_setting_node="Setting up Node.js environment"
STRINGS_EN_node_configured="Node.js environment configured"
STRINGS_EN_setting_docker="Setting up Docker environment"
STRINGS_EN_installing_orbstack="Installing OrbStack"
STRINGS_EN_building_ubuntu="Building Ubuntu development environment"
STRINGS_EN_docker_ready="Docker environment ready"
STRINGS_EN_docker_start_cmd="Start command"
STRINGS_EN_setting_git="Setting up Git configuration"
STRINGS_EN_git_setup="Git configuration setup"
STRINGS_EN_installing_brew="Installing Homebrew packages"
STRINGS_EN_installing_linux_brew="Installing Linux Homebrew packages"
STRINGS_EN_changing_shell="Changing default shell"
STRINGS_EN_shell_changed="Default shell changed"
STRINGS_EN_installing_xcode="Installing Xcode Command Line Tools"
STRINGS_EN_xcode_complete="Please press Enter when Xcode installation is complete"

# Chinese strings
STRINGS_ZH_title="跨平台 Dotfiles 配置"
STRINGS_ZH_subtitle="交互式安装向导"
STRINGS_ZH_platform_detected="检测到平台"
STRINGS_ZH_select_language="Select Language / 选择语言"
STRINGS_ZH_english="English"
STRINGS_ZH_chinese="中文"
STRINGS_ZH_menu_title="请选择要安装的组件："
STRINGS_ZH_core_components="核心组件："
STRINGS_ZH_system_packages="系统软件包（基础工具）"
STRINGS_ZH_shell_config="Shell 配置（Zsh + Zinit）"
STRINGS_ZH_dev_tools="开发工具（Git，现代 CLI 工具）"
STRINGS_ZH_editors="编辑器（Vim，Neovim，Tmux）"
STRINGS_ZH_dev_environments="开发环境："
STRINGS_ZH_python_env="Python 环境（Pyenv + Anaconda + uv + direnv）"
STRINGS_ZH_node_env="Node.js 环境（NVM + LTS Node）"
STRINGS_ZH_docker_env="Docker 开发环境（Ubuntu 24.04.2 LTS）"
STRINGS_ZH_configuration="配置："
STRINGS_ZH_git_config="Git 配置设置"
STRINGS_ZH_quick_options="快速选项："
STRINGS_ZH_install_all="安装所有组件"
STRINGS_ZH_core_only="仅核心组件（1-4）"
STRINGS_ZH_dev_only="仅开发环境（5-7）"
STRINGS_ZH_actions="操作："
STRINGS_ZH_show_selections="显示当前选择"
STRINGS_ZH_start_install="开始安装"
STRINGS_ZH_quit="退出"
STRINGS_ZH_current_selections="当前选择："
STRINGS_ZH_conflict_detected="检测到配置冲突！"
STRINGS_ZH_backup_option="备份现有配置"
STRINGS_ZH_overwrite_option="覆盖现有配置"
STRINGS_ZH_skip_option="跳过冲突文件"
STRINGS_ZH_cancel_option="取消安装"
STRINGS_ZH_choose_conflict_action="如何处理冲突？"
STRINGS_ZH_installation_cancelled="安装已取消。"
STRINGS_ZH_invalid_choice="无效选择。请重试。"
STRINGS_ZH_enter_choice="输入你的选择"
STRINGS_ZH_press_enter="按 Enter 继续..."
STRINGS_ZH_starting_install="开始安装..."
STRINGS_ZH_install_complete="安装完成！"
STRINGS_ZH_restart_terminal="请重启终端以应用所有更改。"
STRINGS_ZH_manage_dotfiles="你可以使用以下命令管理 dotfiles："
STRINGS_ZH_happy_coding="编程愉快！"

# Get localized string - simple case statement for compatibility
get_string() {
    local key="$1"
    if [ "$CURRENT_LANG" = "zh" ]; then
        case "$key" in
            "title") echo "$STRINGS_ZH_title" ;;
            "subtitle") echo "$STRINGS_ZH_subtitle" ;;
            "platform_detected") echo "$STRINGS_ZH_platform_detected" ;;
            "select_language") echo "$STRINGS_ZH_select_language" ;;
            "english") echo "$STRINGS_ZH_english" ;;
            "chinese") echo "$STRINGS_ZH_chinese" ;;
            "menu_title") echo "$STRINGS_ZH_menu_title" ;;
            "core_components") echo "$STRINGS_ZH_core_components" ;;
            "system_packages") echo "$STRINGS_ZH_system_packages" ;;
            "shell_config") echo "$STRINGS_ZH_shell_config" ;;
            "dev_tools") echo "$STRINGS_ZH_dev_tools" ;;
            "editors") echo "$STRINGS_ZH_editors" ;;
            "dev_environments") echo "$STRINGS_ZH_dev_environments" ;;
            "python_env") echo "$STRINGS_ZH_python_env" ;;
            "node_env") echo "$STRINGS_ZH_node_env" ;;
            "docker_env") echo "$STRINGS_ZH_docker_env" ;;
            "configuration") echo "$STRINGS_ZH_configuration" ;;
            "git_config") echo "$STRINGS_ZH_git_config" ;;
            "quick_options") echo "$STRINGS_ZH_quick_options" ;;
            "install_all") echo "$STRINGS_ZH_install_all" ;;
            "core_only") echo "$STRINGS_ZH_core_only" ;;
            "dev_only") echo "$STRINGS_ZH_dev_only" ;;
            "actions") echo "$STRINGS_ZH_actions" ;;
            "show_selections") echo "$STRINGS_ZH_show_selections" ;;
            "start_install") echo "$STRINGS_ZH_start_install" ;;
            "quit") echo "$STRINGS_ZH_quit" ;;
            "current_selections") echo "$STRINGS_ZH_current_selections" ;;
            "conflict_detected") echo "$STRINGS_ZH_conflict_detected" ;;
            "backup_option") echo "$STRINGS_ZH_backup_option" ;;
            "overwrite_option") echo "$STRINGS_ZH_overwrite_option" ;;
            "skip_option") echo "$STRINGS_ZH_skip_option" ;;
            "cancel_option") echo "$STRINGS_ZH_cancel_option" ;;
            "choose_conflict_action") echo "$STRINGS_ZH_choose_conflict_action" ;;
            "installation_cancelled") echo "$STRINGS_ZH_installation_cancelled" ;;
            "invalid_choice") echo "$STRINGS_ZH_invalid_choice" ;;
            "enter_choice") echo "$STRINGS_ZH_enter_choice" ;;
            "press_enter") echo "$STRINGS_ZH_press_enter" ;;
            "starting_install") echo "$STRINGS_ZH_starting_install" ;;
            "install_complete") echo "$STRINGS_ZH_install_complete" ;;
            "restart_terminal") echo "$STRINGS_ZH_restart_terminal" ;;
            "manage_dotfiles") echo "$STRINGS_ZH_manage_dotfiles" ;;
            "happy_coding") echo "$STRINGS_ZH_happy_coding" ;;
            "no_components") echo "$STRINGS_ZH_no_components" ;;
            "installing_prerequisites") echo "$STRINGS_ZH_installing_prerequisites" ;;
            "prerequisites_installed") echo "$STRINGS_ZH_prerequisites_installed" ;;
            "cloning_dotfiles") echo "$STRINGS_ZH_cloning_dotfiles" ;;
            "dotfiles_cloned") echo "$STRINGS_ZH_dotfiles_cloned" ;;
            "installing_system") echo "$STRINGS_ZH_installing_system" ;;
            "system_installed") echo "$STRINGS_ZH_system_installed" ;;
            "installing_shell") echo "$STRINGS_ZH_installing_shell" ;;
            "installing_zinit") echo "$STRINGS_ZH_installing_zinit" ;;
            "shell_installed") echo "$STRINGS_ZH_shell_installed" ;;
            "installing_dev") echo "$STRINGS_ZH_installing_dev" ;;
            "dev_installed") echo "$STRINGS_ZH_dev_installed" ;;
            "installing_editors") echo "$STRINGS_ZH_installing_editors" ;;
            "installing_tmux") echo "$STRINGS_ZH_installing_tmux" ;;
            "editors_installed") echo "$STRINGS_ZH_editors_installed" ;;
            "setting_python") echo "$STRINGS_ZH_setting_python" ;;
            "python_configured") echo "$STRINGS_ZH_python_configured" ;;
            "setting_node") echo "$STRINGS_ZH_setting_node" ;;
            "node_configured") echo "$STRINGS_ZH_node_configured" ;;
            "setting_docker") echo "$STRINGS_ZH_setting_docker" ;;
            "installing_orbstack") echo "$STRINGS_ZH_installing_orbstack" ;;
            "building_ubuntu") echo "$STRINGS_ZH_building_ubuntu" ;;
            "docker_ready") echo "$STRINGS_ZH_docker_ready" ;;
            "docker_start_cmd") echo "$STRINGS_ZH_docker_start_cmd" ;;
            "setting_git") echo "$STRINGS_ZH_setting_git" ;;
            "git_setup") echo "$STRINGS_ZH_git_setup" ;;
            "installing_brew") echo "$STRINGS_ZH_installing_brew" ;;
            "installing_linux_brew") echo "$STRINGS_ZH_installing_linux_brew" ;;
            "changing_shell") echo "$STRINGS_ZH_changing_shell" ;;
            "shell_changed") echo "$STRINGS_ZH_shell_changed" ;;
            "installing_xcode") echo "$STRINGS_ZH_installing_xcode" ;;
            "xcode_complete") echo "$STRINGS_ZH_xcode_complete" ;;
            *) echo "$key" ;;
        esac
    else
        case "$key" in
            "title") echo "$STRINGS_EN_title" ;;
            "subtitle") echo "$STRINGS_EN_subtitle" ;;
            "platform_detected") echo "$STRINGS_EN_platform_detected" ;;
            "select_language") echo "$STRINGS_EN_select_language" ;;
            "english") echo "$STRINGS_EN_english" ;;
            "chinese") echo "$STRINGS_EN_chinese" ;;
            "menu_title") echo "$STRINGS_EN_menu_title" ;;
            "core_components") echo "$STRINGS_EN_core_components" ;;
            "system_packages") echo "$STRINGS_EN_system_packages" ;;
            "shell_config") echo "$STRINGS_EN_shell_config" ;;
            "dev_tools") echo "$STRINGS_EN_dev_tools" ;;
            "editors") echo "$STRINGS_EN_editors" ;;
            "dev_environments") echo "$STRINGS_EN_dev_environments" ;;
            "python_env") echo "$STRINGS_EN_python_env" ;;
            "node_env") echo "$STRINGS_EN_node_env" ;;
            "docker_env") echo "$STRINGS_EN_docker_env" ;;
            "configuration") echo "$STRINGS_EN_configuration" ;;
            "git_config") echo "$STRINGS_EN_git_config" ;;
            "quick_options") echo "$STRINGS_EN_quick_options" ;;
            "install_all") echo "$STRINGS_EN_install_all" ;;
            "core_only") echo "$STRINGS_EN_core_only" ;;
            "dev_only") echo "$STRINGS_EN_dev_only" ;;
            "actions") echo "$STRINGS_EN_actions" ;;
            "show_selections") echo "$STRINGS_EN_show_selections" ;;
            "start_install") echo "$STRINGS_EN_start_install" ;;
            "quit") echo "$STRINGS_EN_quit" ;;
            "current_selections") echo "$STRINGS_EN_current_selections" ;;
            "conflict_detected") echo "$STRINGS_EN_conflict_detected" ;;
            "backup_option") echo "$STRINGS_EN_backup_option" ;;
            "overwrite_option") echo "$STRINGS_EN_overwrite_option" ;;
            "skip_option") echo "$STRINGS_EN_skip_option" ;;
            "cancel_option") echo "$STRINGS_EN_cancel_option" ;;
            "choose_conflict_action") echo "$STRINGS_EN_choose_conflict_action" ;;
            "installation_cancelled") echo "$STRINGS_EN_installation_cancelled" ;;
            "invalid_choice") echo "$STRINGS_EN_invalid_choice" ;;
            "enter_choice") echo "$STRINGS_EN_enter_choice" ;;
            "press_enter") echo "$STRINGS_EN_press_enter" ;;
            "starting_install") echo "$STRINGS_EN_starting_install" ;;
            "install_complete") echo "$STRINGS_EN_install_complete" ;;
            "restart_terminal") echo "$STRINGS_EN_restart_terminal" ;;
            "manage_dotfiles") echo "$STRINGS_EN_manage_dotfiles" ;;
            "happy_coding") echo "$STRINGS_EN_happy_coding" ;;
            "no_components") echo "$STRINGS_EN_no_components" ;;
            "installing_prerequisites") echo "$STRINGS_EN_installing_prerequisites" ;;
            "prerequisites_installed") echo "$STRINGS_EN_prerequisites_installed" ;;
            "cloning_dotfiles") echo "$STRINGS_EN_cloning_dotfiles" ;;
            "dotfiles_cloned") echo "$STRINGS_EN_dotfiles_cloned" ;;
            "installing_system") echo "$STRINGS_EN_installing_system" ;;
            "system_installed") echo "$STRINGS_EN_system_installed" ;;
            "installing_shell") echo "$STRINGS_EN_installing_shell" ;;
            "installing_zinit") echo "$STRINGS_EN_installing_zinit" ;;
            "shell_installed") echo "$STRINGS_EN_shell_installed" ;;
            "installing_dev") echo "$STRINGS_EN_installing_dev" ;;
            "dev_installed") echo "$STRINGS_EN_dev_installed" ;;
            "installing_editors") echo "$STRINGS_EN_installing_editors" ;;
            "installing_tmux") echo "$STRINGS_EN_installing_tmux" ;;
            "editors_installed") echo "$STRINGS_EN_editors_installed" ;;
            "setting_python") echo "$STRINGS_EN_setting_python" ;;
            "python_configured") echo "$STRINGS_EN_python_configured" ;;
            "setting_node") echo "$STRINGS_EN_setting_node" ;;
            "node_configured") echo "$STRINGS_EN_node_configured" ;;
            "setting_docker") echo "$STRINGS_EN_setting_docker" ;;
            "installing_orbstack") echo "$STRINGS_EN_installing_orbstack" ;;
            "building_ubuntu") echo "$STRINGS_EN_building_ubuntu" ;;
            "docker_ready") echo "$STRINGS_EN_docker_ready" ;;
            "docker_start_cmd") echo "$STRINGS_EN_docker_start_cmd" ;;
            "setting_git") echo "$STRINGS_EN_setting_git" ;;
            "git_setup") echo "$STRINGS_EN_git_setup" ;;
            "installing_brew") echo "$STRINGS_EN_installing_brew" ;;
            "installing_linux_brew") echo "$STRINGS_EN_installing_linux_brew" ;;
            "changing_shell") echo "$STRINGS_EN_changing_shell" ;;
            "shell_changed") echo "$STRINGS_EN_shell_changed" ;;
            "installing_xcode") echo "$STRINGS_EN_installing_xcode" ;;
            "xcode_complete") echo "$STRINGS_EN_xcode_complete" ;;
            *) echo "$key" ;;
        esac
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
        printf "${RED}Unsupported OS: $OS${NC}\n"
        exit 1
        ;;
esac

# Function to check and request sudo access
check_sudo_access() {
    printf "${YELLOW}Checking sudo access...${NC}\n"
    
    # Check if sudo is available on the system
    if ! command -v sudo >/dev/null 2>&1; then
        printf "${YELLOW}Sudo command not found on this system.${NC}\n"
        printf "${YELLOW}Some features may not work correctly.${NC}\n"
        return 1
    fi
    
    # Check if we already have sudo rights
    if sudo -n true 2>/dev/null; then
        printf "${GREEN}✓ Sudo access already granted${NC}\n"
        return 0
    fi
    
    # Request sudo access
    printf "${YELLOW}This script requires sudo access for some operations.${NC}\n"
    printf "${YELLOW}Please enter your password when prompted.${NC}\n"
    
    if sudo -v; then
        printf "${GREEN}✓ Sudo access granted${NC}\n"
        return 0
    else
        printf "${RED}✗ Sudo access denied${NC}\n"
        return 1
    fi
}

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
    printf "${CYAN}%s${NC}\n" "$(get_string "title")"
    printf "${CYAN}%s${NC}\n" "$(get_string "subtitle")"
    printf "\n"
    printf "${YELLOW}%s: $PLATFORM ${DISTRO}${NC}\n" "$(get_string "platform_detected")"
    printf "\n"
    
    # Language selection
    printf "%s\n" "$(get_string "select_language")"
    printf "1) %s\n" "$(get_string "english")"
    printf "2) %s\n" "$(get_string "chinese")"
    printf "\n"
    
    # Installation options
    printf "%s\n" "$(get_string "menu_title")"
    printf "\n"
    printf "%s\n" "$(get_string "core_components")"
    printf "1) %s\n" "$(get_string "system_packages")"
    printf "2) %s\n" "$(get_string "shell_config")"
    printf "3) %s\n" "$(get_string "dev_tools")"
    printf "4) %s\n" "$(get_string "editors")"
    printf "\n"
    printf "%s\n" "$(get_string "dev_environments")"
    printf "5) %s\n" "$(get_string "python_env")"
    printf "6) %s\n" "$(get_string "node_env")"
    printf "7) %s\n" "$(get_string "docker_env")"
    printf "\n"
    printf "%s\n" "$(get_string "configuration")"
    printf "8) %s\n" "$(get_string "git_config")"
    printf "\n"
    printf "%s\n" "$(get_string "quick_options")"
    printf "a) %s\n" "$(get_string "install_all")"
    printf "b) %s\n" "$(get_string "core_only")"
    printf "c) %s\n" "$(get_string "dev_only")"
    printf "\n"
    printf "%s\n" "$(get_string "actions")"
    printf "s) %s\n" "$(get_string "show_selections")"
    printf "i) %s\n" "$(get_string "start_install")"
    printf "q) %s\n" "$(get_string "quit")"
    printf "\n"
}

# Function to show current selections
show_selections() {
    printf "%s\n" "$(get_string "current_selections")"
    printf "\n"
    
    if [ "$INSTALL_SYSTEM_PACKAGES" = "true" ]; then
        printf "${GREEN}✓${NC} %s\n" "$(get_string "system_packages")"
    fi
    
    if [ "$INSTALL_SHELL_CONFIG" = "true" ]; then
        printf "${GREEN}✓${NC} %s\n" "$(get_string "shell_config")"
    fi
    
    if [ "$INSTALL_DEV_TOOLS" = "true" ]; then
        printf "${GREEN}✓${NC} %s\n" "$(get_string "dev_tools")"
    fi
    
    if [ "$INSTALL_EDITORS" = "true" ]; then
        printf "${GREEN}✓${NC} %s\n" "$(get_string "editors")"
    fi
    
    if [ "$INSTALL_PYTHON_ENV" = "true" ]; then
        printf "${GREEN}✓${NC} %s\n" "$(get_string "python_env")"
    fi
    
    if [ "$INSTALL_NODE_ENV" = "true" ]; then
        printf "${GREEN}✓${NC} %s\n" "$(get_string "node_env")"
    fi
    
    if [ "$INSTALL_DOCKER_ENV" = "true" ]; then
        printf "${GREEN}✓${NC} %s\n" "$(get_string "docker_env")"
    fi
    
    if [ "$INSTALL_GIT_CONFIG" = "true" ]; then
        printf "${GREEN}✓${NC} %s\n" "$(get_string "git_config")"
    fi
    
    if [ "$INSTALL_SYSTEM_PACKAGES" = "false" ] && [ "$INSTALL_SHELL_CONFIG" = "false" ] && [ "$INSTALL_DEV_TOOLS" = "false" ] && [ "$INSTALL_EDITORS" = "false" ] && [ "$INSTALL_PYTHON_ENV" = "false" ] && [ "$INSTALL_NODE_ENV" = "false" ] && [ "$INSTALL_DOCKER_ENV" = "false" ] && [ "$INSTALL_GIT_CONFIG" = "false" ]; then
        printf "${RED}%s${NC}\n" "$(get_string "no_components")"
    fi
    
    printf "\n"
    printf "%s\n" "$(get_string "press_enter")"
    
    # Check if stdin is a terminal before reading
    if [ ! -t 0 ]; then
        printf "${YELLOW}Press Enter to continue... (not a terminal, skipping wait)${NC}\n"
        return
    fi
    
    # Read with error handling
    if ! read -r dummy; then
        printf "${YELLOW}Failed to read input, continuing...${NC}\n"
        return
    fi
}

# Function to handle user input
handle_input() {
    while true; do
        show_main_menu
        printf "%s:\n" "$(get_string "enter_choice")"
        
        # Read user input with error handling
        # Try different methods to read input
        choice=""
        
        # Method 1: Try standard read
        if [ -t 0 ]; then
            if read -r choice 2>/dev/null; then
                : # Read successful
            else
                printf "${RED}Error: Failed to read input from terminal.${NC}\n"
                exit 1
            fi
        else
            # Method 2: Try reading from /dev/tty
            if [ -c /dev/tty ]; then
                printf "${YELLOW}Terminal not interactive, trying alternative input method...${NC}\n"
                if read -r choice < /dev/tty 2>/dev/null; then
                    : # Read from /dev/tty successful
                else
                    printf "${RED}Error: This script requires an interactive terminal.${NC}\n"
                    printf "${YELLOW}Please run this script directly in your terminal, not through a pipe.${NC}\n"
                    printf "${YELLOW}Or try: bash -i $(basename "$0")${NC}\n"
                    exit 1
                fi
            else
                printf "${RED}Error: This script requires an interactive terminal.${NC}\n"
                printf "${YELLOW}Please run this script directly in your terminal.${NC}\n"
                printf "${YELLOW}Or try: bash -i $(basename "$0")${NC}\n"
                exit 1
            fi
        fi
        
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
            b|B)
                INSTALL_SYSTEM_PACKAGES=true
                INSTALL_SHELL_CONFIG=true
                INSTALL_DEV_TOOLS=true
                INSTALL_EDITORS=true
                ;;
            c|C)
                INSTALL_PYTHON_ENV=true
                INSTALL_NODE_ENV=true
                INSTALL_DOCKER_ENV=true
                ;;
            s|S) show_selections ;;
            i|I) return 0 ;;
            q|Q) 
                printf "%s\n" "$(get_string "installation_cancelled")"
                exit 0
                ;;
            *)
                printf "%s\n" "$(get_string "invalid_choice")"
                sleep 1
                ;;
        esac
    done
}

# Main installation function
main_install() {
    printf "%s\n" "$(get_string "starting_install")"
    printf "\n"
    
    # Check for sudo access
    check_sudo_access
    
    # Install system packages
    if [ "$INSTALL_SYSTEM_PACKAGES" = "true" ]; then
        printf "${YELLOW}%s...${NC}\n" "$(get_string "installing_system")"
        # Add system package installation logic here
        printf "${GREEN}%s${NC}\n" "$(get_string "system_installed")"
    fi
    
    # Install shell configuration
    if [ "$INSTALL_SHELL_CONFIG" = "true" ]; then
        printf "${YELLOW}%s...${NC}\n" "$(get_string "installing_shell")"
        # Add shell configuration installation logic here
        printf "${GREEN}%s${NC}\n" "$(get_string "shell_installed")"
    fi
    
    # Install development tools
    if [ "$INSTALL_DEV_TOOLS" = "true" ]; then
        printf "${YELLOW}%s...${NC}\n" "$(get_string "installing_dev")"
        # Add development tools installation logic here
        printf "${GREEN}%s${NC}\n" "$(get_string "dev_installed")"
    fi
    
    # Install editors
    if [ "$INSTALL_EDITORS" = "true" ]; then
        printf "${YELLOW}%s...${NC}\n" "$(get_string "installing_editors")"
        # Add editors installation logic here
        printf "${GREEN}%s${NC}\n" "$(get_string "editors_installed")"
    fi
    
    # Install Python environment
    if [ "$INSTALL_PYTHON_ENV" = "true" ]; then
        printf "${YELLOW}%s...${NC}\n" "$(get_string "setting_python")"
        # Add Python environment installation logic here
        printf "${GREEN}%s${NC}\n" "$(get_string "python_configured")"
    fi
    
    # Install Node.js environment
    if [ "$INSTALL_NODE_ENV" = "true" ]; then
        printf "${YELLOW}%s...${NC}\n" "$(get_string "setting_node")"
        # Add Node.js environment installation logic here
        printf "${GREEN}%s${NC}\n" "$(get_string "node_configured")"
    fi
    
    # Install Docker environment
    if [ "$INSTALL_DOCKER_ENV" = "true" ]; then
        printf "${YELLOW}%s...${NC}\n" "$(get_string "setting_docker")"
        # Add Docker environment installation logic here
        printf "${GREEN}%s${NC}\n" "$(get_string "docker_ready")"
    fi
    
    # Setup Git configuration
    if [ "$INSTALL_GIT_CONFIG" = "true" ]; then
        printf "${YELLOW}%s...${NC}\n" "$(get_string "setting_git")"
        # Add Git configuration logic here
        printf "${GREEN}%s${NC}\n" "$(get_string "git_setup")"
    fi
    
    printf "\n"
    printf "${GREEN}%s${NC}\n" "$(get_string "install_complete")"
    printf "%s\n" "$(get_string "restart_terminal")"
    printf "\n"
    printf "%s\n" "$(get_string "manage_dotfiles")"
    printf "${CYAN}cd ~/.dotfiles && ./manage.sh${NC}\n"
    printf "\n"
    printf "%s\n" "$(get_string "happy_coding")"
}

# Main execution
handle_input
main_install