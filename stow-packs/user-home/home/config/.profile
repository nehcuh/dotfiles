# Generic Profile
# This file is executed by various shells for login sessions

# Set default PATH
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"

# Set default environment variables
export PAGER=less
export LESS="-R"
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0;2m'
export LESS_TERMCAP_so=$'\E[0;33;40;2m'
export LESS_TERMCAP_ue=$'\E[0;4m'

# Set default editor
export EDITOR=nano
export VISUAL=nano

# Set default language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Add common paths
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Source user-specific profile
if [ -f "$HOME/.profile.local" ]; then
    source "$HOME/.profile.local"
fi