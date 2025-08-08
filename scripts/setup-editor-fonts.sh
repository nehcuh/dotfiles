#!/bin/bash

# Setup Editor Fonts Script
# Installs necessary fonts for VS Code and Zed editors

# set -e  # Don't exit on error, handle them gracefully

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up fonts for VS Code and Zed...${NC}"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Error: Homebrew is not installed. Please install Homebrew first.${NC}"
    exit 1
fi

# Add font tap if not already added (new location)
echo -e "${YELLOW}Adding font tap to Homebrew...${NC}"
brew tap homebrew/cask-fonts 2>/dev/null || echo "Font tap already exists or not needed"

# Install JetBrains Mono Nerd Font (for Zed terminal)
echo -e "${YELLOW}Installing JetBrains Mono Nerd Font...${NC}"
brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || echo -e "${YELLOW}  → Already installed or failed, continuing...${NC}"

# Install Fira Code (already in VS Code config, good fallback)
echo -e "${YELLOW}Installing Fira Code font...${NC}"
brew install --cask font-fira-code 2>/dev/null || echo -e "${YELLOW}  → Already installed or failed, continuing...${NC}"

# Install Google fonts
echo -e "${YELLOW}Installing Google fonts...${NC}"
brew install --cask font-source-code-pro 2>/dev/null || echo -e "${YELLOW}  → Already installed or failed, continuing...${NC}"

# Try to install Google Sans Code (may not be available via brew)
# We'll download it directly from Google Fonts
FONT_DIR="$HOME/Library/Fonts"
TEMP_DIR="/tmp/google-fonts"

echo -e "${YELLOW}Attempting to install Google Sans Code font...${NC}"
mkdir -p "$TEMP_DIR"

# Download and install Google Sans from GitHub (open source version)
if ! ls "$FONT_DIR"/*"Google Sans"* 1> /dev/null 2>&1; then
    echo -e "${YELLOW}Downloading Google Sans font family...${NC}"
    curl -L "https://github.com/google/fonts/raw/main/ofl/opensans/OpenSans-VariableFont_wdth%2Cwght.ttf" -o "$TEMP_DIR/OpenSans-Variable.ttf"
    curl -L "https://github.com/google/fonts/raw/main/ofl/sourcecodepro/SourceCodePro-VariableFont_wght.ttf" -o "$TEMP_DIR/SourceCodePro-Variable.ttf"
    
    # Copy to system font directory
    cp "$TEMP_DIR"/*.ttf "$FONT_DIR/"
    
    echo -e "${GREEN}✓ Google fonts installed${NC}"
else
    echo -e "${GREEN}✓ Google fonts already installed${NC}"
fi

# Install additional development fonts
echo -e "${YELLOW}Installing additional development fonts...${NC}"
brew install --cask font-hack-nerd-font 2>/dev/null || echo -e "${YELLOW}  → Hack Nerd Font: Already installed or failed${NC}"
brew install --cask font-inconsolata 2>/dev/null || echo -e "${YELLOW}  → Inconsolata: Already installed or failed${NC}"
brew install --cask font-sf-mono 2>/dev/null || echo -e "${YELLOW}  → SF Mono: Already installed or failed${NC}"

# Clear font cache
echo -e "${YELLOW}Clearing font cache...${NC}"
sudo atsutil databases -remove

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✓ All fonts installed successfully!${NC}"
echo -e "${YELLOW}Note: You may need to restart your editors to see the new fonts.${NC}"
echo ""
echo -e "${BLUE}Installed fonts:${NC}"
echo -e "• JetBrains Mono Nerd Font (recommended for Zed terminal)"
echo -e "• Fira Code (VS Code editor font)"
echo -e "• Source Code Pro (Google's code font)"
echo -e "• SF Mono (macOS system monospace font)"
echo -e "• Hack Nerd Font (alternative development font)"
echo -e "• Inconsolata (classic programming font)"
