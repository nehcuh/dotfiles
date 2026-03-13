# ZSH environment
# Only static PATH setup and environment variables here.
# Slow commands (brew shellenv, pyenv init) are in .zprofile (login shells only).

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export EDITOR='nvim'
export DEFAULT_USER=$USER

# Base PATH setup
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/sbin:$PATH

# NVM - set DIR only, initialization is done in .config/zsh/dev.zsh
export NVM_DIR="$HOME/.nvm"

# Zinit
export PATH=$HOME/.local/share/zinit/polaris/bin:$PATH

# Cask
export PATH=$HOME/.cask/bin:$PATH

# Golang
export GOPATH=$HOME/go
export PATH=${GOPATH//://bin:}/bin:$PATH

# Rust
export PATH=$HOME/.cargo/bin:$PATH

# Pyenv root (init is done in .zprofile)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# Secrets (API keys, tokens) — load from local file, never commit
[[ -f "$HOME/.config/zsh/secrets.zsh" ]] && source "$HOME/.config/zsh/secrets.zsh"
