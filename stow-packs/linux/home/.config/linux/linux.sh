# Linux-specific configuration
# This file is sourced by zshrc for Linux systems

# Homebrew for Linux
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Linux-specific aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Package manager aliases based on distribution
if command -v apt &> /dev/null; then
    alias update='sudo apt update && sudo apt upgrade'
    alias install='sudo apt install'
    alias search='apt search'
    alias remove='sudo apt remove'
elif command -v dnf &> /dev/null; then
    alias update='sudo dnf upgrade'
    alias install='sudo dnf install'
    alias search='dnf search'
    alias remove='sudo dnf remove'
elif command -v pacman &> /dev/null; then
    alias update='sudo pacman -Syu'
    alias install='sudo pacman -S'
    alias search='pacman -Ss'
    alias remove='sudo pacman -R'
elif command -v zypper &> /dev/null; then
    alias update='sudo zypper refresh && sudo zypper update'
    alias install='sudo zypper install'
    alias search='zypper search'
    alias remove='sudo zypper remove'
fi

# Linux-specific environment variables
export EDITOR="nvim"
export BROWSER="google-chrome"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Add local bin to PATH if it exists
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Note: Python (pyenv) and Node.js (NVM) development tools are configured
# in the main .zshenv and .zshrc files for cross-platform consistency.
# This avoids duplication and ensures consistent behavior across all systems.

# Rust development
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi
