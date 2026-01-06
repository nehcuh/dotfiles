#!/bin/bash
# Quick fix for git package migration

set -e

echo "Fixing git package structure..."

mkdir -p "stow-packs/git/.config"

# If there's legacy content in config/ dir, move it into .config/
if [[ -d "stow-packs/git/config" ]]; then
    echo "Migrating legacy stow-packs/git/config/ -> stow-packs/git/.config/..."
    mkdir -p "stow-packs/git/.config/git"
    if [[ -f "stow-packs/git/config/git/config" ]] && [[ ! -f "stow-packs/git/.config/git/config" ]]; then
        mv "stow-packs/git/config/git/config" "stow-packs/git/.config/git/config"
    fi
    if [[ -f "stow-packs/git/config/git/ignore" ]]; then
        cat "stow-packs/git/config/git/ignore" >>"stow-packs/git/.config/git/ignore" 2>/dev/null || true
        rm -f "stow-packs/git/config/git/ignore"
    fi
    rmdir "stow-packs/git/config/git" 2>/dev/null || true
    rmdir "stow-packs/git/config" 2>/dev/null || true
fi

# Create empty .config/git directory if needed
if [[ ! -d "stow-packs/git/.config/git" ]]; then
    echo "Creating .config/git directory..."
    mkdir -p "stow-packs/git/.config/git"
fi

# Stow the package
echo "Stowing git package..."
cd "$(dirname "$0")/.."
stow -D git 2>/dev/null || true
stow --dir=stow-packs -S git

echo "✓ Git package fixed!"
echo ""
echo "Now you can add files with:"
echo "  make add FILE=~/.config/git/config PACKAGE=git"
