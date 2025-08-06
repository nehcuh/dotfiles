#!/bin/bash
# macOS Settings Reset Script
# Resets macOS settings to defaults

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}macOS Settings Reset${NC}"
echo -e "${YELLOW}This will reset macOS settings to defaults...${NC}"

# Ask for confirmation
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Operation cancelled.${NC}"
    exit 1
fi

# Ask for password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# Reset Keyboard Settings
###############################################################################

echo -e "${YELLOW}Resetting keyboard settings...${NC}"

# Reset keyboard repeat rate
defaults delete NSGlobalDomain KeyRepeat 2>/dev/null || true
defaults delete NSGlobalDomain InitialKeyRepeat 2>/dev/null || true

# Reset press-and-hold
defaults delete NSGlobalDomain ApplePressAndHoldEnabled 2>/dev/null || true

# Reset keyboard access mode
defaults delete NSGlobalDomain AppleKeyboardUIMode 2>/dev/null || true

# Reset auto-correct and smart quotes
defaults delete NSGlobalDomain NSAutomaticSpellingCorrectionEnabled 2>/dev/null || true
defaults delete NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled 2>/dev/null || true
defaults delete NSGlobalDomain NSAutomaticDashSubstitutionEnabled 2>/dev/null || true

###############################################################################
# Reset Mouse & Trackpad Settings
###############################################################################

echo -e "${YELLOW}Resetting mouse and trackpad settings...${NC}"

# Reset trackpad clicking
defaults delete com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking 2>/dev/null || true
defaults delete -currentHost NSGlobalDomain com.apple.mouse.tapBehavior 2>/dev/null || true
defaults delete NSGlobalDomain com.apple.mouse.tapBehavior 2>/dev/null || true

# Reset natural scrolling
defaults delete NSGlobalDomain com.apple.swipescrolldirection 2>/dev/null || true

# Reset mouse scaling
defaults delete NSGlobalDomain com.apple.mouse.scaling 2>/dev/null || true

###############################################################################
# Reset Finder Settings
###############################################################################

echo -e "${YELLOW}Resetting Finder settings...${NC}"

# Reset hidden files and extensions
defaults delete com.apple.finder AppleShowAllFiles 2>/dev/null || true
defaults delete NSGlobalDomain AppleShowAllExtensions 2>/dev/null || true

# Reset path bar and status bar
defaults delete com.apple.finder ShowPathbar 2>/dev/null || true
defaults delete com.apple.finder ShowStatusBar 2>/dev/null || true

# Reset icon view settings
defaults delete com.apple.finder FXPreferredViewStyle 2>/dev/null || true

# Reset desktop icons
defaults delete com.apple.finder ShowExternalHardDrivesOnDesktop 2>/dev/null || true
defaults delete com.apple.finder ShowHardDrivesOnDesktop 2>/dev/null || true
defaults delete com.apple.finder ShowMountedServersOnDesktop 2>/dev/null || true
defaults delete com.apple.finder ShowRemovableMediaOnDesktop 2>/dev/null || true

###############################################################################
# Reset Dock Settings
###############################################################################

echo -e "${YELLOW}Resetting Dock settings...${NC}"

# Reset auto-hide and icon size
defaults delete com.apple.dock autohide 2>/dev/null || true
defaults delete com.apple.dock tilesize 2>/dev/null || true
defaults delete com.apple.dock minimize-to-application 2>/dev/null || true
defaults delete com.apple.dock mineffect 2>/dev/null || true
defaults delete com.apple.dock mru-spaces 2>/dev/null || true

# Reset Dashboard
defaults delete com.apple.dashboard mcx-disabled 2>/dev/null || true

###############################################################################
# Reset Safari Settings
###############################################################################

echo -e "${YELLOW}Resetting Safari settings...${NC}"

defaults delete com.apple.Safari ShowFullURLInSmartSearchField 2>/dev/null || true
defaults delete com.apple.Safari UniversalSearchEnabled 2>/dev/null || true
defaults delete com.apple.Safari SuppressSearchSuggestions 2>/dev/null || true
defaults delete com.apple.Safari IncludeDevelopMenu 2>/dev/null || true

###############################################################################
# Kill affected applications
###############################################################################

echo -e "${YELLOW}Restarting affected applications...${NC}"

for app in "Dock" "Finder" "SystemUIServer" "Safari"; do
    killall "${app}" &> /dev/null
done

echo -e "${GREEN}✓ Settings reset to defaults!${NC}"
echo -e "${YELLOW}Note: Some changes may require a restart to take effect.${NC}"