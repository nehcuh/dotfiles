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
    [[ "${DOTFILES_SKIP_BREWFILE:-false}" == "true" ]] && {
        log_info "Skipping Brewfile (DOTFILES_SKIP_BREWFILE=true)"
        return
    }

    log_info "Installing Homebrew packages..."

    # Determine which Brewfile to use
    local brewfile_to_use="$([[ -f "$brewfile" ]] && echo "$brewfile" || echo "$repo_brewfile")"

    local is_tty=true
    [[ ! -t 0 ]] && is_tty=false

    # Default behavior: never run brew bundle without a TTY unless explicitly opted-in.
    if [[ "$is_tty" == "false" && "${DOTFILES_BREWFILE_INSTALL:-false}" != "true" ]]; then
        log_info "Non-interactive environment detected, skipping Brewfile"
        log_info "To run anyway: DOTFILES_BREWFILE_INSTALL=true brew bundle --file='$brewfile_to_use'"
        log_info "Or install later with: brew bundle --file='$brewfile_to_use'"
        return
    fi

    # Interactive prompt
    if [[ "$is_tty" == "true" && "${DOTFILES_NON_INTERACTIVE:-false}" != "true" && "${DOTFILES_BREWFILE_INSTALL:-false}" != "true" ]]; then
        echo
        read -p "Install Brewfile packages? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && {
            log_info "Skipped. Install later with: brew bundle --file='$brewfile_to_use'"
            return
        }
    fi

    if brew bundle --file="$brewfile_to_use"; then
        log_success "Brewfile packages installed"
    else
        log_warning "Some packages failed. Retry with: brew bundle --file='$brewfile_to_use'"
    fi
}
