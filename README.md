# Cross-Platform Dotfiles

![Cross-Platform](logo.png)

Full and clean configurations for development environment on Linux, macOS,
and Windows.

## Features

### Cross-Platform Support
- **Linux**: Ubuntu, Debian, Arch, Fedora, and more
- **macOS**: All recent versions with Homebrew
- **Windows**: WSL, MSYS2, native PowerShell

### Package Management
- **Linux**: apt, pacman, dnf, Homebrew
- **macOS**: Homebrew
- **Windows**: Scoop, Winget

### Tools Included
- **Shell**: Zsh with Zinit plugin manager
- **Terminal**: tmux with Oh My Tmux
- **Editors**: Neovim, Vim
- **Utilities**: fzf, ripgrep, eza, bat, starship, zoxide
- **Git**: Enhanced configuration with aliases

## Prerequisite

- Linux, macOS, Windows (WSL/MSYS2)
- Git, Zsh/PowerShell, curl/wget
- Recommend: Neovim, tmux
- Optional: Vim

## Quickstart

### Interactive Installation (Recommended)

**All Platforms:**
```bash
# Universal installer (auto-detects your shell)
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/universal-install.sh | sh

# Or use specific shell
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh | bash
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh | zsh
```

This will launch an interactive wizard that automatically detects your shell and lets you choose exactly what to install.

### 🔐 Sudo Permission Handling

All installation scripts include comprehensive sudo permission management:

- **Automatic Detection**: Scripts check for sudo access before requiring it
- **User-Friendly Prompts**: Clear instructions when password entry is needed
- **Session Management**: Sudo sessions are kept alive to prevent timeout during long installations
- **Graceful Error Handling**: Detailed error messages and manual execution suggestions if sudo fails
- **Cross-Platform Support**: Works seamlessly on Linux, macOS, and Windows (WSL/MSYS2)

**macOS Users**: If you encounter permission issues, ensure your user has administrator privileges in System Preferences > Users & Groups.

### One-Command Installation

**Linux & macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/install.sh | bash

# Or use the POSIX-compatible version:
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/install.sh | sh
```

**Windows:**
```powershell
# Run in PowerShell
iwr -useb https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/install-windows-improved.ps1 | iex
```

### Manual Installation

**Linux & macOS:**
```bash
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install.sh
```

**Windows:**
```powershell
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install-windows-improved.ps1
```

### Using Make

```bash
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

## Detailed Configuration

### 🖥️ System Packages
**Core Development Tools:**
- **Neovim**: Modern, extensible text editor with LSP support
- **Zed**: Lightning-fast, collaborative code editor
- **Tmux**: Terminal multiplexer for session management
- **Git**: Version control with enhanced configuration
- **Zsh**: Powerful shell with Zinit plugin manager
- **Starship**: Minimal, fast, and customizable prompt

**Modern Command Line Tools:**
- **eza**: Modern replacement for `ls` with icons and Git integration
- **bat**: Cat clone with syntax highlighting and Git integration
- **ripgrep**: Fast recursive search that replaces `grep`
- **fd**: Simple, fast and user-friendly alternative to `find`
- **fzf**: Command-line fuzzy finder
- **zoxide**: Smarter `cd` command that learns your habits
- **delta**: Syntax-highlighting pager for Git
- **yazi**: Blazing fast terminal file manager

**Development Tools:**
- **Go**: Go programming language with gopls
- **Rust**: Rust programming language with rust-analyzer
- **Python**: Python language servers (basedpyright, pyrefly for Zed)
- **Node.js**: TypeScript and JavaScript language servers
- **OrbStack**: Modern Docker alternative for macOS
- **Java**: OpenJDK with Maven and Gradle
- **C/C++**: GCC, Clang, CMake, and debugging tools

**Container Development:**
- **Dev Containers**: VS Code development containers support
- **Docker Compose**: Multi-container development environments  
- **Ubuntu Dev Environment**: Complete Ubuntu 24.04.2 LTS development container

**System Monitoring:**
- **bottom**: Better `top` with charts and GPU monitoring
- **procs**: Modern replacement for `ps`
- **duf**: Better `df` with colorful output
- **dust**: More intuitive version of `du`
- **hyperfine**: Command-line benchmarking tool
- **gping**: Ping, but with a graph

## Management

### Interactive Management
```bash
cd ~/.dotfiles
./scripts/interactive-install.sh  # Interactive installation wizard
```

### Using stow.sh
```bash
cd ~/.dotfiles
./scripts/stow.sh install system zsh git tools vim nvim tmux
./scripts/stow.sh remove system zsh git tools vim nvim tmux
./scripts/stow.sh status
./scripts/stow.sh list
```

### Using Make
```bash
cd ~/.dotfiles
make setup-python        # Setup Python environment
make setup-node          # Setup Node.js environment
make setup-dev           # Setup both Python and Node.js
make install             # Install all dotfiles
make remove              # Remove all dotfiles
make status              # Check current status
make clean               # Clean up obsolete files
make update              # Update repository
```

## Platform-Specific Notes

### Docker Development Environment
- **Ubuntu 24.04.2 LTS**: Complete development environment in container
- **User**: "huchen" with sudo privileges
- **Synchronized Configuration**: Your dotfiles are automatically available inside the container
- **Persistent Storage**: Home directory persists between container restarts
- **Port Mapping**: Common development ports (3000, 8000, 8080, etc.) are mapped
- **Usage**: `docker-compose -f docker/docker-compose.ubuntu-dev.yml up -d`

### Windows
- Requires Windows 10/11 with PowerShell 5.1+
- Works best with Windows Terminal
- Supports both WSL and native Windows environments
- Uses junction points for symbolic links

### Linux
- Supports all major distributions
- Automatic package manager detection
- Optional Linux Homebrew support

### macOS
- Requires Xcode Command Line Tools
- Uses Homebrew for package management
- Apple Silicon Mac support included

## Setup & Security

### Before Publishing to GitHub

1. **Replace `nehcuh`** in all files with your actual GitHub username
2. **Update `dotfiles.conf`** with your GitHub username  
3. **Create personal configuration files**:
   ```bash
   cp stow-packs/git/.gitconfig_local.template ~/.gitconfig_local
   # Edit ~/.gitconfig_local with your name and email
   ```

### First Time Setup

#### Quick Interactive Setup (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh | bash
```

#### Manual Setup
1. **Clone the repository**
   ```bash
   git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Run the installer**
   ```bash
   # Linux & macOS
   ./scripts/install.sh
   
   # Windows
   ./scripts/install-windows-improved.ps1
   ```

3. **Configure personal information**
   ```bash
   # Edit the git configuration template
   nano ~/.gitconfig_local
   ```

4. **Restart your terminal** to apply all changes

### Security Best Practices

- **Template files** are used for configurations needing personal information
- **`.local` files** are included in `.gitignore` to prevent accidental commits
- **Personal configurations** should be kept in `~/.gitconfig_local`, `~/.zshrc.local`, `~/.tmux.conf.local`
- **API keys and tokens** should never be committed to the repository

## Customization

### Environment Variables

Add your environment variables in `~/.zshenv` (recommended by ZSH):

```bash
export PATH=/usr/local/sbin:$PATH
export PATH=$HOME/.rbenv/shims:$PATH
export PYTHONPATH=/usr/local/lib/python2.7/site-packages
```

### Local Configuration

Set your personal configurations in these local files:

**Zsh:** `~/.zshrc.local`
```bash
# Additional zsh plugins
zinit snippet OMZP::golang
zinit snippet OMZP::python
zinit snippet OMZP::ruby
zinit light ptavares/zsh-direnv
```

**Git:** `~/.gitconfig.local`
```bash
[commit]
    # Sign commits using GPG
    gpgsign = true

[user]
    name = Your Name
    email = your.email@example.com
    signingkey = XXXXXXXX
```

**tmux:** `~/.tmux.conf.local`
```bash
# Personal tmux settings
set -g mouse on
set -g status-interval 5
```

### Development Environment Usage

**Python Development:**
```bash
# Use pyenv to manage Python versions
pyenv versions                    # List installed versions
pyenv install 3.11.0             # Install specific version
pyenv local 3.11.0               # Set version for current directory

# Use direnv for project-specific environments
echo 'layout python' > .envrc    # Create Python environment
direnv allow                      # Allow direnv for current directory

# Use uv for fast package management
uv pip install package-name      # Fast package installation
```

**Node.js Development:**
```bash
# Use nvm to manage Node.js versions
nvm list                          # List installed versions
nvm install 18.17.0              # Install specific version
nvm use 18.17.0                  # Use specific version
echo '18.17.0' > .nvmrc          # Set version for project
nvm use                          # Use version from .nvmrc
```

**Docker Development:**
```bash
# Start development environment
docker-compose -f docker/docker-compose.ubuntu-dev.yml up -d

# Access the environment
docker-compose -f docker/docker-compose.ubuntu-dev.yml exec ubuntu-dev zsh

# Stop the environment
docker-compose -f docker/docker-compose.ubuntu-dev.yml down
```

## Acknowledgements

This project is inspired by various dotfiles repositories and the community.
Special thanks to:
- [GNU Stow](https://www.gnu.org/software/stow/) for symlink management
- The open-source community for the amazing tools and configurations

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.