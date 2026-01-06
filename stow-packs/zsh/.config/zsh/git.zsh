# Git configuration and utilities
# Git extras and aliases

# Install git-extras via Zinit
zinit ice wait lucid depth"1" as"program" pick"$ZPFX/bin/git-*" \
    src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX" \
    if'(( $+commands[make] ))'
zinit light tj/git-extras

# Git aliases
alias gtr='git tag -d $(git tag) && git fetch --tags'

# Ripgrep integration with FZF and Vim
function rgv () {
    rg --color=always --line-number --no-heading --smart-case "${*:-}" |
        fzf --ansi --height 80% --tmux 100%,80% \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
            --bind 'enter:become(nvim +{2} {1} || vim {1} +{2})'
}
