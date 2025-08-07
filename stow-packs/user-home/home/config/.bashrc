# Bash Configuration
# This file contains bash-specific settings

# Source common configuration
if [ -f "$HOME/.config/shell/common" ]; then
    source "$HOME/.config/shell/common"
fi

# Bash-specific settings
if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

# User specific aliases and functions
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Enable bash completion (only in bash)
if [ -n "$BASH_VERSION" ] && [ -f /etc/bash_completion ] && ! shopt -oq posix 2>/dev/null; then
    source /etc/bash_completion
fi

# Bash history settings
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "

# Bash history append (only in bash)
if [ -n "$BASH_VERSION" ]; then
    shopt -s histappend 2>/dev/null || true
fi

# Save history immediately
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Bash specific options (only in bash)
if [ -n "$BASH_VERSION" ]; then
    shopt -s checkwinsize 2>/dev/null || true
    shopt -s globstar 2>/dev/null || true
    shopt -s extglob 2>/dev/null || true
fi

# Set default editor
export EDITOR=${EDITOR:-nano}
export VISUAL=${VISUAL:-nano}