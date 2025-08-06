# Cross-Platform Dotfiles

![Cross-Platform](logo.png)

Full and clean configurations for development environment on Linux, macOS,
and Windows.

## Prerequisite

- Linux, macOS, Windows (WSL/MSYS2)
- Git, Zsh/PowerShell, curl/wget
- Recommend: Neovim, tmux
- Optional: Vim

## Quickstart

### One-Command Installation (Recommended)

**Linux & macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/install-unified.sh | bash
```

**Windows:**
```powershell
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install.bat
```

### Manual Installation

**Linux & macOS:**
```bash
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install-unified.sh
```

**Windows:**
```powershell
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install.bat
```

### Using Make

```bash
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

## Features

### Cross-Platform Support
- **Linux**: Ubuntu, Debian, Arch, Fedora, etc.
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
- **Python**: Python language server (basedpyright)
- **Node.js**: TypeScript and JavaScript language servers
- **Docker**: Container management (when available)

**Container Development:**
- **Dev Containers**: VS Code development containers support
- **Docker Compose**: Multi-container development environments
- **Ubuntu Dev Environment**: Complete Ubuntu 24.04.2 LTS development container
- **OrbStack**: Modern Docker alternative for macOS

**System Monitoring:**
- **bottom**: Better `top` with charts and GPU monitoring
- **procs**: Modern replacement for `ps`
- **duf**: Better `df` with colorful output
- **dust**: More intuitive version of `du`
- **hyperfine**: Command-line benchmarking tool
- **gping**: Ping, but with a graph

### 🎨 Shell Configuration
**Zsh Features:**
- **Zinit**: Fast plugin manager with Turbo mode
- **Syntax Highlighting**: Real-time command highlighting
- **Auto Suggestions**: Smart command completion
- **History Search**: Interactive history search with fzf
- **Directory Navigation**: Smart jumping with zoxide
- **Git Integration**: Status in prompt and aliases

**Key Bindings:**
- `Alt-c`: Fuzzy directory selection and navigation
- `Ctrl-r`: Interactive command history search
- `Ctrl-t`: Fuzzy file selection and insertion
- `Tab`: Smart completion with fzf-tab

### 🧠 Git Configuration
**Enhanced Features:**
- **Delta**: Beautiful git diff output with syntax highlighting
- **Aliases**: Common git operations simplified
- **Merge Tools**: Neovim integration for conflict resolution
- **Global Ignores**: Consistent ignore patterns across projects
- **Safe Settings**: Secure default configurations

**Useful Aliases:**
- `gco` → `git checkout`
- `gcm` → `git commit -m`
- `ga` → `git add`
- `gs` → `git status`
- `gp` → `git push`
- `gl` → `git pull`

### 🎯 Terminal Multiplexer (Tmux)
**Features:**
- **Session Persistence**: Detach and reattach sessions
- **Panels**: Split terminal windows efficiently
- **Status Bar**: Custom status with system information
- **Copy Mode**: Vim-like copy and paste
- **Mouse Support**: Clickable panes and scrolling

### ⚡ Performance Benefits
- **Fast Startup**: Zsh with optimized plugin loading
- **Minimal Overhead**: Lightweight tools that don't slow down your system
- **Parallel Processing**: Efficient use of system resources
- **Memory Efficient**: Tools designed to be lightweight and fast

### 🎨 Visual Enhancements
- **Consistent Theme**: Starship prompt across all shells
- **Syntax Highlighting**: All tools support color and syntax
- **Icons**: File type icons in listings and prompts
- **Git Integration**: Visual Git status everywhere

### 🔧 Developer Experience
- **LSP Support**: Language servers for multiple programming languages
- **IntelliSense**: Smart code completion and suggestions
- **Error Checking**: Real-time syntax and error highlighting
- **Formatting**: Code formatting tools integration
- **Debugging**: Debug adapter support where available

## Management

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
make install          # Install all dotfiles
make remove           # Remove all dotfiles
make status           # Check current status
make clean            # Clean up obsolete files
make update           # Update repository
```

### Shell Shortcuts
- `Alt-c`: cd into the selected directory
- `Ctrl-r`: Paste the selected command from history
- `Ctrl-t`: Paste the selected file path(s)
- `Tab`: Smart completions

## Platform-Specific Notes

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

1. **Clone the repository**
   ```bash
   git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Run the installer**
   ```bash
   # Linux & macOS
   ./scripts/install-unified.sh
   
   # Windows
   ./scripts/install.bat
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

## Acknowledgements

This project is inspired by various dotfiles repositories and the community.
Special thanks to:
- [GNU Stow](https://www.gnu.org/software/stow/) for symlink management
- The open-source community for the amazing tools and configurations

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
