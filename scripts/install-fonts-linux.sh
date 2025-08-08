#!/bin/bash

# Linux Font Installation Script
# Downloads and installs Nerd Fonts and other development fonts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "This script is only for Linux systems"
    exit 1
fi

# Font installation directory
FONT_DIR="$HOME/.local/share/fonts"
TEMP_DIR="/tmp/fonts-install"

# Create directories
print_status "Creating font directories..."
mkdir -p "$FONT_DIR"
mkdir -p "$TEMP_DIR"

# Download and install function
install_font() {
    local font_name="$1"
    local download_url="$2"
    local extract_dir="$3"
    
    print_status "Installing $font_name..."
    
    cd "$TEMP_DIR"
    
    # Download font
    if command -v wget &> /dev/null; then
        wget -q --show-progress -O "${font_name}.zip" "$download_url"
    elif command -v curl &> /dev/null; then
        curl -L -o "${font_name}.zip" "$download_url"
    else
        print_error "Neither wget nor curl is available. Please install one of them."
        return 1
    fi
    
    # Extract and install
    unzip -q "${font_name}.zip" -d "$extract_dir"
    
    # Copy font files to system font directory
    find "$extract_dir" -name "*.ttf" -o -name "*.otf" | while read -r font_file; do
        cp "$font_file" "$FONT_DIR/"
        print_status "Installed: $(basename "$font_file")"
    done
    
    # Clean up
    rm -rf "${font_name}.zip" "$extract_dir"
    
    print_success "$font_name installed successfully"
}

# Install Fira Code Nerd Font
install_font "FiraCode" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip" \
    "FiraCode"

# Install Hack Nerd Font
install_font "Hack" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" \
    "Hack"

# Download and install Google Fonts
print_status "Installing Google Fonts..."

# Create temp directory for Google Fonts
GOOGLE_TEMP="$TEMP_DIR/google-fonts"
mkdir -p "$GOOGLE_TEMP"
cd "$GOOGLE_TEMP"

# Clone Google Fonts repository (shallow clone for faster download)
if command -v git &> /dev/null; then
    print_status "Downloading Google Fonts repository..."
    git clone --depth 1 --filter=blob:none --sparse https://github.com/google/fonts.git
    cd fonts
    git sparse-checkout set ofl/sourcecodepro apache/roboto apache/robotomono
    
    # Install Source Code Pro (closest to SF Mono)
    if [ -d "ofl/sourcecodepro" ]; then
        find ofl/sourcecodepro -name "*.ttf" | while read -r font_file; do
            cp "$font_file" "$FONT_DIR/"
            print_status "Installed: $(basename "$font_file")"
        done
        print_success "Source Code Pro installed"
    fi
    
    # Install Roboto (alternative to San Francisco font)
    if [ -d "apache/roboto" ]; then
        find apache/roboto -name "*.ttf" | while read -r font_file; do
            cp "$font_file" "$FONT_DIR/"
            print_status "Installed: $(basename "$font_file")"
        done
        print_success "Roboto installed"
    fi
    
    # Install Roboto Mono
    if [ -d "apache/robotomono" ]; then
        find apache/robotomono -name "*.ttf" | while read -r font_file; do
            cp "$font_file" "$FONT_DIR/"
            print_status "Installed: $(basename "$font_file")"
        done
        print_success "Roboto Mono installed"
    fi
else
    print_warning "Git not available, skipping Google Fonts installation"
fi

# Clean up temp directory
print_status "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

# Refresh font cache
print_status "Refreshing font cache..."
if command -v fc-cache &> /dev/null; then
    fc-cache -fv "$FONT_DIR" > /dev/null 2>&1
    print_success "Font cache refreshed"
else
    print_warning "fontconfig not available, font cache not refreshed"
    print_warning "You may need to restart your terminal or system for fonts to take effect"
fi

# List installed fonts
print_status "Verifying font installation..."
if command -v fc-list &> /dev/null; then
    echo
    echo "Installed Nerd Fonts:"
    fc-list : family | grep -i "fira\|hack" | sort | uniq || print_warning "No Nerd Fonts detected yet"
    echo
    echo "Installed Google/System Fonts:"
    fc-list : family | grep -i "source\|roboto" | sort | uniq || print_warning "No Google fonts detected yet"
else
    print_warning "fc-list not available, cannot verify font installation"
fi

echo
print_success "Font installation completed!"
print_status "Fonts installed to: $FONT_DIR"
print_status "You may need to restart applications to see the new fonts"

# Provide usage suggestions
echo
print_status "Recommended font settings for development:"
echo "  Terminal: 'FiraCode Nerd Font' or 'Hack Nerd Font'"
echo "  Code Editor: 'FiraCode Nerd Font' (with ligatures enabled)"
echo "  System UI: 'Roboto' or system default"
echo "  Monospace: 'Source Code Pro' or 'Roboto Mono'"
