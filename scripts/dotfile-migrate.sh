#!/bin/bash
# Dotfiles Migration Tool - 统一迁移外部应用的配置文件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "\n${CYAN}${BOLD}▶ $1${NC}"; }

# 应用分类数据库
# 使用普通数组避免关联数组的特殊字符问题

# 敏感文件列表
SENSITIVE_APPS=(
    ".claude.json"
    ".claude"
    ".config/gh"
    ".config/gitai"
    ".ssh"
    ".aws"
    ".config/gcloud"
    ".config/slack"
    ".netrc"
    ".config/hub"
    ".config/git/user"
)

# 个人配置文件列表
PERSONAL_APPS=(
    ".alma"
    ".wakatime"
    ".config/iterm2"
    ".config/fish"
    ".config/oh-my-zsh"
    ".config/karabiner"
    ".config/yabai"
    ".config/skhd"
    ".Brewfile.apps"
    ".Brewfile.base"
    ".config/jetbrains"
    ".config/Sublime Text"
)

# 系统配置列表
SYSTEM_APPS=(
    ".config/systemd"
    ".config/upstart"
    ".config/starship"
)

# Git 相关列表
GIT_APPS=(
    ".config/git"
    ".config/tig"
)

# 工具配置列表
TOOLS_APPS=(
    ".config/nvim"
    ".config/vim"
    ".config/rg"
    ".config/fd"
    ".config/bat"
    ".docker"
    ".config/docker"
    ".config/pip"
    ".config/npm"
    ".config/yarn"
    ".cargo"
    ".gem"
    ".bundle"
)

# 编辑器列表
EDITOR_APPS=(
    ".config/Code"
    ".config/Code - Insiders"
    ".config/VSCodium"
    ".config/zed"
)

# Shell 配置列表
SHELL_APPS=(
    ".bashrc"
    ".bash_profile"
)

# Tmux 配置
TMUX_APPS=(
    ".tmux.conf"
    ".config/tmux"
)

# Nvim 配置
NVIM_APPS=(
    ".config/nvim"
)

# Vscode 配置
VSCODE_APPS=(
    ".config/Code"
    ".config/Code - Insiders"
    ".config/VSCodium"
)

# Zed 配置
ZED_APPS=(
    ".config/zed"
)

# 应用说明数据库（使用函数而不是关联数组避免特殊字符问题）
get_app_description() {
    local key="$1"
    case "$key" in
        *claude.json*) echo "Claude AI 配置（包含 API 密钥）" ;;
        *claude*) echo "Claude AI 配置目录" ;;
        *gh*) echo "GitHub CLI 配置（包含认证 token）" ;;
        *gitai*) echo "GitAI 配置（可能包含密钥）" ;;
        *alma*) echo "Alma 期刊管理器配置" ;;
        *ssh*) echo "SSH 密钥和配置" ;;
        *aws*) echo "AWS CLI 配置和凭证" ;;
        *iterm2*) echo "iTerm2 终端配置" ;;
        *starship*) echo "Starship 提示符配置" ;;
        *Code*) echo "VS Code 配置" ;;
        *zed*) echo "Zed 编辑器配置" ;;
        *git*) echo "Git 配置" ;;
        *) echo "" ;;
    esac
}

# 显示帮助
show_help() {
    cat << EOF
${BOLD}${CYAN}Dotfiles Migration Tool${NC}

统一迁移外部应用的配置文件到 dotfiles 项目

${BOLD}用法:${NC}
    $(basename "$0") [命令] [选项]

${BOLD}命令:${NC}
    scan        扫描主目录中未管理的配置文件
    migrate     交互式迁移文件
    auto        自动迁移所有识别的文件
    status      显示迁移状态
    restore     从备份恢复文件

${BOLD}选项:${NC}
    -h, --help          显示此帮助信息
    -d, --dry-run       预览操作但不执行
    -y, --yes           自动确认所有提示
    -f, --force         强制覆盖已存在的文件
    -b, --backup        迁移前自动备份

${BOLD}示例:${NC}
    # 扫描未管理的文件
    $(basename "$0") scan

    # 交互式迁移
    $(basename "$0") migrate

    # 自动迁移所有识别的文件（预览）
    $(basename "$0") auto --dry-run

    # 自动迁移（实际执行）
    $(basename "$0") auto -y

${BOLD}工作流:${NC}
    1. scan  - 查看哪些文件可以被迁移
    2. migrate - 选择并迁移文件
    3. status - 验证迁移结果

EOF
}

# 检查文件是否被管理
is_managed() {
    local file="$1"
    if [[ -L "$file" ]]; then
        local target="$(readlink "$file")"
        [[ "$target" == *".dotfiles"* ]]
    else
        return 1
    fi
}

# 获取文件的分类
get_category() {
    local file="$1"
    local filename="$(basename "$file")"
    local relative_path="${file#$HOME/}"

    # 检查各个分类数组
    for app in "${SENSITIVE_APPS[@]}"; do
        if [[ "$relative_path" == "$app"* ]] || [[ "$filename" == "$app" ]]; then
            echo "sensitive"
            return
        fi
    done

    for app in "${PERSONAL_APPS[@]}"; do
        if [[ "$relative_path" == "$app"* ]] || [[ "$filename" == "$app" ]]; then
            echo "personal"
            return
        fi
    done

    for app in "${SYSTEM_APPS[@]}"; do
        if [[ "$relative_path" == "$app"* ]] || [[ "$filename" == "$app" ]]; then
            echo "system"
            return
        fi
    done

    for app in "${GIT_APPS[@]}"; do
        if [[ "$relative_path" == "$app"* ]] || [[ "$filename" == "$app" ]]; then
            echo "git"
            return
        fi
    done

    for app in "${TOOLS_APPS[@]}"; do
        if [[ "$relative_path" == "$app"* ]] || [[ "$filename" == "$app" ]]; then
            echo "tools"
            return
        fi
    done

    for app in "${EDITOR_APPS[@]}"; do
        if [[ "$relative_path" == "$app"* ]] || [[ "$filename" == "$app" ]]; then
            echo "editor"
            return
        fi
    done

    for app in "${NVIM_APPS[@]}"; do
        if [[ "$relative_path" == "$app"* ]] || [[ "$filename" == "$app" ]]; then
            echo "nvim"
            return
        fi
    done

    for app in "${VSCODE_APPS[@]}"; do
        if [[ "$relative_path" == "$app"* ]] || [[ "$filename" == "$app" ]]; then
            echo "vscode"
            return
        fi
    done

    for app in "${ZED_APPS[@]}"; do
        if [[ "$relative_path" == "$app"* ]] || [[ "$filename" == "$app" ]]; then
            echo "zed"
            return
        fi
    done

    for app in "${TMUX_APPS[@]}"; do
        if [[ "$relative_path" == "$app"* ]] || [[ "$filename" == "$app" ]]; then
            echo "tmux"
            return
        fi
    done

    for app in "${SHELL_APPS[@]}"; do
        if [[ "$relative_path" == "$app"* ]] || [[ "$filename" == "$app" ]]; then
            echo "zsh"
            return
        fi
    done

    # 默认分类 - 安全起见默认为 sensitive
    echo "sensitive"
}

# 获取文件描述
get_description() {
    local file="$1"
    local filename="$(basename "$file")"
    local relative_path="${file#$HOME/}"

    # 先尝试获取特定应用的描述
    local desc=$(get_app_description "$relative_path")
    if [[ -n "$desc" ]]; then
        echo "$desc"
        return
    fi

    desc=$(get_app_description "$filename")
    if [[ -n "$desc" ]]; then
        echo "$desc"
        return
    fi

    # 根据分类返回通用描述
    local category=$(get_category "$file")
    case "$category" in
        sensitive) echo "包含敏感信息的应用配置" ;;
        personal) echo "个人偏好设置" ;;
        system) echo "系统级配置" ;;
        git) echo "Git 版本控制配置" ;;
        tools) echo "开发工具配置" ;;
        *) echo "外部应用配置文件" ;;
    esac
}

# 扫描未管理的配置文件
scan_dotfiles() {
    log_step "扫描主目录中的配置文件..."

    local found_files=()
    local count=0

    # 常见的配置文件位置
    local search_paths=(
        "$HOME/.[!.]*"              # 主目录隐藏文件
        "$HOME/.config/[^.]*/"      # .config 目录
    )

    echo
    echo -e "${BOLD}发现以下未管理的配置文件:${NC}"
    echo "══════════════════════════════════════════════════════════════"

    # 扫描主目录
    for file in $HOME/.[!.]*; do
        [[ -e "$file" ]] || continue
        [[ -d "$file" ]] && [[ "$file" != *"/.config" ]] && continue

        # 跳过已管理的
        is_managed "$file" && continue

        # 跳过特殊目录
        case "$(basename "$file")" in
            .|..|.local|.cache|.npm|.yarn|.nvm|.Trash|Applications|Desktop|Documents|Downloads|Library|Movies|Music|Pictures|Public)
                continue
                ;;
        esac

        # 跳过系统文件
        case "$(basename "$file")" in
            .DS_Store|.CFUserTextEncoding|.localized)
                continue
                ;;
        esac

        local category=$(get_category "$file")
        local description=$(get_description "$file")
        local relative_path="${file#$HOME/}"

        printf "\n${CYAN}▸ %s${NC}\n" "$relative_path"
        printf "  类型: ${YELLOW}%s${NC}\n" "$category"
        printf "  说明: %s\n" "$description"

        found_files+=("$file")
        ((count++))
    done

    # 扫描 .config 目录
    if [[ -d "$HOME/.config" ]]; then
        for dir in "$HOME/.config"/*/; do
            [[ -d "$dir" ]] || continue

            # 跳过已管理的
            is_managed "$dir" && continue

            local category=$(get_category "$dir")
            local description=$(get_description "$dir")
            local relative_path="${dir#$HOME/}"

            printf "\n${CYAN}▸ %s${NC}\n" "$relative_path"
            printf "  类型: ${YELLOW}%s${NC}\n" "$category"
            printf "  说明: %s\n" "$description"

            found_files+=("$dir")
            ((count++))
        done
    fi

    echo
    echo "══════════════════════════════════════════════════════════════"

    if [[ $count -eq 0 ]]; then
        log_success "没有发现未管理的配置文件！"
    else
        log_info "共发现 ${BOLD}$count${NC} 个未管理的配置文件"
        echo
        log_info "下一步: 运行 '$(basename "$0") migrate' 来迁移这些文件"
    fi
}

# 显示文件详情并询问
show_file_details() {
    local file="$1"
    local category="$2"
    local relative_path="${file#$HOME/}"

    echo
    echo -e "${BOLD}${CYAN}文件: $relative_path${NC}"
    echo "┌─────────────────────────────────────────────────────────┐"

    # 文件类型
    if [[ -d "$file" ]]; then
        echo "│ 类型: ${YELLOW}目录${NC}"
        echo "│ 内容: $(ls -1 "$file" 2>/dev/null | wc -l | tr -d ' ') 项"
    else
        echo "│ 类型: ${YELLOW}文件${NC}"
        echo "│ 大小: $(ls -lh "$file" 2>/dev/null | awk '{print $5}')"
    fi

    # 分类和说明
    echo "│ 分类: ${YELLOW}$category${NC}"
    echo "│ 说明: $(get_description "$file")"

    # 目标位置
    local target_dir="$DOTFILES_DIR/stow-packs/$category"
    if [[ "$relative_path" == .config/* ]]; then
        local target_path="$target_dir/.config/${relative_path#.config/}"
    else
        local target_path="$target_dir/$relative_path"
    fi
    echo "│ 目标: ${GREEN}stow-packs/$category/${NC}"

    # 是否包含敏感信息（简单检测）
    if [[ "$category" == "sensitive" ]]; then
        echo "│ ${RED}⚠ 包含敏感信息，不会被 Git 跟踪${NC}"
    fi

    echo "└─────────────────────────────────────────────────────────┘"
}

# 迁移单个文件
migrate_file() {
    local source="$1"
    local category="$2"
    local dry_run="${3:-false}"

    local relative_path="${source#$HOME/}"
    local target_dir="$DOTFILES_DIR/stow-packs/$category"

    # 确定目标路径
    if [[ "$relative_path" == .config/* ]]; then
        local config_subpath="${relative_path#.config/}"
        local target="$target_dir/.config/$config_subpath"
    else
        local target="$target_dir/$relative_path"
    fi

    log_info "迁移: $relative_path → $category"

    if [[ "$dry_run" == "true" ]]; then
        log_warning "[DRY RUN] 会移动到: $target"
        return 0
    fi

    # 创建目标目录
    mkdir -p "$(dirname "$target")"

    # 移动文件
    if mv "$source" "$target"; then
        log_success "文件已移动"

        # 重新 stow 包
        cd "$DOTFILES_DIR"
        if stow -d stow-packs -t ~ -R "$category" 2>/dev/null; then
            log_success "包已重新链接"

            # 验证链接
            if [[ -L "$source" ]]; then
                log_success "✓ $relative_path 现在是一个符号链接"
                return 0
            else
                log_warning "符号链接未创建，请手动检查"
                return 1
            fi
        else
            log_warning "Stow 自动链接失败，尝试手动创建..."

            # 手动创建符号链接
            cd "$HOME"
            if [[ "$relative_path" == .config/* ]]; then
                # .config 目录下的文件
                local link_path="$relative_path"
                local link_target="../.dotfiles/stow-packs/$category/.config/${relative_path#.config/}"
            else
                # 主目录下的文件
                local link_path="$relative_path"
                local link_target=".dotfiles/stow-packs/$category/$relative_path"
            fi

            # 创建符号链接
            if ln -sf "$link_target" "$link_path"; then
                log_success "✓ 手动创建符号链接成功"

                # 验证链接
                local symlink_path="$HOME/$link_path"
                if [[ -L "$symlink_path" ]]; then
                    log_success "✓ $relative_path 现在是一个符号链接"
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

# 交互式迁移
interactive_migrate() {
    log_step "交互式迁移向导"

    # 扫描文件
    local files_to_migrate=()
    local categories=()

    # 收集主目录文件
    for file in $HOME/.[!.]*; do
        [[ -e "$file" ]] || continue
        [[ -d "$file" ]] && [[ "$file" != *"/.config" ]] && continue
        is_managed "$file" && continue

        # 跳过特殊文件
        case "$(basename "$file")" in
            .|..|.local|.cache|.npm|.yarn|.nvm|.Trash|.DS_Store|.CFUserTextEncoding|.localized|Applications)
                continue
                ;;
        esac

        files_to_migrate+=("$file")
        categories+=("$(get_category "$file")")
    done

    # 收集 .config 目录
    if [[ -d "$HOME/.config" ]]; then
        for dir in "$HOME/.config"/*/; do
            [[ -d "$dir" ]] || continue
            is_managed "$dir" && continue

            files_to_migrate+=("$dir")
            categories+=("$(get_category "$dir")")
        done
    fi

    if [[ ${#files_to_migrate[@]} -eq 0 ]]; then
        log_success "没有需要迁移的文件"
        return 0
    fi

    echo
    log_info "发现 ${#files_to_migrate[@]} 个可迁移的文件"
    echo

    # 逐个询问
    local migrated=0
    local skipped=0

    for i in "${!files_to_migrate[@]}"; do
        local file="${files_to_migrate[$i]}"
        local category="${categories[$i]}"

        show_file_details "$file" "$category"

        echo -n "是否迁移? [Y/n/s/q] (Y=是, n=否, s=跳过所有, q=退出): "
        read -r answer

        case "$answer" in
            s|S|skip)
                log_warning "跳过剩余所有文件"
                break
                ;;
            q|Q|quit)
                log_info "退出迁移"
                break
                ;;
            n|N|no)
                log_warning "跳过此文件"
                ((skipped++))
                ;;
            y|Y|yes|"")
                if migrate_file "$file" "$category"; then
                    ((migrated++))
                else
                    ((skipped++))
                fi
                ;;
            *)
                log_warning "无效选择，跳过"
                ((skipped++))
                ;;
        esac
    done

    echo
    echo "══════════════════════════════════════════════════════════════"
    log_success "迁移完成!"
    echo "  已迁移: $migrated 个文件"
    echo "  已跳过: $skipped 个文件"
    echo "══════════════════════════════════════════════════════════════"
}

# 自动迁移
auto_migrate() {
    local dry_run="${1:-false}"

    if [[ "$dry_run" == "true" ]]; then
        log_step "自动迁移预览模式"
    else
        log_step "自动迁移所有识别的文件"
        log_warning "此操作将移动所有识别的配置文件"
        echo -n "确认继续? [y/N] "
        read -r answer
        [[ "$answer" =~ ^[Yy] ]] || return 0
    fi

    local migrated=0
    local failed=0

    # 迁移主目录文件
    for file in $HOME/.[!.]*; do
        [[ -e "$file" ]] || continue
        [[ -d "$file" ]] && [[ "$file" != *"/.config" ]] && continue
        is_managed "$file" && continue

        case "$(basename "$file")" in
            .|..|.local|.cache|.npm|.yarn|.nvm|.Trash|.DS_Store|.CFUserTextEncoding|.localized|Applications)
                continue
                ;;
        esac

        local category=$(get_category "$file")
        if migrate_file "$file" "$category" "$dry_run"; then
            if [[ "$dry_run" != "true" ]]; then
                ((migrated++))
            fi
        else
            ((failed++))
        fi
    done

    # 迁移 .config 目录
    if [[ -d "$HOME/.config" ]]; then
        for dir in "$HOME/.config"/*/; do
            [[ -d "$dir" ]] || continue
            is_managed "$dir" && continue

            local category=$(get_category "$dir")
            if migrate_file "$dir" "$category" "$dry_run"; then
                if [[ "$dry_run" != "true" ]]; then
                    ((migrated++))
                fi
            else
                ((failed++))
            fi
        done
    fi

    echo
    echo "══════════════════════════════════════════════════════════════"
    if [[ "$dry_run" == "true" ]]; then
        log_info "预览完成"
    else
        log_success "自动迁移完成!"
        echo "  成功: $migrated 个文件"
        [[ $failed -gt 0 ]] && echo "  失败: $failed 个文件"
    fi
    echo "══════════════════════════════════════════════════════════════"
}

# 显示迁移状态
show_status() {
    log_step "当前迁移状态"

    local managed=0
    local unmanaged=0
    local total=0

    # 统计已管理的文件
    for file in ~/.* ~/.config/*; do
        [[ -e "$file" ]] || continue
        ((total++))

        if is_managed "$file"; then
            ((managed++))
        else
            ((unmanaged++))
        fi
    done 2>/dev/null

    echo
    echo "┌──────────────────────────────────────────────┐"
    echo "│           迁移状态概览                        │"
    echo "├──────────────────────────────────────────────┤"
    echo "│ 总文件数: $total"
    echo "│ ${GREEN}已管理:   $managed${NC}"
    echo "│ ${YELLOW}未管理:   $unmanaged${NC}"
    echo "└──────────────────────────────────────────────┘"

    echo
    log_info "使用 '$(basename "$0") scan' 查看详细的未管理文件列表"
}

# 主函数
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    local command="$1"
    shift

    case "$command" in
        -h|--help)
            show_help
            exit 0
            ;;
        scan)
            scan_dotfiles
            ;;
        migrate)
            interactive_migrate
            ;;
        auto)
            local dry_run=false
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    -d|--dry-run) dry_run=true ;;
                    -y|--yes) export AUTO_CONFIRM=true ;;
                esac
                shift
            done
            auto_migrate "$dry_run"
            ;;
        status)
            show_status
            ;;
        *)
            log_error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
