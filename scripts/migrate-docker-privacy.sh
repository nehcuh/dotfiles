#!/bin/bash
# Docker Privacy Migration Script
# This script helps migrate existing Docker sensitive data to the privacy-protected structure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Docker Privacy Migration Script${NC}"
echo -e "${YELLOW}This script will help you migrate Docker sensitive data to the privacy-protected structure${NC}"
echo ""

# Get the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_PRIVACY_DIR="$DOTFILES_DIR/stow-packs/docker-privacy/home"

# Check if the privacy directory exists
if [ ! -d "$DOCKER_PRIVACY_DIR" ]; then
    echo -e "${RED}Error: Docker privacy directory not found: $DOCKER_PRIVACY_DIR${NC}"
    exit 1
fi

# Function to backup and migrate Docker data
migrate_docker_data() {
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
        if [ -f "$DOCKER_PRIVACY_DIR/.docker_privacy_config.json" ]; then
            mkdir -p "$dest_dir"
            cp "$DOCKER_PRIVACY_DIR/.docker_privacy_config.json" "$dest_dir/config.json"
            echo -e "${GREEN}✓ Privacy settings applied to: $dest_dir/config.json${NC}"
        fi
        
        # Clean up sensitive data
        rm -rf "$src_dir/contexts" 2>/dev/null || true
        rm -rf "$src_dir/buildx" 2>/dev/null || true
        rm -rf "$src_dir/scan" 2>/dev/null || true
        rm -f "$src_dir/credentials.json" 2>/dev/null || true
        rm -f "$src_dir/secrets.json" 2>/dev/null || true
        
        echo -e "${GREEN}✓ Sensitive data cleaned from $description${NC}"
        echo ""
    fi
}

# Function to backup and migrate Docker daemon config
migrate_docker_daemon_config() {
    local config_path="$1"
    
    if [ -f "$config_path" ]; then
        echo -e "${YELLOW}Migrating Docker daemon configuration...${NC}"
        
        # Create backup
        local backup_file="${config_path}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$config_path" "$backup_file"
        echo -e "${GREEN}✓ Backup created: $backup_file${NC}"
        
        # Apply privacy settings
        if [ -f "$DOCKER_PRIVACY_DIR/.docker_daemon_privacy_config.json" ]; then
            cp "$DOCKER_PRIVACY_DIR/.docker_daemon_privacy_config.json" "$config_path"
            echo -e "${GREEN}✓ Privacy daemon settings applied to: $config_path${NC}"
        fi
        
        echo ""
    fi
}

# Function to clean up Docker files
cleanup_docker_files() {
    echo -e "${YELLOW}Cleaning up Docker files...${NC}"
    
    # Clean up Docker cache
    if [ -d "$HOME/.cache/docker" ]; then
        local backup_dir="$HOME/.cache/docker.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$HOME/.cache/docker" "$backup_dir"
        rm -rf "$HOME/.cache/docker"
        echo -e "${GREEN}✓ Docker cache backed up and removed${NC}"
    fi
    
    # Clean up Docker data
    if [ -d "$HOME/.local/share/docker" ]; then
        local backup_dir="$HOME/.local/share/docker.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$HOME/.local/share/docker" "$backup_dir"
        rm -rf "$HOME/.local/share/docker"
        echo -e "${GREEN}✓ Docker data backed up and removed${NC}"
    fi
    
    # Clean up Docker state
    if [ -d "$HOME/.local/state/docker" ]; then
        local backup_dir="$HOME/.local/state/docker.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$HOME/.local/state/docker" "$backup_dir"
        rm -rf "$HOME/.local/state/docker"
        echo -e "${GREEN}✓ Docker state backed up and removed${NC}"
    fi
    
    # Clean up Docker logs
    if [ -d "$HOME/.local/share/docker/logs" ]; then
        rm -rf "$HOME/.local/share/docker/logs"
        echo -e "${GREEN}✓ Docker logs removed${NC}"
    fi
    
    echo ""
}

# Function to create .dockerignore file
create_dockerignore() {
    local dockerignore_path="$HOME/.dockerignore"
    if [ ! -f "$dockerignore_path" ]; then
        echo -e "${YELLOW}Creating .dockerignore file...${NC}"
        cat > "$dockerignore_path" << 'EOF'
# Ignore sensitive files and directories
.git/
.gitignore
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.env
.env.local
.env.*.local
*.log
*.tmp
*.temp
.DS_Store
Thumbs.db
.vscode/
.idea/
*.swp
*.swo
*~
coverage/
.nyc_output/
.cache/
dist/
build/
out/
*.pyc
__pycache__/
*.class
*.jar
*.war
*.ear
*.zip
*.tar.gz
*.rar
.svn/
.hg/
CVS/
*.bak
*.backup
*.old
*.orig
.rej
*.patch
*.diff
EOF
        echo -e "${GREEN}✓ Created .dockerignore file${NC}"
        echo ""
    fi
}

# Migrate Docker configuration
if [ -d "$HOME/.docker" ]; then
    migrate_docker_data "$HOME/.docker" "$HOME/.docker" "Docker configuration"
fi

# Migrate Docker daemon configuration
if [ -f "/etc/docker/daemon.json" ]; then
    migrate_docker_daemon_config "/etc/docker/daemon.json"
fi

# Migrate macOS Docker Desktop data
if [ -d "$HOME/Library/Group Containers/group.com.docker" ]; then
    echo -e "${YELLOW}Warning: Docker Desktop data found at $HOME/Library/Group Containers/group.com.docker${NC}"
    echo -e "${YELLOW}This data may contain sensitive information. Manual cleanup may be required.${NC}"
    echo ""
fi

# Clean up Docker files
cleanup_docker_files

# Create .dockerignore file
create_dockerignore

# Apply stow configuration
echo -e "${YELLOW}Applying Docker privacy configuration...${NC}"
cd "$DOTFILES_DIR"
stow -d stow-packs -t ~ docker-privacy
echo -e "${GREEN}✓ Docker privacy configuration applied${NC}"
echo ""

# Add source line to shell rc files
echo -e "${YELLOW}Setting up shell configuration...${NC}"

# Add to .bashrc if not exists
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "source.*docker_privacy_config" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Source Docker privacy configuration" >> "$HOME/.bashrc"
        echo "source \"$DOCKER_PRIVACY_DIR/.docker_privacy_config\"" >> "$HOME/.bashrc"
        echo -e "${GREEN}✓ Added to .bashrc${NC}"
    fi
fi

# Add to .zshrc if not exists
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "source.*docker_privacy_config" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Source Docker privacy configuration" >> "$HOME/.zshrc"
        echo "source \"$DOCKER_PRIVACY_DIR/.docker_privacy_config\"" >> "$HOME/.zshrc"
        echo -e "${GREEN}✓ Added to .zshrc${NC}"
    fi
fi

echo -e "${GREEN}Migration completed!${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo -e "  • Docker sensitive data has been backed up"
echo -e "  • Privacy settings have been applied"
echo -e "  • Sensitive data has been cleaned from original locations"
echo -e "  • Configuration has been added to your shell rc files"
echo ""
echo -e "${BLUE}To use the new configuration:${NC}"
echo -e "  1. Restart your shell or run: source ~/.bashrc (or source ~/.zshrc)"
echo -e "  2. Restart Docker daemon to apply privacy settings"
echo -e "  3. Use the provided aliases: docker-safe, docker-private, docker-offline"
echo ""
echo -e "${YELLOW}Available commands:${NC}"
echo -e "  • docker_clean_cache - Clean Docker cache"
echo -e "  • docker_clean_logs - Clean Docker logs"
echo -e "  • docker_clean_images - Clean unused images"
echo -e "  • docker_clean_containers - Clean stopped containers"
echo -e "  • docker_clean_networks - Clean unused networks"
echo -e "  • docker_clean_volumes - Clean unused volumes"
echo -e "  • docker_reset_privacy - Reset all privacy settings"
echo -e "  • docker_show_privacy_status - Show privacy status"
echo -e "  • docker_privacy_check - Check privacy settings"
echo -e "  • docker_secure_run - Run secure container"
echo -e "  • docker_secure_build - Build secure image"
echo ""
echo -e "${YELLOW}Environment variables:${NC}"
echo -e "  • DOCKER_CONTENT_TRUST=1"
echo -e "  • DOCKER_TLS_VERIFY=1"
echo -e "  • DOCKER_BUILDKIT=0"
echo -e "  • DOCKER_SCAN_SUGGEST=false"
echo -e "  • DOCKER_CLI_EXPERIMENTAL=disabled"
echo ""
echo -e "${YELLOW}Note: This configuration prioritizes privacy over some convenience features${NC}"
echo -e "${YELLOW}Some Docker features may be restricted for security reasons${NC}"
echo ""
echo -e "${YELLOW}Important:${NC}"
echo -e "  • Docker daemon may need to be restarted for some settings to take effect"
echo -e "  • Some settings may require administrator privileges"
echo -e "  • Check Docker documentation for platform-specific requirements"