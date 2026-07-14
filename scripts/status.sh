#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST_FILE="$DOTFILES_DIR/docs/managed-files.yml"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

is_linked_to_package() {
    local home_path="$1"
    local package="$2"

    # Case 1: the path itself is a symlink into the package
    if [[ -L "$home_path" ]]; then
        local target
        target="$(readlink "$home_path" 2>/dev/null || true)"
        if [[ -n "$target" ]] && [[ "$target" == *"stow-packs/$package/"* ]]; then
            if [[ "$target" == *".dotfiles"* || "$target" == *"$DOTFILES_DIR"* ]]; then
                return 0
            fi
        fi
    fi

    # Case 2: the path lives inside a symlinked directory that points into the package.
    # Walk up the path and stop at the first symlinked parent directory.
    local dir="$home_path"
    while [[ "$dir" != "$HOME" && "$dir" != "/" && -n "$dir" ]]; do
        dir="$(dirname "$dir")"
        [[ "$dir" == "$HOME" ]] && break

        if [[ -L "$dir" ]]; then
            local target
            target="$(readlink "$dir" 2>/dev/null || true)"
            if [[ -n "$target" ]] && [[ "$target" == *"stow-packs/$package/"* ]]; then
                if [[ "$target" == *".dotfiles"* || "$target" == *"$DOTFILES_DIR"* ]]; then
                    return 0
                fi
            fi
            # If this parent is a symlink but not into the target package, stop walking;
            # the remaining ancestors are not part of the dotfiles tree we care about.
            return 1
        fi
    done

    return 1
}

list_packages() {
    (cd "$DOTFILES_DIR/stow-packs" && ls -1) 2>/dev/null || true
}

read_manifest_section() {
    local section="$1"
    [[ -f "$MANIFEST_FILE" ]] || return 1
    awk -v section="$section" '
        function ltrim(s) { sub(/^[[:space:]]+/, "", s); return s }
        $0 ~ "^[[:space:]]*"section":[[:space:]]*$" {in_section=1; pkg=""; next}
        in_section && $0 ~ "^[[:alpha:]_-]+:[[:space:]]*$" {in_section=0}
        in_section && $0 ~ "^[[:space:]]*-[[:space:]]*package:[[:space:]]*" {
            line=$0
            sub(/^[[:space:]]*-[[:space:]]*package:[[:space:]]*/, "", line)
            pkg=ltrim(line)
            next
        }
        in_section && $0 ~ "^[[:space:]]*path:[[:space:]]*" && pkg != "" {
            line=$0
            sub(/^[[:space:]]*path:[[:space:]]*/, "", line)
            path=ltrim(line)
            print pkg "\t" path
            pkg=""
        }
    ' "$MANIFEST_FILE" | sed '/^#/d' | sed '/^[[:space:]]*$/d'
}

main() {
    if [[ ! -d "$DOTFILES_DIR/stow-packs" ]]; then
        echo -e "${RED}[ERROR]${NC} stow-packs directory not found: $DOTFILES_DIR/stow-packs" >&2
        exit 1
    fi

    log_info "Dotfiles directory: $DOTFILES_DIR"
    echo
    echo -e "${BLUE}Package status:${NC}"

    local manifest_tracked=""
    local manifest_untracked=""
    if [[ -f "$MANIFEST_FILE" ]]; then
        manifest_tracked="$(read_manifest_section tracked || true)"
        manifest_untracked="$(read_manifest_section untracked || true)"
    fi

    local any=false
    while IFS= read -r package; do
        [[ -n "$package" ]] || continue
        any=true

        if [[ ! -d "$DOTFILES_DIR/stow-packs/$package" ]]; then
            continue
        fi

        local total=0
        local linked=0

        if [[ -n "$manifest_tracked$manifest_untracked" ]]; then
            local entries="$manifest_tracked"
            [[ -n "$manifest_untracked" ]] && entries="${entries}"$'\n'"$manifest_untracked"

            while IFS= read -r entry; do
                [[ -n "$entry" ]] || continue
                local entry_pkg="${entry%%$'\t'*}"
                local entry_path="${entry#*$'\t'}"
                [[ "$entry_pkg" == "$package" ]] || continue
                [[ -e "$DOTFILES_DIR/stow-packs/$entry_pkg/$entry_path" ]] || continue
                ((total+=1))
                is_linked_to_package "$HOME/$entry_path" "$package" && ((linked+=1))
            done <<<"$entries"

            if [[ "$total" -eq 0 ]]; then
                printf "  %b %s\n" "${YELLOW}○${NC}" "$package (no manifest entries)"
            elif [[ "$linked" -eq 0 ]]; then
                printf "  %b %s\n" "${YELLOW}○${NC}" "$package (not linked)"
            elif [[ "$linked" -eq "$total" ]]; then
                printf "  %b %s\n" "${GREEN}✓${NC}" "$package (linked)"
            else
                printf "  %b %s\n" "${YELLOW}◐${NC}" "$package (partial: $linked/$total)"
            fi
        else
            printf "  %b %s\n" "${YELLOW}○${NC}" "$package (no manifest)"
        fi
    done < <(list_packages)

    if [[ "$any" != "true" ]]; then
        echo "  (no packages found)"
    fi
}

main "$@"
