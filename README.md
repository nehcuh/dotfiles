# Simple Dotfiles

A clean, minimal dotfiles setup for Linux and macOS.

## Quick Start

### One-line remote installation
```bash
# Install with default packages (interactive)
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# Install specific packages
INSTALL_PACKAGES="git vim nvim zsh" curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# Non-interactive installation (for automation)
NON_INTERACTIVE=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash
```

**Note for macOS users:** The installer will automatically install Homebrew if not present, which requires administrator privileges. You may be prompted for your password during installation.

**Brewfile Integration:** On macOS, the installer will automatically detect and offer to install packages from your `~/.Brewfile`. This includes CLI tools, applications, and fonts. You can skip this with `SKIP_BREWFILE=true`.

### Local installation
```bash
# Clone and install in one line
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./install.sh

# Or step by step
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh

# Or use make
make install
```

## What's included

- **Shell**: Zsh configuration with modern prompt
- **Git**: Enhanced git aliases and settings  
- **Editors**: Vim and Neovim configurations
- **Terminal**: Tmux configuration
- **Tools**: Modern CLI tools and utilities

## Available Packages

- `system` - System-wide configurations
- `zsh` - Zsh shell configuration
- `git` - Git configuration and aliases
- `vim` - Vim configuration
- `nvim` - Neovim configuration  
- `tmux` - Terminal multiplexer configuration
- `tools` - CLI tools and utilities
- `vscode` - Visual Studio Code settings
- `zed` - Zed editor configuration
- `linux` - Linux-specific configurations
- `macos` - macOS-specific configurations

## Development Environment Setup

The dotfiles include an optional development environment setup that installs and configures multiple programming languages and tools:

### Supported Languages & Tools
- **Rust**: Latest stable Rust with cargo
- **Python**: pyenv + uv for fast Python package management
- **Go**: Latest Go version with proper GOPATH setup
- **Java**: OpenJDK with JAVA_HOME configuration
- **Node.js**: NVM with latest LTS Node.js
- **C/C++**: Build essentials and common development tools

### Installation
```bash
# Install dotfiles with development environments (interactive selection)
./install.sh --dev-env

# Install all development environments automatically
./install.sh --dev-all

# One-line remote installation with dev environments
DEV_ENV=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# Run dev environment setup separately
./scripts/setup-dev-environment.sh
```

**📖 For detailed development environment documentation, see [DEVELOPMENT_ENVIRONMENTS.md](DEVELOPMENT_ENVIRONMENTS.md)**

## Environment Variables

The installer supports several environment variables for automation and customization:

### Remote Installation Variables
```bash
# Skip all confirmation prompts (auto-install everything)
NON_INTERACTIVE=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# Skip Brewfile installation
SKIP_BREWFILE=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# Install specific packages only
INSTALL_PACKAGES="git vim zsh" curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# Setup development environments
DEV_ENV=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash
DEV_ALL=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# Combine multiple options
NON_INTERACTIVE=true DEV_ALL=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash
```

### Local Installation Variables
```bash
# Skip Brewfile installation locally
SKIP_BREWFILE=true ./install.sh

# Non-interactive local installation
NON_INTERACTIVE=true ./install.sh
```

### Available Variables
- **`NON_INTERACTIVE`**: Set to `true` to skip all confirmation prompts
- **`SKIP_BREWFILE`**: Set to `true` to skip Homebrew package installation
- **`INSTALL_PACKAGES`**: Specify packages to install (space-separated)
- **`DEV_ENV`**: Set to `true` to setup development environments (interactive)
- **`DEV_ALL`**: Set to `true` to install all development environments
- **`DOTFILES_REPO`**: Custom repository URL (default: `https://github.com/nehcuh/dotfiles.git`)
- **`DOTFILES_DIR`**: Custom installation directory (default: `~/.dotfiles`)

## Homebrew Package Management (macOS)

On macOS, the dotfiles include a comprehensive `Brewfile` that installs essential tools and applications:

### What's included in the Brewfile
- **CLI Tools**: bat, eza, fzf, ripgrep, neovim, git-delta, etc.
- **Development Tools**: go, rust, pyenv, nvm, maven, gradle, etc.
- **Applications**: Zed editor, Obsidian, Raycast, Rectangle, etc.
- **Fonts**: Fira Code, Hack Nerd Font, SF Mono, etc.

### Brewfile Installation
```bash
# Automatic installation during dotfiles setup (with confirmation)
./install.sh

# Skip Brewfile during installation
SKIP_BREWFILE=true ./install.sh

# Install Brewfile manually later
brew bundle --global

# Non-interactive remote installation (includes Brewfile)
NON_INTERACTIVE=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash
```

## Usage

### Install specific packages
```bash
./install.sh git vim nvim  # Install only git, vim, and nvim
```

### List available packages
```bash
make list
# or
./uninstall.sh list
```

### Remove dotfiles
```bash
./uninstall.sh           # Remove all packages
./uninstall.sh vim nvim   # Remove specific packages
make uninstall           # Remove all packages
```

### Update repository
```bash
make update
```

## Customization

### Local configuration files
Create these files for personal settings (they won't be tracked by git):

- `~/.gitconfig.local` - Personal git settings
- `~/.zshrc.local` - Additional zsh configuration
- `~/.tmux.conf.local` - Personal tmux settings

### Example ~/.gitconfig.local
```ini
[user]
    name = Your Name
    email = your.email@example.com
[commit]
    gpgsign = true
[user]
    signingkey = YOUR_GPG_KEY
```

## Requirements

- Git
- GNU Stow (automatically installed if missing)
- Zsh (optional, but recommended)

## Supported Systems

- **macOS**: All recent versions (main branch)
- **Linux**: Ubuntu, Debian, Arch, Fedora, and derivatives

### Linux Support

🐧 **For dedicated Linux support, use the `linux` branch:**

```bash
# Clone and switch to Linux branch
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git checkout linux
./install.sh
```

The Linux branch provides:
- ✅ **Homebrew for Linux** (CLI tools only, no cask)
- ✅ **Native package manager support** (apt, dnf, pacman, zypper)
- ✅ **Official app installations** (VS Code, Zed, Chrome)
- ✅ **Distribution-specific optimizations**
- ✅ **GPG error fixes** for Microsoft repositories

📖 **See [README-Linux.md](https://github.com/nehcuh/dotfiles/blob/linux/README-Linux.md) for detailed Linux documentation.**

## Files Structure

```
~/.dotfiles/
├── install.sh          # Main installer
├── uninstall.sh        # Uninstaller  
├── Makefile            # Make targets
├── stow-packs/         # Configuration packages
│   ├── git/           # Git configuration
│   ├── zsh/           # Zsh configuration
│   ├── vim/           # Vim configuration
│   ├── nvim/          # Neovim configuration
│   ├── tmux/          # Tmux configuration
│   └── ...
└── scripts/            # Helper scripts
```

## Troubleshooting

### Conflicts with existing files
The installer automatically backs up conflicting files to `~/.dotfiles-backup-TIMESTAMP/`.

### Restore from backup
```bash
# List available backups
ls -la ~/.dotfiles-backup-*

# Restore manually
cp ~/.dotfiles-backup-TIMESTAMP/.vimrc ~/.vimrc
```

### Clean old backups
```bash
make clean  # Removes backups older than 30 days
```

## License

MIT License - see [LICENSE](LICENSE) file.
