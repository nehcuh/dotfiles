#!/bin/bash
# Quick macOS Optimization Script
# Applies common macOS optimizations quickly

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Quick macOS Optimization${NC}"
echo -e "${YELLOW}This will apply common macOS optimizations...${NC}"

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
# Essential Optimizations
###############################################################################

echo -e "${YELLOW}Applying essential optimizations...${NC}"

# Keyboard: faster repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Enable full keyboard access
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Trackpad: enable right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# Mouse: enable secondary click (right-click)
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode -string "TwoButton"

# Enable mouse button assistive features
defaults write com.apple.universalaccess mouseDriverTracking -bool true
defaults write com.apple.universalaccess mouseDriverHIDClickAssist -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show path bar and status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Dock: auto-hide and smaller icons
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock minimize-to-application -bool true

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Safari: show full URL and disable suggestions
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable smart quotes and dashes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

###############################################################################
# Kill affected applications
###############################################################################

echo -e "${YELLOW}Restarting affected applications...${NC}"

for app in "Dock" "Finder" "SystemUIServer"; do
    killall "${app}" &> /dev/null
done

echo -e "${GREEN}✓ Quick optimizations applied successfully!${NC}"
echo -e "${YELLOW}Note: Some changes may require a restart to take effect.${NC}"
echo -e "${BLUE}For more advanced optimizations, run: ~/.config/macos/optimize.sh${NC}"