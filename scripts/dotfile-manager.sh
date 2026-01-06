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

    # 检查源文件是否存在
    if [[ ! -e "$source_file" ]]; then
        log_error "文件不存在: $source_file"
        return 1
    fi

    # 获取文件名
    local filename="$(basename "$source_file")"
    local dirname="$(dirname "$source_file")"

    # 确定目标包和路径
    local target_package=""
    local target_path=""

    case "$file_type" in
        sensitive)
            target_package="sensitive"
            if [[ "$dirname" == "$HOME/.config" ]]; then
                target_path="$DOTFILES_DIR/stow-packs/sensitive/.config/$filename"
            else
                target_path="$DOTFILES_DIR/stow-packs/sensitive/$filename"
            fi
            ;;
        personal)
            target_package="personal"
            if [[ "$dirname" == "$HOME/.config" ]]; then
                target_path="$DOTFILES_DIR/stow-packs/personal/.config/$filename"
            else
                target_path="$DOTFILES_DIR/stow-packs/personal/$filename"
            fi
            ;;
        system)
            target_package="system"
            if [[ "$dirname" == "$HOME/.config" ]]; then
                target_path="$DOTFILES_DIR/stow-packs/system/.config/$filename"
            else
                target_path="$DOTFILES_DIR/stow-packs/system/$filename"
            fi
            ;;
        git)
            target_package="git"
            if [[ "$dirname" == "$HOME/.config" ]]; then
                target_path="$DOTFILES_DIR/stow-packs/git/.config/$filename"
            else
                target_path="$DOTFILES_DIR/stow-packs/git/$filename"
            fi
            ;;
        zsh)
            target_package="zsh"
            if [[ "$dirname" == "$HOME/.config" ]]; then
                target_path="$DOTFILES_DIR/stow-packs/zsh/.config/$filename"
            else
                target_path="$DOTFILES_DIR/stow-packs/zsh/$filename"
            fi
            ;;
        tools)
            target_package="tools"
            if [[ "$dirname" == "$HOME/.config" ]]; then
                target_path="$DOTFILES_DIR/stow-packs/tools/.config/$filename"
            else
                target_path="$DOTFILES_DIR/stow-packs/tools/$filename"
            fi
            ;;
        *)
            log_error "未知的文件类型: $file_type"
            log_info "支持的类型: sensitive, personal, system, git, zsh, tools"
            return 1
            ;;
    esac

    # 创建目标目录
    local target_dir="$(dirname "$target_path")"
    mkdir -p "$target_dir"

    # 移动文件
    log_info "移动 $filename 到 $target_package 包..."

    if mv "$source_file" "$target_path"; then
        log_success "文件已移动"

        # 重新 stow 该包
        log_info "重新链接 $target_package 包..."
        cd "$DOTFILES_DIR"

        # 尝试 stow
        if stow -d stow-packs -t ~ -R "$target_package" 2>/dev/null; then
            log_success "包已重新链接"
        else
            log_warning "Stow 自动链接失败，手动创建符号链接..."

            # 手动创建符号链接
            cd "$HOME"
            if [[ "$dirname" == "$HOME/.config" ]]; then
                # .config 目录下的文件
                link_path=".config/$filename"
                link_target="../.dotfiles/stow-packs/$target_package/.config/$filename"
            else
                # 主目录下的文件
                link_path="$filename"
                link_target=".dotfiles/stow-packs/$target_package/$filename"
            fi

            # 创建符号链接
            if ln -sf "$link_target" "$link_path"; then
                log_success "✓ 手动创建符号链接成功"

                # 验证链接
                local symlink_path="$HOME/$link_path"
                if [[ -L "$symlink_path" ]]; then
                    log_success "✓ $link_path 现在是一个符号链接"
                    return 0
                else
                    log_warning "符号链接未创建，请手动检查"
                    return 1
                fi
            else
                log_error "手动创建符号链接失败"
                return 1
            fi
        fi
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
