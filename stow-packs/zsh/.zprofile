# Zsh profile for login shells
# Slow initialization commands go here — runs once per login, not per subshell.

# Homebrew setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]] && [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Pyenv init (path setup)
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
fi

# Java configuration (cross-platform)
if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
    JAVA_HOME_BREW="$(brew --prefix)/opt/openjdk"
    if [[ -d "$JAVA_HOME_BREW" ]]; then
        export JAVA_HOME="$JAVA_HOME_BREW"
        export PATH="$JAVA_HOME_BREW/bin:$PATH"
        export CPPFLAGS="-I$JAVA_HOME_BREW/include"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    for _jvm in \
        /usr/lib/jvm/default-java \
        /usr/lib/jvm/java-17-openjdk-amd64 \
        /usr/lib/jvm/java-17-openjdk \
        /usr/lib/jvm/java-11-openjdk-amd64 \
        /usr/lib/jvm/java-11-openjdk \
        /usr/lib/jvm/java-8-openjdk-amd64 \
        /usr/lib/jvm/java-8-openjdk; do
        if [[ -d "$_jvm" ]]; then
            export JAVA_HOME="$_jvm"
            break
        fi
    done
    unset _jvm
    [[ -n "$JAVA_HOME" && -d "$JAVA_HOME/bin" ]] && export PATH="$JAVA_HOME/bin:$PATH"
fi

# OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

