#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TMP_REPO="$(mktemp -d)"
TMP_HOME="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_REPO" "$TMP_HOME"
}
trap cleanup EXIT

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    if ! grep -Fq -- "$needle" <<<"$haystack"; then
        fail "expected output to contain: $needle"
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    if grep -Fq -- "$needle" <<<"$haystack"; then
        fail "expected output NOT to contain: $needle"
    fi
}

strip_ansi() {
    sed -E $'s/\x1B\\[[0-9;]*m//g' <<<"$1"
}

assert_entry_category() {
    local plain_output="$1"
    local entry_path="$2"
    local expected_category="$3"

    local actual_category
    actual_category="$(
        echo "$plain_output" | awk -v entry="▸ $entry_path" '
            $0 == entry {
                if (getline line) {
                    if (line ~ /^  类型: /) {
                        sub(/^  类型: /, "", line)
                        print line
                    }
                }
                exit
            }
        '
    )"

    [[ -n "$actual_category" ]] || fail "expected scan entry to exist: ▸ $entry_path"
    [[ "$actual_category" == "$expected_category" ]] || fail "expected category for $entry_path to be $expected_category, got: $actual_category"
}

copy_repo() {
    mkdir -p "$TMP_REPO"
    if command -v rsync >/dev/null 2>&1; then
        local rsync_err
        rsync_err="$(mktemp)"
        if ! rsync -a --no-specials --no-devices \
            --exclude "/.git/" \
            --exclude "/stow-packs/sensitive/" \
            --exclude "/stow-packs/personal/.config/iterm2/sockets/" \
            "$REPO_ROOT/" "$TMP_REPO/" \
            >/dev/null 2>"$rsync_err"; then
            cat "$rsync_err" >&2 || true
            rm -f "$rsync_err"
            fail "rsync failed while copying repo fixture"
        fi
        grep -v '^skipping non-regular file ' "$rsync_err" >&2 || true
        rm -f "$rsync_err"
    else
        tar -C "$REPO_ROOT" \
            --exclude "./.git" \
            --exclude "./stow-packs/sensitive" \
            --exclude "./stow-packs/personal/.config/iterm2/sockets" \
            -cf - . | tar -C "$TMP_REPO" -xf -
    fi

    mkdir -p "$TMP_REPO/stow-packs/sensitive"
}

setup_home_fixture() {
    mkdir -p "$TMP_HOME/.config/gh"
    mkdir -p "$TMP_HOME/.config/nvim"
    mkdir -p "$TMP_HOME/.config/zed"
    mkdir -p "$TMP_HOME/.config/Code"
    mkdir -p "$TMP_HOME/.config/configstore"
    mkdir -p "$TMP_HOME/.ssh"
    echo "host github.com" >"$TMP_HOME/.ssh/config"
}

run_scan() {
    (cd "$TMP_REPO" && HOME="$TMP_HOME" bash scripts/dotfile-migrate.sh scan)
}

run_move_ssh_config() {
    (cd "$TMP_REPO" && HOME="$TMP_HOME" bash scripts/dotfile-manager.sh --move "$TMP_HOME/.ssh/config" sensitive)
}

copy_repo
setup_home_fixture

scan_output="$(run_scan || true)"
scan_plain="$(strip_ansi "$scan_output")"

# Desired behavior (currently expected to FAIL until fixed):
# - scan should not suggest migrating the ".config" root itself
# - scan should still include managed subdirs like ".config/gh/"
echo "$scan_plain" | grep -Fxq "▸ .config" && fail "expected scan output NOT to contain standalone entry: ▸ .config"
echo "$scan_plain" | grep -Fxq "▸ .config/configstore/" && fail "expected scan output NOT to contain entry: ▸ .config/configstore/"
echo "$scan_plain" | grep -Fxq "▸ .config/gh/" || fail "expected scan output to contain entry: ▸ .config/gh/"
echo "$scan_plain" | grep -Fxq "▸ .ssh/config" || fail "expected scan output to contain entry: ▸ .ssh/config"
assert_entry_category "$scan_plain" ".config/nvim/" "nvim"
assert_entry_category "$scan_plain" ".config/zed/" "zed"
assert_entry_category "$scan_plain" ".config/Code/" "vscode"

run_move_ssh_config || true

# Desired behavior (currently expected to FAIL until fixed):
# - preserve nested paths when moving (e.g. ~/.ssh/config -> stow-packs/sensitive/.ssh/config)
[[ -f "$TMP_REPO/stow-packs/sensitive/.ssh/config" ]] || fail "expected target to exist: stow-packs/sensitive/.ssh/config"
[[ -L "$TMP_HOME/.ssh/config" ]] || fail "expected symlink to exist: ~/.ssh/config"
link_target="$(readlink "$TMP_HOME/.ssh/config")"
case "$link_target" in
    *"stow-packs/sensitive/.ssh/config"*) ;;
    *) fail "unexpected symlink target for ~/.ssh/config: $link_target" ;;
esac

echo "PASS"
