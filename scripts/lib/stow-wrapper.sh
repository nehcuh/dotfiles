#!/bin/bash
# Stow wrapper with conflict resolution
# Simple, safe backup and restore

backup_and_stow() {
    local package="$1"
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

    cd "$DOTFILES_DIR/stow-packs" || return 1

    # Try normal stow first
    if stow -v -t "$HOME" "$package" 2>/dev/null; then
        log_success "✓ $package installed"
        return 0
    fi

    # Conflict detected - backup and retry
    log_warning "Conflicts detected for $package"

    # Find and backup conflicting files
    find "$package" -type f 2>/dev/null | while IFS= read -r file; do
        local home_file="${file#$package/}"

        if [[ -f "$HOME/$home_file" && ! -L "$HOME/$home_file" ]]; then
            mkdir -p "$backup_dir/$(dirname "$home_file")"
            cp "$HOME/$home_file" "$backup_dir/$home_file"
            rm "$HOME/$home_file"
        fi
    done

    log_info "Backed up conflicts to: $backup_dir"

    # Retry stow
    if stow -v -t "$HOME" "$package"; then
        log_success "✓ $package installed (backed up conflicts)"
        return 0
    else
        log_error "✗ Failed to install $package"
        return 1
    fi
}
