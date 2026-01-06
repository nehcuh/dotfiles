#!/bin/bash
# Dotfile Manager - 帮助将主目录的文件分类到相应的 stow 包中

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 显示帮助
show_help() {
    cat << EOF
${BLUE}Dotfile Manager${NC} - 管理你的 dotfiles

用法: $(basename "$0") [选项] [文件...]

选项:
    -h, --help              显示此帮助信息
    -l, --list              列出主目录中未管理的文件
    -m, --move FILE [TYPE]  移动文件到相应的包
    -s, --status            显示当前管理状态
    -c, --check             检查哪些文件应该被管理但还没被

文件类型:
    sensitive   敏感文件（SSH 密钥、API token 等）
    personal    个人配置（非敏感）
    system      系统配置
    git         Git 配置
    zsh         Zsh 配置
    tools       工具配置

示例:
    $(basename "$0") --list
    $(basename "$0") --move ~/.ssh/config sensitive
    $(basename "$0") --move ~/.gitconfig_global git
    $(basename "$0") --check

EOF
}

# 检查文件是否为符号链接
is_symlink() {
    [[ -L "$1" ]]
}

# 检查文件是否链接到 dotfiles
is_managed() {
    local file="$1"
    if [[ -L "$file" ]]; then
        local target="$(readlink "$file")"
        [[ "$target" == *".dotfiles"* ]] || [[ "$target" == *".dotfiles/stow-packs"* ]]
    else
        return 1
    fi
}

# 列出主目录中未管理的文件
list_unmanaged() {
    log_info "扫描主目录中的文件..."

    echo
    echo -e "${YELLOW}未管理的配置文件:${NC}"
    echo "================================"

    local found=false

    # 常见的配置文件列表
    local config_files=(
        ".ssh/config"
        ".gitconfig_local"
        ".zshrc.local"
        ".claude.json"
        ".Brewfile.apps"
        ".Brewfile.base"
    )

    for file in "${config_files[@]}"; do
        local full_path="$HOME/$file"
        if [[ -e "$full_path" ]] && ! is_managed "$full_path"; then
            echo "  - $file"
            found=true
        fi
    done

    # 检查 .config 目录
    if [[ -d "$HOME/.config" ]]; then
        local config_dirs=(
            "gh"
            "aws"
        )

        for dir in "${config_dirs[@]}"; do
            local full_path="$HOME/.config/$dir"
            if [[ -e "$full_path" ]] && ! is_managed "$full_path"; then
                echo "  - .config/$dir/"
                found=true
            fi
        done
    fi

    if ! $found; then
        log_success "所有文件都已管理！"
    else
        echo
        log_info "使用 '$(basename "$0") --move <file> <type>' 来移动文件"
    fi
}

# 移动文件到相应的包
move_file() {
    local source_file="$1"
    local file_type="$2"

    source_file="${source_file/#\~\//$HOME/}"

    # 检查源文件是否存在
    if [[ ! -e "$source_file" ]]; then
        log_error "文件不存在: $source_file"
        return 1
    fi

    # 只允许移动 $HOME 下的文件，且保持原始相对路径
    if [[ "$source_file" != "$HOME/"* ]]; then
        log_error "仅支持移动主目录下的文件: $source_file"
        return 1
    fi

    local relative_path="${source_file#$HOME/}"

    # 目标包（优先使用 stow-packs 下真实存在的包名）
    local target_package="$file_type"
    if [[ -z "$target_package" ]]; then
        log_error "缺少目标包名"
        return 1
    fi

    if [[ ! -d "$DOTFILES_DIR/stow-packs/$target_package" ]]; then
        log_error "目标包不存在: $target_package"
        log_info "可用包: $(ls -1 "$DOTFILES_DIR/stow-packs" 2>/dev/null | tr '\n' ' ')"
        return 1
    fi

    local target_path="$DOTFILES_DIR/stow-packs/$target_package/$relative_path"

    # 创建目标目录
    local target_dir="$(dirname "$target_path")"
    mkdir -p "$target_dir"

    # 移动文件
    log_info "移动 $relative_path 到 $target_package 包..."

    if mv -- "$source_file" "$target_path"; then
        log_success "文件已移动"

        # 重新 stow 该包
        log_info "重新链接 $target_package 包..."
        cd "$DOTFILES_DIR"

        if ! command -v stow >/dev/null 2>&1; then
            log_error "GNU Stow 未安装，无法创建链接"
            log_info "macOS: brew install stow"
            return 1
        fi

        if ! stow -d stow-packs -t "$HOME" -R "$target_package"; then
            log_error "Stow 链接失败（可能存在冲突文件/目录）"
            log_info "建议：先移除冲突项或用 'stow -d stow-packs -t \"$HOME\" -R $target_package -v' 查看细节"
            return 1
        fi

        log_success "包已重新链接"

        if [[ -L "$source_file" ]]; then
            log_success "✓ $relative_path 现在是一个符号链接"
            return 0
        fi

        log_warning "符号链接未创建，请手动检查"
        return 1
    else
        log_error "移动文件失败"
        return 1
    fi
}

# 显示当前状态
show_status() {
    log_info "检查文件管理状态..."

    echo
    echo -e "${BLUE}已管理的文件:${NC}"
    echo "=========================="

    local managed_count=0

    # 检查已知的 stow 链接
    for file in ~/.* ~/.*; do
        if [[ -e "$file" ]] && is_managed "$file"; then
            local filename="$(basename "$file")"
            local target="$(readlink "$file")"
            echo "  ✓ $filename → $target"
            ((managed_count++))
        fi
    done 2>/dev/null

    echo
    log_success "共 $managed_count 个文件被管理"

    # 显示未管理的文件
    list_unmanaged
}

# 检查哪些文件应该被管理
check_files() {
    log_info "检查应该被管理的文件..."

    echo
    echo -e "${YELLOW}建议管理的文件:${NC}"
    echo "=========================="

    local suggestions=(
        "文件:~/.ssh/config:类型:sensitive:说明:SSH 配置"
        "文件:~/.gitconfig_local:类型:sensitive:说明:Git 本地配置"
        "文件:~/.zshrc.local:类型:sensitive:说明:Zsh 本地配置"
        "文件:~/.claude.json:类型:sensitive:说明:Claude API 配置"
        "文件:~/.Brewfile.apps:类型:personal:说明:个人应用列表"
    )

    for suggestion in "${suggestions[@]}"; do
        IFS=':' read -r type file category desc <<< "$suggestion"

        local actual_file="${file//文件:/}"

        if [[ -e "$actual_file" ]] && ! is_managed "$actual_file"; then
            local filename="$(basename "$actual_file")"
            local category="${category//类型:/}"
            local description="${desc//说明:/}"

            echo -e "\n${YELLOW}$filename${NC}"
            echo "  位置: $actual_file"
            echo "  类型: $category"
            echo "  说明: $description"
            echo "  命令: $(basename "$0") --move $actual_file $category"
        fi
    done

    echo
    log_info "使用上面的命令来移动文件"
}

# 主函数
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--list)
                list_unmanaged
                exit 0
                ;;
            -m|--move)
                if [[ -z "$2" ]]; then
                    log_error "缺少文件参数"
                    exit 1
                fi
                if [[ -z "$3" ]]; then
                    log_error "缺少类型参数"
                    exit 1
                fi
                move_file "$2" "$3"
                exit 0
                ;;
            -s|--status)
                show_status
                exit 0
                ;;
            -c|--check)
                check_files
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

main "$@"
