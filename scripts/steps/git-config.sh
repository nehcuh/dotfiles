#!/bin/bash
# Configure Git user identity during installation

configure_git_identity() {
    if ! command -v git &>/dev/null; then
        log_warning "Git not found, skipping git identity configuration"
        return 0
    fi

    local local_config="$HOME/.gitconfig_local"
    local template="$DOTFILES_DIR/stow-packs/git/.gitconfig_local.template"

    # Create ~/.gitconfig_local from template if it doesn't exist yet.
    if [[ ! -f "$local_config" ]] && [[ -f "$template" ]]; then
        log_info "Creating $local_config from template..."
        cp "$template" "$local_config"
    fi

    local name="${DOTFILES_GIT_USER_NAME:-}"
    local email="${DOTFILES_GIT_USER_EMAIL:-}"

    # If not provided via environment, try to read existing local config as defaults.
    if [[ -z "$name" ]]; then
        name="$(git config --file "$local_config" user.name 2>/dev/null || true)"
        # Ignore placeholder values from the template.
        if [[ "$name" == "Your Name" ]]; then
            name=""
        fi
    fi
    if [[ -z "$email" ]]; then
        email="$(git config --file "$local_config" user.email 2>/dev/null || true)"
        if [[ "$email" == "your.email@example.com" ]]; then
            email=""
        fi
    fi

    # In non-interactive mode without values, keep existing config if present.
    if [[ ! -t 0 ]] && [[ -z "$name" || -z "$email" ]]; then
        if [[ -n "$(git config --file "$local_config" user.name 2>/dev/null)" && \
              -n "$(git config --file "$local_config" user.email 2>/dev/null)" ]]; then
            log_info "Git identity already configured in $local_config, skipping"
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

    git config --file "$local_config" user.name "$name"
    git config --file "$local_config" user.email "$email"

    log_success "Git identity configured: $name <$email>"
}
