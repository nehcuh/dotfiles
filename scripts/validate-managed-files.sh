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

STRICT=false

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [--strict]

Validates strict allowlist tracking under stow-packs/ using docs/managed-files.yml:
  - All git-tracked files under stow-packs/ (excluding submodules, excluding .gitignore) must be listed in tracked:
  - Each tracked entry must resolve to exactly one stow-packs/<pkg>/<path> file

Options:
  --strict   Treat missing manifest entries as errors
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --strict) STRICT=true ;;
        *) log_error "Unknown argument: $1"; usage; exit 2 ;;
    esac
    shift
done

if [[ ! -f "$MANIFEST_FILE" ]]; then
    log_error "Manifest not found: $MANIFEST_FILE"
    exit 1
fi

read_manifest_section() {
    local section="$1"
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
    ' "$MANIFEST_FILE"
}

tracked_entries="$(read_manifest_section tracked | sed '/^#/d' | sed '/^[[:space:]]*$/d' || true)"
untracked_entries="$(read_manifest_section untracked | sed '/^#/d' | sed '/^[[:space:]]*$/d' || true)"

if [[ -z "$tracked_entries" ]]; then
    log_error "No tracked entries found in manifest: $MANIFEST_FILE"
    exit 1
fi

log_info "Manifest: $MANIFEST_FILE"

errors=0
warns=0

log_info "Checking manifest entries resolve to exactly one package path..."
while IFS= read -r entry; do
    [[ -n "$entry" ]] || continue
    pkg="${entry%%$'\t'*}"
    path="${entry#*$'\t'}"
    repo_path="$DOTFILES_DIR/stow-packs/$pkg/$path"
    if [[ -e "$repo_path" ]]; then
        :
    else
        if [[ "$STRICT" == "true" ]]; then
            log_error "Missing in stow-packs: $pkg -> $path"
            ((errors+=1))
        else
            log_warn "Missing in stow-packs (skipped): $pkg -> $path"
            ((warns+=1))
        fi
    fi
done <<<"$tracked_entries"

while IFS= read -r entry; do
    [[ -n "$entry" ]] || continue
    pkg="${entry%%$'\t'*}"
    path="${entry#*$'\t'}"
    repo_path="$DOTFILES_DIR/stow-packs/$pkg/$path"
    if [[ ! -e "$repo_path" ]]; then
        log_info "Untracked entry not present (ok): $pkg -> $path"
    fi
done <<<"$untracked_entries"

log_info "Checking git-tracked files under stow-packs are all in tracked:..."
git_tracked_paths="$(
    cd "$DOTFILES_DIR" && \
    git ls-files -s 'stow-packs/**' | awk '$1 != "160000" {print $4}' || true
)"

git_tracked_manifest_keys="$(
    echo "$git_tracked_paths" | awk -F/ '{print $2 "\t" substr($0, length($1"/"$2"/")+1)}' | sort -u
)"

missing_from_manifest="$(
    comm -23 \
        <(echo "$git_tracked_manifest_keys") \
        <(echo "$tracked_entries" | sort -u) || true
)"

if [[ -n "$missing_from_manifest" ]]; then
    log_error "These git-tracked files are not listed in tracked:"
    echo "$missing_from_manifest" | awk -F'\t' '{print "  - " $1 " -> " $2}'
    ((errors+=1))
fi

extra_in_manifest="$(
    comm -13 \
        <(echo "$git_tracked_manifest_keys") \
        <(echo "$tracked_entries" | sort -u) || true
)"

if [[ -n "$extra_in_manifest" ]]; then
    log_warn "These manifest tracked entries are not currently tracked by git:"
    echo "$extra_in_manifest" | awk -F'\t' '{print "  - " $1 " -> " $2}'
    ((warns+=1))
fi

if [[ "$errors" -gt 0 ]]; then
    log_error "Validation failed: $errors errors, $warns warnings"
    exit 1
fi

log_ok "Validation passed: $errors errors, $warns warnings"
