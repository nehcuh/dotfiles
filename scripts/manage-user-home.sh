#!/bin/bash
# User Home Directory Management Script
# This script helps manage the user home directory configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
USER_HOME_DIR="$DOTFILES_DIR/stow-packs/user-home"

# Function to show usage
show_usage() {
    echo -e "${CYAN}User Home Directory Management Script${NC}"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  install, apply     Apply the user home directory configuration"
    echo "  remove, delete     Remove the user home directory configuration"
    echo "  status            Show current status of the configuration"
    echo "  clean             Clean up cache and temporary files"
    echo "  backup            Create backup of current user files"
    echo "  restore           Restore from backup"
    echo "  help              Show this help message"
    echo ""
    echo "Options:"
    echo "  -v, --verbose     Show verbose output"
    echo "  -f, --force       Force operation without confirmation"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 install        Install the configuration"
    echo "  $0 status         Check current status"
    echo "  $0 clean          Clean up cache files"
}

# Function to show status
show_status() {
    echo -e "${CYAN}User Home Directory Status${NC}"
    echo ""
    
    # Check if user-home directory exists
    if [ ! -d "$USER_HOME_DIR" ]; then
        echo -e "${RED}✗ User home directory not found: $USER_HOME_DIR${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Configuration directory:${NC}"
    echo -e "  $USER_HOME_DIR"
    echo ""
    
    # Show stow status
    echo -e "${YELLOW}Stow status:${NC}"
    if stow -d stow-packs -t ~ user-home -v 2>/dev/null; then
        echo -e "${GREEN}✓ Configuration is properly applied${NC}"
    else
        echo -e "${RED}✗ Configuration is not applied or has conflicts${NC}"
    fi
    echo ""
    
    # Show file status
    echo -e "${YELLOW}File status:${NC}"
    
    # Configuration files
    echo -e "${CYAN}Configuration files:${NC}"
    for file in .bashrc .bash_profile .bash_logout .profile .pythonrc; do
        if [ -L "$HOME/$file" ]; then
            target=$(readlink -f "$HOME/$file")
            if [[ "$target" == *"$USER_HOME_DIR"* ]]; then
                echo -e "  ${GREEN}✓ $file -> symlinked${NC}"
            else
                echo -e "  ${YELLOW}⚠ $file -> external symlink${NC}"
            fi
        elif [ -f "$HOME/$file" ]; then
            echo -e "  ${RED}✗ $file -> local file (not managed)${NC}"
        else
            echo -e "  ${BLUE}○ $file -> not found${NC}"
        fi
    done
    
    # History files
    echo -e "${CYAN}History files:${NC}"
    for file in .bash_history .zsh_history .history .histfile .python_history .node_repl_history .irb_history; do
        if [ -f "$HOME/$file" ]; then
            size=$(du -h "$HOME/$file" | cut -f1)
            echo -e "  ${GREEN}✓ $file -> exists ($size)${NC}"
        else
            echo -e "  ${BLUE}○ $file -> not found${NC}"
        fi
    done
    
    # Cache files
    echo -e "${CYAN}Cache files:${NC}"
    for file in .zcompdump* .z .sudo_as_admin_successful .lesshst .wget-hsts; do
        if [ -f "$HOME/$file" ]; then
            size=$(du -h "$HOME/$file" | cut -f1)
            echo -e "  ${GREEN}✓ $file -> exists ($size)${NC}"
        else
            echo -e "  ${BLUE}○ $file -> not found${NC}"
        fi
    done
    
    echo ""
}

# Function to install configuration
install_config() {
    echo -e "${CYAN}Installing user home directory configuration...${NC}"
    echo ""
    
    # Check if user-home directory exists
    if [ ! -d "$USER_HOME_DIR" ]; then
        echo -e "${RED}Error: User home directory not found: $USER_HOME_DIR${NC}"
        echo -e "${YELLOW}Please run the migration script first:${NC}"
        echo -e "${BLUE}  ./scripts/migrate-user-home.sh${NC}"
        exit 1
    fi
    
    # Apply stow configuration
    cd "$DOTFILES_DIR"
    if stow -d stow-packs -t ~ user-home -v; then
        echo -e "${GREEN}✓ Configuration applied successfully${NC}"
    else
        echo -e "${RED}✗ Failed to apply configuration${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${YELLOW}To activate the configuration, restart your shell or run:${NC}"
    echo -e "${BLUE}  source ~/.bashrc    # for bash${NC}"
    echo -e "${BLUE}  source ~/.zshrc    # for zsh${NC}"
    echo ""
}

# Function to remove configuration
remove_config() {
    echo -e "${CYAN}Removing user home directory configuration...${NC}"
    echo ""
    
    # Ask for confirmation
    if [ "$FORCE" != "true" ]; then
        echo -e "${YELLOW}This will remove all symlinks created by the user-home configuration.${NC}"
        echo -e "${YELLOW}Your actual files will not be deleted.${NC}"
        echo ""
        read -p "Are you sure you want to continue? [y/N]: " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Operation cancelled.${NC}"
            exit 0
        fi
    fi
    
    # Remove stow configuration
    cd "$DOTFILES_DIR"
    if stow -d stow-packs -t ~ -D user-home -v; then
        echo -e "${GREEN}✓ Configuration removed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to remove configuration${NC}"
        exit 1
    fi
    
    echo ""
}

# Function to clean cache files
clean_cache() {
    echo -e "${CYAN}Cleaning cache files...${NC}"
    echo ""
    
    # Clean zsh completion cache
    if [ -f "$HOME/.zcompdump" ]; then
        rm -f "$HOME/.zcompdump"*
        echo -e "${GREEN}✓ Removed zsh completion cache${NC}"
    fi
    
    # Clean other cache files
    for file in .lesshst .wget-hsts; do
        if [ -f "$HOME/$file" ]; then
            rm -f "$HOME/$file"
            echo -e "${GREEN}✓ Removed $file${NC}"
        fi
    done
    
    # Clean .z file (directory jump history)
    if [ -f "$HOME/.z" ]; then
        echo -e "${YELLOW}⚠ Found .z file (directory jump history)${NC}"
        echo -e "${YELLOW}  This file might be useful. Remove manually if needed.${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}Cache cleaning completed!${NC}"
    echo ""
}

# Function to create backup
create_backup() {
    echo -e "${CYAN}Creating backup of user files...${NC}"
    echo ""
    
    BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup configuration files
    for file in .bashrc .bash_profile .bash_logout .profile .pythonrc; do
        if [ -f "$HOME/$file" ]; then
            cp "$HOME/$file" "$BACKUP_DIR/"
            echo -e "${GREEN}✓ Backed up $file${NC}"
        fi
    done
    
    # Backup history files
    mkdir -p "$BACKUP_DIR/history"
    for file in .bash_history .zsh_history .history .histfile .python_history .node_repl_history .irb_history; do
        if [ -f "$HOME/$file" ]; then
            cp "$HOME/$file" "$BACKUP_DIR/history/"
            echo -e "${GREEN}✓ Backed up history/$file${NC}"
        fi
    done
    
    # Backup cache files
    mkdir -p "$BACKUP_DIR/cache"
    for file in .zcompdump* .z .sudo_as_admin_successful .lesshst .wget-hsts; do
        if [ -f "$HOME/$file" ]; then
            cp "$HOME/$file" "$BACKUP_DIR/cache/"
            echo -e "${GREEN}✓ Backed up cache/$file${NC}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}Backup created successfully!${NC}"
    echo -e "${YELLOW}Backup location: $BACKUP_DIR${NC}"
    echo ""
}

# Function to restore from backup
restore_backup() {
    echo -e "${CYAN}Restoring from backup...${NC}"
    echo ""
    
    # Find the latest backup
    latest_backup=$(ls -td ~/.dotfiles-backup-* 2>/dev/null | head -1)
    
    if [ -z "$latest_backup" ]; then
        echo -e "${RED}No backup found!${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Found backup: $latest_backup${NC}"
    
    # Ask for confirmation
    if [ "$FORCE" != "true" ]; then
        read -p "Are you sure you want to restore from this backup? [y/N]: " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Operation cancelled.${NC}"
            exit 0
        fi
    fi
    
    # Restore configuration files
    if [ -d "$latest_backup" ]; then
        cp -r "$latest_backup"/* "$HOME/"
        echo -e "${GREEN}✓ Files restored successfully${NC}"
    else
        echo -e "${RED}✗ Backup directory not found${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${GREEN}Restore completed!${NC}"
    echo ""
}

# Parse command line arguments
COMMAND=""
FORCE=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        install|apply|remove|delete|status|clean|backup|restore|help)
            COMMAND="$1"
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Execute command
case "$COMMAND" in
    install|apply)
        install_config
        ;;
    remove|delete)
        remove_config
        ;;
    status)
        show_status
        ;;
    clean)
        clean_cache
        ;;
    backup)
        create_backup
        ;;
    restore)
        restore_backup
        ;;
    help|"")
        show_usage
        ;;
    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}"
        show_usage
        exit 1
        ;;
esac