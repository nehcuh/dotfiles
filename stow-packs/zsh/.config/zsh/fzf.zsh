# FZF configuration
# Fuzzy finder integration

# Detect FZF location
if (( $+commands[brew] )); then
    FZF="$(brew --prefix)/opt/fzf/shell/"
elif (( $+commands[apt-get] )); then
    FZF="/usr/share/doc/fzf/examples/"
else
    FZF="/usr/share/fzf/"
fi

# Load FZF bindings and completion
[[ -f "$FZF/completion.zsh" ]] && source "$FZF/completion.zsh"
[[ -f "$FZF/key-bindings.zsh" ]] && source "$FZF/key-bindings.zsh"

# FZF defaults
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git || \
                           git ls-tree -r --name-only HEAD || \
                           rg --files --hidden --follow --glob '!.git' || \
                           find ."

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --tmux 100%,60% --border'

export FZF_CTRL_T_OPTS="--preview '(bat --style=numbers --color=always {} || \
                   cat {} || tree -NC {}) 2>/dev/null | head -200'"

export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview' --exact"

export FZF_ALT_C_OPTS="--preview '(eza --tree --icons --level 3 --color=always --group-directories-first {} || \
                   tree -NC {} || ls --color=always --group-directories-first {}) 2>/dev/null | head -200'"

# FZF tab completions
zinit ice wait lucid depth"1" atload"zicompinit; zicdreplay" blockf
zinit light Aloxaf/fzf-tab

# Git utilities powered by FZF
zinit ice wait lucid depth"1"
zinit light wfxr/forgit

# zstyle configurations
zstyle ':completion:*' menu no
zstyle ':completion.*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:complete:*:options' sort false
zstyle ':fzf-tab:*' switch-group '<' '>'

# Preview configurations
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
export LESSOPEN='|~/.lessfilter %s'

zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo ${(P)word}'

zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
    '[[ $group == "[process ID]" ]] && ps -p $word -o comm="" -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# Git command previews
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview 'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
    'case "$group" in commit tag) git show --color=always $word ;; *) git show --color=always $word | delta ;; esac'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
    'case "$group" in modified file) git diff $word | delta ;; recent commit) git show --color=always $word | delta ;; *) git log --color=always $word ;; esac'

# Command previews
zstyle ':fzf-tab:complete:(\\|*/|)man:*' fzf-preview 'man $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:tldr:argument-1' fzf-preview 'tldr --color always $word'
zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-preview 'brew info $word'
