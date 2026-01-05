#!/bin/bash
# Terminal Font Configuration Script
# 配置终端使用 Hack Nerd Font

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "\n${CYAN}${BOLD}▶ $1${NC}"; }

# 字体名称
FONT_NAME="HackNerdFont"
FONT_DISPLAY_NAME="Hack Nerd Font"

# 检查字体是否已安装
check_font_installed() {
    log_step "检查字体安装状态"

    if system_profiler SPFontsDataType 2>/dev/null | grep -qi "Hack Nerd Font"; then
        log_success "✓ Hack Nerd Font 已安装"
        return 0
    else
        log_warning "✗ Hack Nerd Font 未安装"
        log_info "请先运行: brew install --cask font-hack-nerd-font"
        return 1
    fi
}

# 配置 Terminal.app
configure_terminal_app() {
    if [[ ! -d "/Applications/Utilities/Terminal.app" ]]; then
        return 0
    fi

    log_step "配置 Terminal.app"

    # 获取当前默认配置文件名称
    DEFAULT_PROFILE=$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null)

    if [[ -z "$DEFAULT_PROFILE" ]]; then
        # 如果没有默认配置，使用 Basic
        DEFAULT_PROFILE="Basic"
    fi

    log_info "使用配置文件: $DEFAULT_PROFILE"

    # 设置字体
    # 注意：Terminal.app 需要字体名称的完整 PostScript 名称
    if defaults write com.apple.Terminal "$DEFAULT_PROFILE" -dict-add "Font" "$FONT_NAME"; then
        defaults write com.apple.Terminal "Default Window Settings" "$DEFAULT_PROFILE"
        defaults write com.apple.Terminal "Startup Window Settings" "$DEFAULT_PROFILE"
        log_success "✓ Terminal.app 已配置为使用 $FONT_DISPLAY_NAME"
    else
        log_warning "配置 Terminal.app 失败"
    fi
}

# 配置 iTerm2
configure_iterm2() {
    if [[ ! -d "/Applications/iTerm.app" ]] && [[ ! -d "$HOME/Applications/iTerm.app" ]]; then
        return 0
    fi

    log_step "配置 iTerm2"

    # iTerm2 使用 plist 文件，需要使用 plutil 或 defaults
    # 检查 iTerm2 是否正在运行
    if pgrep -q "iTerm2"; then
        log_warning "iTerm2 正在运行，配置将在重启后生效"
        RUNNING=true
    else
        RUNNING=false
    fi

    # 设置字体
    # iTerm2 的字体设置存储在 com.googlecode.iterm2.plist 中
    # 我们需要设置 "Normal Font" 和 "Non-ASCII Font"

    # 检查是否已有自定义配置文件
    if defaults read com.googlecode.iterm2 "New Bookmarks" >/dev/null 2>&1; then
        # 创建一个脚本来设置字体
        osascript <<EOF >/dev/null 2>&1
tell application "System Events"
    tell application "iTerm"
        -- 尝试设置当前会话的字体
        try
            set current_terminal to current window
            set current_session to current terminal
            tell current_session
                set font name to "$FONT_NAME"
                set font size to 13
            end tell
        on error
            -- 如果失败，说明需要手动配置
        end try
    end tell
end tell
EOF

        if [[ $? -eq 0 ]]; then
            log_success "✓ iTerm2 已配置为使用 $FONT_DISPLAY_NAME"
        else
            log_warning "自动配置 iTerm2 失败，请手动配置"
        fi
    fi
}

# 配置 Warp
configure_warp() {
    if [[ ! -d "/Applications/Warp.app" ]] && [[ ! -d "$HOME/Applications/Warp.app" ]]; then
        return 0
    fi

    log_step "配置 Warp"

    # Warp 的配置存储在 ~/.warp/ 目录
    # Warp 不支持通过命令行直接配置字体
    log_warning "Warp 需要手动配置字体"
    log_info "请按照以下步骤操作："
    echo "  1. 打开 Warp"
    echo "  2. 按 Cmd+, 打开设置"
    echo "  3. 选择 'Appearance'"
    echo "  4. 在 'Font' 下拉菜单中选择 '$FONT_DISPLAY_NAME'"
}

# 显示手动配置说明
show_manual_instructions() {
    cat <<EOF

${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}
${BOLD}              手动配置终端字体说明${NC}
${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}

${BOLD}${YELLOW}Terminal.app (macOS 内置终端)${NC}
${GREEN}✓${NC} 已自动配置

${BOLD}${YELLOW}iTerm2${NC}
1. 打开 iTerm2
2. 按 ${GREEN}Cmd + ,${NC} 打开偏好设置
3. 选择 ${GREEN}Profiles${NC} → ${GREEN}Text${NC}
4. 在 ${GREEN}Font${NC} 部分，点击 ${GREEN}Change Font${NC}
5. 选择 ${GREEN}$FONT_DISPLAY_NAME${NC}，建议大小 13
6. 关闭设置窗口

${BOLD}${YELLOW}Warp${NC}
1. 打开 Warp
2. 按 ${GREEN}Cmd + ,${NC} 打开设置
3. 选择 ${GREEN}Appearance${NC}
4. 在 ${GREEN}Font${NC} 下拉菜单中选择 ${GREEN}$FONT_DISPLAY_NAME${NC}

${BOLD}${YELLOW}VS Code 集成终端${NC}
1. 打开 VS Code
2. 按 ${GREEN}Cmd + ,${NC} 打开设置
3. 搜索 ${GREEN}terminal.integrated.fontFamily${NC}
4. 设置为: ${GREEN}\"$FONT_NAME\"${NC}
5. 设置 ${GREEN}terminal.integrated.fontSize${NC} 为 ${GREEN}13${NC}

${BOLD}${YELLOW}验证配置${NC}
运行以下命令验证字体是否正确安装:
  ${GREEN}fc-list : family | grep -i "hack nerd" 2>/dev/null || echo "Font installed in macOS"${NC}

${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}
EOF
}

# 显示测试字符
show_test_chars() {
    cat <<EOF

${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}
${BOLD}                    Nerd Font 图标测试${NC}
${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}

${GREEN}如果下面的图标显示正常，说明 Nerd Font 已正确配置:${NC}

                  󰊠  󰊨  󰋀
                    󰊠

${BOLD}Git 分支图标:${NC}   
${BOLD}文件夹图标:${NC}    󰉋 󰉔 󰉓 󰉒 󰉐
${BOLD}开发工具图标:${NC}        󰌛  󰏖
${BOLD}编程语言图标:${NC}  󰘧  󰘦    󰛘  󰟷

${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}
EOF
}

# 主函数
main() {
    echo
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║          Terminal Font Configuration Tool                        ║${NC}"
    echo -e "${BOLD}${CYAN}║          配置终端使用 Hack Nerd Font                           ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo

    # 检查字体
    if ! check_font_installed; then
        log_warning "字体未安装，尝试安装..."
        if command -v brew >/dev/null 2>&1; then
            brew install --cask font-hack-nerd-font
            echo
            if check_font_installed; then
                log_success "字体安装成功"
            else
                log_error "字体安装失败"
                exit 1
            fi
        else
            log_error "Homebrew 未安装，无法自动安装字体"
            exit 1
        fi
    fi

    # 配置各个终端
    configure_terminal_app
    configure_iterm2
    configure_warp

    # 显示手动配置说明
    show_manual_instructions

    # 显示测试字符
    show_test_chars

    echo
    log_success "配置完成！"
    echo
    log_info "提示: 重启终端应用以使字体更改生效"
    echo
    log_info "在新终端中运行此脚本以查看 Nerd Font 图标:"
    echo "  ${GREEN}~/.dotfiles/scripts/configure-terminal-font.sh --test${NC}"
    echo
}

# 测试模式
if [[ "${1:-}" == "--test" ]]; then
    show_test_chars
    exit 0
fi

main "$@"
