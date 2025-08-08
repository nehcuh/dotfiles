# Editor and System Optimization Setup

This document describes the comprehensive editor and system optimization setup for VS Code, Zed, and macOS.

## 🎯 Overview

The optimization setup includes:

1. **VS Code Configuration** - Complete multi-language development setup
2. **Zed Configuration** - Modern editor with proper font settings  
3. **macOS System Optimizations** - Improved keyboard, mouse, and trackpad settings
4. **Development Tools** - Language servers and formatters for all supported languages
5. **Editor Fonts** - Professional fonts for coding (Nerd Fonts, Google Sans Code, etc.)

## 🚀 Quick Start

Run the complete optimization setup:

```bash
make optimize
```

Or install components individually:

```bash
make fonts      # Install editor fonts only
make dev-tools  # Install development tools only
```

## 📝 Detailed Configuration

### VS Code Settings

**Languages Supported:**
- **Python** - Uses `basedpyright` as LSP (instead of Pylsp), with Black formatter and Ruff linter
- **Rust** - rust-analyzer with Clippy checking
- **Go** - gopls with goimports formatting
- **Java** - Red Hat Java extension with Google style formatting
- **JavaScript/TypeScript** - ESLint + Prettier
- **C/C++** - Microsoft C++ extension with IntelliSense
- **Docker** - Dockerfile support and container management
- **Configuration Files** - YAML, TOML, INI, XML support

**Key Features:**
- `basedpyright` for Python type checking (strict mode)
- Format on save for all languages
- Auto-import organization
- **Vim support** with `vscodevim.vim` plugin
- Vim configuration (leader=space, jj=Esc, system clipboard)
- Comprehensive extension set for productivity
- SSH and remote development support

### Zed Configuration

**Font Setup:**
- **Editor Font**: `Google Sans Code` (14px)
- **Terminal Font**: `JetBrains Mono Nerd Font` (14px, 400 weight)

**Language Support:**
- Built-in LSP support for all major languages
- External formatters (Black, Prettier, etc.)
- **Vim mode enabled** (`vim_mode: true`)
- Optimized settings for development workflow

### macOS System Optimizations

**Keyboard:**
- Fast key repeat rate (1)
- Short initial repeat delay (15)
- Disabled press-and-hold for accent characters
- Continuous key repeat support ✅

**Mouse & Trackpad:**
- Trackpad tap-to-click enabled ✅
- Light tap support ✅
- Mouse assistive click (right-click by holding) ✅
- Optimized mouse movement speed (3.0) ✅
- Enhanced tracking and precision

**Other Optimizations:**
- Finder improvements (show extensions, path bar, status bar)
- Dock auto-hide with fast animations
- Safari developer tools enabled
- Disabled unnecessary animations

## 🛠 Development Tools Installed

### Language Runtimes
- **Python** - Latest via pyenv, with virtual environment support
- **Node.js** - Latest LTS with npm
- **Rust** - Latest stable with cargo tools
- **Go** - Latest with standard tools (goimports, golangci-lint)
- **Java** - OpenJDK 17 with Maven and Gradle
- **C/C++** - LLVM/Clang with development tools

### Language Servers & Formatters
- `basedpyright` - Python LSP (instead of pylsp)
- `rust-analyzer` - Rust LSP
- `gopls` - Go LSP  
- `typescript-language-server` - JavaScript/TypeScript
- `yaml-language-server` - YAML support
- `bash-language-server` - Shell scripting
- `@taplo/cli` - TOML formatter

### Development Utilities
- **Git Tools** - git-flow, git-lfs, GitHub CLI
- **Container Tools** - Docker, docker-compose
- **File Tools** - ripgrep, fd, fzf, bat, exa
- **System Tools** - tree, htop, curl, wget
- **Database Tools** - PostgreSQL, Redis
- **Browsers** - Google Chrome

## 🎨 Fonts Installed

- **JetBrains Mono Nerd Font** - Recommended for terminals
- **Fira Code** - Code font with ligatures
- **Source Code Pro** - Google's monospace font
- **SF Mono** - Apple's system monospace font
- **Hack Nerd Font** - Alternative development font
- **Inconsolata** - Classic programming font

## 📁 File Structure

```
.dotfiles/
├── scripts/
│   ├── setup-editor-optimization.sh  # Master optimization script
│   ├── setup-editor-fonts.sh         # Font installation
│   └── setup-dev-tools.sh           # Development tools
├── stow-packs/
│   ├── vscode/                       # VS Code configurations
│   ├── zed/                         # Zed configurations
│   └── macos/                       # macOS optimization scripts
└── Makefile                         # Updated with new targets
```

## 🔧 Configuration Files

### VS Code
- `settings.json` - Main editor settings with language-specific configurations
- `extensions.json` - Comprehensive extension list including basedpyright
- `keybindings.json` - Custom keyboard shortcuts

### Zed
- `settings.json` - Optimized settings with proper fonts
- `keymap.json` - Custom key mappings

### macOS
- `optimize.sh` - System optimization script
- `defaults.conf` - Configuration values
- `quick-optimize.sh` - Rapid system tweaks

## ⚡ Usage Examples

### Complete Setup
```bash
# Run full optimization (interactive)
make optimize

# Apply all configurations with stow
make install
```

### Partial Setup
```bash
# Install fonts only
make fonts

# Install development tools only
make dev-tools

# Apply macOS optimizations only
./stow-packs/macos/home/.config/macos/optimize.sh
```

### VS Code Extensions
The setup automatically installs essential extensions:
- `detachhead.basedpyright` - Python LSP
- `rust-lang.rust-analyzer` - Rust support
- `golang.go` - Go development
- `ms-azuretools.vscode-docker` - Docker integration
- And many more...

## 🔍 Troubleshooting

### Python LSP Issues
If `basedpyright` isn't working:
```bash
pip install basedpyright
# Restart VS Code
```

### Font Issues  
If fonts aren't appearing:
```bash
# Clear font cache
sudo atsutil databases -remove
# Restart editors
```

### macOS Settings Not Applied
Some settings require logout/restart:
```bash
# Kill affected applications
killall Finder Dock SystemUIServer
# Or restart the system
```

## 📚 Additional Resources

- [VS Code Python Documentation](https://code.visualstudio.com/docs/python/python-tutorial)
- [Zed Editor Documentation](https://zed.dev/docs)
- [basedpyright Documentation](https://github.com/DetachHead/basedpyright)
- [macOS defaults Documentation](https://macos-defaults.com/)

## 🎉 What's Optimized

✅ **Multi-language development environment**  
✅ **Professional editor fonts and appearance**  
✅ **Fast keyboard input with continuous repeat**  
✅ **Responsive trackpad and mouse controls**  
✅ **Optimized system animations and UI**  
✅ **Docker and SSH development support**  
✅ **Configuration file editing (YAML, TOML, INI)**  
✅ **Comprehensive language server support**  

Your development environment is now fully optimized for productivity! 🚀
