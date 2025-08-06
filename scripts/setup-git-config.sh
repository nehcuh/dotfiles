#!/bin/bash
# Setup platform-specific git configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

OS="$(uname -s)"
DOTFILES_DIR="$HOME/.dotfiles"

echo -e "${BLUE}Setting up platform-specific git configuration...${NC}"

# Remove existing gitconfig if it exists
if [ -f "$HOME/.gitconfig" ]; then
    echo -e "${YELLOW}Removing existing .gitconfig...${NC}"
    rm -f "$HOME/.gitconfig"
fi

# Create appropriate gitconfig based on OS
case "$OS" in
    Darwin)
        echo -e "${YELLOW}Creating macOS git configuration...${NC}"
        cp "$DOTFILES_DIR/stow-packs/git/.platform-specific/.gitconfig_macOS" "$HOME/.gitconfig"
        ;;
    Linux)
        echo -e "${YELLOW}Creating Linux git configuration...${NC}"
        cp "$DOTFILES_DIR/stow-packs/git/.platform-specific/.gitconfig_linux" "$HOME/.gitconfig"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        echo -e "${YELLOW}Creating Windows/Cygwin git configuration...${NC}"
        cp "$DOTFILES_DIR/stow-packs/git/.platform-specific/.gitconfig_cygwin" "$HOME/.gitconfig"
        ;;
    *)
        echo -e "${RED}Unsupported OS: $OS${NC}"
        echo -e "${YELLOW}Using default git configuration...${NC}"
        cp "$DOTFILES_DIR/stow-packs/git/.platform-specific/.gitconfig_linux" "$HOME/.gitconfig"
        ;;
esac

# Create local gitconfig if it doesn't exist
if [ ! -f "$HOME/.gitconfig_local" ]; then
    echo -e "${YELLOW}Creating local git configuration template...${NC}"
    cp "$DOTFILES_DIR/stow-packs/git/.platform-specific/.gitconfig_local.template" "$HOME/.gitconfig_local"
    echo -e "${GREEN}✓ Local git configuration template created${NC}"
    echo -e "${YELLOW}Please edit ~/.gitconfig_local to set your name and email${NC}"
else
    echo -e "${GREEN}✓ Local git configuration already exists${NC}"
fi

echo -e "${GREEN}✓ Git configuration created for $OS${NC}"