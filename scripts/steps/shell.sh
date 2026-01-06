#!/bin/bash
# Setup default shell

setup_shell() {
    log_info "Setting up shell..."

    command -v zsh &> /dev/null || {
        log_warning "Zsh not found, keeping current shell"
        return
    }

    local zsh_path="$(command -v zsh)"

    # Already using zsh?
    if [[ "$SHELL" == "$zsh_path" ]]; then
        log_success "Default shell is already zsh"
        return
    fi

    # Default behavior: do not change login shell automatically.
    if [[ "${DOTFILES_SET_DEFAULT_SHELL:-false}" != "true" ]]; then
        log_info "Skipping default shell change (DOTFILES_SET_DEFAULT_SHELL=true to enable)"
        log_info "To change manually: chsh -s $zsh_path"
        return
    fi

    # Change shell
    log_info "Changing shell to zsh..."
    if chsh -s "$zsh_path" 2>/dev/null; then
        log_success "Shell changed to zsh (restart terminal to take effect)"
    else
        log_warning "Failed to change shell automatically"
        log_info "Run: chsh -s $zsh_path"
    fi
}
