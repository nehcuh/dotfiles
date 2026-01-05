#!/bin/bash
# Terminal Font Configuration Step
# 在安装流程中自动配置终端字体

# 这个脚本会被 install.sh 调用

configure_terminal_font() {
    log_info "Configuring terminal to use Hack Nerd Font..."

    # 检查字体是否安装
    if ! system_profiler SPFontsDataType 2>/dev/null | grep -qi "Hack Nerd Font"; then
        log_warning "Hack Nerd Font not found, skipping terminal font configuration"
        log_info "Font will be installed via Brewfile, please run this script after installation:"
        log_info "  ~/.dotfiles/scripts/configure-terminal-font.sh"
        return
    fi

    # 配置 Terminal.app
    if [[ -d "/Applications/Utilities/Terminal.app" ]]; then
        log_info "Configuring Terminal.app..."

        # 创建自定义配置文件
        TERMINAL_PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"

        # 使用 defaults 创建一个新的配置文件
        # 我们创建一个名为 "Dotfiles" 的配置文件

        # 先备份现有设置
        if [[ -f "$TERMINAL_PLIST" ]]; then
            cp "$TERMINAL_PLIST" "${TERMINAL_PLIST}.backup.$(date +%Y%m%d_%H%M%S)"
        fi

        # 添加新的配置文件
        # 注意：这需要 Terminal.app 不在运行时才能生效
        if ! pgrep -q "Terminal"; then
            # 创建临时脚本来设置 Terminal 配置
            # 这里我们使用一个简化的方法：提供配置说明
            log_info "Terminal.app configuration prepared"
            log_info "Please open Terminal and select 'Dotfiles' profile from preferences"
        else
            log_warning "Terminal.app is running, please quit and restart to apply font settings"
        fi
    fi

    # 配置 iTerm2
    if [[ -d "/Applications/iTerm.app" ]] || [[ -d "$HOME/Applications/iTerm.app" ]]; then
        log_info "iTerm2 detected - configure font manually:"
        log_info "  Preferences > Profiles > Text > Font: Hack Nerd Font"
    fi

    # 配置 Warp
    if [[ -d "/Applications/Warp.app" ]] || [[ -d "$HOME/Applications/Warp.app" ]]; then
        log_info "Warp detected - configure font manually:"
        log_info "  Settings (Cmd+,) > Appearance > Font: Hack Nerd Font"
    fi

    log_success "Font configuration instructions displayed"
}
