#!/bin/bash
# Privacy Migration Script Template
# This script helps migrate sensitive data to privacy-protected structures

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - Customize these variables for your software
SOFTWARE_NAME="privacy-template"
SOFTWARE_DISPLAY_NAME="Privacy Template"
CONFIG_DIRS=("$HOME/.config/privacy-template" "$HOME/.privacy-template")
DATA_DIRS=("$HOME/.local/share/privacy-template" "$HOME/.privacy-template-data")
CACHE_DIRS=("$HOME/.cache/privacy-template" "$HOME/.privacy-template-cache")
STATE_DIRS=("$HOME/.local/state/privacy-template" "$HOME/.privacy-template-state")
SENSITIVE_FILES=("$HOME/.privacy-template-history" "$HOME/.privacy-template.log")
SENSITIVE_PATTERNS=("*.session" "*.backup" "*.tmp" "*.temp")

echo -e "${BLUE}${SOFTWARE_DISPLAY_NAME} Privacy Migration Script${NC}"
echo -e "${YELLOW}This script will help you migrate ${SOFTWARE_DISPLAY_NAME} sensitive data to the privacy-protected structure${NC}"
echo ""

# Get the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
PRIVACY_DIR="$DOTFILES_DIR/stow-packs/${SOFTWARE_NAME}/home"

# Check if the privacy directory exists
if [ ! -d "$PRIVACY_DIR" ]; then
    echo -e "${RED}Error: ${SOFTWARE_DISPLAY_NAME} privacy directory not found: $PRIVACY_DIR${NC}"
    exit 1
fi

# Function to backup and migrate data
migrate_data() {
    local src_path="$1"
    local description="$2"
    
    if [ -e "$src_path" ]; then
        echo -e "${YELLOW}Migrating $description...${NC}"
        
        # Create backup
        local backup_path="${src_path}.backup.$(date +%Y%m%d_%H%M%S)"
        if [ -f "$src_path" ]; then
            cp "$src_path" "$backup_path"
        elif [ -d "$src_path" ]; then
            cp -r "$src_path" "$backup_path"
        fi
        echo -e "${GREEN}✓ Backup created: $backup_path${NC}"
        
        # Clean sensitive data
        clean_sensitive_data "$src_path"
        
        echo -e "${GREEN}✓ Sensitive data cleaned from $description${NC}"
        echo ""
    fi
}

# Function to clean sensitive data
clean_sensitive_data() {
    local path="$1"
    
    if [ -d "$path" ]; then
        # Remove common sensitive subdirectories
        rm -rf "$path/cache" 2>/dev/null || true
        rm -rf "$path/sessions" 2>/dev/null || true
        rm -rf "$path/backups" 2>/dev/null || true
        rm -rf "$path/state" 2>/dev/null || true
        rm -rf "$path/history" 2>/dev/null || true
        rm -rf "$path/temp" 2>/dev/null || true
        rm -rf "$path/tmp" 2>/dev/null || true
        rm -rf "$path/log" 2>/dev/null || true
        rm -rf "$path/logs" 2>/dev/null || true
        
        # Remove sensitive files
        find "$path" -name "*.log" -delete 2>/dev/null || true
        find "$path" -name "*.tmp" -delete 2>/dev/null || true
        find "$path" -name "*.temp" -delete 2>/dev/null || true
        find "$path" -name "*.session" -delete 2>/dev/null || true
        find "$path" -name "*.backup" -delete 2>/dev/null || true
        find "$path" -name "*.history" -delete 2>/dev/null || true
        find "$path" -name "*.cache" -delete 2>/dev/null || true
        
    elif [ -f "$path" ]; then
        # For files, just remove them if they're sensitive
        case "$path" in
            *.log|*.tmp|*.temp|*.session|*.backup|*.history|*.cache)
                rm -f "$path"
                ;;
        esac
    fi
}

# Function to clean up sensitive files
cleanup_sensitive_files() {
    echo -e "${YELLOW}Cleaning up sensitive files...${NC}"
    
    # Clean up specific sensitive files
    for file in "${SENSITIVE_FILES[@]}"; do
        if [ -e "$file" ]; then
            local backup_file="${file}.backup.$(date +%Y%m%d_%H%M%S)"
            if [ -f "$file" ]; then
                cp "$file" "$backup_file"
            elif [ -d "$file" ]; then
                cp -r "$file" "$backup_file"
            fi
            rm -rf "$file"
            echo -e "${GREEN}✓ Cleaned: $file${NC}"
        fi
    done
    
    # Clean up files matching patterns
    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        find "$HOME" -name "$pattern" -maxdepth 1 -exec rm -rf {} \; 2>/dev/null || true
    done
    
    echo ""
}

# Function to apply privacy settings
apply_privacy_settings() {
    echo -e "${YELLOW}Applying privacy settings...${NC}"
    
    # Apply privacy settings if they exist
    if [ -f "$PRIVACY_DIR/.privacy_settings.json" ]; then
        echo -e "${GREEN}✓ Privacy settings template available${NC}"
        echo -e "${YELLOW}  Note: Manual integration of privacy settings may be required${NC}"
    fi
    
    echo ""
}

# Migrate configuration directories
for config_dir in "${CONFIG_DIRS[@]}"; do
    migrate_data "$config_dir" "configuration directory"
done

# Migrate data directories
for data_dir in "${DATA_DIRS[@]}"; do
    migrate_data "$data_dir" "data directory"
done

# Migrate cache directories
for cache_dir in "${CACHE_DIRS[@]}"; do
    migrate_data "$cache_dir" "cache directory"
done

# Migrate state directories
for state_dir in "${STATE_DIRS[@]}"; do
    migrate_data "$state_dir" "state directory"
done

# Clean up sensitive files
cleanup_sensitive_files

# Apply privacy settings
apply_privacy_settings

# Apply stow configuration
echo -e "${YELLOW}Applying ${SOFTWARE_DISPLAY_NAME} privacy configuration...${NC}"
cd "$DOTFILES_DIR"
if stow -d stow-packs -t ~ "${SOFTWARE_NAME}" 2>/dev/null; then
    echo -e "${GREEN}✓ ${SOFTWARE_DISPLAY_NAME} privacy configuration applied${NC}"
else
    echo -e "${YELLOW}⚠ Stow configuration not found or already applied${NC}"
fi
echo ""

# Add source line to shell rc files
echo -e "${YELLOW}Setting up shell configuration...${NC}"

# Add to .bashrc if not exists
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "source.*${SOFTWARE_NAME}_privacy_config" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Source ${SOFTWARE_DISPLAY_NAME} privacy configuration" >> "$HOME/.bashrc"
        echo "source \"$PRIVACY_DIR/.privacy_config\"" >> "$HOME/.bashrc"
        echo -e "${GREEN}✓ Added to .bashrc${NC}"
    fi
fi

# Add to .zshrc if not exists
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "source.*${SOFTWARE_NAME}_privacy_config" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Source ${SOFTWARE_DISPLAY_NAME} privacy configuration" >> "$HOME/.zshrc"
        echo "source \"$PRIVACY_DIR/.privacy_config\"" >> "$HOME/.zshrc"
        echo -e "${GREEN}✓ Added to .zshrc${NC}"
    fi
fi

echo -e "${GREEN}Migration completed!${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo -e "  • ${SOFTWARE_DISPLAY_NAME} sensitive data has been backed up"
echo -e "  • Privacy settings have been applied"
echo -e "  • Sensitive data has been cleaned from original locations"
echo -e "  • Configuration has been added to your shell rc files"
echo ""
echo -e "${BLUE}To use the new configuration:${NC}"
echo -e "  1. Restart your shell or run: source ~/.bashrc (or source ~/.zshrc)"
echo -e "  2. Restart ${SOFTWARE_DISPLAY_NAME} to apply privacy settings"
echo -e "  3. Use the provided aliases: ${SOFTWARE_NAME}-safe, ${SOFTWARE_NAME}-private"
echo ""
echo -e "${YELLOW}Available commands:${NC}"
echo -e "  • ${SOFTWARE_NAME}_clean_cache - Clean ${SOFTWARE_DISPLAY_NAME} cache"
echo -e "  • ${SOFTWARE_NAME}_clean_data - Clean ${SOFTWARE_DISPLAY_NAME} data"
echo -e "  • ${SOFTWARE_NAME}_show_privacy_status - Show privacy status"
echo -e "  • ${SOFTWARE_NAME}_privacy_check - Check privacy settings"
echo ""
echo -e "${YELLOW}Environment variables:${NC}"
echo -e "  • TELEMETRY_DISABLED=1"
echo -e "  • AUTO_UPDATE_DISABLED=1"
echo -e "  • DIAGNOSTICS_DISABLED=1"
echo -e "  • ONLINE_FEATURES_DISABLED=1"
echo ""
echo -e "${YELLOW}Customization:${NC}"
echo -e "  • Edit this script to match your software's directory structure"
echo -e "  • Update the configuration variables at the top of the script"
echo -e "  • Add software-specific privacy settings"
echo -e "  • Test the migration process"
echo ""
echo -e "${YELLOW}Note: This configuration prioritizes privacy over some convenience features${NC}"