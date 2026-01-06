#!/bin/bash
# Install stow packages

install_packages() {
    local packages=("$@")

    if [[ ${#packages[@]} -eq 0 ]]; then
        local mirror_package="${DOTFILES_MIRROR_PACKAGE:-}"
        [[ -z "$mirror_package" ]] && mirror_package="$([[ "${IN_CHINA:-false}" == "true" ]] && echo "mirrors-china" || echo "mirrors-international")"

        packages=("system" "zsh" "git" "$mirror_package" "tools" "vim" "nvim" "tmux")
        [[ "$OS" == "linux" ]] && packages+=("linux")
        [[ "$OS" == "macos" ]] && packages+=("macos")
    fi

    log_info "Installing packages: ${packages[*]}"

    # Handle sensitive files
    [[ -x "$DOTFILES_DIR/scripts/manage-sensitive-files.sh" ]] && \
        "$DOTFILES_DIR/scripts/manage-sensitive-files.sh" backup >/dev/null 2>&1 || true

    # Install each package
    for package in "${packages[@]}"; do
        if [[ -d "$DOTFILES_DIR/stow-packs/$package" ]]; then
            log_info "Installing $package..."
            backup_and_stow "$package"
        else
            log_warning "Package $package not found, skipping"
        fi
    done

    # Restore sensitive files
    [[ -x "$DOTFILES_DIR/scripts/manage-sensitive-files.sh" ]] && \
        "$DOTFILES_DIR/scripts/manage-sensitive-files.sh" restore >/dev/null 2>&1 || true
}
