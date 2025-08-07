#!/bin/bash
# Zed Privacy Migration Script
# This script helps migrate existing Zed sensitive data to the privacy-protected structure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Zed Privacy Migration Script${NC}"
echo -e "${YELLOW}This script will help you migrate Zed sensitive data to the privacy-protected structure${NC}"
echo ""

# Get the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
ZED_PRIVACY_DIR="$DOTFILES_DIR/stow-packs/zed-privacy/home"

# Check if the privacy directory exists
if [ ! -d "$ZED_PRIVACY_DIR" ]; then
    echo -e "${RED}Error: Zed privacy directory not found: $ZED_PRIVACY_DIR${NC}"
    exit 1
fi

# Function to backup and migrate Zed data
migrate_zed_data() {
    local src_dir="$1"
    local dest_dir="$2"
    local description="$3"
    
    if [ -d "$src_dir" ]; then
        echo -e "${YELLOW}Migrating $description...${NC}"
        
        # Create backup
        local backup_dir="${src_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$src_dir" "$backup_dir"
        echo -e "${GREEN}✓ Backup created: $backup_dir${NC}"
        
        # Apply privacy settings
        if [ -f "$ZED_PRIVACY_DIR/.zed_privacy_settings.json" ]; then
            mkdir -p "$dest_dir"
            cp "$ZED_PRIVACY_DIR/.zed_privacy_settings.json" "$dest_dir/config.json"
            echo -e "${GREEN}✓ Privacy settings applied to: $dest_dir/config.json${NC}"
        fi
        
        # Clean up sensitive data
        rm -rf "$src_dir/state" 2>/dev/null || true
        rm -rf "$src_dir/sessions" 2>/dev/null || true
        rm -rf "$src_dir/backups" 2>/dev/null || true
        rm -f "$src_dir/history" 2>/dev/null || true
        rm -f "$src_dir/recent" 2>/dev/null || true
        
        echo -e "${GREEN}✓ Sensitive data cleaned from $description${NC}"
        echo ""
    fi
}

# Function to clean up Zed files
cleanup_zed_files() {
    echo -e "${YELLOW}Cleaning up Zed files...${NC}"
    
    # Clean up history file
    if [ -f "$HOME/.zed-history" ]; then
        local backup_file="$HOME/.zed-history.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.zed-history" "$backup_file"
        rm -f "$HOME/.zed-history"
        echo -e "${GREEN}✓ History file backed up and removed${NC}"
    fi
    
    # Clean up session files
    if [ -d "$HOME/.zed-sessions" ]; then
        local backup_dir="$HOME/.zed-sessions.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$HOME/.zed-sessions" "$backup_dir"
        rm -rf "$HOME/.zed-sessions"
        echo -e "${GREEN}✓ Session directory backed up and removed${NC}"
    fi
    
    # Clean up state files
    if [ -d "$HOME/.zed-state" ]; then
        local backup_dir="$HOME/.zed-state.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$HOME/.zed-state" "$backup_dir"
        rm -rf "$HOME/.zed-state"
        echo -e "${GREEN}✓ State directory backed up and removed${NC}"
    fi
    
    # Clean up temporary files
    if [ -d "$HOME/.zed-temp" ]; then
        rm -rf "$HOME/.zed-temp"
        echo -e "${GREEN}✓ Temporary directory removed${NC}"
    fi
    
    # Clean up backup files
    if [ -d "$HOME/.zed-backup" ]; then
        rm -rf "$HOME/.zed-backup"
        echo -e "${GREEN}✓ Backup directory removed${NC}"
    fi
    
    echo ""
}

# Migrate Zed configuration (Linux)
if [ -d "$HOME/.config/zed" ]; then
    migrate_zed_data "$HOME/.config/zed" "$HOME/.config/zed" "Zed configuration (Linux)"
fi

# Migrate Zed data (macOS)
if [ -d "$HOME/Library/Application Support/Zed" ]; then
    migrate_zed_data "$HOME/Library/Application Support/Zed" "$HOME/Library/Application Support/Zed" "Zed data (macOS)"
fi

# Clean up Zed files
cleanup_zed_files

# Apply stow configuration
echo -e "${YELLOW}Applying Zed privacy configuration...${NC}"
cd "$DOTFILES_DIR"
stow -d stow-packs -t ~ zed-privacy
echo -e "${GREEN}✓ Zed privacy configuration applied${NC}"
echo ""

# Add source line to shell rc files
echo -e "${YELLOW}Setting up shell configuration...${NC}"

# Add to .bashrc if not exists
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "source.*zed_privacy_config" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Source Zed privacy configuration" >> "$HOME/.bashrc"
        echo "source \"$ZED_PRIVACY_DIR/.zed_privacy_config\"" >> "$HOME/.bashrc"
        echo -e "${GREEN}✓ Added to .bashrc${NC}"
    fi
fi

# Add to .zshrc if not exists
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "source.*zed_privacy_config" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Source Zed privacy configuration" >> "$HOME/.zshrc"
        echo "source \"$ZED_PRIVACY_DIR/.zed_privacy_config\"" >> "$HOME/.zshrc"
        echo -e "${GREEN}✓ Added to .zshrc${NC}"
    fi
fi

echo -e "${GREEN}Migration completed!${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo -e "  • Zed sensitive data has been backed up"
echo -e "  • Privacy settings have been applied"
echo -e "  • Sensitive data has been cleaned from original locations"
echo -e "  • Configuration has been added to your shell rc files"
echo ""
echo -e "${BLUE}To use the new configuration:${NC}"
echo -e "  1. Restart your shell or run: source ~/.bashrc (or source ~/.zshrc)"
echo -e "  2. Restart Zed to apply privacy settings"
echo -e "  3. Use the provided aliases: zed-safe, zed-private, zed-offline"
echo ""
echo -e "${YELLOW}Available commands:${NC}"
echo -e "  • zed_clean_cache - Clean Zed cache"
echo -e "  • zed_reset_config - Reset Zed configuration"
echo -e "  • zed_clean_data - Clean Zed data"
echo -e "  • zed_show_privacy_status - Show privacy status"
echo -e "  • zed_privacy_check - Check privacy settings"
echo ""
echo -e "${YELLOW}Environment variables:${NC}"
echo -e "  • ZED_TELEMETRY_DISABLED=1"
echo -e "  • ZED_AUTO_UPDATE=0"
echo -e "  • ZED_DIAGNOSTICS=0"
echo -e "  • ZED_COLLABORATION=0"
echo ""
echo -e "${YELLOW}Note: This configuration prioritizes privacy over some convenience features${NC}"