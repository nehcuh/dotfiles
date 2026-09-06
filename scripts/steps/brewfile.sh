#!/bin/bash
# Install Homebrew packages from Brewfile

# Print aggregate download progress while `brew bundle` runs in the
# background. Homebrew's parallel downloads print little on their own,
# so watch the download cache directory instead.
show_download_progress() {
    local brew_pid="$1"
    local cache_dir="$HOME/Library/Caches/Homebrew/downloads"
    local prev_bytes=0 prev_ts=$SECONDS bytes ts speed_kb

    while kill -0 "$brew_pid" 2>/dev/null; do
        sleep 3
        bytes=$(find "$cache_dir" -name '*.incomplete' -type f -exec stat -f%z {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
        ts=$SECONDS
        if (( bytes > prev_bytes )); then
            local files
            files=$(find "$cache_dir" -name '*.incomplete' -type f 2>/dev/null | wc -l | tr -d ' ')
            speed_kb=$(( (bytes - prev_bytes) / (ts - prev_ts) / 1024 ))
            printf "${GRAY}  ⇣ %d MB @ %d KB/s (%s downloading)${NC}\n" \
                $(( bytes / 1048576 )) "$speed_kb" "$files"
        fi
        prev_bytes=$bytes
        prev_ts=$ts
    done
}

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

    brew bundle --file="$brewfile_to_use" &
    local brew_pid=$!
    [[ -t 1 ]] && show_download_progress "$brew_pid"
    if wait "$brew_pid"; then
        log_success "Brewfile packages installed"
    else
        log_warning "Some packages failed. Retry with: brew bundle --file='$brewfile_to_use'"
    fi
}
