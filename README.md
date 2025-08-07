# Simple Dotfiles

A clean, minimal dotfiles setup for Linux and macOS.

## Quick Start

### One-line remote installation
```bash
# Install with default packages
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# Or install specific packages
INSTALL_PACKAGES="git vim nvim zsh" curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash
```

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

- **macOS**: All recent versions
- **Linux**: Ubuntu, Debian, Arch, Fedora, and derivatives

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
