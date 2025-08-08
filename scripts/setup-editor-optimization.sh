#!/bin/bash

# Master Editor and System Optimization Script
# Comprehensive setup for VS Code, Zed, and macOS optimizations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║               Editor and System Optimization Setup                   ║${NC}"
echo -e "${PURPLE}║             VS Code • Zed • macOS System Settings                   ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print section headers
print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to confirm action
confirm() {
    local message="$1"
    local default="${2:-y}"
    
    if [[ "$default" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    while true; do
        read -rp "$message $prompt " response
        response=${response:-$default}
        case "$response" in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * ) echo -e "${YELLOW}Please answer yes or no.${NC}" ;;
        esac
    done
}

print_section "1. Setting up Fonts for Editors"

if confirm "Install fonts (JetBrains Mono Nerd Font, Fira Code, etc.) for VS Code and Zed?"; then
    if [ -f "$SCRIPT_DIR/setup-editor-fonts.sh" ]; then
        echo -e "${YELLOW}Running font installation script...${NC}"
        chmod +x "$SCRIPT_DIR/setup-editor-fonts.sh"
        "$SCRIPT_DIR/setup-editor-fonts.sh"
    else
        echo -e "${RED}Font installation script not found at $SCRIPT_DIR/setup-editor-fonts.sh${NC}"
    fi
else
    echo -e "${YELLOW}Skipping font installation...${NC}"
fi

print_section "2. Installing Development Tools and Language Servers"

if confirm "Install development tools (Python, Rust, Go, Java, Node.js, etc.) and language servers?"; then
    if [ -f "$SCRIPT_DIR/setup-dev-tools.sh" ]; then
        echo -e "${YELLOW}Running development tools installation script...${NC}"
        chmod +x "$SCRIPT_DIR/setup-dev-tools.sh"
        "$SCRIPT_DIR/setup-dev-tools.sh"
    else
        echo -e "${RED}Development tools script not found at $SCRIPT_DIR/setup-dev-tools.sh${NC}"
    fi
else
    echo -e "${YELLOW}Skipping development tools installation...${NC}"
fi

print_section "3. Applying macOS System Optimizations"

if confirm "Apply macOS system optimizations (keyboard, mouse, trackpad settings)?"; then
    if [ -f "$DOTFILES_DIR/stow-packs/macos/home/.config/macos/optimize.sh" ]; then
        echo -e "${YELLOW}Running macOS optimization script...${NC}"
        chmod +x "$DOTFILES_DIR/stow-packs/macos/home/.config/macos/optimize.sh"
        "$DOTFILES_DIR/stow-packs/macos/home/.config/macos/optimize.sh"
    else
        echo -e "${RED}macOS optimization script not found${NC}"
    fi
else
    echo -e "${YELLOW}Skipping macOS optimizations...${NC}"
fi

print_section "4. Installing VS Code Extensions"

if command_exists code && confirm "Install VS Code extensions automatically?"; then
    echo -e "${YELLOW}Installing VS Code extensions...${NC}"
    
    # Read extensions from the JSON file and install them
    EXTENSIONS_FILE="$DOTFILES_DIR/stow-packs/vscode/.config/Code/User/extensions.json"
    if [ -f "$EXTENSIONS_FILE" ]; then
        # Extract extension IDs from JSON and install them
        grep '"' "$EXTENSIONS_FILE" | grep -v '//' | grep -v 'recommendations' | sed 's/.*"\([^"]*\)".*/\1/' | while read -r extension; do
            if [[ "$extension" =~ ^[a-zA-Z0-9\.-]+\.[a-zA-Z0-9\.-]+$ ]]; then
                echo -e "${YELLOW}Installing VS Code extension: $extension${NC}"
                code --install-extension "$extension" --force
            fi
        done
        echo -e "${GREEN}✓ VS Code extensions installed${NC}"
    else
        echo -e "${RED}VS Code extensions file not found${NC}"
    fi
else
    if ! command_exists code; then
        echo -e "${YELLOW}VS Code not found. Please install VS Code first.${NC}"
    else
        echo -e "${YELLOW}Skipping VS Code extension installation...${NC}"
    fi
fi

print_section "5. Applying Stow Configurations"

if confirm "Apply dotfiles configurations using stow (VS Code, Zed, macOS settings)?"; then
    echo -e "${YELLOW}Applying stow configurations...${NC}"
    cd "$DOTFILES_DIR"
    
    # Apply VS Code configuration
    if [ -d "stow-packs/vscode" ]; then
        stow -t "$HOME" stow-packs/vscode
        echo -e "${GREEN}✓ VS Code configuration applied${NC}"
    fi
    
    # Apply Zed configuration
    if [ -d "stow-packs/zed" ]; then
        stow -t "$HOME" stow-packs/zed
        echo -e "${GREEN}✓ Zed configuration applied${NC}"
    fi
    
    # Apply macOS configuration
    if [ -d "stow-packs/macos" ]; then
        stow -t "$HOME" stow-packs/macos
        echo -e "${GREEN}✓ macOS configuration applied${NC}"
    fi
else
    echo -e "${YELLOW}Skipping stow configuration...${NC}"
fi

print_section "6. Final Configuration Steps"

echo -e "${YELLOW}Updating shell configuration...${NC}"
if [ -f "$HOME/.zshrc.local.template" ]; then
    # Create local config if it doesn't exist
    if [ ! -f "$HOME/.zshrc.local" ]; then
        cp "$HOME/.zshrc.local.template" "$HOME/.zshrc.local"
        echo -e "${GREEN}✓ Created local zsh configuration${NC}"
    fi
fi

# Check if basedpyright is available
if command_exists python3; then
    echo -e "${YELLOW}Checking basedpyright installation...${NC}"
    if ! python3 -c "import basedpyright" 2>/dev/null; then
        echo -e "${YELLOW}Installing basedpyright for Python LSP...${NC}"
        pip3 install basedpyright
        echo -e "${GREEN}✓ basedpyright installed${NC}"
    else
        echo -e "${GREEN}✓ basedpyright already available${NC}"
    fi
fi

print_section "Setup Complete!"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                       Setup Complete! 🎉                            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Summary of what was configured:${NC}"
echo ""
echo -e "${GREEN}✓ VS Code Configuration:${NC}"
echo -e "  • Multi-language support (Python, Rust, Go, Java, JS/TS, C/C++)"
echo -e "  • basedpyright for Python LSP"
echo -e "  • Docker and SSH extensions"
echo -e "  • Configuration file support (YAML, TOML, INI, XML)"
echo -e "  • Development productivity extensions"
echo ""
echo -e "${GREEN}✓ Zed Configuration:${NC}"
echo -e "  • Google Sans Code for editor font"
echo -e "  • JetBrains Mono Nerd Font for terminal"
echo -e "  • Built-in LSP support for all languages"
echo -e "  • Optimized settings for development"
echo ""
echo -e "${GREEN}✓ macOS System Optimizations:${NC}"
echo -e "  • Fast keyboard repeat rate"
echo -e "  • Trackpad tap-to-click enabled"
echo -e "  • Mouse assistive click support"
echo -e "  • Optimized mouse movement speed"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "1. Restart your terminal or run: source ~/.zshrc"
echo -e "2. Restart VS Code and Zed to apply new settings"
echo -e "3. Some macOS changes may require a system restart"
echo -e "4. Install additional VS Code extensions as needed"
echo ""
echo -e "${BLUE}Happy coding! 🚀${NC}"
