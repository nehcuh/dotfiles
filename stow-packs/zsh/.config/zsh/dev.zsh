# Development tools initialization
# Language version managers and tools

# Zoxide (smart cd)
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
    export _ZO_FZF_OPTS="--scheme=path --tiebreak=end,chunk,index \
           --bind=ctrl-z:ignore,btab:up,tab:down --cycle --keep-right \
           --border=sharp --height=45% --info=inline --layout=reverse \
           --tabstop=1 --exit-0 --select-1 \
           --preview '(eza --tree --icons --level 3 --color=always \
           --group-directories-first {2} || tree -NC {2} || \
           ls --color=always --group-directories-first {2}) 2>/dev/null | head -200'"
else
    zinit ice wait lucid depth"1"
    zinit light agkozak/zsh-z
fi

# NVM (Node Version Manager)
# Support both official and Homebrew installations
if (( $+commands[brew] )); then
    export NVM_DIR="$HOME/.nvm"
    [[ ! -d "$NVM_DIR" ]] && mkdir -p "$NVM_DIR"

    if [[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ]]; then
        source "$(brew --prefix)/opt/nvm/nvm.sh"
        [[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ]] && \
            source "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"
    elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
        [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    fi
else
    export NVM_DIR="$HOME/.nvm"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

# Homebrew completion
if (( $+commands[brew] )); then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit
fi
