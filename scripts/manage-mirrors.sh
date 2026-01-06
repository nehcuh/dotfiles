#!/bin/bash
# Mirror configuration management script
# Usage: ./manage-mirrors.sh [china|international|auto|status]

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source libraries
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/china-mirror.sh"

# Show help
show_help() {
    cat << EOF
${BLUE}Mirror Configuration Manager${NC}

Manage mirror configurations for package managers and Homebrew.

Usage: $(basename "$0") [command]

Commands:
    china        Force use of China mirrors
    international Force use of international mirrors (no China mirrors)
    auto         Automatically detect and configure mirrors
    status       Show current mirror configuration
    restore      Deprecated (no-op)

Environment Variables:
    DOTFILES_FORCE_CHINA_MIRROR=true    Force China mirrors
    DOTFILES_FORCE_NO_MIRROR=true       Force no mirrors (international)

Examples:
    $(basename "$0") auto              # Auto-detect and configure
    $(basename "$0") china             # Force China mirrors
    $(basename "$0") international     # Force international mirrors
    DOTFILES_FORCE_CHINA_MIRROR=true $(basename "$0") auto

EOF
}

# Show current status
show_status() {
    echo
    echo -e "${BLUE}Current Mirror Configuration${NC}"
    echo "================================"

    # Check environment variables
    if [[ "${DOTFILES_FORCE_CHINA_MIRROR:-false}" == "true" ]]; then
        echo -e "${GREEN}Mode:${NC} China (forced)"
    elif [[ "${DOTFILES_FORCE_NO_MIRROR:-false}" == "true" ]]; then
        echo -e "${GREEN}Mode:${NC} International (forced)"
    elif [[ "$IN_CHINA" == "true" ]]; then
        echo -e "${GREEN}Mode:${NC} China (auto-detected)"
    else
        echo -e "${GREEN}Mode:${NC} International (auto-detected)"
    fi

    echo
    echo "Package Manager Sources:"
    echo "------------------------"

    # Check pip
    if [[ -f "$HOME/.pip.conf" ]] || [[ -f "$HOME/.config/pip/pip.conf" ]]; then
        local pip_config="$HOME/.pip.conf"
        [[ -f "$HOME/.config/pip/pip.conf" ]] && pip_config="$HOME/.config/pip/pip.conf"
        local pip_url=$(grep "index-url" "$pip_config" 2>/dev/null | awk '{print $3}' || echo "Not configured")
        echo -e "  pip:        ${YELLOW}$pip_url${NC}"
    else
        echo -e "  pip:        ${GRAY}Not configured${NC}"
    fi

    # Check npm
    if [[ -f "$HOME/.npmrc" ]]; then
        local npm_url=$(grep "registry" "$HOME/.npmrc" 2>/dev/null | awk '{print $2}' || echo "Not configured")
        echo -e "  npm:        ${YELLOW}$npm_url${NC}"
    else
        echo -e "  npm:        ${GRAY}Not configured${NC}"
    fi

    # Check gem
    if [[ -f "$HOME/.gemrc" ]]; then
        local gem_url=$(grep -A1 ":sources:" "$HOME/.gemrc" 2>/dev/null | tail -1 | awk '{print $1}' || echo "Not configured")
        echo -e "  gem:        ${YELLOW}$gem_url${NC}"
    else
        echo -e "  gem:        ${GRAY}Not configured${NC}"
    fi

    # Check cargo
    if [[ -f "$HOME/.cargo/config.toml" ]] || [[ -f "$HOME/.cargo/config" ]] || [[ -f "$HOME/.config/cargo.toml" ]]; then
        local cargo_config="$HOME/.cargo/config.toml"
        [[ -f "$HOME/.cargo/config" ]] && cargo_config="$HOME/.cargo/config"
        [[ -f "$HOME/.config/cargo.toml" ]] && cargo_config="$HOME/.config/cargo.toml"
        local cargo_url=$(grep -A2 "source.crates-io" "$cargo_config" 2>/dev/null | grep "registry" | awk '{print $2}' || echo "Not configured")
        echo -e "  cargo:      ${YELLOW}$cargo_url${NC} (${cargo_config#$HOME/})"
    else
        echo -e "  cargo:      ${GRAY}Not configured${NC}"
    fi

    # Check Homebrew
    echo
    echo "Homebrew Configuration:"
    echo "-----------------------"
    if [[ -n "${HOMEBREW_BOTTLE_DOMAIN:-}" ]]; then
        echo -e "  Bottles:    ${YELLOW}${HOMEBREW_BOTTLE_DOMAIN}${NC}"
    else
        echo -e "  Bottles:    ${GRAY}Default (official)${NC}"
    fi

    if command -v brew &> /dev/null; then
        local core_remote=$(brew tap-info homebrew/core 2>/dev/null | grep "From" | awk '{print $2}' || echo "https://github.com/Homebrew/homebrew-core")
        echo -e "  Core:       ${YELLOW}$core_remote${NC}"
    else
        echo -e "  Core:       ${GRAY}Homebrew not installed${NC}"
    fi

    echo
}

# Main function
main() {
    local command="${1:-auto}"

    case "$command" in
        -h|--help|help)
            show_help
            exit 0
            ;;
        china)
            export DOTFILES_FORCE_CHINA_MIRROR=true
            export DOTFILES_FORCE_NO_MIRROR=false
            export APPLY_MIRRORS_NOW=true
            detect_china
            log_info "Configuring China mirrors..."
            configure_homebrew_mirror
            configure_package_mirrors
            log_success "China mirrors configured"
            show_status
            ;;
        international)
            export DOTFILES_FORCE_NO_MIRROR=true
            export DOTFILES_FORCE_CHINA_MIRROR=false
            export APPLY_MIRRORS_NOW=true
            detect_china
            log_info "Configuring international mirrors..."
            configure_package_mirrors
            log_success "International mirrors configured"
            show_status
            ;;
        auto)
            export APPLY_MIRRORS_NOW=true
            export DOTFILES_FORCE_CHINA_MIRROR=false
            export DOTFILES_FORCE_NO_MIRROR=false
            detect_china
            log_info "Auto-configuring mirrors based on network environment..."
            configure_homebrew_mirror
            configure_package_mirrors
            log_success "Mirrors configured automatically"
            show_status
            ;;
        status)
            detect_china
            show_status
            ;;
        restore)
            log_info "Restoring original mirror configuration..."
            restore_china_mirrors
            ;;
        *)
            log_error "Unknown command: $command"
            echo
            show_help
            exit 1
            ;;
    esac
}

main "$@"
