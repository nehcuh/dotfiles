# ZSH environment

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export TERM=xterm-256color
export DEFAULT_USER=$USER
export EDITOR='nvim'

# Homebrew - ensure it's loaded first for PATH precedence
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]] && [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Base PATH setup
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/sbin:$PATH

# Pyenv configuration - must be set early for PATH precedence
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# pyenv init --path must be in .zshenv for noninteractive shells
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
fi

# NVM configuration - set DIR but don't source yet (done in .zshrc)
if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
fi

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

# uv (Python package manager)
export PATH="$HOME/.local/bin:$PATH"

# Java configuration (cross-platform)
if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
    # macOS: Java via Homebrew
    JAVA_HOME_BREW="$(brew --prefix)/opt/openjdk"
    if [[ -d "$JAVA_HOME_BREW" ]]; then
        export JAVA_HOME="$JAVA_HOME_BREW"
        export PATH="$JAVA_HOME_BREW/bin:$PATH"
        export CPPFLAGS="-I$JAVA_HOME_BREW/include"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux: Java via system package managers (try various common paths)
    if [[ -d "/usr/lib/jvm/default-java" ]]; then
        export JAVA_HOME="/usr/lib/jvm/default-java"
    elif [[ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]]; then
        export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
    elif [[ -d "/usr/lib/jvm/java-17-openjdk" ]]; then
        export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
    elif [[ -d "/usr/lib/jvm/java-11-openjdk-amd64" ]]; then
        export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
    elif [[ -d "/usr/lib/jvm/java-11-openjdk" ]]; then
        export JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
    elif [[ -d "/usr/lib/jvm/java-8-openjdk-amd64" ]]; then
        export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
    elif [[ -d "/usr/lib/jvm/java-8-openjdk" ]]; then
        export JAVA_HOME="/usr/lib/jvm/java-8-openjdk"
    fi
    # Add JAVA_HOME/bin to PATH if JAVA_HOME is set
    if [[ -n "$JAVA_HOME" && -d "$JAVA_HOME/bin" ]]; then
        export PATH="$JAVA_HOME/bin:$PATH"
    fi
fi

# AI/LLM API Configuration (Templates - Uncomment and modify with your actual keys)
export ***REMOVED***=https://api.gpt2share.com/v1
export ***REMOVED***=sk-arOZQzfQXe0KIFn15fEHhDHPRMx7VMS0W1LFaJpbkVQuoe4h
export ***REMOVED***=sk-arOZQzfQXe0KIFn15fEHhDHPRMx7VMS0W1LFaJpbkVQuoe4h
export ***REMOVED***=https://api.gpt2share.com/v1
# export GEMINI_API_KEY=your-gemini-api-key
# export DEEPSEEK_API_KEY=your-deepseek-api-key
# export GROQ_API_KEY=your-groq-api-key
# export PERPLEXITY_API_KEY=your-perplexity-api-key
export ***REMOVED***=sk-FeG3ZfDXzeKKQhaU6mN3ocWTbp5gfDsQBB4cSMJTgJekxR19

# Proxy configuration (Uncomment if needed)
# setproxy
# export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897
