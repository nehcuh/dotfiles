#!/bin/bash
# Setup development tools for specific languages

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up development tools...${NC}"

# Python development tools
if command -v python3 >/dev/null 2>&1; then
    echo -e "${YELLOW}Setting up Python development tools...${NC}"
    
    # Install pipx if not exists
    if ! command -v pipx >/dev/null 2>&1; then
        python3 -m pip install --user pipx
        python3 -m pipx ensurepath
    fi
    
    # Install Python tools via pipx
    pipx install black
    pipx install isort
    pipx install flake8
    pipx install mypy
    pipx install poetry
    
    echo -e "${GREEN}✓ Python tools installed${NC}"
fi

# Node.js development tools
if command -v npm >/dev/null 2>&1; then
    echo -e "${YELLOW}Setting up Node.js development tools...${NC}"
    
    npm install -g \
        prettier \
        eslint \
        typescript \
        ts-node \
        @typescript-eslint/parser \
        @typescript-eslint/eslint-plugin
    
    echo -e "${GREEN}✓ Node.js tools installed${NC}"
fi

# Rust development tools
if command -v cargo >/dev/null 2>&1; then
    echo -e "${YELLOW}Setting up Rust development tools...${NC}"
    
    # Install common Rust tools
    cargo install \
        cargo-watch \
        cargo-edit \
        cargo-outdated \
        cargo-audit \
        cargo-expand
    
    echo -e "${GREEN}✓ Rust tools installed${NC}"
fi

# Go development tools
if command -v go >/dev/null 2>&1; then
    echo -e "${YELLOW}Setting up Go development tools...${NC}"
    
    go install golang.org/x/tools/gopls@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    go install github.com/air-verse/air@latest
    
    echo -e "${GREEN}✓ Go tools installed${NC}"
fi

# Java development tools (if using SDKMAN)
if [ -d "$HOME/.sdkman" ]; then
    echo -e "${YELLOW}Setting up Java development tools...${NC}"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    # Install latest Java versions
    sdk install java 17.0.9-tem
    sdk install java 21.0.1-tem
    sdk install maven
    sdk install gradle
    
    echo -e "${GREEN}✓ Java tools installed${NC}"
fi

echo -e "${GREEN}🎉 Development tools setup complete!${NC}"