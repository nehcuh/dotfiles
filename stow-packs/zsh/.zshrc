# Zsh configuration

# vars
DOTFILES=$HOME/.dotfiles
NVIMD=$HOME/.config/nvim

# Initialize starship prompt
eval "$(starship init zsh)"

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone --depth=1 https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
            print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode depth"1" for \
      zdharma-continuum/zinit-annex-bin-gem-node \
      zdharma-continuum/zinit-annex-patch-dl

### End of Zinit's installer chunk

# Oh My Zsh
zinit for \
      OMZL::correction.zsh \
      OMZL::directories.zsh \
      OMZL::history.zsh \
      OMZL::key-bindings.zsh \
      OMZL::theme-and-appearance.zsh \
      OMZP::common-aliases

zinit wait lucid for \
      OMZP::colored-man-pages \
      OMZP::cp \
      OMZP::extract \
      OMZP::fancy-ctrl-z \
      OMZP::git \
      OMZP::sudo

# Completion enhancements
zinit wait lucid depth"1" for \
      atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
      zdharma-continuum/fast-syntax-highlighting \
      blockf \
      zsh-users/zsh-completions \
      atload"!_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions

zinit wait lucid light-mode depth"1" for \
      djui/alias-tips \
      zsh-users/zsh-history-substring-search \
      hlissner/zsh-autopair

#
# Utilities
#

# Z
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

# Git extras
zinit ice wait lucid depth"1" as"program" pick"$ZPFX/bin/git-*" \
      src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX" \
      if'(( $+commands[make] ))'
zinit light tj/git-extras

# Prettify ls
if (( $+commands[gls] )); then
    alias ls='gls --color=tty --group-directories-first'
else
    alias ls='ls --color=tty --group-directories-first'
fi

# Homebrew completion
if (( $+commands[brew] )); then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit
fi

# FZF: fuzzy finder
if (( $+commands[brew] )); then
    FZF="$(brew --prefix)/opt/fzf/shell/"
elif (( $+commands[apt-get] )); then
    FZF="/usr/share/doc/fzf/examples/"
else
    FZF="/usr/share/fzf/"
fi

if [[ -f "$FZF/completion.zsh" ]]; then
    source "$FZF/completion.zsh"
fi

if [[ -f "$FZF/key-bindings.zsh" ]]; then
    source "$FZF/key-bindings.zsh"
fi

# Git utilities powered by FZF
zinit ice wait lucid depth"1"
zinit light wfxr/forgit

# Replace zsh's default completion selection menu with fzf
zinit ice wait lucid depth"1" atload"zicompinit; zicdreplay" blockf
zinit light Aloxaf/fzf-tab

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

zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:complete:*:options' sort false

# Switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# Preview directory's content
# zstyle ':fzf-tab:complete:(cd|ls|lsd|exa|eza|bat|cat|nano|vi|vim|nvim):*' \
    #        fzf-preview 'eza -1 --icons --color=always --group-directories-first $realpath 2>/dev/null || \
    #                     ls -1 --color=always --group-directories-first $realpath'

# Preview contents
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
export LESSOPEN='|~/.dotfiles/.lessfilter %s'

# Preview environment vareiables
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
       fzf-preview 'echo ${(P)word}'

# Preivew `kill` and `ps` commands
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
       '[[ $group == "[process ID]" ]] &&
        if [[ $OSTYPE == darwin* ]]; then
            ps -p $word -o comm="" -w -w
        elif [[ $OSTYPE == linux* ]]; then
            ps --pid=$word -o cmd --no-headers -w -w
        fi'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# Preivew `git` commands
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
	   'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
	   'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
	   'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
	   'case "$group" in
	"commit tag") git show --color=always $word ;;
	*) git show --color=always $word | delta ;;
	esac'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
	   'case "$group" in
	"modified file") git diff $word | delta ;;
	"recent commit object name") git show --color=always $word | delta ;;
	*) git log --color=always $word ;;
	esac'

# Privew help
zstyle ':fzf-tab:complete:(\\|*/|)man:*' fzf-preview 'man $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:tldr:argument-1' fzf-preview 'tldr --color always $word'

# Preview brew
zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-preview 'brew info $word'

# Preview systemd
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# Ripgrep integration
function rgv () {
	rg --color=always --line-number --no-heading --smart-case "${*:-}" |
        fzf --ansi --height 80% --tmux 100%,80% \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
            --bind 'enter:become(nvim +{2} {1} || vim {1} +{2})'
}

# OS bundles
if [[ $OSTYPE == darwin* ]]; then
    zinit snippet PZTM::osx
    if (( $+commands[brew] )); then
        alias bu='brew update; brew upgrade; brew cleanup'
        alias bcu='brew cu --all --yes --cleanup'
        alias bua='bu; bcu'
    fi
elif [[ $OSTYPE == linux* ]]; then
    if (( $+commands[apt-get] )); then
        zinit snippet OMZP::ubuntu
        alias agua='aguu -y && agar -y && aga -y'
        alias kclean+='sudo aptitude remove -P "?and(~i~nlinux-(ima|hea),\
                            ?not(?or(~n`uname -r | cut -d'\''-'\'' -f-2`,\
                            ~nlinux-generic,\
                            ~n(linux-(virtual|headers-virtual|headers-generic|image-virtual|image-generic|image-`dpkg --print-architecture`)))))"'
    elif (( $+commands[pacman] )); then
        zinit snippet OMZP::archlinux
    fi
fi

# LSP booster
# if (( $+commands[nvim-lsp-booster] == 0 )); then
#     zinit ice wait lucid depth"1" sbin"**/nvim-lsp-booster"
#     zinit light blahgeek/nvim-lsp-booster
# fi

#
# Aliases
#

# General
alias zshconf="$EDITOR $HOME/.zshrc; $EDITOR $HOME/.zshrc.local"
alias h='history'
alias c='clear'

# Modern Unix commands
# See https://github.com/ibraheemdev/modern-unix
if (( $+commands[eza] )); then
    alias ls='eza --color=auto --icons --group-directories-first'
    alias l='ls -lhF'
    alias la='ls -lhAF'
    alias tree='ls --tree'
elif (( $+commands[exa] )); then
    alias ls='exa --color=auto --icons --group-directories-first'
    alias l='ls -lhF'
    alias la='ls -lahF'
    alias tree='ls --tree'
fi
(( $+commands[bat] )) && alias cat='bat -p --wrap character'
(( $+commands[fd] )) && alias find=fd
if (( $+commands[btop] )); then
    alias top=btop
elif (( $+commands[btm] )); then
    alias top=btm
fi
(( $+commands[rg] )) && alias grep=rg
(( $+commands[tldr] )) && alias help=tldr
(( $+commands[delta] )) && alias diff=delta
(( $+commands[duf] )) && alias df=duf
(( $+commands[dust] )) && alias du=dust
(( $+commands[hyperfine] )) && alias benchmark=hyperfine
(( $+commands[gping] )) && alias ping=gping
(( $+commands[paru] )) && alias yay=paru

# Git
alias gtr='git tag -d $(git tag) && git fetch --tags' # Refresh local tags from remote

# Neovim
alias e="$EDITOR -n"
alias ec="$EDITOR -n -c"
alias ef="$EDITOR -c"
alias te="$EDITOR -nw"
alias vt="nvim --remote-send ':e<CR>' && nvim --remote-tab" # Open file in current neovim instance

# Upgrade
alias upgrade_repo='git pull --rebase --stat origin master'
alias upgrade_dotfiles='cd $DOTFILES && upgrade_repo; cd - >/dev/null'
alias upgrade_nvim='nvim --headless "+Lazy sync" +qa'
alias upgrade_omt='cd $HOME/.tmux && upgrade_repo; cd - >/dev/null'
alias upgrade_zinit='zinit self-update && zinit update -a -p && zinit compinit'
alias upgrade_env='upgrade_dotfiles; sh $DOTFILES/install.sh'

(( $+commands[cargo] )) && alias upgrade_cargo='cargo install-update -a' # cargo install cargo-update
(( $+commands[gem] )) && alias upgrade_gem='gem update && gem cleanup'
(( $+commands[go] )) && alias upgrade_go='$DOTFILES/install_go.sh'
(( $+commands[npm] )) && alias upgrade_npm='for package in $(npm -g outdated --parseable --depth=0 | cut -d: -f2); do npm -g install "$package"; done'
(( ! $+commands[brew] )) && (( $+commands[pip] )) && alias upgrade_pip="pip list --outdated --format=json | python -c '
import json
import sys

for item in json.loads(sys.stdin.read()):
    print(\"=\".join([item[\"name\"], item[\"latest_version\"]]))
' | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U"
(( ! $+commands[brew] )) && (( $+commands[pip3] )) && alias upgrade_pip3="pip3 list --outdated --format=json | python3 -c '
import json
import sys

for item in json.loads(sys.stdin.read()):
    print(\"=\".join([item[\"name\"], item[\"latest_version\"]]))
' | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U"
(( $+commands[brew] )) && alias upgrade_brew='brew bundle --global; bua'

# Proxy
PROXY=http://127.0.0.1:7897         # ss:1088, vr:8001
NO_PROXY=10.*.*.*,192.168.*.*,*.local,localhost,127.0.0.1
alias showproxy='echo "proxy=$http_proxy"'
alias setproxy='export http_proxy=$PROXY; export https_proxy=$PROXY; all_proxy=$PROXY; export no_proxy=$NO_PROXY; showproxy'
alias unsetproxy='export http_proxy=; export https_proxy=; export all_proxy=; export no_proxy=; showproxy'
alias toggleproxy='if [ -n "$http_proxy" ]; then unsetproxy; else setproxy; fi'

# Local customizations, e.g. theme, plugins, aliases, etc.
[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/huchen/.lmstudio/bin"
# End of LM Studio CLI section


# opencode
export PATH=/Users/huchen/.opencode/bin:$PATH

# bun completions
[ -s "/Users/huchen/.bun/_bun" ] && source "/Users/huchen/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
alias gitai="/Users/huchen/Projects/gitai/target/release/gitai"
