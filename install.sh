#!/bin/bash
# Simple dotfiles installer
# Works on Linux and macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Utility functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    log_error "Unsupported OS: $OSTYPE"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

log_info "Dotfiles directory: $DOTFILES_DIR"
log_info "Operating system: $OS"

# Check sudo access
check_sudo() {
    if [[ "$OS" == "macos" ]]; then
        log_info "Checking sudo access for macOS package installation..."
        if ! sudo -n true 2>/dev/null; then
            log_warning "This installation requires administrator privileges"
            log_info "You may be prompted for your password to install system dependencies"
            
            # Test sudo access
            if ! sudo -v; then
                log_error "Administrator access is required but not available"
                log_error "Please ensure you have admin privileges on this macOS system"
                exit 1
            fi
            
            # Keep sudo alive during installation
            log_info "Keeping administrator session active during installation..."
            (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &)
        fi
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed"
        if [[ "$OS" == "macos" ]]; then
            log_info "Installing Xcode Command Line Tools (includes Git)..."
            log_warning "This may take a few minutes and requires user interaction"
            xcode-select --install
            log_info "Please complete the Xcode Command Line Tools installation and run this script again"
            exit 1
        else
            log_error "Please install Git first"
            exit 1
        fi
    fi
    
    if ! command -v stow &> /dev/null; then
        log_info "Installing GNU Stow..."
        case $OS in
            linux)
                if command -v apt &> /dev/null; then
                    sudo apt update && sudo apt install -y stow
                elif command -v pacman &> /dev/null; then
                    sudo pacman -S --noconfirm stow
                elif command -v dnf &> /dev/null; then
                    sudo dnf install -y stow
                else
                    log_error "Unable to install stow. Please install it manually."
                    exit 1
                fi
                ;;
            macos)
                if command -v brew &> /dev/null; then
                    log_info "Homebrew found, installing GNU Stow..."
                    brew install stow
                else
                    log_warning "Homebrew not found. Installing Homebrew first..."
                    
                    # Install Homebrew
                    log_info "Installing Homebrew..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    
                    # Add Homebrew to PATH for current session
                    if [ -f "/opt/homebrew/bin/brew" ]; then
                        # Apple Silicon Mac
                        export PATH="/opt/homebrew/bin:$PATH"
                        eval "$(/opt/homebrew/bin/brew shellenv)"
                    elif [ -f "/usr/local/bin/brew" ]; then
                        # Intel Mac
                        export PATH="/usr/local/bin:$PATH"
                        eval "$(/usr/local/bin/brew shellenv)"
                    fi
                    
                    # Verify Homebrew installation
                    if command -v brew &> /dev/null; then
                        log_success "Homebrew installed successfully"
                        log_info "Installing GNU Stow..."
                        brew install stow
                    else
                        log_error "Failed to install Homebrew. Please install it manually:"
                        log_error "Visit: https://brew.sh"
                        exit 1
                    fi
                fi
                ;;
        esac
    fi
    
    log_success "Prerequisites check passed"
}

# Install packages
install_packages() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        # Default packages
        packages=("system" "zsh" "git" "tools" "vim" "nvim" "tmux")
        
        # Add OS-specific packages
        if [ "$OS" = "linux" ]; then
            packages+=("linux")
        elif [ "$OS" = "macos" ]; then
            packages+=("macos")
        fi
    fi
    
    # Handle sensitive files first
    if [[ -x "$DOTFILES_DIR/scripts/manage-sensitive-files.sh" ]]; then
        log_info "Managing sensitive dotfiles..."
        "$DOTFILES_DIR/scripts/manage-sensitive-files.sh" backup >/dev/null 2>&1 || true
    fi
    
    log_info "Installing packages: ${packages[*]}"
    
    cd "$DOTFILES_DIR/stow-packs" || exit 1
    
    for package in "${packages[@]}"; do
        if [ -d "$package" ]; then
            log_info "Installing $package..."
            if stow -v -t "$HOME" "$package"; then
                log_success "✓ $package installed"
            else
log_warning "Failed to install $package (conflicts detected)"
                
                # Create backup directory
                backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
                mkdir -p "$backup_dir"
                log_warning "Backing up conflicting files to $backup_dir"
                
                # Use stow --adopt to take over existing files, then restore from backup
                cd "$DOTFILES_DIR/stow-packs" || exit 1
                
                # First, find files that would be affected
                find "$package" -type f | while IFS= read -r file; do
                    # Convert package file path to home file path
                    home_file=$(echo "$file" | sed "s|^$package/||")
                    
                    if [ -f "$HOME/$home_file" ] && [ ! -L "$HOME/$home_file" ]; then
                        log_info "  Backing up $home_file"
                        # Create directory structure in backup
                        mkdir -p "$backup_dir/$(dirname "$home_file")"
                        cp "$HOME/$home_file" "$backup_dir/$home_file"
                    fi
                done
                
                # Now use stow --adopt to take over the files
                if stow --adopt -v -t "$HOME" "$package"; then
                    log_success "✓ $package installed after resolving conflicts"
                    log_info "  Original files backed up to: $backup_dir"
                else
                    log_error "✗ Failed to install $package even with --adopt"
                fi
            fi
        else
            log_warning "Package $package not found, skipping"
        fi
    done
    
    # Restore sensitive files as symlinks after all packages are installed
    if [[ -x "$DOTFILES_DIR/scripts/manage-sensitive-files.sh" ]]; then
        "$DOTFILES_DIR/scripts/manage-sensitive-files.sh" restore >/dev/null 2>&1 || true
    fi
}

# Install Linux packages
install_linux_packages() {
    local linux_script="$DOTFILES_DIR/scripts/setup-linux-packages.sh"
    
    if [ -f "$linux_script" ]; then
        log_info "Setting up Linux packages..."
        chmod +x "$linux_script"
        "$linux_script"
        
        # After Linux packages installation, ensure Homebrew is available for current session
        if [ -d "/home/linuxbrew/.linuxbrew" ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            log_info "Homebrew environment loaded for current session"
        fi
    else
        log_error "Linux package setup script not found: $linux_script"
    fi
    
    # Install fonts for Linux
    install_linux_fonts
}

# Install Linux fonts
install_linux_fonts() {
    local font_script="$DOTFILES_DIR/scripts/install-fonts-linux.sh"
    
    if [ -f "$font_script" ]; then
        # Skip if explicitly requested
        if [ "${SKIP_FONTS:-false}" = "true" ]; then
            log_info "Skipping font installation (SKIP_FONTS=true)"
            return
        fi
        
        log_info "Installing fonts for Linux..."
        
        # Ask for confirmation unless in non-interactive mode
        if [ "${NON_INTERACTIVE:-false}" != "true" ]; then
            echo
            log_info "The font installer will download and install:"
            log_info "• FiraCode Nerd Font (programming font with ligatures)"
            log_info "• Hack Nerd Font (alternative programming font)"
            log_info "• Source Code Pro (monospace font, similar to SF Mono)"
            log_info "• Roboto and Roboto Mono (Google fonts)"
            echo
            read -p "Do you want to install fonts? (Y/n): " -n 1 -r
            echo
            
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                log_info "Skipping font installation"
                log_info "You can install fonts later with: $font_script"
                return
            fi
        else
            log_info "Non-interactive mode: installing fonts automatically"
        fi
        
        chmod +x "$font_script"
        if "$font_script"; then
            log_success "Fonts installed successfully"
        else
            log_warning "Font installation encountered some issues"
            log_info "You can retry with: $font_script"
        fi
    else
        log_warning "Linux font installation script not found: $font_script"
    fi
}

# Install Brewfile packages
install_brewfile() {
    if [[ "$OS" == "macos" ]] && command -v brew &> /dev/null; then
        local brewfile="$HOME/.Brewfile"
        local repo_brewfile="$DOTFILES_DIR/stow-packs/system/home/.Brewfile"
        
        # Check if Brewfile exists either in home directory (after stow) or in repo
        if [ -f "$brewfile" ] || [ -f "$repo_brewfile" ]; then
            # Skip if explicitly requested
            if [ "${SKIP_BREWFILE:-false}" = "true" ]; then
                log_info "Skipping Brewfile installation (SKIP_BREWFILE=true)"
                return
            fi
            
            log_info "Found Brewfile, installing Homebrew packages..."
            log_warning "This may take several minutes and will install many applications"
            
            # Ask for confirmation unless in non-interactive mode
            if [ "${NON_INTERACTIVE:-false}" != "true" ]; then
                echo
                log_info "The Brewfile includes:"
                log_info "• CLI tools: bat, eza, fzf, ripgrep, neovim, etc."
                log_info "• Development tools: go, rust, pyenv, nvm, maven, gradle"
                log_info "• Applications: Zed editor, Obsidian, Raycast, etc."
                log_info "• Fonts: Fira Code, Hack Nerd Font, etc."
                echo
                read -p "Do you want to install Brewfile packages? (y/N): " -n 1 -r
                echo
                
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log_info "Skipping Brewfile installation"
                    log_info "You can install it later with: brew bundle --global"
                    return
                fi
            else
                log_info "Non-interactive mode: installing Brewfile packages automatically"
            fi
            
            # Use the Brewfile that exists (prefer the one in home directory if both exist)
            local brewfile_to_use="$brewfile"
            if [ ! -f "$brewfile" ] && [ -f "$repo_brewfile" ]; then
                brewfile_to_use="$repo_brewfile"
                log_info "Using Brewfile from repository: $repo_brewfile"
            fi
            
            # Install packages from Brewfile
            if brew bundle --file="$brewfile_to_use"; then
                log_success "Brewfile packages installed successfully"
            else
                log_warning "Some Brewfile packages failed to install"
                log_info "You can retry with: brew bundle --file='$brewfile_to_use'"
            fi
        else
            log_info "No Brewfile found at $brewfile, skipping Homebrew package installation"
        fi
    fi
}

# Setup shell
setup_shell() {
    log_info "Setting up shell..."
    
    if command -v zsh &> /dev/null; then
        local zsh_path="$(command -v zsh)"
        local current_shell="$SHELL"
        
        # Multiple ways to detect if running in zsh context
        local is_zsh_session=false
        
        # Method 1: Check parent process
        if [[ "$(ps -p $PPID -o comm= 2>/dev/null)" == *"zsh"* ]]; then
            is_zsh_session=true
        fi
        
        # Method 2: Check current process
        if [[ "$(ps -p $$ -o comm= 2>/dev/null)" == *"zsh"* ]]; then
            is_zsh_session=true
        fi
        
        # Method 3: Check $0 variable
        if [[ "$0" == *"zsh"* ]]; then
            is_zsh_session=true
        fi
        
        # Method 4: Check if SHELL matches zsh_path
        if [ "$current_shell" = "$zsh_path" ]; then
            log_success "Default shell is already set to zsh"
            return
        fi
        
        # If we detect zsh session, be more gentle
        if [ "$is_zsh_session" = true ]; then
            log_info "Detected zsh environment, updating default shell setting..."
            
            if chsh -s "$zsh_path" 2>/dev/null; then
                log_success "Default shell updated to zsh"
            else
                log_info "Could not update default shell automatically (this is normal in some environments)"
                log_info "Your current session is already using zsh"
                log_info "To set zsh as default permanently, run: chsh -s $zsh_path"
            fi
        else
            # Regular shell change logic
            log_info "Changing shell from $current_shell to $zsh_path..."
            
            if chsh -s "$zsh_path" 2>/dev/null; then
                log_success "Shell changed to zsh (restart terminal to take effect)"
            else
                log_warning "Failed to change shell automatically"
                log_info "You can manually change your shell to zsh with:"
                log_info "  chsh -s $zsh_path"
                log_info "Or add this to your current shell's rc file:"
                log_info "  exec zsh"
                
                # Check if zsh is in /etc/shells
                if [ -f /etc/shells ] && ! grep -q "^$zsh_path$" /etc/shells; then
                    log_warning "Zsh may not be in /etc/shells. You might need to add it:"
                    log_info "  echo '$zsh_path' | sudo tee -a /etc/shells"
                fi
            fi
        fi
    else
        log_warning "Zsh not found, keeping current shell"
    fi
}

# Show help
show_help() {
    echo "Simple Dotfiles Installer"
    echo "Usage: $0 [options] [packages...]"
    echo ""
    echo "Options:"
    echo "  --help, -h        Show this help message"
    echo "  --dev-env         Setup development environments after dotfiles installation"
    echo "  --dev-all         Setup all development environments (Rust, Python, Go, Java, Node.js, C/C++)"
    echo ""
    echo "Available packages:"
    echo "  system        System-wide configurations"
    echo "  zsh           Zsh shell configuration"
    echo "  git           Git configuration and aliases"
    echo "  tools         CLI tools and utilities"
    echo "  vim           Vim configuration"
    echo "  nvim          Neovim configuration"
    echo "  tmux          Terminal multiplexer configuration"
    echo "  vscode        Visual Studio Code settings"
    echo "  zed           Zed editor configuration"
    echo "  linux         Linux-specific configurations"
    echo "  macos         macOS-specific configurations"
    echo ""
    echo "Examples:"
    echo "  $0                  # Install default packages"
    echo "  $0 git vim          # Install only git and vim"
    echo "  $0 zsh tmux         # Install shell and terminal multiplexer"
    echo "  $0 --dev-env        # Install default packages + setup dev environments"
    echo "  $0 --dev-all        # Install default packages + setup all dev environments"
    echo "  $0 git --dev-env    # Install git package + setup dev environments"
}

# Setup development environment
setup_dev_environment() {
    local dev_script="$DOTFILES_DIR/scripts/setup-dev-environment.sh"
    
    if [ -f "$dev_script" ]; then
        log_info "Setting up development environments..."
        chmod +x "$dev_script"
        "$dev_script" "$@"
    else
        log_error "Development environment setup script not found: $dev_script"
    fi
}

# Main installation
main() {
    local dev_env=false
    local dev_all=false
    local packages=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --dev-env)
                dev_env=true
                shift
                ;;
            --dev-all)
                dev_all=true
                shift
                ;;
            --*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                packages+=("$1")
                shift
                ;;
        esac
    done
    
    echo "========================================"
    echo "         Dotfiles Installation          "
    echo "========================================"
    echo
    
    check_sudo
    check_prerequisites
    install_packages "${packages[@]}"
    
    # Install OS-specific packages
    if [[ "$OS" == "macos" ]]; then
        install_brewfile
    elif [[ "$OS" == "linux" ]]; then
        install_linux_packages
    fi
    
    setup_shell
    
    # Setup development environments if requested
    if [ "$dev_env" = true ]; then
        echo
        log_info "Setting up development environments..."
        setup_dev_environment
    elif [ "$dev_all" = true ]; then
        echo
        log_info "Setting up all development environments..."
        setup_dev_environment --all
    fi
    
    # Setup VS Code extensions if requested
    if command -v code &> /dev/null && [ -f "$DOTFILES_DIR/scripts/setup-vscode-extensions.sh" ]; then
        echo
        log_info "Setting up VS Code extensions..."
        if [ "${NON_INTERACTIVE:-false}" != "true" ]; then
            read -p "Do you want to install VS Code extensions? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                chmod +x "$DOTFILES_DIR/scripts/setup-vscode-extensions.sh"
                "$DOTFILES_DIR/scripts/setup-vscode-extensions.sh" || log_warning "Some VS Code extensions failed to install"
            fi
        else
            log_info "Non-interactive mode: installing VS Code extensions automatically"
            chmod +x "$DOTFILES_DIR/scripts/setup-vscode-extensions.sh"
            "$DOTFILES_DIR/scripts/setup-vscode-extensions.sh" || log_warning "Some VS Code extensions failed to install"
        fi
    fi
    
    # Run macOS optimizations if on macOS
    if [[ "$OS" == "macos" ]] && [ -f "$HOME/.config/macos/optimize.sh" ]; then
        echo
        log_info "Applying macOS system optimizations..."
        if [ "${NON_INTERACTIVE:-false}" != "true" ]; then
            read -p "Do you want to apply macOS system optimizations? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                chmod +x "$HOME/.config/macos/optimize.sh"
                "$HOME/.config/macos/optimize.sh" || log_warning "Some macOS optimizations failed to apply"
                
                if [ -f "$HOME/.config/macos/quick-optimize.sh" ]; then
                    log_info "Running additional quick optimizations..."
                    chmod +x "$HOME/.config/macos/quick-optimize.sh"
                    "$HOME/.config/macos/quick-optimize.sh" || log_warning "Some quick optimizations failed to apply"
                fi
            fi
        else
            log_info "Non-interactive mode: applying macOS optimizations automatically"
            chmod +x "$HOME/.config/macos/optimize.sh"
            "$HOME/.config/macos/optimize.sh" || log_warning "Some macOS optimizations failed to apply"
        fi
    elif [[ "$OS" == "macos" ]]; then
        log_warning "macOS optimization scripts not found. Run 'stow -R -t $HOME macos' to fix this."
    fi
    
    echo
    log_success "Installation completed!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    log_info "If VS Code was configured, please restart it to load all extensions"
    if [[ "$OS" == "macos" ]]; then
        log_info "Some macOS settings may require a system restart to take full effect"
    fi
}

# Run main function with all arguments
main "$@"
