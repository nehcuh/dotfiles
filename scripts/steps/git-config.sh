#!/bin/bash
# Configure Git user identity during installation

configure_git_identity() {
    if ! command -v git &>/dev/null; then
        log_warning "Git not found, skipping git identity configuration"
        return 0
    fi

    local name="${DOTFILES_GIT_USER_NAME:-}"
    local email="${DOTFILES_GIT_USER_EMAIL:-}"

    # If not provided via environment, try to read existing git config as defaults.
    if [[ -z "$name" ]]; then
        name="$(git config --global user.name 2>/dev/null || true)"
    fi
    if [[ -z "$email" ]]; then
        email="$(git config --global user.email 2>/dev/null || true)"
    fi

    # In non-interactive mode without values, keep existing config if present.
    if [[ ! -t 0 ]] && [[ -z "$name" || -z "$email" ]]; then
        if [[ -n "$(git config --global user.name 2>/dev/null)" && -n "$(git config --global user.email 2>/dev/null)" ]]; then
            log_info "Git identity already configured, skipping"
            return 0
        fi
    fi

    # Prompt interactively when stdin is a terminal and values are still empty.
    if [[ -t 0 ]]; then
        if [[ -z "$name" ]]; then
            read -rp "Git user name: " name
        else
            log_info "Using git user name: $name"
        fi

        if [[ -z "$email" ]]; then
            read -rp "Git user email: " email
        else
            log_info "Using git user email: $email"
        fi
    fi

    if [[ -z "$name" || -z "$email" ]]; then
        log_warning "Git user name or email not provided, skipping identity configuration"
        return 0
    fi

    git config --global user.name "$name"
    git config --global user.email "$email"

    log_success "Git identity configured: $name <$email>"
}
