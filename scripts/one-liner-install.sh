#!/bin/bash
# One-liner installer for dotfiles
# This script downloads and runs the smart universal installer

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Dotfiles One-Liner Installer${NC}"
echo -e "${BLUE}==============================${NC}"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo -e "${YELLOW}Downloading smart universal installer...${NC}"

# Download the script
if ! curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/smart-universal-install.sh -o smart-universal-install.sh; then
    echo -e "${RED}Failed to download the installer script${NC}"
    exit 1
fi

# Make it executable
chmod +x smart-universal-install.sh

echo -e "${GREEN}Starting dotfiles installation...${NC}"
echo ""

# Run the installer
./smart-universal-install.sh "$@"

# Clean up
cd /
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Installation completed!${NC}"