#!/bin/bash
# Shell history migration script
# This script helps migrate existing shell history files to the dotfiles structure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Shell History Migration Script${NC}"
echo -e "${YELLOW}This script will migrate your shell history files to the dotfiles structure${NC}"
echo ""

# Get the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
HISTORY_DIR="$DOTFILES_DIR/stow-packs/shell-history/home"

# Check if the history directory exists
if [ ! -d "$HISTORY_DIR" ]; then
    echo -e "${RED}Error: History directory not found: $HISTORY_DIR${NC}"
    exit 1
fi

# Function to backup and migrate history file
migrate_history_file() {
    local src_file="$1"
    local dest_file="$2"
    local description="$3"
    
    if [ -f "$src_file" ]; then
        echo -e "${YELLOW}Migrating $description...${NC}"
        
        # Create backup
        local backup_file="${src_file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$src_file" "$backup_file"
        echo -e "${GREEN}✓ Backup created: $backup_file${NC}"
        
        # Copy to dotfiles location
        cp "$src_file" "$dest_file"
        echo -e "${GREEN}✓ Copied to: $dest_file${NC}"
        
        # Remove original file
        rm "$src_file"
        echo -e "${GREEN}✓ Original file removed${NC}"
        
        echo ""
    fi
}

# Migrate bash history
migrate_history_file "$HOME/.bash_history" "$HISTORY_DIR/.bash_history" "bash history"

# Migrate zsh history
migrate_history_file "$HOME/.zsh_history" "$HISTORY_DIR/.zsh_history" "zsh history"

# Migrate other common history files
migrate_history_file "$HOME/.history" "$HISTORY_DIR/.history" "general history file"
migrate_history_file "$HOME/.histfile" "$HISTORY_DIR/.histfile" "histfile"

# Check if we need to source the shell history config
echo -e "${YELLOW}Setting up shell history configuration...${NC}"

# Add source line to .bashrc if not exists
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "source.*\.shell_history_config" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Source shell history configuration" >> "$HOME/.bashrc"
        echo "source \"$DOTFILES_DIR/stow-packs/shell-history/home/.shell_history_config\"" >> "$HOME/.bashrc"
        echo -e "${GREEN}✓ Added to .bashrc${NC}"
    fi
fi

# Add source line to .zshrc if not exists
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "source.*\.shell_history_config" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Source shell history configuration" >> "$HOME/.zshrc"
        echo "source \"$DOTFILES_DIR/stow-packs/shell-history/home/.shell_history_config\"" >> "$HOME/.zshrc"
        echo -e "${GREEN}✓ Added to .zshrc${NC}"
    fi
fi

echo -e "${GREEN}Migration completed!${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo -e "  • Shell history files have been moved to the dotfiles structure"
echo -e "  • Original files have been backed up"
echo -e "  • Configuration has been added to your shell rc files"
echo ""
echo -e "${BLUE}To use the new configuration:${NC}"
echo -e "  1. Restart your shell or run: source ~/.bashrc (or source ~/.zshrc)"
echo -e "  2. Your history will now be managed through the dotfiles structure"
echo ""
echo -e "${YELLOW}Note: The actual history files are ignored by git to protect your privacy${NC}"