#!/bin/sh
# Uninstall script for dotfiles
# This script removes all dotfiles and restores original configuration

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

# Source common library
# shellcheck disable=SC1091
. "$SCRIPT_DIR/lib/common.sh"

# Print header
print_header() {
  print_color "$CYAN" "╔══════════════════════════════════════════════════════════════╗"
  print_color "$CYAN" "║                    Dotfiles Uninstaller                      ║"
  print_color "$CYAN" "╚══════════════════════════════════════════════════════════════╝"
  printf "\n"
  log_info "Platform: $PLATFORM ($DISTRO) on $ARCH"
  log_info "Shell: $CURRENT_SHELL ($SHELL_TYPE)"
  printf "\n"
}

# Confirm uninstallation
confirm_uninstall() {
  log_warning "This will remove all dotfiles and restore original configuration."
  log_warning "Are you sure you want to continue? [y/N]"
  
  read -r response
  case "$response" in
    [yY][eE][sS]|[yY])
      return 0
      ;;
    *)
      log_info "Uninstallation cancelled."
      return 1
      ;;
  esac
}

# Remove dotfiles using stow
remove_dotfiles() {
  log_info "Removing dotfiles..."
  
  # Check if stow is installed
  if ! command_exists stow; then
    log_error "GNU Stow is not installed"
    return 1
  fi
  
  # Check if stow directory exists
  if [ ! -d "$STOW_DIR" ]; then
    log_error "Stow directory not found: $STOW_DIR"
    return 1
  fi
  
  # Get all packages
  packages=""
  for pkg in "$STOW_DIR"/*; do
    if [ -d "$pkg" ]; then
      pkg_name=$(basename "$pkg")
      if [ -z "$packages" ]; then
        packages="$pkg_name"
      else
        packages="$packages $pkg_name"
      fi
    fi
  done
  
  if [ -z "$packages" ]; then
    log_warning "No packages found in $STOW_DIR"
    return 0
  fi
  
  # Remove all packages
  log_info "Removing packages: $packages"
  
  for pkg in $packages; do
    log_info "Removing $pkg..."
    cd "$STOW_DIR" || exit 1
    stow -v -D -t "$TARGET_DIR" "$pkg" 2>/dev/null || true
    log_success "✓ $pkg removed"
  done
  
  log_success "All dotfiles removed"
  return 0
}

# Restore backups if available
restore_backups() {
  log_info "Checking for backups..."
  
  # Find the most recent backup
  backup_dir=$(find "$HOME" -maxdepth 1 -name ".dotfiles-backup-*" -type d | sort -r | head -n 1)
  
  if [ -z "$backup_dir" ]; then
    log_warning "No backup found"
    return 0
  fi
  
  log_info "Found backup: $backup_dir"
  log_info "Restoring from backup..."
  
  # Restore all files from backup
  for file in "$backup_dir"/*; do
    if [ -f "$file" ]; then
      filename=$(basename "$file")
      cp -f "$file" "$HOME/$filename"
      log_success "✓ Restored $filename"
    fi
  done
  
  log_success "Backup restored"
  return 0
}

# Clean up dotfiles directory
clean_up() {
  log_info "Cleaning up..."
  
  # Ask if user wants to remove dotfiles directory
  log_warning "Do you want to remove the dotfiles directory? [y/N]"
  
  read -r response
  case "$response" in
    [yY][eE][sS]|[yY])
      if [ -d "$DOTFILES_DIR" ]; then
        rm -rf "$DOTFILES_DIR"
        log_success "✓ Dotfiles directory removed"
      fi
      ;;
    *)
      log_info "Keeping dotfiles directory"
      ;;
  esac
  
  # Clean up any broken symlinks in home directory
  log_info "Cleaning up broken symlinks..."
  find "$HOME" -maxdepth 1 -type l -exec test ! -e {} \; -delete
  
  log_success "Cleanup complete"
  return 0
}

# Main function
main() {
  print_header
  
  # Load configuration
  if [ -f "$DOTFILES_DIR/dotfiles.conf" ]; then
    load_config "$DOTFILES_DIR/dotfiles.conf"
  fi
  
  # Confirm uninstallation
  if ! confirm_uninstall; then
    exit 0
  fi
  
  # Remove dotfiles
  if ! remove_dotfiles; then
    log_error "Failed to remove dotfiles"
  fi
  
  # Restore backups
  if ! restore_backups; then
    log_warning "Failed to restore backups"
  fi
  
  # Clean up
  if ! clean_up; then
    log_warning "Failed to clean up"
  fi
  
  log_success "Uninstallation complete"
}

# Run main function
main "$@"