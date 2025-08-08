#!/bin/bash

# Setup Development Tools Script
# Installs language servers, formatters, and development tools for VS Code and Zed

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up development tools and language servers...${NC}"

# Check if package managers are installed
check_package_manager() {
    local manager=$1
    local install_cmd=$2
    
    if ! command -v "$manager" &> /dev/null; then
        echo -e "${YELLOW}$manager not found. Installing with: $install_cmd${NC}"
        eval "$install_cmd"
    else
        echo -e "${GREEN}✓ $manager is already installed${NC}"
    fi
}

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Node.js and npm
echo -e "${YELLOW}Installing Node.js and npm...${NC}"
brew install node

# Install Python tools
echo -e "${YELLOW}Installing Python development tools...${NC}"
# Install Python via pyenv for better version management
brew install pyenv
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc.local.template
echo 'eval "$(pyenv init -)"' >> ~/.zshrc.local.template

# Install latest Python
PYTHON_VERSION=$(pyenv install --list | grep -v - | grep -v b | tail -1 | xargs)
pyenv install "$PYTHON_VERSION" || true
pyenv global "$PYTHON_VERSION"

# Install Python development tools
pip install --upgrade pip
pip install black ruff isort pytest mypy
pip install basedpyright  # For VS Code Python LSP

# Install Rust and Cargo
echo -e "${YELLOW}Installing Rust and Cargo...${NC}"
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
fi

# Update Rust
rustup update

# Install Rust development tools
cargo install cargo-edit cargo-watch cargo-tree

# Install Go
echo -e "${YELLOW}Installing Go...${NC}"
brew install go

# Install Go tools
echo -e "${YELLOW}Installing Go development tools...${NC}"
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Install Java (OpenJDK)
echo -e "${YELLOW}Installing Java (OpenJDK)...${NC}"
brew install openjdk@17
brew install maven gradle

# Install C/C++ tools
echo -e "${YELLOW}Installing C/C++ development tools...${NC}"
brew install llvm cmake ninja
brew install clang-format

# Install JavaScript/TypeScript tools
echo -e "${YELLOW}Installing JavaScript/TypeScript development tools...${NC}"
npm install -g typescript
npm install -g @typescript-eslint/eslint-plugin @typescript-eslint/parser
npm install -g prettier
npm install -g eslint
npm install -g ts-node

# Install language servers
echo -e "${YELLOW}Installing language servers...${NC}"

# TypeScript Language Server
npm install -g typescript-language-server

# Bash Language Server
npm install -g bash-language-server

# YAML Language Server
npm install -g yaml-language-server

# Docker tools
echo -e "${YELLOW}Installing Docker development tools...${NC}"
brew install docker docker-compose
brew install --cask docker

# Install configuration file tools
echo -e "${YELLOW}Installing configuration file tools...${NC}"
brew install yq  # YAML processor
brew install jq  # JSON processor
npm install -g @taplo/cli  # TOML formatter and LSP

# Install Git tools
echo -e "${YELLOW}Installing additional Git tools...${NC}"
brew install git-flow git-lfs
brew install gh  # GitHub CLI

# Install database tools (optional but useful)
echo -e "${YELLOW}Installing database tools...${NC}"
brew install postgresql@15 redis
brew services start postgresql@15
brew services start redis

# Install browsers and essential apps
echo -e "${YELLOW}Installing browsers and essential applications...${NC}"
brew install --cask google-chrome

# Install other useful development tools
echo -e "${YELLOW}Installing additional development tools...${NC}"
brew install ripgrep fd fzf bat exa
brew install tree htop
brew install curl wget

# Install SSH and networking tools
echo -e "${YELLOW}Installing SSH and networking tools...${NC}"
brew install openssh
brew install mosh  # Mobile shell

# Update shell configuration
echo -e "${YELLOW}Updating shell configuration...${NC}"

# Add paths to shell configuration
SHELL_CONFIG="$HOME/.zshrc.local.template"
if [ ! -f "$SHELL_CONFIG" ]; then
    touch "$SHELL_CONFIG"
fi

# Add Go path
echo 'export GOPATH=$HOME/go' >> "$SHELL_CONFIG"
echo 'export PATH=$GOPATH/bin:$PATH' >> "$SHELL_CONFIG"

# Add Cargo path
echo 'export PATH=$HOME/.cargo/bin:$PATH' >> "$SHELL_CONFIG"

# Add Java path (for macOS)
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> "$SHELL_CONFIG"

# Add LLVM path
echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"' >> "$SHELL_CONFIG"

echo -e "${GREEN}✓ All development tools installed successfully!${NC}"
echo ""
echo -e "${BLUE}Installed tools summary:${NC}"
echo -e "• Python: $(python3 --version 2>/dev/null || echo 'Installation pending')"
echo -e "• Node.js: $(node --version 2>/dev/null || echo 'Installation pending')"
echo -e "• Rust: $(rustc --version 2>/dev/null || echo 'Installation pending')"
echo -e "• Go: $(go version 2>/dev/null || echo 'Installation pending')"
echo -e "• Java: $(java --version 2>/dev/null | head -1 || echo 'Installation pending')"
echo ""
echo -e "${YELLOW}Note: Please restart your terminal or run 'source ~/.zshrc' to use the new tools.${NC}"
echo -e "${YELLOW}Note: Some VS Code extensions may need to be installed manually.${NC}"
