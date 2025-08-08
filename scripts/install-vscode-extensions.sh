#!/bin/bash

# VS Code Extensions Auto-Installer
# Automatically installs all recommended extensions from extensions.json

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${CYAN}[VSCODE]${NC} $1"; }

# Check if VS Code is installed
check_vscode() {
    local vscode_cmd=""
    
    # Try different VS Code command names
    if command -v code &> /dev/null; then
        vscode_cmd="code"
    elif command -v code-insiders &> /dev/null; then
        vscode_cmd="code-insiders"
    elif command -v codium &> /dev/null; then
        vscode_cmd="codium"  # VSCodium
    elif [[ -f "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
        # macOS app bundle
        vscode_cmd="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    elif [[ -f "/usr/share/code/bin/code" ]]; then
        # Linux system installation
        vscode_cmd="/usr/share/code/bin/code"
    else
        return 1
    fi
    
    echo "$vscode_cmd"
    return 0
}

# Extract extension IDs from extensions.json
get_extension_list() {
    local extensions_file="$1"
    
    if [[ ! -f "$extensions_file" ]]; then
        print_error "Extensions file not found: $extensions_file"
        return 1
    fi
    
    # Extract extension IDs, removing comments, quotes, commas, and empty lines
    # Match lines that contain extension IDs in quotes
    cat "$extensions_file" | \
        grep '"[^"]*\.[^"]*"' | \
        sed 's/.*"\([^"]*\.[^"]*\)".*/\1/' | \
        sed 's/,\s*$//' | \
        grep -v '^$' | \
        sort -u
}

# Install extensions
install_extensions() {
    local vscode_cmd="$1"
    local extensions_file="$2"
    
    print_header "Installing VS Code extensions..."
    
    local extensions
    extensions=$(get_extension_list "$extensions_file")
    
    if [[ -z "$extensions" ]]; then
        print_warning "No extensions found in $extensions_file"
        return 1
    fi
    
    local total_count
    total_count=$(echo "$extensions" | wc -l)
    local current=0
    local installed=0
    local skipped=0
    local failed=0
    
    print_info "Found $total_count extensions to install"
    echo
    
    # Get already installed extensions
    local installed_extensions
    installed_extensions=$("$vscode_cmd" --list-extensions 2>/dev/null || echo "")
    
    while IFS= read -r extension; do
        ((current++))
        
        if [[ -z "$extension" ]]; then
            continue
        fi
        
        printf "[%2d/%d] %-50s " "$current" "$total_count" "$extension"
        
        # Check if already installed
        if echo "$installed_extensions" | grep -qi "^$extension$"; then
            echo -e "${GREEN}✓ Already installed${NC}"
            ((skipped++))
            continue
        fi
        
        # Install the extension
        if "$vscode_cmd" --install-extension "$extension" --force > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Installed${NC}"
            ((installed++))
        else
            echo -e "${RED}✗ Failed${NC}"
            ((failed++))
        fi
    done <<< "$extensions"
    
    echo
    print_success "Extension installation completed!"
    print_info "Summary:"
    echo "  • Installed: $installed"
    echo "  • Already installed: $skipped"
    echo "  • Failed: $failed"
    echo "  • Total processed: $current"
}

# Show help
show_help() {
    cat << 'EOF'
VS Code Extensions Auto-Installer

This script automatically installs all recommended VS Code extensions 
from your dotfiles configuration.

Usage:
    ./scripts/install-vscode-extensions.sh [OPTIONS]

Options:
    -h, --help          Show this help message
    -f, --file FILE     Specify custom extensions.json file
    -l, --list          List extensions without installing
    --dry-run           Show what would be installed without installing

Examples:
    # Install all recommended extensions
    ./scripts/install-vscode-extensions.sh
    
    # List extensions that would be installed
    ./scripts/install-vscode-extensions.sh --list
    
    # Use custom extensions file
    ./scripts/install-vscode-extensions.sh -f /path/to/extensions.json

Supported VS Code variants:
    • Visual Studio Code (code)
    • Visual Studio Code Insiders (code-insiders)
    • VSCodium (codium)

EOF
}

# List extensions without installing
list_extensions() {
    local extensions_file="$1"
    
    print_header "Extensions found in configuration:"
    echo
    
    local extensions
    extensions=$(get_extension_list "$extensions_file")
    
    if [[ -z "$extensions" ]]; then
        print_warning "No extensions found in $extensions_file"
        return 1
    fi
    
    local count=0
    while IFS= read -r extension; do
        if [[ -n "$extension" ]]; then
            ((count++))
            printf "%3d. %s\n" "$count" "$extension"
        fi
    done <<< "$extensions"
    
    echo
    print_info "Total: $count extensions"
}

# Main function
main() {
    local extensions_file=""
    local list_only=false
    local dry_run=false
    
    # Get script directory
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local default_extensions_file="$script_dir/../stow-packs/vscode/.config/Code/User/extensions.json"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--file)
                extensions_file="$2"
                shift 2
                ;;
            -l|--list)
                list_only=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Use default file if none specified
    if [[ -z "$extensions_file" ]]; then
        extensions_file="$default_extensions_file"
    fi
    
    # Check if extensions file exists
    if [[ ! -f "$extensions_file" ]]; then
        print_error "Extensions file not found: $extensions_file"
        exit 1
    fi
    
    print_info "Using extensions file: $extensions_file"
    
    # List mode
    if [[ "$list_only" == "true" ]]; then
        list_extensions "$extensions_file"
        exit 0
    fi
    
    # Check VS Code installation
    local vscode_cmd
    if ! vscode_cmd=$(check_vscode); then
        print_error "VS Code is not installed or not in PATH"
        print_info "Please install VS Code first:"
        print_info "  • Linux: sudo snap install code --classic"
        print_info "  • macOS: brew install --cask visual-studio-code"
        print_info "  • Or download from: https://code.visualstudio.com/"
        exit 1
    fi
    
    print_info "Found VS Code: $vscode_cmd"
    
    # Dry run mode
    if [[ "$dry_run" == "true" ]]; then
        print_warning "Dry run mode - no extensions will be installed"
        list_extensions "$extensions_file"
        exit 0
    fi
    
    # Install extensions
    install_extensions "$vscode_cmd" "$extensions_file"
    
    echo
    print_success "All done! Restart VS Code to see the new extensions."
    print_info "You can also run: $vscode_cmd --list-extensions to see installed extensions"
}

# Run main function
main "$@"
