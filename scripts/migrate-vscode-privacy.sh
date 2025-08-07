#!/bin/bash
# VS Code Privacy Migration Script
# This script helps migrate existing VS Code sensitive data to the dotfiles structure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}VS Code Privacy Migration Script${NC}"
echo -e "${YELLOW}This script will help you migrate VS Code sensitive data to the privacy-protected structure${NC}"
echo ""

# Get the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
VSCODE_PRIVACY_DIR="$DOTFILES_DIR/stow-packs/vscode-privacy/home"

# Check if the privacy directory exists
if [ ! -d "$VSCODE_PRIVACY_DIR" ]; then
    echo -e "${RED}Error: VS Code privacy directory not found: $VSCODE_PRIVACY_DIR${NC}"
    exit 1
fi

# Function to backup and migrate VS Code data
migrate_vscode_data() {
    local src_dir="$1"
    local dest_dir="$2"
    local description="$3"
    
    if [ -d "$src_dir" ]; then
        echo -e "${YELLOW}Migrating $description...${NC}"
        
        # Create backup
        local backup_dir="${src_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$src_dir" "$backup_dir"
        echo -e "${GREEN}✓ Backup created: $backup_dir${NC}"
        
        # Copy privacy settings to the destination
        if [ -f "$VSCODE_PRIVACY_DIR/.vscode_privacy_settings.json" ]; then
            cp "$VSCODE_PRIVACY_DIR/.vscode_privacy_settings.json" "$dest_dir/settings.json"
            echo -e "${GREEN}✓ Privacy settings applied to: $dest_dir/settings.json${NC}"
        fi
        
        # Clean up sensitive data
        rm -rf "$src_dir/globalStorage" 2>/dev/null || true
        rm -rf "$src_dir/workspaceStorage" 2>/dev/null || true
        rm -f "$src_dir/CloudSettings" 2>/dev/null || true
        
        echo -e "${GREEN}✓ Sensitive data cleaned from $description${NC}"
        echo ""
    fi
}

# Function to create .vscodeignore file
create_vscodeignore() {
    local vscodeignore_path="$HOME/.vscodeignore"
    if [ ! -f "$vscodeignore_path" ]; then
        echo -e "${YELLOW}Creating .vscodeignore file...${NC}"
        cat > "$vscodeignore_path" << 'EOF'
# Ignore sensitive files and directories
node_modules/
dist/
build/
.env
.env.local
.env.*.local
*.log
*.tmp
*.temp
.DS_Store
Thumbs.db
.vscode/
.vscode-test/
coverage/
.nyc_output/
.cache/
*.pyc
__pycache__/
*.class
*.jar
*.war
*.ear
*.zip
*.tar.gz
*.rar
.git/
.svn/
.hg/
CVS/
EOF
        echo -e "${GREEN}✓ Created .vscodeignore file${NC}"
        echo ""
    fi
}

# Migrate VS Code configuration
if [ -d "$HOME/.config/Code" ]; then
    migrate_vscode_data "$HOME/.config/Code/User" "$HOME/.config/Code/User" "VS Code User configuration"
fi

# Migrate VS Code Insiders configuration
if [ -d "$HOME/.config/Code - Insiders" ]; then
    migrate_vscode_data "$HOME/.config/Code - Insiders/User" "$HOME/.config/Code - Insiders/User" "VS Code Insiders User configuration"
fi

# Migrate macOS VS Code data
if [ -d "$HOME/Library/Application Support/Code" ]; then
    migrate_vscode_data "$HOME/Library/Application Support/Code/User" "$HOME/Library/Application Support/Code/User" "macOS VS Code User data"
fi

# Create .vscodeignore file
create_vscodeignore

# Apply stow configuration
echo -e "${YELLOW}Applying VS Code privacy configuration...${NC}"
cd "$DOTFILES_DIR"
stow -d stow-packs -t ~ vscode-privacy
echo -e "${GREEN}✓ VS Code privacy configuration applied${NC}"
echo ""

# Add source line to shell rc files
echo -e "${YELLOW}Setting up shell configuration...${NC}"

# Add to .bashrc if not exists
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "source.*vscode_privacy_config" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Source VS Code privacy configuration" >> "$HOME/.bashrc"
        echo "source \"$VSCODE_PRIVACY_DIR/.vscode_privacy_config\"" >> "$HOME/.bashrc"
        echo -e "${GREEN}✓ Added to .bashrc${NC}"
    fi
fi

# Add to .zshrc if not exists
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "source.*vscode_privacy_config" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Source VS Code privacy configuration" >> "$HOME/.zshrc"
        echo "source \"$VSCODE_PRIVACY_DIR/.vscode_privacy_config\"" >> "$HOME/.zshrc"
        echo -e "${GREEN}✓ Added to .zshrc${NC}"
    fi
fi

echo -e "${GREEN}Migration completed!${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo -e "  • VS Code sensitive data has been backed up"
echo -e "  • Privacy settings have been applied"
echo -e "  • Sensitive data has been cleaned from original locations"
echo -e "  • Configuration has been added to your shell rc files"
echo ""
echo -e "${BLUE}To use the new configuration:${NC}"
echo -e "  1. Restart your shell or run: source ~/.bashrc (or source ~/.zshrc)"
echo -e "  2. Restart VS Code to apply privacy settings"
echo -e "  3. Use the provided aliases: code-safe, code-private"
echo ""
echo -e "${YELLOW}Available commands:${NC}"
echo -e "  • code_clean_cache - Clean VS Code cache"
echo -e "  • code_reset_extensions - Reset VS Code extensions"
echo -e "  • code_show_privacy_status - Show privacy status"
echo ""
echo -e "${YELLOW}Note: This configuration prioritizes privacy over some convenience features${NC}"