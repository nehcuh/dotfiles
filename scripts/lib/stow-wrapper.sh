#!/bin/bash
# Stow wrapper with conflict resolution
# Simple, safe backup and restore

is_truthy() {
    case "${1:-}" in
        1|true|TRUE|yes|YES|y|Y) return 0 ;;
        *) return 1 ;;
    esac
}

print_stow_conflict_summary() {
    local package="$1"

    log_info "Stow dry-run output:"
    stow -n -v -t "$HOME" "$package" 2>&1 | sed 's/^/  /' || true

    log_info "Conflicting paths in \$HOME (existing, non-symlinks):"
    local found=false

    while IFS= read -r file; do
        local home_file="${file#$package/}"
        if [[ -e "$HOME/$home_file" && ! -L "$HOME/$home_file" ]]; then
            echo "  - ~/$home_file"
            found=true
        fi
    done < <(find "$package" -type f 2>/dev/null)

    if [[ "$found" == "false" ]]; then
        log_info "  (No regular-file conflicts detected; conflict may involve directories or permissions.)"
    fi
}

backup_and_stow() {
    local package="$1"

    cd "$DOTFILES_DIR/stow-packs" || return 1

    # Dry-run first: never modify $HOME unless we're confident it will succeed.
    if stow -n -v -t "$HOME" "$package" >/dev/null 2>&1; then
        if stow -v -t "$HOME" "$package"; then
            log_success "✓ $package installed"
            return 0
        fi
        log_error "✗ Failed to install $package"
        return 1
    fi

    log_warning "Conflicts detected for $package"
    print_stow_conflict_summary "$package"

    if ! is_truthy "${DOTFILES_CONFLICT_OVERWRITE:-}"; then
        log_error "Aborting install for $package (set DOTFILES_CONFLICT_OVERWRITE=true to backup and overwrite conflicting files)."
        return 1
    fi

    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    local -a removed_files=()

    log_warning "Conflict overwrite enabled: backing up and overwriting conflicting regular files"

    while IFS= read -r file; do
        local home_file="${file#$package/}"
        local abs_home_file="$HOME/$home_file"

        if [[ -e "$abs_home_file" && ! -L "$abs_home_file" ]]; then
            if [[ -d "$abs_home_file" ]]; then
                log_warning "Directory conflict (not auto-removed): ~/$home_file"
                continue
            fi

            mkdir -p "$backup_dir/$(dirname "$home_file")"
            cp "$abs_home_file" "$backup_dir/$home_file"
            rm "$abs_home_file"
            removed_files+=("$home_file")
        fi
    done < <(find "$package" -type f 2>/dev/null)

    log_info "Backed up conflicts to: $backup_dir"

    # Validate again before performing the real stow to avoid partial installs.
    if ! stow -n -v -t "$HOME" "$package" >/dev/null 2>&1; then
        log_error "Still blocked by conflicts after backup. Restoring removed files."
        for home_file in "${removed_files[@]}"; do
            mkdir -p "$(dirname "$HOME/$home_file")"
            cp "$backup_dir/$home_file" "$HOME/$home_file" 2>/dev/null || true
        done
        print_stow_conflict_summary "$package"
        return 1
    fi

    if stow -v -t "$HOME" "$package"; then
        log_success "✓ $package installed (backed up conflicts)"
        return 0
    fi

    log_error "✗ Failed to install $package (backup preserved at: $backup_dir)"
    return 1
}
