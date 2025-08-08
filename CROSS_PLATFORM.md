# Cross-Platform Compatibility Guide

This dotfiles configuration is fully adapted for both **Linux** and **macOS** systems, ensuring consistent development environment setup across platforms.

## 🎯 Supported Platforms

### macOS
- ✅ macOS Big Sur and later (Intel & Apple Silicon)
- ✅ Homebrew integration (both `/opt/homebrew` and `/usr/local`)
- ✅ Native macOS apps via Homebrew Cask

### Linux Distributions
- ✅ **Ubuntu/Debian** (apt package manager)
- ✅ **Fedora/RHEL/CentOS** (dnf package manager)
- ✅ **Arch Linux** (pacman package manager)
- ✅ **openSUSE** (zypper package manager)
- ✅ **Any Linux** with Homebrew for Linux support

## 🔧 Cross-Platform Shell Configuration

### Core Files
All shell configuration files work identically on both platforms:

**`.zshenv`** - Environment variables and PATH setup
- Homebrew detection for both macOS and Linux
- Pyenv configuration with proper PATH precedence
- NVM_DIR setup
- Java, Go, Rust, Python tool paths
- Cross-platform PATH optimization

**`.zshrc`** - Interactive shell configuration  
- Pyenv initialization (`pyenv init - zsh`)
- NVM loading with bash completion
- Universal aliases and functions
- Cross-platform plugin management

**`.zprofile`** - Login shell configuration
- Noninteractive login shell support
- Homebrew environment loading
- Pyenv path setup for all shell contexts

## 🛠️ Development Tools Support

### Python (Pyenv)
Both platforms use identical configuration following [official pyenv installation guide](https://github.com/pyenv/pyenv#installation):

```bash
# .zshenv (all shell types)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# .zshrc (interactive shells)  
eval "$(pyenv init - zsh)"

# .zprofile (noninteractive login shells)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
```

### Node.js (NVM)
Both platforms use identical configuration following [official NVM installation guide](https://github.com/nvm-sh/nvm#installation-and-update):

```bash
# .zshrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

### Java
Platform-specific but unified configuration:

**macOS**: Homebrew OpenJDK detection
```bash
# Automatic detection of Homebrew Java
JAVA_HOME_BREW="$(brew --prefix)/opt/openjdk"
export JAVA_HOME="$JAVA_HOME_BREW"
```

**Linux**: Multiple OpenJDK path detection
```bash
# Auto-detection of system Java installations
# Supports: java-17-openjdk, java-11-openjdk, java-8-openjdk
# Both generic and amd64-specific paths
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
```

### Other Tools
- **Go**: Homebrew on macOS, direct binary on Linux
- **Rust**: rustup installer on both platforms
- **Homebrew**: Native on macOS, Linux Homebrew support
- **Package Managers**: Platform-specific aliases (apt, dnf, pacman, zypper)

## 📦 Installation Process

### Automatic Platform Detection
The installation script automatically detects your platform:

```bash
# Works on both Linux and macOS
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# Or for Linux specifically:
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/linux/remote-install-linux.sh | bash
```

### Development Environment Setup
Install development tools with identical commands on both platforms:

```bash
# Install all development environments
./install.sh --dev-all

# Or specific tools
./scripts/setup-dev-environment.sh python node go java rust cpp vscode
```

## 🧪 Testing Cross-Platform Compatibility

Use the included test script to verify configuration on any platform:

```bash
# Test current configuration
./scripts/test-dev-tools.sh

# Expected output shows:
# ✅ Platform detection (linux/macos)
# ✅ Pyenv configuration and PATH
# ✅ NVM configuration and loading
# ✅ Development tools availability
# ✅ Shell configuration files (symlinks)
# ✅ PATH optimization and order
```

## 🔄 Platform-Specific Features

### macOS Only
- Homebrew Cask applications (VS Code, browsers, etc.)
- macOS system optimization scripts
- Xcode Command Line Tools integration
- Apple Silicon vs Intel detection

### Linux Only
- Distribution-specific package manager aliases
- XDG Base Directory Specification compliance
- Systemd integration where available
- Linux-specific font and display configurations

## 🚀 Migration Between Platforms

The configuration is designed to work seamlessly when switching between platforms:

1. **Same Commands**: All setup commands work identically
2. **Same Paths**: Development tools use consistent home directory paths
3. **Same Configuration**: All dotfiles work without modification
4. **Same Experience**: Terminal, editors, and tools behave consistently

## ✅ Verification Checklist

Run this checklist on any new platform to ensure everything works:

- [ ] `pyenv --version` shows version (after installation)
- [ ] `nvm --version` shows version (after installation)  
- [ ] `echo $PYENV_ROOT` shows `/home/user/.pyenv` or `/Users/user/.pyenv`
- [ ] `echo $NVM_DIR` shows `/home/user/.nvm` or `/Users/user/.nvm`
- [ ] `which python` shows pyenv shim path
- [ ] `which node` shows nvm managed Node.js (after installation)
- [ ] Shell startup is fast (< 2 seconds)
- [ ] All dotfiles are symlinks to `.dotfiles/stow-packs/`

## 📚 References

This configuration follows official installation guides from:
- [Pyenv Installation Guide](https://github.com/pyenv/pyenv#installation)
- [NVM Installation Guide](https://github.com/nvm-sh/nvm#installation-and-update)
- [Homebrew Installation Guide](https://brew.sh/)
- [Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux)

The cross-platform adaptation ensures you get the same powerful development environment whether you're on Ubuntu, Arch Linux, Fedora, macOS, or any other supported platform! 🎉
