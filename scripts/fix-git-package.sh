#!/bin/bash
# Quick fix for git package migration

set -e

echo "Fixing git package structure..."

# Check if .config/git exists in git package
if [[ ! -d "stow-packs/git/.config" ]]; then
    echo "Creating .config directory in git package..."
    mkdir -p "stow-packs/git/.config"

    # If there's content in config/ dir, move it
    if [[ -d "stow-packs/git/config" ]]; then
        echo "Moving files from config/ to .config/..."
        mv "stow-packs/git/config/"* "stow-packs/git/.config/" 2>/dev/null
        rmdir "stow-packs/git/config" 2>/dev/null
    fi
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
