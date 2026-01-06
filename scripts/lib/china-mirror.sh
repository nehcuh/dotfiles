#!/bin/bash
# China mirror detection and configuration
# Automatically detects if user is in China and configures appropriate mirrors

# Export global variable for mirror usage
export IN_CHINA=false
export DOTFILES_MIRROR_PACKAGE=""

is_truthy() {
    case "${1:-}" in
        1|true|TRUE|yes|YES|y|Y) return 0 ;;
        *) return 1 ;;
    esac
}

# Detect if user is in China
detect_china() {
    log_info "Detecting network environment..."

    # Check environment variable first (for manual override)
    if [[ "${DOTFILES_FORCE_CHINA_MIRROR:-false}" == "true" ]]; then
        log_info "China mirror forced by environment variable"
        IN_CHINA=true
        return 0
    fi

    if [[ "${DOTFILES_FORCE_NO_MIRROR:-false}" == "true" ]]; then
        log_info "Mirror disabled by environment variable"
        IN_CHINA=false
        return 0
    fi

    if is_truthy "${DOTFILES_SKIP_MIRROR_DETECT:-}"; then
        log_warning "Skipping mirror auto-detection (DOTFILES_SKIP_MIRROR_DETECT=1)"
        IN_CHINA=false
        export IN_CHINA
        return 0
    fi

    # Method 1: Check IP location using multiple services (with timeout)
    local ip_country=""
    local services=(
        "https://ipinfo.io/country"      # International (returns "CN")
        "https://ipapi.co/country/"      # International (returns "CN")
        "https://ip.cn"                  # Chinese (HTML; best-effort grep)
    )

    for service in "${services[@]}"; do
        if command -v curl &> /dev/null; then
            ip_country=$(curl -s --max-time 3 "$service" 2>/dev/null | grep -iE "(^CN$|china|CN)" || echo "")
        elif command -v wget &> /dev/null; then
            ip_country=$(wget -q -O- --timeout=3 "$service" 2>/dev/null | grep -iE "(^CN$|china|CN)" || echo "")
        fi

        if [[ -n "$ip_country" ]]; then
            break
        fi
    done

    # Method 2: Check DNS resolution speed (backup method, Linux only)
    if [[ -z "$ip_country" ]]; then
        if [[ "$(uname -s)" == "Linux" ]] && command -v ping &> /dev/null; then
            # Compare response times
            local china_time
            local google_time

            china_time=$(ping -c 1 -W 2 114.114.114.114 2>/dev/null | grep -oE 'time=[0-9.]+ ms' | head -n1 | sed -E 's/^time=([0-9.]+) ms$/\\1/' || echo "")
            google_time=$(ping -c 1 -W 2 8.8.8.8 2>/dev/null | grep -oE 'time=[0-9.]+ ms' | head -n1 | sed -E 's/^time=([0-9.]+) ms$/\\1/' || echo "")

            if [[ -n "$china_time" && -n "$google_time" ]]; then
                # If China DNS is faster, assume in China (best-effort heuristic)
                if awk "BEGIN {exit !($china_time < $google_time)}"; then
                    ip_country="CN"
                fi
            fi
        fi
    fi

    # Method 3: Check system timezone (least reliable but useful as hint)
    if [[ -z "$ip_country" ]] && command -v date &> /dev/null; then
        local timezone=$(date +%Z 2>/dev/null || echo "")
        if [[ "$timezone" == *"CST"* ]] || [[ "$timezone" == *"China"* ]]; then
            ip_country="CN"
        fi
    fi

    # Set result
    if [[ -n "$ip_country" ]]; then
        log_info "China network environment detected"
        IN_CHINA=true
    else
        log_info "International network environment detected"
        IN_CHINA=false
    fi

    export IN_CHINA
}

# Configure Homebrew bottle mirror for China
configure_homebrew_mirror() {
    if [[ "$IN_CHINA" != "true" ]]; then
        return 0
    fi

    log_info "Configuring Homebrew mirrors for China..."

    # Set Homebrew bottle mirror (binary packages)
    local bottle_mirror="https://mirrors.ustc.edu.cn/homebrew-bottles"

    # Set for current session only (avoid editing user profiles automatically).
    export HOMEBREW_BOTTLE_DOMAIN="$bottle_mirror"
    log_info "HOMEBREW_BOTTLE_DOMAIN set for this session: $bottle_mirror"
    log_info "To persist, add to your local shell config (e.g. ~/.zshrc.local):"
    log_info "  export HOMEBREW_BOTTLE_DOMAIN=\"$bottle_mirror\""

    # Optionally set Homebrew tap remotes (higher impact; opt-in only)
    if is_truthy "${DOTFILES_HOMEBREW_TAP_CHINA_MIRRORS:-}"; then
        if ! command -v brew >/dev/null 2>&1; then
            log_warning "brew not found; cannot update tap remotes (DOTFILES_HOMEBREW_TAP_CHINA_MIRRORS=true)"
            return 0
        fi

        brew tap --custom-remote --force homebrew/core https://mirrors.ustc.edu.cn/homebrew-core.git 2>/dev/null || true
        brew tap --custom-remote --force homebrew/cask https://mirrors.ustc.edu.cn/homebrew-cask.git 2>/dev/null || true
        brew tap --custom-remote --force homebrew/cask-fonts https://mirrors.ustc.edu.cn/homebrew-cask-fonts.git 2>/dev/null || true
        log_success "Homebrew tap remotes updated to China mirrors"
    else
        log_info "To also switch Homebrew tap remotes (core/cask) to China mirrors, set: DOTFILES_HOMEBREW_TAP_CHINA_MIRRORS=true"
    fi

    log_success "Homebrew mirrors configured"
}

# Install Homebrew with appropriate mirror
install_homebrew() {
    log_info "Installing Homebrew..."

    if [[ "$IN_CHINA" == "true" ]]; then
        log_info "Using China mirror for faster installation..."

        # Set environment variables for Homebrew install script
        export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
        export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
        export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"

        # Install script source (default to official; opt-in to third-party installer)
        if is_truthy "${DOTFILES_HOMEBREW_USE_CHINA_INSTALLER:-}"; then
            log_warning "Using third-party Homebrew installer (DOTFILES_HOMEBREW_USE_CHINA_INSTALLER=true)"
            /bin/bash -c "$(curl -fsSL https://gitee.com/ineo6/homebrew-install/raw/master/install.sh)" || \
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    else
        # Standard installation
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Add Homebrew to PATH
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        export PATH="/usr/local/bin:$PATH"
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

# Select which mirror package to install (pip, npm, gem, cargo)
select_mirror_package() {
    if [[ "$IN_CHINA" == "true" ]]; then
        echo "mirrors-china"
    else
        echo "mirrors-international"
    fi
}

# Apply mirror package immediately (used by manage-mirrors.sh)
apply_mirror_package() {
    local package="$1"
    local other_package="mirrors-international"
    [[ "$package" == "mirrors-international" ]] && other_package="mirrors-china"

    command -v stow >/dev/null 2>&1 || {
        log_warning "GNU Stow not found; cannot apply mirror package now"
        return 1
    }

    cd "$DOTFILES_DIR" || return 1
    stow -d stow-packs -t "$HOME" -D "$other_package" >/dev/null 2>&1 || true
    stow -d stow-packs -t "$HOME" -R "$package"
}

# Configure package manager mirrors (pip, npm, gem, cargo)
configure_package_mirrors() {
    DOTFILES_MIRROR_PACKAGE="$(select_mirror_package)"
    export DOTFILES_MIRROR_PACKAGE

    log_info "Selected mirror package: $DOTFILES_MIRROR_PACKAGE"

    if is_truthy "${APPLY_MIRRORS_NOW:-}"; then
        log_info "Applying mirror package now..."
        apply_mirror_package "$DOTFILES_MIRROR_PACKAGE"
        log_success "Mirror package applied: $DOTFILES_MIRROR_PACKAGE"
    fi
}

# Restore China mirrors (if needed)
restore_china_mirrors() {
    log_info "No-op: mirrors are selected via stow packages now"
    log_info "Use: ~/.dotfiles/scripts/manage-mirrors.sh auto"
}
