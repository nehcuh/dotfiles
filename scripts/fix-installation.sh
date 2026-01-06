#!/bin/bash
# Fix dotfiles installation issues
# 修复dotfiles安装问题的统一脚本

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Utility functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "    修复 Dotfiles 安装问题"
echo "========================================"
echo

# 1. 确保所有必要的包都已安装
log_info "1. 检查并重新安装必要的stow包..."
cd "$SCRIPT_DIR/../stow-packs" || exit 1

# 重新安装vscode包（确保VS Code配置被正确链接）
if [ -d "vscode" ]; then
    log_info "重新安装vscode包..."
    stow -R -t "$HOME" vscode || log_warning "vscode包安装失败"
fi

# 重新安装macos包（确保macOS配置被正确链接）
if [ -d "macos" ]; then
    log_info "重新安装macos包..."
    stow -R -t "$HOME" macos || log_warning "macos包安装失败"
fi

# 2. 运行VS Code扩展安装
log_info "2. 安装VS Code扩展..."
if command -v code &> /dev/null; then
    if [ -f "$SCRIPT_DIR/scripts/setup-vscode-extensions.sh" ]; then
        chmod +x "$SCRIPT_DIR/scripts/setup-vscode-extensions.sh"
        "$SCRIPT_DIR/scripts/setup-vscode-extensions.sh" || log_warning "部分VS Code扩展安装失败"
    else
        log_warning "VS Code扩展安装脚本未找到"
    fi
else
    log_warning "VS Code未安装或不在PATH中"
fi

# 3. 运行macOS优化
log_info "3. 应用macOS系统优化..."
if [ -f "$HOME/.config/macos/optimize.sh" ]; then
    log_info "运行macOS优化脚本..."
    chmod +x "$HOME/.config/macos/optimize.sh"
    "$HOME/.config/macos/optimize.sh" || log_warning "macOS优化脚本执行遇到问题"
else
    log_warning "macOS优化脚本未找到，可能stow安装失败"
    if [ -f "$SCRIPT_DIR/../stow-packs/macos/home/.config/macos/optimize.sh" ]; then
        log_info "直接运行仓库中的macOS优化脚本..."
        chmod +x "$SCRIPT_DIR/../stow-packs/macos/home/.config/macos/optimize.sh"
        "$SCRIPT_DIR/../stow-packs/macos/home/.config/macos/optimize.sh" || log_warning "macOS优化脚本执行遇到问题"
    fi
fi

# 4. 运行快速优化（可选）
if [ -f "$HOME/.config/macos/quick-optimize.sh" ]; then
    log_info "4. 运行macOS快速优化..."
    chmod +x "$HOME/.config/macos/quick-optimize.sh"
    "$HOME/.config/macos/quick-optimize.sh" || log_warning "macOS快速优化脚本执行遇到问题"
elif [ -f "$SCRIPT_DIR/../stow-packs/macos/home/.config/macos/quick-optimize.sh" ]; then
    log_info "4. 直接运行仓库中的macOS快速优化脚本..."
    chmod +x "$SCRIPT_DIR/../stow-packs/macos/home/.config/macos/quick-optimize.sh"
    "$SCRIPT_DIR/../stow-packs/macos/home/.config/macos/quick-optimize.sh" || log_warning "macOS快速优化脚本执行遇到问题"
fi

# 5. 检查安装结果
log_info "5. 检查安装结果..."

# 检查VS Code配置是否正确链接
if [ -L "$HOME/.config/Code/User/settings.json" ]; then
    log_success "VS Code settings.json 已正确链接"
else
    log_warning "VS Code settings.json 未正确链接"
fi

if [ -L "$HOME/.config/Code/User/keybindings.json" ]; then
    log_success "VS Code keybindings.json 已正确链接"
else
    log_warning "VS Code keybindings.json 未正确链接"
fi

# 检查macOS配置是否正确链接
if [ -L "$HOME/.config/macos/optimize.sh" ]; then
    log_success "macOS优化脚本已正确链接"
else
    log_warning "macOS优化脚本未正确链接"
fi

echo
log_info "修复完成！"
log_info "建议操作："
log_info "1. 重启Terminal或运行 'source ~/.zshrc'"
log_info "2. 重启VS Code以确保所有扩展正常加载"
log_info "3. 部分macOS设置可能需要重启系统才能生效"
echo
