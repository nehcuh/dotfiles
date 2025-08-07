#!/bin/sh
# Stow-based dotfiles management script
# POSIX-compliant for maximum compatibility

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

# Default paths
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
STOW_DIR="$DOTFILES_DIR/stow-packs"
TARGET_DIR="$HOME"

# Load configuration if available
if [ -f "$DOTFILES_DIR/dotfiles.conf" ]; then
  load_config "$DOTFILES_DIR/dotfiles.conf"
fi

# Available packages (auto-detected from stow-packs directory)
detect_available_packages() {
  if [ ! -d "$STOW_DIR" ]; then
    log_error "Stow directory not found: $STOW_DIR"
    exit 1
  fi
  
  PACKAGES=""
  for pkg in "$STOW_DIR"/*; do
    if [ -d "$pkg" ]; then
      pkg_name=$(basename "$pkg")
      if [ -z "$PACKAGES" ]; then
        PACKAGES="$pkg_name"
      else
        PACKAGES="$PACKAGES $pkg_name"
      fi
    fi
  done
  
  if [ -z "$PACKAGES" ]; then
    log_error "No packages found in $STOW_DIR"
    exit 1
  fi
}

# Print usage information
usage() {
  echo "Usage: $0 [command] [package...]"
  echo ""
  echo "Commands:"
  echo "  install [package...]  - Install specified packages (or all if none specified)"
  echo "  remove [package...]   - Remove specified packages (or all if none specified)"
  echo "  list                  - List available packages"
  echo "  status                - Show current stow status"
  echo ""
  echo "Available packages: $PACKAGES"
  echo ""
  echo "Examples:"
  echo "  $0 install            # Install all packages"
  echo "  $0 install zsh git    # Install only zsh and git"
  echo "  $0 remove nvim        # Remove nvim package"
  echo ""
  echo "For complete uninstallation, use: ./scripts/uninstall.sh complete"
}

# List available packages
list_packages() {
  log_info "Available packages:"
  for pkg in $PACKAGES; do
    if [ -d "$STOW_DIR/$pkg" ]; then
      log_success "  ✓ $pkg"
    else
      log_error "  ✗ $pkg (not found)"
    fi
  done
}

# Check if stow is installed
check_stow() {
  if ! command_exists stow; then
    log_error "GNU Stow is not installed"
    
    case "$PLATFORM" in
      linux)
        log_warning "Installing GNU Stow..."
        install_package stow
        ;;
      macos)
        log_warning "Installing GNU Stow with Homebrew..."
        if command_exists brew; then
          brew install stow
        else
          log_error "Homebrew not found. Please install GNU Stow manually."
          exit 1
        fi
        ;;
      windows)
        log_error "Please install GNU Stow manually."
        exit 1
        ;;
    esac
    
    if ! command_exists stow; then
      log_error "Failed to install GNU Stow"
      exit 1
    fi
  fi
}

# Install packages using stow
stow_install() {
  local packages="$*"
  
  if [ -z "$packages" ]; then
    packages="$PACKAGES"
  fi
  
  log_info "Installing packages: $packages"
  
  for pkg in $packages; do
    if [ -d "$STOW_DIR/$pkg" ]; then
      log_info "Installing $pkg..."
      cd "$STOW_DIR" || exit 1
      
      # Try to stow, if conflicts exist, handle them
      if ! stow -v -t "$TARGET_DIR" "$pkg" 2>/dev/null; then
        log_warning "Conflicts detected for $pkg, backing up existing files..."
        
        # Create backup directory
        backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$backup_dir"
        
        # Find conflicting files and back them up
        # This is a bit tricky in POSIX shell, so we use a temporary file
        stow -v -t "$TARGET_DIR" -n "$pkg" 2>&1 > /tmp/stow_conflicts.txt
        
        # Process the conflicts file
        grep "existing target" /tmp/stow_conflicts.txt | while read -r line; do
          # Extract the filename from the line
          # This is a simplified version and might need adjustment
          conflict_file=$(echo "$line" | sed -E 's/.*existing target is (.*): .*$/\1/')
          
          if [ -f "$TARGET_DIR/$conflict_file" ] && [ ! -L "$TARGET_DIR/$conflict_file" ]; then
            log_warning "  Backing up $conflict_file"
            mkdir -p "$backup_dir/$(dirname "$conflict_file")"
            cp "$TARGET_DIR/$conflict_file" "$backup_dir/$conflict_file"
            rm -f "$TARGET_DIR/$conflict_file"
          fi
        done
        
        rm -f /tmp/stow_conflicts.txt
        
        # Try stowing again
        if stow -v -t "$TARGET_DIR" "$pkg"; then
          log_success "✓ $pkg installed (conflicts backed up to $backup_dir)"
        else
          log_error "✗ Failed to install $pkg"
        fi
      else
        log_success "✓ $pkg installed"
      fi
    else
      log_error "✗ Package $pkg not found"
    fi
  done
}

# Remove packages using stow
stow_remove() {
  local packages="$*"
  
  if [ -z "$packages" ]; then
    packages="$PACKAGES"
  fi
  
  log_warning "Removing packages: $packages"
  
  for pkg in $packages; do
    if [ -d "$STOW_DIR/$pkg" ]; then
      log_warning "Removing $pkg..."
      cd "$STOW_DIR" || exit 1
      stow -v -D -t "$TARGET_DIR" "$pkg"
      log_success "✓ $pkg removed"
    else
      log_error "✗ Package $pkg not found"
    fi
  done
}

# Show current stow status
show_status() {
  log_info "Current stow status:"
  cd "$STOW_DIR" || exit 1
  
  for pkg in $PACKAGES; do
    if [ -d "$pkg" ]; then
      log_warning "Checking $pkg:"
      stow_output=$(stow -v -t "$TARGET_DIR" -n "$pkg" 2>&1)
      if echo "$stow_output" | grep -q "existing target"; then
        echo "$stow_output" | grep -E "(existing|linking)"
      else
        log_success "  No conflicts found"
      fi
    fi
  done
}

# Main logic
main() {
  # Detect available packages
  detect_available_packages
  
  # Check if stow is installed
  check_stow
  
  # Process command
  case "${1:-help}" in
    install)
      shift
      stow_install "$@"
      ;;
    remove)
      shift
      stow_remove "$@"
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
      log_error "Unknown command: $1"
      usage
      exit 1
      ;;
  esac
}

# Run main function
main "$@"