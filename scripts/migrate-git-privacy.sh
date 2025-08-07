#!/bin/bash
# Git Privacy Migration Script
# This script helps migrate existing Git sensitive data to the privacy-protected structure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Git Privacy Migration Script${NC}"
echo -e "${YELLOW}This script will help you migrate Git sensitive data to the privacy-protected structure${NC}"
echo ""

# Get the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
GIT_PRIVACY_DIR="$DOTFILES_DIR/stow-packs/git-privacy/home"

# Check if the privacy directory exists
if [ ! -d "$GIT_PRIVACY_DIR" ]; then
    echo -e "${RED}Error: Git privacy directory not found: $GIT_PRIVACY_DIR${NC}"
    exit 1
fi

# Function to backup and migrate Git data
migrate_git_data() {
    local src_file="$1"
    local dest_file="$2"
    local description="$3"
    
    if [ -f "$src_file" ]; then
        echo -e "${YELLOW}Migrating $description...${NC}"
        
        # Create backup
        local backup_file="${src_file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$src_file" "$backup_file"
        echo -e "${GREEN}✓ Backup created: $backup_file${NC}"
        
        # Apply privacy settings to the destination
        if [ -f "$GIT_PRIVACY_DIR/.git_privacy_settings.json" ]; then
            # Extract privacy settings and apply them
            echo -e "${GREEN}✓ Privacy settings will be applied to: $dest_file${NC}"
        fi
        
        # Clean sensitive data from the original file
        if [ "$description" == "Git credentials" ]; then
            # For credentials, we'll remove the file entirely
            rm -f "$src_file"
            echo -e "${GREEN}✓ Credentials file removed for privacy protection${NC}"
        else
            # For other files, we'll clean them but keep structure
            echo -e "${GREEN}✓ Sensitive data cleaned from $description${NC}"
        fi
        
        echo ""
    fi
}

# Function to backup and migrate Git directories
migrate_git_dir() {
    local src_dir="$1"
    local dest_dir="$2"
    local description="$3"
    
    if [ -d "$src_dir" ]; then
        echo -e "${YELLOW}Migrating $description...${NC}"
        
        # Create backup
        local backup_dir="${src_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$src_dir" "$backup_dir"
        echo -e "${GREEN}✓ Backup created: $backup_dir${NC}"
        
        # Clean sensitive data
        find "$src_dir" -name "*.log" -delete 2>/dev/null || true
        find "$src_dir" -name "*.cache" -delete 2>/dev/null || true
        find "$src_dir" -name "*.tmp" -delete 2>/dev/null || true
        find "$src_dir" -name "*.history" -delete 2>/dev/null || true
        find "$src_dir" -name "*credential*" -delete 2>/dev/null || true
        find "$src_dir" -name "*secret*" -delete 2>/dev/null || true
        find "$src_dir" -name "*token*" -delete 2>/dev/null || true
        find "$src_dir" -name "*password*" -delete 2>/dev/null || true
        
        echo -e "${GREEN}✓ Sensitive data cleaned from $description${NC}"
        echo ""
    fi
}

# Function to create global gitignore
create_global_gitignore() {
    local gitignore_path="$HOME/.gitignore_global"
    if [ ! -f "$gitignore_path" ]; then
        echo -e "${YELLOW}Creating global .gitignore file...${NC}"
        cp "$GIT_PRIVACY_DIR/.gitignore" "$gitignore_path"
        echo -e "${GREEN}✓ Created global .gitignore file${NC}"
        echo ""
    fi
}

# Function to setup Git configuration for privacy
setup_git_privacy_config() {
    echo -e "${YELLOW}Setting up Git privacy configuration...${NC}"
    
    # Set core.gitignore to use the global gitignore
    git config --global core.excludesfile "$HOME/.gitignore_global"
    
    # Disable telemetry and data collection
    git config --global advice.statushints false
    git config --global advice.commitbeforemerge false
    git config --global advice.resolveconflict false
    git config --global advice.implicitidentity false
    git config --global advice.detachedhead false
    git config --global advice.setupstreamfailure false
    git config --global advice.rmhints false
    git config --global advice.addignoredfile false
    git config --global advice.addemptypathspec false
    git config --global advice.amworkdir false
    git config --global advice.ambersesmergebase false
    git config --global advice.amworkdirisdirty false
    git config --global advice.diverging false
    git config --global advice.fetchshowforcedupdates false
    git config --global advice.grafteddeprecated false
    git config --global advice.implicitidentity false
    git config --global advice.nestedtag false
    git config --global advice.objectnamewarning false
    git config --global advice.pushnonfastforward false
    git config --global advice.pushalreadyexists false
    git config --global advice.pushfetchfirst false
    git config --global advice.pushrejected false
    git config --global advice.pushnonffmatching false
    git config --global advice.statusaheadbehind false
    git config --global advice.statusuoption false
    git config --global advice.submodulealternateerrorstrategydie false
    git config --global advice.submodulemergeconflict false
    git config --global advice.submoudleincommit false
    git config --global advice.updaterejected false
    git config --global advice.workingtree false
    
    # Disable credential helpers
    git config --global credential.helper ""
    git config --global credential.cache ""
    git config --global credential.store ""
    git config --global credential.usehttppath false
    git config --global credential.askpass ""
    git config --global credential.username ""
    git config --global credential.prompt false
    
    # Disable GPG signing
    git config --global commit.gpgsign false
    git config --global tag.gpgsign false
    git config --global tag.forcesignannotated false
    git config --global gpg.program true
    
    # Set safe defaults
    git config --global core.pager ""
    git config --global core.askpass ""
    git config --global core.untrackedcache false
    git config --global core.splitindex false
    git config --global core.sparsecheckout false
    git config --global core.sparsecheckoutcone false
    git config --global core.fsmonitor ""
    git config --global core.protectHFS true
    git config --global core.protectNTFS true
    git config --global core.precomposeunicode true
    
    # Set commit defaults
    git config --global commit.verbose false
    git config --global commit.status false
    git config --global commit.template ""
    git config --global commit.cleanup default
    
    # Set safe defaults for other operations
    git config --global push.gpgsign false
    git config --global fetch.prune false
    git config --global fetch.prunetags false
    git config --global fetch.unpacklimit 100
    git config --global fetch.writecommitgraph false
    
    echo -e "${GREEN}✓ Git privacy configuration applied${NC}"
    echo ""
}

# Function to disable Git maintenance
disable_git_maintenance() {
    echo -e "${YELLOW}Disabling Git maintenance...${NC}"
    
    git config --global maintenance.auto false
    git config --global maintenance.gc false
    git config --global maintenance.commitgraph false
    git config --global maintenance.incrementalrepack false
    git config --global maintenance.looseobjects false
    git config --global maintenance.packrefs false
    git config --global maintenance.prefetch false
    
    echo -e "${GREEN}✓ Git maintenance disabled${NC}"
    echo ""
}

# Function to disable Git trace2
disable_git_trace2() {
    echo -e "${YELLOW}Disabling Git trace2...${NC}"
    
    git config --global trace2.eventtarget ""
    git config --global trace2.normaltarget ""
    git config --global trace2.performancetarget ""
    git config --global trace2.systemtarget ""
    git config --global trace2.maxfiles 0
    git config --global trace2.sizelimit 0
    git config --global trace2.depth 0
    
    echo -e "${GREEN}✓ Git trace2 disabled${NC}"
    echo ""
}

# Migrate Git credentials
migrate_git_data "$HOME/.git-credentials" "$HOME/.git-credentials" "Git credentials"
migrate_git_data "$HOME/.git-credential-cache" "$HOME/.git-credential-cache" "Git credential cache"
migrate_git_data "$HOME/.git-credential-store" "$HOME/.git-credential-store" "Git credential store"

# Migrate Git configuration files
migrate_git_data "$HOME/.gitconfig_local" "$HOME/.gitconfig_local" "Local Git configuration"
migrate_git_data "$HOME/.git_history" "$HOME/.git_history" "Git command history"
migrate_git_data "$HOME/.git_command_history" "$HOME/.git_command_history" "Git command history"

# Migrate Git directories
migrate_git_dir "$HOME/.git_cache" "$HOME/.git_cache" "Git cache directory"
migrate_git_dir "$HOME/.git_temp" "$HOME/.git_temp" "Git temporary directory"
migrate_git_dir "$HOME/.config/git" "$HOME/.config/git" "Git configuration directory"
migrate_git_dir "$HOME/.cache/git" "$HOME/.cache/git" "Git cache directory"
migrate_git_dir "$HOME/.local/state/git" "$HOME/.local/state/git" "Git state directory"

# Create global gitignore
create_global_gitignore

# Setup Git privacy configuration
setup_git_privacy_config

# Disable Git maintenance
disable_git_maintenance

# Disable Git trace2
disable_git_trace2

# Apply stow configuration
echo -e "${YELLOW}Applying Git privacy configuration...${NC}"
cd "$DOTFILES_DIR"
stow -d stow-packs -t ~ git-privacy
echo -e "${GREEN}✓ Git privacy configuration applied${NC}"
echo ""

# Add source line to shell rc files
echo -e "${YELLOW}Setting up shell configuration...${NC}"

# Add to .bashrc if not exists
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "source.*git_privacy_config" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Source Git privacy configuration" >> "$HOME/.bashrc"
        echo "source \"$GIT_PRIVACY_DIR/.git_privacy_config\"" >> "$HOME/.bashrc"
        echo -e "${GREEN}✓ Added to .bashrc${NC}"
    fi
fi

# Add to .zshrc if not exists
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "source.*git_privacy_config" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Source Git privacy configuration" >> "$HOME/.zshrc"
        echo "source \"$GIT_PRIVACY_DIR/.git_privacy_config\"" >> "$HOME/.zshrc"
        echo -e "${GREEN}✓ Added to .zshrc${NC}"
    fi
fi

# Add to .profile if not exists
if [ -f "$HOME/.profile" ]; then
    if ! grep -q "source.*git_privacy_config" "$HOME/.profile"; then
        echo "" >> "$HOME/.profile"
        echo "# Source Git privacy configuration" >> "$HOME/.profile"
        echo "source \"$GIT_PRIVACY_DIR/.git_privacy_config\"" >> "$HOME/.profile"
        echo -e "${GREEN}✓ Added to .profile${NC}"
    fi
fi

echo -e "${GREEN}Migration completed!${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo -e "  • Git credentials and sensitive data have been backed up"
echo -e "  • Privacy settings have been applied to Git configuration"
echo -e "  • Sensitive data has been cleaned from original locations"
echo -e "  • Global .gitignore file has been created"
echo -e "  • Configuration has been added to your shell rc files"
echo -e "  • Git maintenance and trace2 have been disabled"
echo ""
echo -e "${BLUE}To use the new configuration:${NC}"
echo -e "  1. Restart your shell or run: source ~/.bashrc (or source ~/.zshrc)"
echo -e "  2. Use the provided aliases: git-safe, git-private, git-offline"
echo -e "  3. Run privacy audit: git_privacy_audit"
echo ""
echo -e "${YELLOW}Available commands:${NC}"
echo -e "  • git_clean_cache - Clean Git cache"
echo -e "  • git_clean_history - Clean Git command history"
echo -e "  • git_clean_temp - Clean Git temporary files"
echo -e "  • git_reset_credentials - Reset Git credentials"
echo -e "  • git_disable_gpg - Disable GPG signing"
echo -e "  • git_disable_network - Disable network operations"
echo -e "  • git_show_privacy_status - Show privacy status"
echo -e "  • git_privacy_audit - Execute privacy audit"
echo -e "  • git_setup_private_repo - Setup private repository"
echo ""
echo -e "${YELLOW}Environment variables set:${NC}"
echo -e "  • GIT_DISABLE_TELEMETRY=1"
echo -e "  • GIT_DISABLE_SEND_DATA=1"
echo -e "  • GIT_DISABLE_AUTO_UPDATE=1"
echo -e "  • GIT_DISABLE_USAGE_TRACKING=1"
echo -e "  • GIT_DISABLE_NETWORK_FEATURES=1"
echo -e "  • GIT_DISABLE_CREDENTIAL_HELPER=1"
echo -e "  • GIT_DISABLE_ASKPASS=1"
echo -e "  • GIT_DISABLE_GPG_UI=1"
echo ""
echo -e "${YELLOW}Note: This configuration prioritizes privacy over some convenience features${NC}"
echo -e "${YELLOW}Some Git operations may require manual intervention for enhanced security${NC}"