#!/bin/bash
# Sensitive Dotfiles Management Script
# Helps manage files that should be handled by stow but not committed to git

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Utility functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${CYAN}[SENSITIVE]${NC} $1"; }

DOTFILES_DIR="$HOME/.dotfiles"
SENSITIVE_DIR="$DOTFILES_DIR/stow-packs/sensitive"

# Ensure sensitive directory exists
mkdir -p "$SENSITIVE_DIR"

# List of sensitive files that should be managed but not committed
SENSITIVE_FILES=(
    ".viminfo"
    ".z"
    ".zcompdump"
    ".zsh_history"
    ".bash_history" 
    ".lesshst"
    ".sqlite_history"
    ".python_history"
    ".node_repl_history"
    ".mysql_history"
    ".psql_history"
    ".rediscli_history"
)

show_help() {
    echo "Sensitive Dotfiles Management"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  backup      Move sensitive files from ~ to stow sensitive pack"
    echo "  restore     Create symlinks from stow sensitive pack to ~"
    echo "  list        List all managed sensitive files"
    echo "  status      Show status of sensitive files"
    echo "  clean       Remove broken symlinks in home directory"
    echo ""
    echo "This script manages files that should be handled by stow but"
    echo "not committed to version control (like shell history files)."
}

backup_sensitive_files() {
    log_header "Backing up sensitive files to stow pack..."
    
    local backed_up=0
    for file in "${SENSITIVE_FILES[@]}"; do
        local home_file="$HOME/$file"
        local sensitive_file="$SENSITIVE_DIR/$file"
        
        if [[ -f "$home_file" ]] && [[ ! -L "$home_file" ]]; then
            # Create directory structure if needed
            mkdir -p "$(dirname "$sensitive_file")"
            
            # Move file to sensitive directory
            mv "$home_file" "$sensitive_file"
            log_info "Moved $file to sensitive pack"
            ((backed_up++))
        elif [[ -L "$home_file" ]]; then
            log_info "$file is already a symlink"
        elif [[ -f "$sensitive_file" ]]; then
            log_info "$file already exists in sensitive pack"
        fi
    done
    
    if [[ $backed_up -gt 0 ]]; then
        log_success "Backed up $backed_up sensitive files"
        log_info "Run 'stow sensitive' from $DOTFILES_DIR to create symlinks"
    else
        log_info "No files needed to be backed up"
    fi
}

restore_sensitive_files() {
    log_header "Restoring sensitive files with stow..."
    
    cd "$DOTFILES_DIR"
    if command -v stow &> /dev/null; then
        # First try normal stow, if conflicts, backup new files and retry
        if ! stow -d stow-packs -t ~ sensitive 2>/dev/null; then
            log_warning "Conflicts detected, backing up new files first..."
            backup_sensitive_files
            stow -d stow-packs -t ~ sensitive
        fi
        log_success "Sensitive files symlinked with stow"
    else
        log_error "stow command not found. Install it first."
        return 1
    fi
}

list_sensitive_files() {
    log_header "Managed sensitive files:"
    echo ""
    for file in "${SENSITIVE_FILES[@]}"; do
        echo "  $file"
    done
}

check_status() {
    log_header "Sensitive files status:"
    echo ""
    
    for file in "${SENSITIVE_FILES[@]}"; do
        local home_file="$HOME/$file"
        local sensitive_file="$SENSITIVE_DIR/$file"
        
        if [[ -L "$home_file" ]] && [[ -f "$sensitive_file" ]]; then
            echo -e "  ${GREEN}✓${NC} $file (symlinked)"
        elif [[ -f "$sensitive_file" ]] && [[ ! -e "$home_file" ]]; then
            echo -e "  ${YELLOW}○${NC} $file (in sensitive pack, not linked)"
        elif [[ -f "$home_file" ]] && [[ ! -L "$home_file" ]]; then
            echo -e "  ${BLUE}●${NC} $file (regular file in home)"
        elif [[ -f "$sensitive_file" ]]; then
            echo -e "  ${GREEN}◐${NC} $file (managed)"
        else
            echo -e "  ${RED}○${NC} $file (not found)"
        fi
    done
}

clean_broken_links() {
    log_header "Cleaning broken symlinks in home directory..."
    
    local cleaned=0
    for file in "${SENSITIVE_FILES[@]}"; do
        local home_file="$HOME/$file"
        
        if [[ -L "$home_file" ]] && [[ ! -e "$home_file" ]]; then
            rm "$home_file"
            log_info "Removed broken symlink: $file"
            ((cleaned++))
        fi
    done
    
    if [[ $cleaned -gt 0 ]]; then
        log_success "Cleaned $cleaned broken symlinks"
    else
        log_info "No broken symlinks found"
    fi
}

main() {
    case "${1:-}" in
        backup)
            backup_sensitive_files
            ;;
        restore)
            restore_sensitive_files
            ;;
        list)
            list_sensitive_files
            ;;
        status)
            check_status
            ;;
        clean)
            clean_broken_links
            ;;
        --help|-h|help)
            show_help
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

main "$@"
