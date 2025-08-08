#!/bin/bash
# VS Code Extensions Installation Script
# Automatically installs extensions from extensions.json

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
log_header() { echo -e "${CYAN}[VSCODE]${NC} $1"; }

echo "========================================"
echo "    VS Code Extensions Installation     "
echo "========================================"
echo

# Check if VS Code is installed
if ! command -v code &> /dev/null; then
    log_error "VS Code command line tool not found"
    log_info "Please install VS Code first or ensure 'code' command is in PATH"
    exit 1
fi

log_info "VS Code found: $(code --version | head -1)"

# Find extensions.json file
EXTENSIONS_FILE=""
POSSIBLE_PATHS=(
    "$HOME/.config/Code/User/extensions.json"
    "$HOME/.dotfiles/stow-packs/vscode/.config/Code/User/extensions.json"
    "./stow-packs/vscode/.config/Code/User/extensions.json"
)

for path in "${POSSIBLE_PATHS[@]}"; do
    if [[ -f "$path" ]]; then
        EXTENSIONS_FILE="$path"
        break
    fi
done

if [[ -z "$EXTENSIONS_FILE" ]]; then
    log_error "extensions.json file not found in any of the expected locations"
    exit 1
fi

log_info "Found extensions.json at: $EXTENSIONS_FILE"

# Extract extensions from JSON file
log_info "Reading recommended extensions..."
EXTENSIONS=$(grep -o '"[^"]*"' "$EXTENSIONS_FILE" | grep -v '"recommendations"' | sed 's/"//g' | grep -E '^[a-zA-Z0-9_.-]+\.[a-zA-Z0-9_.-]+$')

if [[ -z "$EXTENSIONS" ]]; then
    log_error "No extensions found in extensions.json"
    exit 1
fi

# Get currently installed extensions
log_info "Checking currently installed extensions..."
INSTALLED_EXTENSIONS=$(code --list-extensions)

# Install extensions
INSTALLED_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0

log_header "Installing VS Code extensions..."
echo

while IFS= read -r extension; do
    if [[ -z "$extension" ]]; then
        continue
    fi
    
    # Check if extension is already installed
    if echo "$INSTALLED_EXTENSIONS" | grep -qi "^${extension}$"; then
        log_info "✓ $extension (already installed)"
        ((SKIPPED_COUNT++))
    else
        log_info "Installing $extension..."
        if code --install-extension "$extension" --force > /dev/null 2>&1; then
            log_success "✓ $extension installed"
            ((INSTALLED_COUNT++))
        else
            log_error "✗ Failed to install $extension"
            ((FAILED_COUNT++))
        fi
    fi
done <<< "$EXTENSIONS"

echo
log_header "Installation Summary:"
log_info "Newly installed: $INSTALLED_COUNT"
log_info "Already installed: $SKIPPED_COUNT"
if [[ $FAILED_COUNT -gt 0 ]]; then
    log_warning "Failed to install: $FAILED_COUNT"
fi

echo
if [[ $FAILED_COUNT -eq 0 ]]; then
    log_success "All VS Code extensions have been successfully installed!"
else
    log_warning "Installation completed with some failures. You may want to manually install the failed extensions."
fi

log_info "Please restart VS Code to ensure all extensions are properly loaded."
