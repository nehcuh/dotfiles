# Development Environment Setup Guide

This guide covers the development environment setup integrated with the dotfiles project.

## Overview

The dotfiles include comprehensive development environment setup for multiple programming languages and tools. This setup is completely optional and can be installed alongside your dotfiles configuration.

## Supported Languages & Tools

### Rust
- **rustup**: Rust toolchain installer
- **cargo**: Rust package manager
- **rust-analyzer**: Language server for better IDE support
- **Common tools**: clippy, rustfmt, cargo-edit, cargo-watch

### Python
- **pyenv**: Python version manager
- **uv**: Ultra-fast Python package installer and resolver
- **pip**: Python package installer (latest version)
- **Common tools**: python-build, pipenv support

### Go
- **Go**: Latest stable version
- **GOPATH**: Properly configured
- **Common tools**: gofmt, go-imports, go-lint

### Java
- **OpenJDK**: Latest LTS version
- **Maven**: Build automation tool
- **Gradle**: Build automation tool
- **JAVA_HOME**: Properly configured

### Node.js
- **NVM**: Node Version Manager
- **Node.js**: Latest LTS version
- **npm**: Node package manager
- **Common tools**: yarn, pnpm support

### C/C++
- **Build essentials**: gcc, g++, make
- **cmake**: Cross-platform build system
- **Common libraries**: Standard development libraries

## Installation Methods

### 1. Integrated Installation

Install dotfiles and development environments together:

```bash
# Interactive selection of development environments
./install.sh --dev-env

# Install all development environments automatically
./install.sh --dev-all

# Install specific packages with development environments
./install.sh git zsh --dev-env
```

### 2. Remote One-Line Installation

```bash
# With development environment selection
DEV_ENV=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# With all development environments
DEV_ALL=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash
```

### 3. Standalone Installation

Install development environments separately:

```bash
# Interactive selection
./scripts/setup-dev-environment.sh

# Install all environments
./scripts/setup-dev-environment.sh --all

# Install specific languages
./scripts/setup-dev-environment.sh rust python node
./scripts/setup-dev-environment.sh java go cpp
```

## Environment Configuration

### Shell Integration

After installation, development environments are properly integrated into your shell:

```bash
# Rust
cargo --version
rustc --version

# Python
python --version
uv --version

# Go
go version

# Java
java -version
mvn --version
gradle --version

# Node.js
node --version
npm --version
```

### Environment Variables

The following environment variables are automatically configured:

- **GOPATH**: `$HOME/go`
- **GOROOT**: Auto-detected Go installation
- **JAVA_HOME**: Auto-detected Java installation
- **CARGO_HOME**: `$HOME/.cargo`
- **PYENV_ROOT**: `$HOME/.pyenv`

### PATH Updates

Your PATH is automatically updated to include:
- `$HOME/.cargo/bin` (Rust tools)
- `$HOME/.pyenv/bin` (Python tools)
- `$GOPATH/bin` (Go tools)
- NVM paths (Node.js tools)

## Usage Examples

### Rust Development

```bash
# Create a new Rust project
cargo new my-project
cd my-project

# Add dependencies
cargo add serde

# Run the project
cargo run

# Run tests
cargo test

# Format code
cargo fmt

# Lint code
cargo clippy
```

### Python Development

```bash
# Install a Python version
pyenv install 3.12.0
pyenv global 3.12.0

# Create a virtual environment and install packages with uv
uv venv
source .venv/bin/activate
uv add requests numpy

# Run Python
python --version
python -c "import requests; print(requests.__version__)"
```

### Go Development

```bash
# Create a new Go module
mkdir my-go-app
cd my-go-app
go mod init my-go-app

# Add dependencies
go get github.com/gin-gonic/gin

# Build and run
go build
./my-go-app
```

### Java Development

```bash
# Create a new Maven project
mvn archetype:generate -DgroupId=com.example -DartifactId=my-app

# Create a new Gradle project
gradle init --type java-application
```

### Node.js Development

```bash
# Install a specific Node version
nvm install 20
nvm use 20

# Create a new project
npm init -y
npm install express

# Run the project
node index.js
```

## Customization

### Adding More Languages

To add support for additional languages:

1. Edit `scripts/setup-dev-environment.sh`
2. Add installation functions following the existing patterns
3. Update the help text and language list
4. Test the installation

### Custom Configurations

Create local configuration files for additional customization:

- `~/.rustrc` - Rust-specific settings
- `~/.pyenvrc` - Python environment settings
- `~/.gorc` - Go-specific settings

## Troubleshooting

### Common Issues

1. **Permission denied**: Ensure you have admin privileges on macOS
2. **Command not found**: Restart your terminal or run `source ~/.zshrc`
3. **Version conflicts**: Use environment managers (pyenv, nvm) to switch versions

### Environment Verification

Check if environments are properly installed:

```bash
# Check Rust
which rustc
rustc --version

# Check Python
which python
python --version
pyenv versions

# Check Go
which go
go version

# Check Java
which java
java -version

# Check Node.js
which node
node --version
nvm list
```

### Cleanup

To remove installed development environments:

```bash
# Remove Rust
rustup self uninstall

# Remove pyenv
rm -rf ~/.pyenv

# Remove Go (if installed via package manager, use package manager to remove)

# Remove Java (system-dependent)

# Remove NVM
rm -rf ~/.nvm
```

## Platform-Specific Notes

### macOS
- Homebrew is automatically installed if not present
- Some installations require Xcode Command Line Tools
- Administrator privileges may be required

### Linux
- Package managers vary by distribution
- Some packages may require sudo privileges
- Development libraries are automatically installed

## Support

For issues or questions:

1. Check the main README.md for general dotfiles issues
2. Review this guide for development environment specific issues
3. Check individual tool documentation for language-specific problems
4. Open an issue on the GitHub repository

## Contributing

To contribute improvements:

1. Test changes on both macOS and Linux
2. Update this documentation
3. Add appropriate error handling
4. Submit a pull request

---

**Note**: Development environment setup is optional and modular. You can install only the languages you need and add more later.
