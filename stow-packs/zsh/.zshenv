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

# AI/LLM API Configuration (Templates - Uncomment and modify with your actual keys)
# export ANTHROPIC_BASE_URL=https://api.anthropic.com
# export ANTHROPIC_AUTH_TOKEN=your-anthropic-api-key
# export OPENAI_API_KEY=your-openai-api-key
# export GEMINI_API_KEY=your-gemini-api-key
# export DEEPSEEK_API_KEY=your-deepseek-api-key
# export GROQ_API_KEY=your-groq-api-key
# export PERPLEXITY_API_KEY=your-perplexity-api-key

# Proxy configuration (Uncomment if needed)
# setproxy
# export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897