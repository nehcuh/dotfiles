#!/bin/bash
# Install Homebrew packages from Brewfile

install_brewfile() {
    [[ "$OS" != "macos" ]] && return
    command -v brew &> /dev/null || return

    local brewfile="$HOME/.Brewfile"
    local repo_brewfile="$DOTFILES_DIR/stow-packs/system/.Brewfile"

    [[ -f "$brewfile" || -f "$repo_brewfile" ]] || {
        log_info "No Brewfile found, skipping"
        return
    }

    # Skip if requested
    [[ "${SKIP_BREWFILE:-false}" == "true" ]] && {
        log_info "Skipping Brewfile (SKIP_BREWFILE=true)"
        return
    }

    log_info "Installing Homebrew packages..."

    # Determine which Brewfile to use
    local brewfile_to_use="$([[ -f "$brewfile" ]] && echo "$brewfile" || echo "$repo_brewfile")"

    # Check if running in non-interactive mode (e.g., from make)
    if [[ ! -t 0 ]]; then
        log_info "Non-interactive environment detected, skipping Brewfile"
        log_info "Install later with: brew bundle --file='$brewfile_to_use'"
        return
    fi

    # Interactive prompt
    if [[ "${NON_INTERACTIVE:-false}" != "true" ]]; then
        echo
        read -p "Install Brewfile packages? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && {
            log_info "Skipped. Install later with: brew bundle --global"
            return
        }
    fi

    if brew bundle --file="$brewfile_to_use"; then
        log_success "Brewfile packages installed"
    else
        log_warning "Some packages failed. Retry with: brew bundle --file='$brewfile_to_use'"
    fi
}
