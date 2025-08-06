#!/bin/bash
# Dev Container setup script

set -e

echo "🚀 Setting up development environment..."

# Install additional packages
sudo apt-get update
sudo apt-get install -y \
    stow \
    neovim \
    tmux \
    ripgrep \
    fd-find \
    bat \
    fzf \
    zoxide \
    eza \
    git-delta \
    starship

# Install dotfiles
if [ -d "/home/vscode/.dotfiles" ]; then
    cd /home/vscode/.dotfiles
    ./scripts/stow.sh install system zsh git tools vim nvim tmux
fi

# Install Zinit
if [ ! -d "/home/vscode/.local/share/zinit" ]; then
    sh -c "$(curl -fsSL https://git.io/zinit-install)"
fi

# Setup starship
if command -v starship >/dev/null 2>&1; then
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

echo "✅ Development environment setup complete!"