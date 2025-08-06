#!/bin/bash
# Dotfiles uninstaller - supports both individual package and complete uninstallation

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_DIR="$DOTFILES_DIR/stow-packs"
TARGET_DIR="$HOME"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Available packages
PACKAGES=("zsh" "git" "vim" "nvim" "tmux" "tools" "system" "windows" "zed")

# Configuration files that might be managed by dotfiles
CONFIG_FILES=(
    ".zshrc"
    ".zshenv"
    ".zshrc.local"
    ".gitconfig"
    ".gitconfig_global"
    ".gitignore_global"
    ".vimrc"
    ".tmux.conf"
    ".config/starship.toml"
    ".config/nvim"
    ".config/zed"
    ".config/lvim"
    ".config/lazygit"
    ".config/wezterm"
    ".config/alacritty"
    ".config/kitty"
    ".config/ghostty"
    ".config/btop"
    ".config/lsd"
    ".config/bat"
    ".config/ripgrep"
    ".config/fd"
    ".config/git"
)

usage() {
    echo "Usage: $0 [command] [package...]"
    echo ""
    echo "Commands:"
    echo "  package [package...]  - Uninstall specific packages"
    echo "  complete              - Complete uninstallation (all packages + cleanup)"
    echo "  clean                - Clean backup files"
    echo "  list                  - List installed packages"
    echo "  help                  - Show this help message"
    echo ""
    echo "Available packages: ${PACKAGES[*]}"
    echo ""
    echo "Examples:"
    echo "  $0 package zsh git    # Uninstall only zsh and git packages"
    echo "  $0 complete           # Complete uninstallation"
    echo "  $0 clean             # Clean backup files"
}

list_installed_packages() {
    echo -e "${BLUE}Currently installed packages:${NC}"
    local installed=()
    
    for pkg in "${PACKAGES[@]}"; do
        if [ -d "$STOW_DIR/$pkg" ]; then
            # Check if package has any dotfiles that are linked
            local has_linked_files=false
            cd "$STOW_DIR/$pkg"
            
            # Look for common dotfile patterns
            for file in .zshrc .zshenv .gitconfig .gitconfig_global .gitignore_global .vimrc .tmux.conf .config/starship.toml; do
                if [ -f "$file" ] && [ -L "$TARGET_DIR/$file" ]; then
                    local link_target
                    link_target=$(readlink "$TARGET_DIR/$file" 2>/dev/null || echo "")
                    if [[ "$link_target" == *"$DOTFILES_DIR"* ]] || [[ "$link_target" == *"stow-packs/$pkg"* ]]; then
                        has_linked_files=true
                        break
                    fi
                fi
            done
            
            # Also check for config directories
            if [ -d "config" ] && [ -L "$TARGET_DIR/.config" ]; then
                local link_target
                link_target=$(readlink "$TARGET_DIR/.config" 2>/dev/null || echo "")
                if [[ "$link_target" == *"$DOTFILES_DIR"* ]]; then
                    has_linked_files=true
                fi
            fi
            
            if [ "$has_linked_files" = true ]; then
                installed+=("$pkg")
                echo "  ✓ $pkg (installed)"
            else
                echo "  - $pkg (available but not installed)"
            fi
        else
            echo "  ✗ $pkg (not found)"
        fi
    done
    
    if [ ${#installed[@]} -eq 0 ]; then
        echo -e "${YELLOW}No packages currently installed${NC}"
    fi
}

uninstall_packages() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        echo -e "${YELLOW}No packages specified for uninstallation${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Uninstalling packages: ${packages[*]}${NC}"
    
    for pkg in "${packages[@]}"; do
        if [[ ! " ${PACKAGES[@]} " =~ " ${pkg} " ]]; then
            echo -e "${RED}✗ Unknown package: $pkg${NC}"
            continue
        fi
        
        if [ -d "$STOW_DIR/$pkg" ]; then
            echo -e "${YELLOW}Removing $pkg...${NC}"
            cd "$STOW_DIR"
            
            # Check if package is actually installed using our detection logic
            local is_installed=false
            cd "$STOW_DIR/$pkg"
            
            # Look for common dotfile patterns
            for file in .zshrc .zshenv .gitconfig .gitconfig_global .gitignore_global .vimrc .tmux.conf .config/starship.toml; do
                if [ -f "$file" ] && [ -L "$TARGET_DIR/$file" ]; then
                    local link_target
                    link_target=$(readlink "$TARGET_DIR/$file" 2>/dev/null || echo "")
                    if [[ "$link_target" == *"$DOTFILES_DIR"* ]] || [[ "$link_target" == *"stow-packs/$pkg"* ]]; then
                        is_installed=true
                        break
                    fi
                fi
            done
            
            if [ "$is_installed" = true ]; then
                cd "$STOW_DIR"
                if stow -v -D -t "$TARGET_DIR" "$pkg"; then
                    echo -e "${GREEN}✓ $pkg uninstalled${NC}"
                else
                    echo -e "${RED}✗ Failed to uninstall $pkg${NC}"
                fi
            else
                echo -e "${YELLOW}  Package $pkg is not currently installed${NC}"
            fi
        else
            echo -e "${RED}✗ Package $pkg not found${NC}"
        fi
    done
}

complete_uninstall() {
    echo -e "${RED}⚠️  COMPLETE UNINSTALLATION${NC}"
    echo -e "${YELLOW}This will remove ALL dotfiles packages and clean up related files${NC}"
    echo ""
    
    printf "Are you sure you want to proceed? [y/N]: "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            echo -e "${YELLOW}Uninstallation cancelled${NC}"
            return 0
            ;;
    esac
    
    echo -e "${YELLOW}Starting complete uninstallation...${NC}"
    
    # Uninstall all packages
    echo -e "${YELLOW}Removing all installed packages...${NC}"
    cd "$STOW_DIR"
    for pkg in "${PACKAGES[@]}"; do
        if [ -d "$pkg" ]; then
            echo -e "${YELLOW}Removing $pkg...${NC}"
            stow -v -D -t "$TARGET_DIR" "$pkg" 2>/dev/null || true
        fi
    done
    
    # Clean up remaining symlinks
    echo -e "${YELLOW}Cleaning up remaining symlinks...${NC}"
    local symlinks_removed=0
    for config_file in "${CONFIG_FILES[@]}"; do
        local target_path="$TARGET_DIR/$config_file"
        if [ -L "$target_path" ]; then
            # Check if it's a link to our dotfiles
            local link_target
            link_target=$(readlink "$target_path" 2>/dev/null || echo "")
            if [[ "$link_target" == *"$DOTFILES_DIR"* ]]; then
                echo -e "${YELLOW}Removing symlink: $config_file${NC}"
                rm -f "$target_path"
                ((symlinks_removed++))
            fi
        elif [ -d "$target_path" ]; then
            # For directories, check if it's a link to our dotfiles
            if [ -L "$target_path" ]; then
                local link_target
                link_target=$(readlink "$target_path" 2>/dev/null || echo "")
                if [[ "$link_target" == *"$DOTFILES_DIR"* ]]; then
                    echo -e "${YELLOW}Removing symlink directory: $config_file${NC}"
                    rm -f "$target_path"
                    ((symlinks_removed++))
                fi
            fi
        fi
    done
    
    # Clean backup files
    echo -e "${YELLOW}Cleaning backup files...${NC}"
    local backups_removed=0
    for backup_dir in "$TARGET_DIR"/.dotfiles-backup-*; do
        if [ -d "$backup_dir" ]; then
            echo -e "${YELLOW}Removing backup: $(basename "$backup_dir")${NC}"
            rm -rf "$backup_dir"
            ((backups_removed++))
        fi
    done
    
    # Ask about removing the dotfiles repository
    echo ""
    printf "Do you want to remove the dotfiles repository? ($DOTFILES_DIR) [y/N]: "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY])
            echo -e "${YELLOW}Removing dotfiles repository...${NC}"
            cd "$HOME"
            rm -rf "$DOTFILES_DIR"
            echo -e "${GREEN}✓ Dotfiles repository removed${NC}"
            ;;
        *)
            echo -e "${YELLOW}Dotfiles repository kept${NC}"
            ;;
    esac
    
    # Summary
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗"
    echo -e "${GREEN}║                    Uninstallation Complete!                  ║"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝"
    echo -e "${YELLOW}Summary:${NC}"
    echo -e "${GREEN}  • All packages uninstalled${NC}"
    echo -e "${GREEN}  • $symlinks_removed symlinks removed${NC}"
    echo -e "${GREEN}  • $backups_removed backup directories removed${NC}"
    echo ""
    echo -e "${YELLOW}Note: Some changes may require a terminal restart to take full effect${NC}"
}

clean_backup_files() {
    echo -e "${YELLOW}Cleaning backup files...${NC}"
    
    local backups_found=0
    local backups_removed=0
    
    for backup_dir in "$TARGET_DIR"/.dotfiles-backup-*; do
        if [ -d "$backup_dir" ]; then
            ((backups_found++))
            echo -e "${CYAN}Found backup: $(basename "$backup_dir")${NC}"
            
            printf "Remove this backup? [y/N]: "
            read -r response
            case "$response" in
                [yY][eE][sS]|[yY])
                    echo -e "${YELLOW}Removing: $(basename "$backup_dir")${NC}"
                    rm -rf "$backup_dir"
                    ((backups_removed++))
                    ;;
                *)
                    echo -e "${GREEN}Keeping: $(basename "$backup_dir")${NC}"
                    ;;
            esac
        fi
    done
    
    if [ $backups_found -eq 0 ]; then
        echo -e "${GREEN}✓ No backup files found${NC}"
    else
        echo -e "${GREEN}✓ Cleaned $backups_removed/$backups_found backup directories${NC}"
    fi
}

# Main logic
case "${1:-help}" in
    package)
        uninstall_packages "${@:2}"
        ;;
    complete)
        complete_uninstall
        ;;
    clean)
        clean_backup_files
        ;;
    list)
        list_installed_packages
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        usage
        exit 1
        ;;
esac