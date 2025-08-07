#!/bin/bash
# Test script for Linux installation functionality

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Testing Linux installation functionality...${NC}"

# Test 1: Check if script can detect Linux platform
echo -e "${YELLOW}Test 1: Platform detection${NC}"
OS="$(uname -s)"
if [ "$OS" = "Linux" ]; then
    echo -e "${GREEN}✓ Platform detected as Linux${NC}"
    
    # Detect distro
    if [ -f /etc/os-release ]; then
        DISTRO=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
        echo -e "${GREEN}✓ Distribution detected as $DISTRO${NC}"
    else
        echo -e "${YELLOW}⚠ Could not detect specific distribution${NC}"
    fi
else
    echo -e "${RED}✗ Not running on Linux (detected: $OS)${NC}"
    exit 1
fi

# Test 2: Check if required commands are available
echo -e "${YELLOW}Test 2: Required commands${NC}"
REQUIRED_COMMANDS=("curl" "sudo" "grep" "tee")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ $cmd is available${NC}"
    else
        echo -e "${RED}✗ $cmd is not available${NC}"
    fi
done

# Test 3: Check if we can test sudo access
echo -e "${YELLOW}Test 3: Sudo access${NC}"
if sudo -n true 2>/dev/null; then
    echo -e "${GREEN}✓ Sudo access is available${NC}"
else
    echo -e "${YELLOW}⚠ Sudo access requires password (this is normal)${NC}"
fi

# Test 4: Check package manager availability
echo -e "${YELLOW}Test 4: Package manager detection${NC}"
if command -v apt >/dev/null 2>&1; then
    echo -e "${GREEN}✓ apt package manager is available${NC}"
elif command -v dnf >/dev/null 2>&1; then
    echo -e "${GREEN}✓ dnf package manager is available${NC}"
elif command -v pacman >/dev/null 2>&1; then
    echo -e "${GREEN}✓ pacman package manager is available${NC}"
else
    echo -e "${YELLOW}⚠ No known package manager detected${NC}"
fi

# Test 5: Check if editors are already installed
echo -e "${YELLOW}Test 5: Editor status${NC}"
if command -v code >/dev/null 2>&1; then
    echo -e "${GREEN}✓ VS Code is already installed${NC}"
    code --version
else
    echo -e "${YELLOW}⚠ VS Code is not installed (will be installed by main script)${NC}"
fi

if command -v zed >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Zed is already installed${NC}"
    zed --version
else
    echo -e "${YELLOW}⚠ Zed is not installed (will be installed by main script)${NC}"
fi

if command -v brew >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Homebrew is already installed${NC}"
    brew --version
else
    echo -e "${YELLOW}⚠ Homebrew is not installed (will be installed by main script)${NC}"
fi

# Test 6: Check if installation script exists and is executable
echo -e "${YELLOW}Test 6: Installation script${NC}"
if [ -f "./scripts/install-unified.sh" ]; then
    echo -e "${GREEN}✓ Installation script exists${NC}"
    if [ -x "./scripts/install-unified.sh" ]; then
        echo -e "${GREEN}✓ Installation script is executable${NC}"
    else
        echo -e "${YELLOW}⚠ Installation script is not executable${NC}"
        chmod +x ./scripts/install-unified.sh
        echo -e "${GREEN}✓ Made installation script executable${NC}"
    fi
else
    echo -e "${RED}✗ Installation script not found${NC}"
    exit 1
fi

echo -e "${BLUE}Test completed!${NC}"
echo -e "${YELLOW}To run the full installation, execute:${NC}"
echo -e "${CYAN}./scripts/install-unified.sh${NC}"