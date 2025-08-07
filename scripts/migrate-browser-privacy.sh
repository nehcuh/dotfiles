#!/bin/bash
# Browser Privacy Migration Script
# This script helps migrate existing browser sensitive data to the privacy-protected structure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Browser Privacy Migration Script${NC}"
echo -e "${YELLOW}This script will help you migrate browser sensitive data to the privacy-protected structure${NC}"
echo ""

# Get the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
BROWSER_PRIVACY_DIR="$DOTFILES_DIR/stow-packs/browser-privacy/home"

# Check if the privacy directory exists
if [ ! -d "$BROWSER_PRIVACY_DIR" ]; then
    echo -e "${RED}Error: Browser privacy directory not found: $BROWSER_PRIVACY_DIR${NC}"
    exit 1
fi

# Function to backup and migrate browser data
migrate_browser_data() {
    local browser_name="$1"
    local config_dir="$2"
    local profile_dir="$3"
    local description="$4"
    
    if [ -d "$config_dir" ]; then
        echo -e "${YELLOW}Migrating $browser_name data...${NC}"
        echo -e "${YELLOW}  Location: $config_dir${NC}"
        
        # Create backup
        local backup_dir="${config_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$config_dir" "$backup_dir"
        echo -e "${GREEN}✓ Backup created: $backup_dir${NC}"
        
        # Apply privacy settings if profile directory exists
        if [ -d "$profile_dir" ]; then
            echo -e "${YELLOW}  Applying privacy settings to profile...${NC}"
            
            # For Firefox, copy user.js file
            if [ "$browser_name" = "Firefox" ] && [ -f "$BROWSER_PRIVACY_DIR/.mozilla/firefox/user.js" ]; then
                cp "$BROWSER_PRIVACY_DIR/.mozilla/firefox/user.js" "$profile_dir/user.js"
                echo -e "${GREEN}✓ Firefox privacy settings applied to: $profile_dir/user.js${NC}"
            fi
            
            # For Chrome/Chromium/Brave, copy privacy settings
            if [[ "$browser_name" =~ ^(Chrome|Chromium|Brave)$ ]]; then
                local privacy_settings_file=""
                case "$browser_name" in
                    "Chrome")
                        privacy_settings_file="$BROWSER_PRIVACY_DIR/.config/google-chrome/Privacy_Settings.json"
                        ;;
                    "Chromium")
                        privacy_settings_file="$BROWSER_PRIVACY_DIR/.config/chromium/Privacy_Settings.json"
                        ;;
                    "Brave")
                        privacy_settings_file="$BROWSER_PRIVACY_DIR/.config/BraveSoftware/Brave-Browser/Privacy_Settings.json"
                        ;;
                esac
                
                if [ -f "$privacy_settings_file" ]; then
                    mkdir -p "$profile_dir"
                    cp "$privacy_settings_file" "$profile_dir/Privacy_Settings.json"
                    echo -e "${GREEN}✓ $browser_name privacy settings applied to: $profile_dir/Privacy_Settings.json${NC}"
                fi
            fi
        fi
        
        # Clean up sensitive data
        echo -e "${YELLOW}  Cleaning up sensitive data...${NC}"
        
        # Common cleanup for all browsers
        find "$config_dir" -name "History*" -type f -delete 2>/dev/null || true
        find "$config_dir" -name "Cookies*" -type f -delete 2>/dev/null || true
        find "$config_dir" -name "Login Data*" -type f -delete 2>/dev/null || true
        find "$config_dir" -name "Web Data*" -type f -delete 2>/dev/null || true
        find "$config_dir" -name "Bookmarks*" -type f -delete 2>/dev/null || true
        find "$config_dir" -name "Top Sites*" -type f -delete 2>/dev/null || true
        find "$config_dir" -name "Visited Links*" -type f -delete 2>/dev/null || true
        find "$config_dir" -name "Session Store*" -type f -delete 2>/dev/null || true
        find "$config_dir" -name "Tabs*" -type f -delete 2>/dev/null || true
        find "$config_dir" -name "Network Action Predictor*" -type f -delete 2>/dev/null || true
        find "$config_dir" -name "QuotaManager*" -type f -delete 2>/dev/null || true
        find "$config_dir" -name "Origin Bound Certs*" -type f -delete 2>/dev/null || true
        
        # Firefox specific cleanup
        if [ "$browser_name" = "Firefox" ]; then
            find "$config_dir" -name "places.sqlite*" -type f -delete 2>/dev/null || true
            find "$config_dir" -name "formhistory.sqlite*" -type f -delete 2>/dev/null || true
            find "$config_dir" -name "downloads.sqlite*" -type f -delete 2>/dev/null || true
            find "$config_dir" -name "webappsstore.sqlite*" -type f -delete 2>/dev/null || true
            find "$config_dir" -name "signons.sqlite*" -type f -delete 2>/dev/null || true
            find "$config_dir" -name "permissions.sqlite*" -type f -delete 2>/dev/null || true
            find "$config_dir" -name "content-prefs.sqlite*" -type f -delete 2>/dev/null || true
            find "$config_dir" -name "healthreport.sqlite*" -type f -delete 2>/dev/null || true
            find "$config_dir" -name "thumbnails.sqlite*" -type f -delete 2>/dev/null || true
            find "$config_dir" -name "favicons.sqlite*" -type f -delete 2>/dev/null || true
            
            # Remove Firefox telemetry and crash reports
            rm -rf "$config_dir"/*/Crash Reports 2>/dev/null || true
            rm -rf "$config_dir"/*/datareporting 2>/dev/null || true
            rm -rf "$config_dir"/*/gmp-gmpopenh264 2>/dev/null || true
            rm -rf "$config_dir"/*/safebrowsing 2>/dev/null || true
            rm -rf "$config_dir"/*/storage 2>/dev/null || true
            rm -rf "$config_dir"/*/startupCache 2>/dev/null || true
            rm -rf "$config_dir"/*/minidumps 2>/dev/null || true
            rm -rf "$config_dir"/*/saved-telemetry-pings 2>/dev/null || true
            rm -rf "$config_dir"/*/shield-preference-experiments 2>/dev/null || true
            rm -rf "$config_dir"/*/times.json 2>/dev/null || true
        fi
        
        # Chrome/Chromium/Brave specific cleanup
        if [[ "$browser_name" =~ ^(Chrome|Chromium|Brave)$ ]]; then
            find "$config_dir" -name "Cache*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "GPUCache*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "Media Cache*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "Service Worker*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "File System*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "IndexedDB*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "Local Storage*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "Session Storage*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "Web Applications*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "Extensions*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "Extension Rules*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "Extension State*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "DawnCache*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "ShaderCache*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "TextureCache*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "VideoDecodeStats*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "WRI*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "blob_storage*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "databases*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "grit*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "pnacl*" -type d -exec rm -rf {} + 2>/dev/null || true
            find "$config_dir" -name "Pepper Data*" -type d -exec rm -rf {} + 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✓ Sensitive data cleaned from $description${NC}"
        echo ""
    fi
}

# Function to clean browser cache
clean_browser_cache() {
    local browser_name="$1"
    local cache_dir="$2"
    
    if [ -d "$cache_dir" ]; then
        echo -e "${YELLOW}Cleaning $browser_name cache...${NC}"
        
        # Create backup
        local backup_dir="${cache_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$cache_dir" "$backup_dir"
        echo -e "${GREEN}✓ Cache backup created: $backup_dir${NC}"
        
        # Remove cache
        rm -rf "$cache_dir"
        echo -e "${GREEN}✓ $browser_name cache cleaned${NC}"
        echo ""
    fi
}

# Migrate Firefox data
if [ -d "$HOME/.mozilla/firefox" ]; then
    # Find the default profile directory
    local firefox_profile=$(find "$HOME/.mozilla/firefox" -name "*.default-release" -o -name "*.default" -o -name "*.default-esr" | head -1)
    if [ -n "$firefox_profile" ]; then
        migrate_browser_data "Firefox" "$HOME/.mozilla/firefox" "$firefox_profile" "Firefox configuration"
    else
        migrate_browser_data "Firefox" "$HOME/.mozilla/firefox" "" "Firefox configuration"
    fi
    clean_browser_cache "Firefox" "$HOME/.cache/mozilla/firefox"
fi

# Migrate Chrome data
if [ -d "$HOME/.config/google-chrome" ]; then
    migrate_browser_data "Chrome" "$HOME/.config/google-chrome" "$HOME/.config/google-chrome/Default" "Chrome configuration"
    clean_browser_cache "Chrome" "$HOME/.cache/google-chrome"
fi

# Migrate Chromium data
if [ -d "$HOME/.config/chromium" ]; then
    migrate_browser_data "Chromium" "$HOME/.config/chromium" "$HOME/.config/chromium/Default" "Chromium configuration"
    clean_browser_cache "Chromium" "$HOME/.cache/chromium"
fi

# Migrate Brave data
if [ -d "$HOME/.config/BraveSoftware/Brave-Browser" ]; then
    migrate_browser_data "Brave" "$HOME/.config/BraveSoftware/Brave-Browser" "$HOME/.config/BraveSoftware/Brave-Browser/Default" "Brave configuration"
    clean_browser_cache "Brave" "$HOME/.cache/BraveSoftware/Brave-Browser"
fi

# Apply stow configuration
echo -e "${YELLOW}Applying browser privacy configuration...${NC}"
cd "$DOTFILES_DIR"
stow -d stow-packs -t ~ browser-privacy
echo -e "${GREEN}✓ Browser privacy configuration applied${NC}"
echo ""

# Add source line to shell rc files
echo -e "${YELLOW}Setting up shell configuration...${NC}"

# Add to .bashrc if not exists
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "source.*browser_privacy_config" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Source browser privacy configuration" >> "$HOME/.bashrc"
        echo "source \"$BROWSER_PRIVACY_DIR/.browser_privacy_config\"" >> "$HOME/.bashrc"
        echo -e "${GREEN}✓ Added to .bashrc${NC}"
    fi
fi

# Add to .zshrc if not exists
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "source.*browser_privacy_config" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Source browser privacy configuration" >> "$HOME/.zshrc"
        echo "source \"$BROWSER_PRIVACY_DIR/.browser_privacy_config\"" >> "$HOME/.zshrc"
        echo -e "${GREEN}✓ Added to .zshrc${NC}"
    fi
fi

echo -e "${GREEN}Migration completed!${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo -e "  • Browser sensitive data has been backed up"
echo -e "  • Privacy settings have been applied"
echo -e "  • Sensitive data has been cleaned from original locations"
echo -e "  • Cache has been cleaned"
echo -e "  • Configuration has been added to your shell rc files"
echo ""
echo -e "${BLUE}To use the new configuration:${NC}"
echo -e "  1. Restart your shell or run: source ~/.bashrc (or source ~/.zshrc)"
echo -e "  2. Restart your browsers to apply privacy settings"
echo -e "  3. Use the provided aliases: firefox-private, chrome-private, brave-private"
echo ""
echo -e "${YELLOW}Available commands:${NC}"
echo -e "  • firefox_clean_cache - Clean Firefox cache"
echo -e "  • firefox_clean_data - Clean Firefox data"
echo -e "  • firefox_reset_profile - Reset Firefox profile"
echo -e "  • chrome_clean_cache - Clean Chrome cache"
echo -e "  • chrome_clean_data - Clean Chrome data"
echo -e "  • chromium_clean_cache - Clean Chromium cache"
echo -e "  • chromium_clean_data - Clean Chromium data"
echo -e "  • brave_clean_cache - Clean Brave cache"
echo -e "  • brave_clean_data - Clean Brave data"
echo -e "  • browsers_clean_all_cache - Clean all browser caches"
echo -e "  • browsers_clean_all_data - Clean all browser data"
echo -e "  • browser_show_privacy_status - Show privacy status"
echo -e "  • browser_privacy_check - Check privacy settings"
echo ""
echo -e "${YELLOW}Privacy aliases:${NC}"
echo -e "  • firefox-private - Firefox with maximum privacy"
echo -e "  • chrome-private - Chrome with maximum privacy"
echo -e "  • chromium-private - Chromium with maximum privacy"
echo -e "  • brave-private - Brave with maximum privacy"
echo ""
echo -e "${YELLOW}Environment variables:${NC}"
echo -e "  • FIREFOX_TELEMETRY_DISABLED=1"
echo -e "  • FIREFOX_AUTO_UPDATE=0"
echo -e "  • FIREFOX_SYNC_DISABLED=1"
echo -e "  • FIREFOX_DATA_COLLECTION_DISABLED=1"
echo -e "  • CHROME_TELEMETRY_DISABLED=1"
echo -e "  • CHROME_AUTO_UPDATE=0"
echo -e "  • CHROME_SYNC_DISABLED=1"
echo -e "  • CHROME_DATA_COLLECTION_DISABLED=1"
echo -e "  • BRAVE_TELEMETRY_DISABLED=1"
echo -e "  • BRAVE_AUTO_UPDATE=0"
echo -e "  • BRAVE_SYNC_DISABLED=1"
echo -e "  • BRAVE_DATA_COLLECTION_DISABLED=1"
echo ""
echo -e "${YELLOW}Note: This configuration prioritizes privacy over some convenience features${NC}"
echo -e "${YELLOW}Some websites may not work properly in maximum privacy mode${NC}"
echo -e "${YELLOW}You can adjust privacy levels by using different aliases (firefox, firefox-safe, firefox-private)${NC}"