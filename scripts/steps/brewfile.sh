#!/bin/bash
# Install Homebrew packages from Brewfile

# Print live progress while `brew bundle` runs in the background:
# - downloading: aggregate speed and file names parsed from the download
#   cache (files are named "<sha256>--<original-name>.incomplete")
# - installed: new top-level entries under Cellar (formulae) and Caskroom
#   (casks) compared against a snapshot taken when monitoring starts.
show_download_progress() {
    local brew_pid="$1"
    local cache_dir="${HOMEBREW_CACHE:-$HOME/Library/Caches/Homebrew}/downloads"
    local prefix="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null)}"
    local cellar="$prefix/Cellar" caskroom="$prefix/Caskroom"
    local prev_bytes=0 prev_ts=$SECONDS seen_installed bytes ts speed_kb

    _progress_installed_names() {
        find "$cellar" "$caskroom" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort -u
    }

    seen_installed=$(_progress_installed_names)

    while kill -0 "$brew_pid" 2>/dev/null; do
        sleep 3
        ts=$SECONDS
        bytes=$(find "$cache_dir" -name '*.incomplete' -type f -exec stat -f%z {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
        if (( bytes > prev_bytes )); then
            local names
            names=$(find "$cache_dir" -name '*.incomplete' -type f -exec basename {} \; 2>/dev/null \
                | sed -E 's/^[0-9a-f]{64}--//; s/\.incomplete$//' | sort -u | paste -sd, -)
            speed_kb=$(( (bytes - prev_bytes) / (ts - prev_ts) / 1024 ))
            if [[ -n "$names" ]]; then
                printf "${GRAY}  ⇣ %d MB @ %d KB/s · downloading: %s${NC}\n" \
                    $(( bytes / 1048576 )) "$speed_kb" "$names"
            else
                printf "${GRAY}  ⇣ %d MB @ %d KB/s${NC}\n" $(( bytes / 1048576 )) "$speed_kb"
            fi
        fi
        prev_bytes=$bytes
        prev_ts=$ts

        local now_installed newly
        now_installed=$(_progress_installed_names)
        newly=$(comm -13 <(printf '%s\n' "$seen_installed") <(printf '%s\n' "$now_installed") | paste -sd, -)
        if [[ -n "$newly" ]]; then
            printf "${GRAY}  ✔ installed: %s${NC}\n" "$newly"
        fi
        seen_installed=$now_installed
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
