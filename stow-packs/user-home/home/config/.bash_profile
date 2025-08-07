# Bash Profile
# This file is executed for login shells

# Source bashrc
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# User specific environment and startup programs
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Set default umask
umask 022

# Set default language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Add homebrew to PATH if it exists
if [ -d /opt/homebrew/bin ]; then
    export PATH="/opt/homebrew/bin:$PATH"
elif [ -d /home/linuxbrew/.linuxbrew/bin ]; then
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi

# Add user bin directories to PATH
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi