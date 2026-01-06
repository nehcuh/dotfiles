#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

is_linked_to_package() {
    local home_path="$1"
    local package="$2"

    [[ -L "$home_path" ]] || return 1

    local target
    target="$(readlink "$home_path" 2>/dev/null || true)"
    [[ -n "$target" ]] || return 1

    [[ "$target" == *"stow-packs/$package/"* ]] || return 1
    [[ "$target" == *".dotfiles"* || "$target" == *"$DOTFILES_DIR"* ]] || return 1

    return 0
}

list_packages() {
    (cd "$DOTFILES_DIR/stow-packs" && ls -1) 2>/dev/null || true
}

count_package_files() {
    local package="$1"
    (cd "$DOTFILES_DIR/stow-packs/$package" && find . -type f -o -type l 2>/dev/null | sed 's|^\\./||') || true
}

main() {
    if [[ ! -d "$DOTFILES_DIR/stow-packs" ]]; then
        echo -e "${RED}[ERROR]${NC} stow-packs directory not found: $DOTFILES_DIR/stow-packs" >&2
        exit 1
    fi

    log_info "Dotfiles directory: $DOTFILES_DIR"
    echo
    echo -e "${BLUE}Package status:${NC}"

    local any=false
    while IFS= read -r package; do
        [[ -n "$package" ]] || continue
        any=true

        if [[ ! -d "$DOTFILES_DIR/stow-packs/$package" ]]; then
            continue
        fi

        local managed_paths
        managed_paths="$(count_package_files "$package")"

        local total=0
        local linked=0

        while IFS= read -r rel; do
            [[ -n "$rel" ]] || continue
            ((total+=1))
            is_linked_to_package "$HOME/$rel" "$package" && ((linked+=1))
        done <<<"$managed_paths"

        if [[ "$total" -eq 0 ]]; then
            printf "  %b %s\n" "${YELLOW}○${NC}" "$package (empty)"
        elif [[ "$linked" -eq 0 ]]; then
            printf "  %b %s\n" "${YELLOW}○${NC}" "$package (not linked)"
        elif [[ "$linked" -eq "$total" ]]; then
            printf "  %b %s\n" "${GREEN}✓${NC}" "$package (linked)"
        else
            printf "  %b %s\n" "${YELLOW}◐${NC}" "$package (partial: $linked/$total)"
        fi
    done < <(list_packages)

    if [[ "$any" != "true" ]]; then
        echo "  (no packages found)"
    fi
}

main "$@"
