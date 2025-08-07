#!/bin/bash
# User Home Directory Migration Script
# This script helps migrate existing user files to the dotfiles structure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}User Home Directory Migration Script${NC}"
echo -e "${YELLOW}This script will organize your user files into the dotfiles structure${NC}"
echo ""

# Get the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
USER_HOME_DIR="$DOTFILES_DIR/stow-packs/user-home"

# Check if the user-home directory exists
if [ ! -d "$USER_HOME_DIR" ]; then
    echo -e "${RED}Error: User home directory not found: $USER_HOME_DIR${NC}"
    exit 1
fi

# Function to backup and migrate file
migrate_file() {
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
        return 0
    fi
    return 1
}

# Function to create directory if it doesn't exist
create_dir_if_not_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "${GREEN}✓ Created directory: $dir${NC}"
    fi
}

# Function to setup shell configuration
setup_shell_config() {
    local config_file="$1"
    local source_file="$2"
    
    if [ -f "$config_file" ]; then
        echo -e "${YELLOW}Setting up $config_file...${NC}"
        
        # Backup existing config
        cp "$config_file" "${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Create new config that sources our dotfiles
        cat > "$config_file" << EOF
# Managed by dotfiles - Do not edit directly
# Source user configuration from dotfiles
source "$source_file"

# Local configuration (if any)
if [ -f "${config_file}.local" ]; then
    source "${config_file}.local"
fi
EOF
        echo -e "${GREEN}✓ Updated $config_file${NC}"
    fi
}

echo -e "${CYAN}=== Migration Plan ===${NC}"
echo ""

# Create necessary directories
create_dir_if_not_exists "$USER_HOME_DIR/home/config"
create_dir_if_not_exists "$USER_HOME_DIR/home/history"
create_dir_if_not_exists "$USER_HOME_DIR/home/cache"
create_dir_if_not_exists "$USER_HOME_DIR/home/appdata"

echo -e "${CYAN}=== Migrating Shell Configuration Files ===${NC}"
echo ""

# Migrate shell configuration files
setup_shell_config "$HOME/.bashrc" "$USER_HOME_DIR/home/config/.bashrc"
setup_shell_config "$HOME/.bash_profile" "$USER_HOME_DIR/home/config/.bash_profile"
setup_shell_config "$HOME/.bash_logout" "$USER_HOME_DIR/home/config/.bash_logout"
setup_shell_config "$HOME/.profile" "$USER_HOME_DIR/home/config/.profile"

# Setup Python configuration
if [ -f "$HOME/.pythonrc" ]; then
    migrate_file "$HOME/.pythonrc" "$USER_HOME_DIR/home/config/.pythonrc" "Python configuration"
fi

echo -e "${CYAN}=== Migrating History Files ===${NC}"
echo ""

# Migrate history files
migrate_file "$HOME/.bash_history" "$USER_HOME_DIR/home/history/.bash_history" "bash history"
migrate_file "$HOME/.zsh_history" "$USER_HOME_DIR/home/history/.zsh_history" "zsh history"
migrate_file "$HOME/.history" "$USER_HOME_DIR/home/history/.history" "general history"
migrate_file "$HOME/.histfile" "$USER_HOME_DIR/home/history/.histfile" "histfile"
migrate_file "$HOME/.python_history" "$USER_HOME_DIR/home/history/.python_history" "Python history"
migrate_file "$HOME/.node_repl_history" "$USER_HOME_DIR/home/history/.node_repl_history" "Node.js REPL history"
migrate_file "$HOME/.irb_history" "$USER_HOME_DIR/home/history/.irb_history" "Ruby IRB history"

echo -e "${CYAN}=== Migrating Cache Files ===${NC}"
echo ""

# Migrate cache files
migrate_file "$HOME/.zcompdump" "$USER_HOME_DIR/home/cache/.zcompdump" "Zsh completion cache"
migrate_file "$HOME/.z" "$USER_HOME_DIR/home/cache/.z" "directory jump history"
migrate_file "$HOME/.sudo_as_admin_successful" "$USER_HOME_DIR/home/cache/.sudo_as_admin_successful" "sudo admin marker"
migrate_file "$HOME/.lesshst" "$USER_HOME_DIR/home/cache/.lesshst" "less history"
migrate_file "$HOME/.wget-hsts" "$USER_HOME_DIR/home/cache/.wget-hsts" "wget HSTS database"

echo -e "${CYAN}=== Applying Stow Configuration ===${NC}"
echo ""

# Apply stow configuration
cd "$DOTFILES_DIR"
if stow -d stow-packs -t ~ user-home -v; then
    echo -e "${GREEN}✓ Stow configuration applied successfully${NC}"
else
    echo -e "${RED}✗ Failed to apply stow configuration${NC}"
    exit 1
fi

echo -e "${CYAN}=== Setting Up Environment Variables ===${NC}"
echo ""

# Set environment variables for history files
cat >> "$HOME/.profile.local" << 'EOF'

# User home directory management
export HISTFILE="$HOME/.zsh_history"
export BASH_HISTFILE="$HOME/.bash_history"
export PYTHONHISTFILE="$HOME/.python_history"
export NODE_REPL_HISTORY="$HOME/.node_repl_history"
export IRB_HISTORY="$HOME/.irb_history"

# XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
EOF

echo -e "${GREEN}✓ Environment variables configured${NC}"

echo -e "${CYAN}=== Migration Summary ===${NC}"
echo ""
echo -e "${GREEN}Migration completed successfully!${NC}"
echo ""
echo -e "${YELLOW}What was done:${NC}"
echo -e "  • Shell configuration files have been organized"
echo -e "  • History files have been moved to the history directory"
echo -e "  • Cache files have been moved to the cache directory"
echo -e "  • All original files have been backed up"
echo -e "  • Stow configuration has been applied"
echo -e "  • Environment variables have been set"
echo ""
echo -e "${YELLOW}Directory structure:${NC}"
echo -e "  • Configuration files: $USER_HOME_DIR/home/config/"
echo -e "  • History files: $USER_HOME_DIR/home/history/"
echo -e "  • Cache files: $USER_HOME_DIR/home/cache/"
echo -e "  • Application data: $USER_HOME_DIR/home/appdata/"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Restart your shell or run: source ~/.bashrc (or source ~/.zshrc)"
echo -e "  2. Verify that all configurations work correctly"
echo -e "  3. Check that your history is preserved"
echo -e "  4. Review the backup files if needed"
echo ""
echo -e "${YELLOW}Important notes:${NC}"
echo -e "  • All sensitive files are now ignored by git for privacy"
echo -e "  • Configuration files can be safely committed to the repository"
echo -e "  • Local configurations can be added to .local files"
echo -e "  • Backup files are named with timestamps for safety"
echo ""
echo -e "${CYAN}To manage your files:${NC}"
echo -e "  • Apply configuration: stow -d stow-packs -t ~ user-home"
echo -e "  • Remove configuration: stow -d stow-packs -t ~ -D user-home"
echo -e "  • View status: stow -d stow-packs -t ~ user-home -v"
echo ""
echo -e "${GREEN}🎉 Your home directory is now organized and managed by dotfiles!${NC}"