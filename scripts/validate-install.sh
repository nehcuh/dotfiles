#!/bin/bash
# Validation script to check if installation was successful

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Validating Dotfiles Installation${NC}"
echo "===================================="

# Check if dotfiles are properly stowed
echo -e "${YELLOW}📂 Checking stowed files...${NC}"
stowed_files=(
    "$HOME/.zshrc"
    "$HOME/.gitconfig"
    "$HOME/.config/starship.toml"
)

for file in "${stowed_files[@]}"; do
    if [ -L "$file" ]; then
        echo -e "${GREEN}✓ $file is properly linked${NC}"
    elif [ -f "$file" ]; then
        echo -e "${YELLOW}⚠ $file exists but is not a symlink${NC}"
    else
        echo -e "${RED}✗ $file not found${NC}"
    fi
done

# Check if tools are installed
echo -e "${YELLOW}🛠️ Checking installed tools...${NC}"
tools=(
    "zsh"
    "git"
    "stow"
    "starship"
    "eza"
    "bat"
    "ripgrep"
    "fd"
    "fzf"
    "zoxide"
)

for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$(command -v "$tool" --version 2>/dev/null | head -1 || echo "installed")
        echo -e "${GREEN}✓ $tool: $version${NC}"
    else
        echo -e "${RED}✗ $tool not found${NC}"
    fi
done

# Check Python environment
echo -e "${YELLOW}🐍 Checking Python environment...${NC}"
if command -v pyenv >/dev/null 2>&1; then
    echo -e "${GREEN}✓ pyenv installed${NC}"
    pyenv versions | head -3
else
    echo -e "${RED}✗ pyenv not found${NC}"
fi

if command -v uv >/dev/null 2>&1; then
    echo -e "${GREEN}✓ uv installed${NC}"
else
    echo -e "${RED}✗ uv not found${NC}"
fi

# Check Node.js environment
echo -e "${YELLOW}🟢 Checking Node.js environment...${NC}"
if [ -d "$HOME/.nvm" ]; then
    echo -e "${GREEN}✓ nvm installed${NC}"
    if command -v node >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Node.js: $(node --version)${NC}"
    fi
else
    echo -e "${RED}✗ nvm not found${NC}"
fi

# Check shell configuration
echo -e "${YELLOW}🐚 Checking shell configuration...${NC}"
if [ "$SHELL" = "$(which zsh)" ]; then
    echo -e "${GREEN}✓ Zsh is default shell${NC}"
else
    echo -e "${YELLOW}⚠ Default shell is not zsh: $SHELL${NC}"
fi

if [ -d "$HOME/.local/share/zinit" ]; then
    echo -e "${GREEN}✓ Zinit installed${NC}"
else
    echo -e "${RED}✗ Zinit not found${NC}"
fi

echo ""
echo -e "${BLUE}🎯 Validation completed!${NC}"
echo -e "${YELLOW}If you see any red ✗ marks, you may need to run the installation again.${NC}"