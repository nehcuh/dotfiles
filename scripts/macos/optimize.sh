#!/bin/sh
# macOS Optimization Script
# This script applies various optimizations to macOS

# Determine script directory (works in any POSIX shell)
if [ -L "$0" ]; then
  SCRIPT_PATH=$(readlink "$0")
  SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
else
  SCRIPT_DIR=$(dirname "$0")
fi

# Convert to absolute path
cd "$SCRIPT_DIR" || exit 1
SCRIPT_DIR=$(pwd)
cd - >/dev/null || exit 1

# Source common library if available
if [ -f "$SCRIPT_DIR/../lib/common.sh" ]; then
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
else
  # Define minimal logging functions if common.sh is not available
  log_info() {
    echo "[INFO] $1"
  }
  
  log_success() {
    echo "[SUCCESS] $1"
  }
  
  log_warning() {
    echo "[WARNING] $1"
  }
  
  log_error() {
    echo "[ERROR] $1" >&2
  }
fi

# Check if running on macOS
if [ "$(uname -s)" != "Darwin" ]; then
  log_error "This script is only for macOS"
  exit 1
fi

# Print header
print_header() {
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║                    macOS Optimization                        ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
}

# Confirm changes
confirm_changes() {
  log_warning "This script will modify your macOS settings."
  log_warning "Are you sure you want to continue? [y/N]"
  
  read -r response
  case "$response" in
    [yY][eE][sS]|[yY])
      return 0
      ;;
    *)
      log_info "Optimization cancelled."
      return 1
      ;;
  esac
}

# Optimize keyboard settings
optimize_keyboard() {
  log_info "Optimizing keyboard settings..."
  
  # Set a faster key repeat rate
  defaults write NSGlobalDomain KeyRepeat -int 2
  
  # Set a shorter delay until key repeat
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  
  # Disable press-and-hold for keys in favor of key repeat
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  
  # Enable full keyboard access for all controls
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
  
  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  
  # Disable automatic capitalization
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  
  # Disable smart dashes
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  
  # Disable smart quotes
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  
  # Disable automatic period substitution
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  
  log_success "Keyboard settings optimized"
}

# Optimize trackpad settings
optimize_trackpad() {
  log_info "Optimizing trackpad settings..."
  
  # Enable tap to click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  
  # Enable secondary click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
  
  # Enable three finger drag
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
  
  # Increase tracking speed
  defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.0
  
  log_success "Trackpad settings optimized"
}

# Optimize Finder settings
optimize_finder() {
  log_info "Optimizing Finder settings..."
  
  # Show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  
  # Show status bar
  defaults write com.apple.finder ShowStatusBar -bool true
  
  # Show path bar
  defaults write com.apple.finder ShowPathbar -bool true
  
  # Display full POSIX path as Finder window title
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
  
  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true
  
  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  
  # Disable the warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  
  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  
  # Show the ~/Library folder
  chflags nohidden ~/Library
  
  # Show the /Volumes folder
  sudo chflags nohidden /Volumes
  
  log_success "Finder settings optimized"
}

# Optimize Dock settings
optimize_dock() {
  log_info "Optimizing Dock settings..."
  
  # Set the icon size of Dock items
  defaults write com.apple.dock tilesize -int 36
  
  # Change minimize/maximize window effect
  defaults write com.apple.dock mineffect -string "scale"
  
  # Minimize windows into their application's icon
  defaults write com.apple.dock minimize-to-application -bool true
  
  # Enable spring loading for all Dock items
  defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
  
  # Show indicator lights for open applications in the Dock
  defaults write com.apple.dock show-process-indicators -bool true
  
  # Don't animate opening applications from the Dock
  defaults write com.apple.dock launchanim -bool false
  
  # Speed up Mission Control animations
  defaults write com.apple.dock expose-animation-duration -float 0.1
  
  # Don't group windows by application in Mission Control
  defaults write com.apple.dock expose-group-by-app -bool false
  
  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true
  
  # Make Dock icons of hidden applications translucent
  defaults write com.apple.dock showhidden -bool true
  
  # Don't show recent applications in Dock
  defaults write com.apple.dock show-recents -bool false
  
  # Set Dock position to left
  defaults write com.apple.dock orientation -string "left"
  
  log_success "Dock settings optimized"
}

# Optimize Safari settings
optimize_safari() {
  log_info "Optimizing Safari settings..."
  
  # Show the full URL in the address bar
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
  
  # Enable the Develop menu and the Web Inspector
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
  
  # Add a context menu item for showing the Web Inspector in web views
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
  
  # Enable "Do Not Track"
  defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
  
  # Update extensions automatically
  defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true
  
  # Disable auto-playing video
  defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
  defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
  defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
  
  # Disable Safari's thumbnail cache for History and Top Sites
  defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2
  
  # Make Safari's search banners default to Contains instead of Starts With
  defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false
  
  # Disable Safari's thumbnail cache for History and Top Sites
  defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2
  
  log_success "Safari settings optimized"
}

# Optimize system settings
optimize_system() {
  log_info "Optimizing system settings..."
  
  # Disable the sound effects on boot
  sudo nvram SystemAudioVolume=" "
  
  # Disable transparency in the menu bar and elsewhere
  defaults write com.apple.universalaccess reduceTransparency -bool true
  
  # Increase window resize speed for Cocoa applications
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
  
  # Expand save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
  
  # Expand print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
  
  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  
  # Disable the "Are you sure you want to open this application?" dialog
  defaults write com.apple.LaunchServices LSQuarantine -bool false
  
  # Disable Resume system-wide
  defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false
  
  # Disable automatic termination of inactive apps
  defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true
  
  # Disable the crash reporter
  defaults write com.apple.CrashReporter DialogType -string "none"
  
  # Disable Notification Center and remove the menu bar icon
  launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null
  
  # Disable automatic capitalization as it's annoying when typing code
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  
  # Disable smart dashes as they're annoying when typing code
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  
  # Disable automatic period substitution as it's annoying when typing code
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  
  # Disable smart quotes as they're annoying when typing code
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  
  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  
  log_success "System settings optimized"
}

# Optimize energy settings
optimize_energy() {
  log_info "Optimizing energy settings..."
  
  # Enable lid wakeup
  sudo pmset -a lidwake 1
  
  # Restart automatically on power loss
  sudo pmset -a autorestart 1
  
  # Restart automatically if the computer freezes
  sudo systemsetup -setrestartfreeze on
  
  # Sleep the display after 15 minutes
  sudo pmset -a displaysleep 15
  
  # Disable machine sleep while charging
  sudo pmset -c sleep 0
  
  # Set machine sleep to 5 minutes on battery
  sudo pmset -b sleep 5
  
  # Set standby delay to 24 hours (default is 1 hour)
  sudo pmset -a standbydelay 86400
  
  # Never go into computer sleep mode
  sudo systemsetup -setcomputersleep Off > /dev/null
  
  log_success "Energy settings optimized"
}

# Optimize screenshot settings
optimize_screenshots() {
  log_info "Optimizing screenshot settings..."
  
  # Save screenshots to the desktop
  defaults write com.apple.screencapture location -string "${HOME}/Desktop"
  
  # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
  defaults write com.apple.screencapture type -string "png"
  
  # Disable shadow in screenshots
  defaults write com.apple.screencapture disable-shadow -bool true
  
  log_success "Screenshot settings optimized"
}

# Optimize development settings
optimize_development() {
  log_info "Optimizing development settings..."
  
  # Disable the annoying line marks in Terminal.app
  defaults write com.apple.Terminal ShowLineMarks -int 0
  
  # Enable Secure Keyboard Entry in Terminal.app
  defaults write com.apple.Terminal SecureKeyboardEntry -bool true
  
  # Enable the WebKit Developer Tools in the Mac App Store
  defaults write com.apple.appstore WebKitDeveloperExtras -bool true
  
  # Enable Debug Menu in the Mac App Store
  defaults write com.apple.appstore ShowDebugMenu -bool true
  
  # Enable the automatic update check
  defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
  
  # Check for software updates daily, not just once per week
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
  
  # Download newly available updates in background
  defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
  
  # Install System data files & security updates
  defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
  
  # Turn on app auto-update
  defaults write com.apple.commerce AutoUpdate -bool true
  
  log_success "Development settings optimized"
}

# Apply all optimizations
apply_all_optimizations() {
  optimize_keyboard
  optimize_trackpad
  optimize_finder
  optimize_dock
  optimize_safari
  optimize_system
  optimize_energy
  optimize_screenshots
  optimize_development
  
  log_success "All optimizations applied"
}

# Reset all settings to defaults
reset_to_defaults() {
  log_info "Resetting all settings to defaults..."
  
  # Reset keyboard settings
  defaults delete NSGlobalDomain KeyRepeat 2>/dev/null
  defaults delete NSGlobalDomain InitialKeyRepeat 2>/dev/null
  defaults delete NSGlobalDomain ApplePressAndHoldEnabled 2>/dev/null
  defaults delete NSGlobalDomain AppleKeyboardUIMode 2>/dev/null
  defaults delete NSGlobalDomain NSAutomaticSpellingCorrectionEnabled 2>/dev/null
  defaults delete NSGlobalDomain NSAutomaticCapitalizationEnabled 2>/dev/null
  defaults delete NSGlobalDomain NSAutomaticDashSubstitutionEnabled 2>/dev/null
  defaults delete NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled 2>/dev/null
  defaults delete NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled 2>/dev/null
  
  # Reset trackpad settings
  defaults delete com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking 2>/dev/null
  defaults -currentHost delete NSGlobalDomain com.apple.mouse.tapBehavior 2>/dev/null
  defaults delete NSGlobalDomain com.apple.mouse.tapBehavior 2>/dev/null
  defaults delete com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick 2>/dev/null
  defaults -currentHost delete NSGlobalDomain com.apple.trackpad.enableSecondaryClick 2>/dev/null
  defaults delete com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag 2>/dev/null
  defaults delete com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag 2>/dev/null
  defaults delete NSGlobalDomain com.apple.trackpad.scaling 2>/dev/null
  
  # Reset Finder settings
  defaults delete NSGlobalDomain AppleShowAllExtensions 2>/dev/null
  defaults delete com.apple.finder ShowStatusBar 2>/dev/null
  defaults delete com.apple.finder ShowPathbar 2>/dev/null
  defaults delete com.apple.finder _FXShowPosixPathInTitle 2>/dev/null
  defaults delete com.apple.finder _FXSortFoldersFirst 2>/dev/null
  defaults delete com.apple.finder FXDefaultSearchScope 2>/dev/null
  defaults delete com.apple.finder FXEnableExtensionChangeWarning 2>/dev/null
  defaults delete com.apple.desktopservices DSDontWriteNetworkStores 2>/dev/null
  defaults delete com.apple.desktopservices DSDontWriteUSBStores 2>/dev/null
  
  # Reset Dock settings
  defaults delete com.apple.dock tilesize 2>/dev/null
  defaults delete com.apple.dock mineffect 2>/dev/null
  defaults delete com.apple.dock minimize-to-application 2>/dev/null
  defaults delete com.apple.dock enable-spring-load-actions-on-all-items 2>/dev/null
  defaults delete com.apple.dock show-process-indicators 2>/dev/null
  defaults delete com.apple.dock launchanim 2>/dev/null
  defaults delete com.apple.dock expose-animation-duration 2>/dev/null
  defaults delete com.apple.dock expose-group-by-app 2>/dev/null
  defaults delete com.apple.dock autohide 2>/dev/null
  defaults delete com.apple.dock showhidden 2>/dev/null
  defaults delete com.apple.dock show-recents 2>/dev/null
  defaults delete com.apple.dock orientation 2>/dev/null
  
  # Reset Safari settings
  defaults delete com.apple.Safari ShowFullURLInSmartSearchField 2>/dev/null
  defaults delete com.apple.Safari IncludeDevelopMenu 2>/dev/null
  defaults delete com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey 2>/dev/null
  defaults delete com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled 2>/dev/null
  defaults delete NSGlobalDomain WebKitDeveloperExtras 2>/dev/null
  defaults delete com.apple.Safari SendDoNotTrackHTTPHeader 2>/dev/null
  defaults delete com.apple.Safari InstallExtensionUpdatesAutomatically 2>/dev/null
  defaults delete com.apple.Safari WebKitMediaPlaybackAllowsInline 2>/dev/null
  defaults delete com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline 2>/dev/null
  defaults delete com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback 2>/dev/null
  defaults delete com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback 2>/dev/null
  defaults delete com.apple.Safari DebugSnapshotsUpdatePolicy 2>/dev/null
  defaults delete com.apple.Safari FindOnPageMatchesWordStartsOnly 2>/dev/null
  
  # Reset system settings
  defaults delete com.apple.universalaccess reduceTransparency 2>/dev/null
  defaults delete NSGlobalDomain NSWindowResizeTime 2>/dev/null
  defaults delete NSGlobalDomain NSNavPanelExpandedStateForSaveMode 2>/dev/null
  defaults delete NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 2>/dev/null
  defaults delete NSGlobalDomain PMPrintingExpandedStateForPrint 2>/dev/null
  defaults delete NSGlobalDomain PMPrintingExpandedStateForPrint2 2>/dev/null
  defaults delete NSGlobalDomain NSDocumentSaveNewDocumentsToCloud 2>/dev/null
  defaults delete com.apple.LaunchServices LSQuarantine 2>/dev/null
  defaults delete com.apple.systempreferences NSQuitAlwaysKeepsWindows 2>/dev/null
  defaults delete NSGlobalDomain NSDisableAutomaticTermination 2>/dev/null
  defaults delete com.apple.CrashReporter DialogType 2>/dev/null
  
  # Reset screenshot settings
  defaults delete com.apple.screencapture location 2>/dev/null
  defaults delete com.apple.screencapture type 2>/dev/null
  defaults delete com.apple.screencapture disable-shadow 2>/dev/null
  
  # Reset development settings
  defaults delete com.apple.Terminal ShowLineMarks 2>/dev/null
  defaults delete com.apple.Terminal SecureKeyboardEntry 2>/dev/null
  defaults delete com.apple.appstore WebKitDeveloperExtras 2>/dev/null
  defaults delete com.apple.appstore ShowDebugMenu 2>/dev/null
  defaults delete com.apple.SoftwareUpdate AutomaticCheckEnabled 2>/dev/null
  defaults delete com.apple.SoftwareUpdate ScheduleFrequency 2>/dev/null
  defaults delete com.apple.SoftwareUpdate AutomaticDownload 2>/dev/null
  defaults delete com.apple.SoftwareUpdate CriticalUpdateInstall 2>/dev/null
  defaults delete com.apple.commerce AutoUpdate 2>/dev/null
  
  log_success "All settings reset to defaults"
}

# Restart affected applications
restart_applications() {
  log_info "Restarting affected applications..."
  
  for app in "Dock" "Finder" "Safari" "SystemUIServer"; do
    killall "${app}" > /dev/null 2>&1
  done
  
  log_success "Applications restarted"
  log_warning "Some changes may require a logout/restart to take effect."
}

# Show menu
show_menu() {
  print_header
  
  echo "Please select an option:"
  echo ""
  echo "1) Apply all optimizations"
  echo "2) Optimize keyboard settings"
  echo "3) Optimize trackpad settings"
  echo "4) Optimize Finder settings"
  echo "5) Optimize Dock settings"
  echo "6) Optimize Safari settings"
  echo "7) Optimize system settings"
  echo "8) Optimize energy settings"
  echo "9) Optimize screenshot settings"
  echo "10) Optimize development settings"
  echo "11) Reset all settings to defaults"
  echo "12) Exit"
  echo ""
  echo -n "Enter your choice [1-12]: "
  
  read -r choice
  
  case "$choice" in
    1)
      if confirm_changes; then
        apply_all_optimizations
        restart_applications
      fi
      ;;
    2)
      if confirm_changes; then
        optimize_keyboard
        restart_applications
      fi
      ;;
    3)
      if confirm_changes; then
        optimize_trackpad
        restart_applications
      fi
      ;;
    4)
      if confirm_changes; then
        optimize_finder
        restart_applications
      fi
      ;;
    5)
      if confirm_changes; then
        optimize_dock
        restart_applications
      fi
      ;;
    6)
      if confirm_changes; then
        optimize_safari
        restart_applications
      fi
      ;;
    7)
      if confirm_changes; then
        optimize_system
        restart_applications
      fi
      ;;
    8)
      if confirm_changes; then
        optimize_energy
        restart_applications
      fi
      ;;
    9)
      if confirm_changes; then
        optimize_screenshots
        restart_applications
      fi
      ;;
    10)
      if confirm_changes; then
        optimize_development
        restart_applications
      fi
      ;;
    11)
      if confirm_changes; then
        reset_to_defaults
        restart_applications
      fi
      ;;
    12)
      log_info "Exiting..."
      exit 0
      ;;
    *)
      log_error "Invalid choice. Please try again."
      show_menu
      ;;
  esac
}

# Main function
main() {
  # Check if running with sudo
  if [ "$(id -u)" -eq 0 ]; then
    log_error "Please do not run this script with sudo."
    log_error "The script will ask for your password when needed."
    exit 1
  fi
  
  # Show menu
  show_menu
}

# Run main function
main "$@"