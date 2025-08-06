# ZSH envioronment

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export TERM=xterm-256color
export DEFAULT_USER=$USER
export EDITOR='nvim'
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/sbin:$PATH

# Zinit
export PATH=$HOME/.local/share/zinit/polaris/bin:$PATH

# Cask
export PATH=$HOME/.cask/bin:$PATH

# Golang
export GO111MODULE=auto
export GOPROXY=https://goproxy.io,direct
export GOPATH=$HOME/go
export PATH=${GOPATH//://bin:}/bin:$PATH

# Rust
export PATH=$HOME/.cargo/bin:$PATH

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"

# APIKEY - Replace with your actual keys
# export OPENAI_API_KEY=your-openai-api-key
# export OPENAI_BASE_URL="https://api.openai.com/v1"
# export GEMINI_API_KEY=your-gemini-api-key
# export DEEPSEEK_API_KEY=your-deepseek-api-key
# export DEEPSEEK_BASE_URL="https://api.deepseek.com"
# export MOONSHOT_API_KEY=your-moonshot-api-key
# export AVANTE_MOONSHOT_API_KEY=your-moonshot-api-key
# export ANTHROPIC_BASE_URL=https://api.anthropic.com
# export ANTHROPIC_AUTH_TOKEN=your-anthropic-api-key
# setproxy
# export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897