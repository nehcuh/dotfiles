#!/bin/bash
# Stow-based dotfiles management script

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_DIR="$DOTFILES_DIR/stow-packs"
TARGET_DIR="$HOME"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Available packages
PACKAGES=("zsh" "git" "vim" "nvim" "tmux" "tools" "system" "linux" "windows" "zed")

usage() {
    echo "Usage: $0 [command] [package...]"
    echo ""
    echo "Commands:"
    echo "  install [package...]  - Install specified packages (or all if none specified)"
    echo "  remove [package...]   - Remove specified packages (or all if none specified)"
    echo "  list                  - List available packages"
    echo "  status                - Show current stow status"
    echo ""
    echo "Available packages: ${PACKAGES[*]}"
    echo ""
    echo "Examples:"
    echo "  $0 install            # Install all packages"
    echo "  $0 install zsh git    # Install only zsh and git"
    echo "  $0 remove nvim        # Remove nvim package"
    echo ""
    echo "For complete uninstallation, use: ./scripts/uninstall.sh complete"
}

list_packages() {
    echo -e "${BLUE}Available packages:${NC}"
    for pkg in "${PACKAGES[@]}"; do
        if [ -d "$STOW_DIR/$pkg" ]; then
            echo "  ✓ $pkg"
        else
            echo "  ✗ $pkg (not found)"
        fi
    done
}

stow_install() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        packages=("${PACKAGES[@]}")
    fi
    
    echo -e "${GREEN}Installing packages: ${packages[*]}${NC}"
    
    for pkg in "${packages[@]}"; do
        if [ -d "$STOW_DIR/$pkg" ]; then
            echo -e "${YELLOW}Installing $pkg...${NC}"
            cd "$STOW_DIR"
            
            # Try to stow, if conflicts exist, handle them
            if ! stow -v -t "$TARGET_DIR" "$pkg" 2>/dev/null; then
                echo -e "${YELLOW}Conflicts detected for $pkg, backing up existing files...${NC}"
                
                # Create backup directory
                backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
                mkdir -p "$backup_dir"
                
                # Find conflicting files and back them up
                stow -v -t "$TARGET_DIR" -n "$pkg" 2>&1 | grep "existing target" | while read -r line; do
                    if [[ $line =~ "existing target "(.+)" since" ]]; then
                        conflict_file="${BASH_REMATCH[1]}"
                        if [ -f "$TARGET_DIR/$conflict_file" ] && [ ! -L "$TARGET_DIR/$conflict_file" ]; then
                            echo -e "${YELLOW}  Backing up $conflict_file${NC}"
                            mkdir -p "$backup_dir/$(dirname "$conflict_file")"
                            cp "$TARGET_DIR/$conflict_file" "$backup_dir/$conflict_file"
                            rm -f "$TARGET_DIR/$conflict_file"
                        fi
                    fi
                done
                
                # Try stowing again
                if stow -v -t "$TARGET_DIR" "$pkg"; then
                    echo -e "${GREEN}✓ $pkg installed (conflicts backed up to $backup_dir)${NC}"
                else
                    echo -e "${RED}✗ Failed to install $pkg${NC}"
                fi
            else
                echo -e "${GREEN}✓ $pkg installed${NC}"
            fi
        else
            echo -e "${RED}✗ Package $pkg not found${NC}"
        fi
    done
}

stow_remove() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        packages=("${PACKAGES[@]}")
    fi
    
    echo -e "${YELLOW}Removing packages: ${packages[*]}${NC}"
    
    for pkg in "${packages[@]}"; do
        if [ -d "$STOW_DIR/$pkg" ]; then
            echo -e "${YELLOW}Removing $pkg...${NC}"
            cd "$STOW_DIR"
            stow -v -D -t "$TARGET_DIR" "$pkg"
            echo -e "${GREEN}✓ $pkg removed${NC}"
        else
            echo -e "${RED}✗ Package $pkg not found${NC}"
        fi
    done
}

show_status() {
    echo -e "${BLUE}Current stow status:${NC}"
    cd "$STOW_DIR"
    
    for pkg in "${PACKAGES[@]}"; do
        if [ -d "$pkg" ]; then
            echo -e "${YELLOW}Checking $pkg:${NC}"
            stow -v -t "$TARGET_DIR" -n "$pkg" 2>&1 | grep -E "(existing|linking)" || echo "  No conflicts found"
        fi
    done
}

# Main logic
case "${1:-help}" in
    install)
        stow_install "${@:2}"
        ;;
    remove)
        stow_remove "${@:2}"
        ;;
    list)
        list_packages
        ;;
    status)
        show_status
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