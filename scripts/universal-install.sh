#!/usr/bin/env sh
# Universal cross-platform dotfiles installer
# Compatible with sh, bash, zsh, and other POSIX shells

set -e

# Detect current shell
detect_shell() {
    # Get the actual shell being used (not just $SHELL variable)
    if [ -n "$ZSH_VERSION" ]; then
        CURRENT_SHELL="zsh"
        SHELL_TYPE="zsh"
    elif [ -n "$BASH_VERSION" ]; then
        CURRENT_SHELL="bash"
        SHELL_TYPE="bash"
    elif [ -n "$KSH_VERSION" ]; then
        CURRENT_SHELL="ksh"
        SHELL_TYPE="ksh"
    else
        # Fallback to checking the process name
        CURRENT_SHELL=$(ps -p $$ -o comm= 2>/dev/null || echo "sh")
        case "$CURRENT_SHELL" in
            *zsh*) SHELL_TYPE="zsh" ;;
            *bash*) SHELL_TYPE="bash" ;;
            *ksh*) SHELL_TYPE="ksh" ;;
            *) SHELL_TYPE="sh" ;;
        esac
    fi
}

# Colors (compatible with all shells)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    NC=''
fi

# Print colored output (POSIX compatible)
print_color() {
    color="$1"
    message="$2"
    printf "%b%s%b\n" "$color" "$message" "$NC"
}

# Detect platform
detect_platform() {
    OS="$(uname -s)"
    case "$OS" in
        Linux)
            if [ -f /etc/os-release ]; then
                DISTRO=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
            elif command -v lsb_release >/dev/null 2>&1; then
                DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
            else
                DISTRO="unknown"
            fi
            PLATFORM="linux"
            ;;
        Darwin)
            PLATFORM="macos"
            DISTRO="macos"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            PLATFORM="windows"
            DISTRO="windows"
            ;;
        *)
            print_color "$RED" "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

# Check if command exists (POSIX compatible)
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Download file (try curl, then wget)
download_file() {
    url="$1"
    output="$2"
    
    if command_exists curl; then
        curl -fsSL "$url" -o "$output"
    elif command_exists wget; then
        wget -q "$url" -O "$output"
    else
        print_color "$RED" "Error: Neither curl nor wget is available"
        exit 1
    fi
}

# Print header
print_header() {
    clear
    print_color "$CYAN" "╔══════════════════════════════════════════════════════════════╗"
    print_color "$CYAN" "║                    Cross-Platform Dotfiles                   ║"
    print_color "$CYAN" "║                    Universal Shell Installer                 ║"
    print_color "$CYAN" "║                    Linux • macOS • Windows                   ║"
    print_color "$CYAN" "╚══════════════════════════════════════════════════════════════╝"
    printf "\n"
    print_color "$BLUE" "🚀 Platform: $OS ($DISTRO)"
    print_color "$BLUE" "🐚 Shell: $CURRENT_SHELL ($SHELL_TYPE)"
    printf "\n"
}

# Install prerequisites based on platform
install_prerequisites() {
    print_color "$YELLOW" "📦 Installing prerequisites..."
    
    case "$PLATFORM" in
        macos)
            # Check if Xcode Command Line Tools are installed
            if ! command_exists xcode-select; then
                print_color "$YELLOW" "Installing Xcode Command Line Tools..."
                xcode-select --install
                print_color "$YELLOW" "Please press Enter when Xcode installation is complete"
                read -r dummy
            fi

            # Install Homebrew if not exists
            if ! command_exists brew; then
                print_color "$YELLOW" "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add Homebrew to PATH for Apple Silicon Macs
                if [ -d "/opt/homebrew/bin" ]; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
            fi

            # Install GNU Stow
            if ! command_exists stow; then
                brew install stow
            fi
            ;;
        linux)
            case "$DISTRO" in
                ubuntu|debian|linuxmint)
                    if ! safe_sudo apt update; then
                        print_color "$RED" "Failed to update package lists"
                        return 1
                    fi
                    if ! safe_sudo apt install -y git stow curl build-essential; then
                        print_color "$RED" "Failed to install required packages"
                        return 1
                    fi
                    ;;
                arch|manjaro)
                    if ! safe_sudo pacman -Syu --noconfirm git stow curl base-devel; then
                        print_color "$RED" "Failed to install required packages"
                        return 1
                    fi
                    ;;
                fedora|centos|rhel)
                    if ! safe_sudo dnf install -y git stow curl @development-tools; then
                        print_color "$RED" "Failed to install required packages"
                        return 1
                    fi
                    ;;
                *)
                    if command_exists apt; then
                        if ! safe_sudo apt update; then
                            print_color "$RED" "Failed to update package lists"
                            return 1
                        fi
                        if ! safe_sudo apt install -y git stow curl build-essential; then
                            print_color "$RED" "Failed to install required packages"
                            return 1
                        fi
                    elif command_exists pacman; then
                        if ! safe_sudo pacman -Syu --noconfirm git stow curl base-devel; then
                            print_color "$RED" "Failed to install required packages"
                            return 1
                        fi
                    elif command_exists dnf; then
                        if ! safe_sudo dnf install -y git stow curl @development-tools; then
                            print_color "$RED" "Failed to install required packages"
                            return 1
                        fi
                    else
                        print_color "$RED" "Please install git, stow, curl, and build tools manually"
                        return 1
                    fi
                    ;;
            esac
            ;;
        windows)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                if ! safe_sudo apt update; then
                    print_color "$RED" "Failed to update package lists in WSL"
                    return 1
                fi
                if ! safe_sudo apt install -y git stow curl; then
                    print_color "$RED" "Failed to install packages in WSL"
                    return 1
                fi
            elif command_exists pacman; then
                if ! pacman -Syu --noconfirm git stow curl; then
                    print_color "$RED" "Failed to install packages in MSYS2"
                    return 1
                fi
            fi
            ;;
    esac
    
    print_color "$GREEN" "✓ Prerequisites installed"
}

# Clone dotfiles repository
clone_dotfiles() {
    DOTFILES_DIR="$HOME/.dotfiles"
    
    if [ ! -d "$DOTFILES_DIR" ]; then
        print_color "$YELLOW" "📥 Cloning dotfiles repository..."
        git clone https://github.com/nehcuh/dotfiles.git "$DOTFILES_DIR"
        print_color "$GREEN" "✓ Dotfiles cloned to $DOTFILES_DIR"
    else
        print_color "$YELLOW" "📁 Dotfiles directory already exists"
        printf "Do you want to update the existing dotfiles? [Y/n]: "
        read -r response < /dev/tty
        case "$response" in
            [nN][oO]|[nN])
                print_color "$YELLOW" "Using existing dotfiles..."
                ;;
            *)
                print_color "$YELLOW" "Updating dotfiles..."
                cd "$DOTFILES_DIR"
                # Backup any local changes
                if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                    print_color "$YELLOW" "Stashing local changes..."
                    git stash push -m "Backup before update $(date)"
                fi
                # Pull latest changes
                git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || {
                    print_color "$YELLOW" "Update failed. Re-cloning repository..."
                    cd "$HOME"
                    rm -rf "$DOTFILES_DIR"
                    git clone https://github.com/nehcuh/dotfiles.git "$DOTFILES_DIR"
                }
                print_color "$GREEN" "✓ Dotfiles updated"
                ;;
        esac
    fi
    
    cd "$DOTFILES_DIR"
}

# Check for configuration conflicts
check_config_conflicts() {
    print_color "$YELLOW" "🔍 Checking for configuration conflicts..."
    
    conflicts_found=false
    config_files="$HOME/.zshrc $HOME/.gitconfig $HOME/.config/starship.toml $HOME/.tmux.conf $HOME/.vimrc"
    
    for file in $config_files; do
        if [ -f "$file" ] && [ ! -L "$file" ]; then
            if [ "$conflicts_found" = false ]; then
                print_color "$YELLOW" "⚠️  Configuration conflicts detected:"
                conflicts_found=true
            fi
            print_color "$RED" "  ✗ $file (existing file, not a symlink)"
        fi
    done
    
    if [ "$conflicts_found" = true ]; then
        printf "\nHow would you like to handle these conflicts?\n"
        printf "1) Backup existing files and install dotfiles\n"
        printf "2) Overwrite existing files\n"
        printf "3) Skip installation\n"
        printf "Enter your choice [1-3]: "
        read choice < /dev/tty
        
        case "$choice" in
            1)
                backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
                print_color "$YELLOW" "Creating backup at $backup_dir..."
                mkdir -p "$backup_dir"
                for file in $config_files; do
                    if [ -f "$file" ] && [ ! -L "$file" ]; then
                        cp "$file" "$backup_dir/"
                        rm -f "$file"
                        print_color "$GREEN" "  ✓ Backed up $(basename "$file")"
                    fi
                done
                print_color "$GREEN" "✓ Backup completed"
                ;;
            2)
                print_color "$YELLOW" "Removing conflicting files..."
                for file in $config_files; do
                    if [ -f "$file" ] && [ ! -L "$file" ]; then
                        rm -f "$file"
                        print_color "$GREEN" "  ✓ Removed $(basename "$file")"
                    fi
                done
                ;;
            3)
                print_color "$YELLOW" "Installation cancelled by user."
                exit 0
                ;;
            *)
                print_color "$RED" "Invalid choice. Installation cancelled."
                exit 1
                ;;
        esac
    else
        print_color "$GREEN" "✓ No configuration conflicts found"
    fi
}

# Install zsh if not exists
install_zsh_if_needed() {
    if ! command_exists zsh; then
        print_color "$YELLOW" "Zsh not found. Installing zsh..."
        
        case "$PLATFORM" in
            macos)
                if command_exists brew; then
                    print_color "$YELLOW" "Installing zsh with Homebrew..."
                    brew install zsh
                else
                    print_color "$YELLOW" "Installing zsh with Xcode Command Line Tools..."
                    # On macOS, zsh is usually installed with Xcode CLT
                    if ! command_exists xcode-select; then
                        xcode-select --install
                        print_color "$YELLOW" "Please press Enter when Xcode installation is complete"
                        read -r dummy < /dev/tty
                    fi
                fi
                ;;
            linux)
                case "$DISTRO" in
                    ubuntu|debian|linuxmint)
                        print_color "$YELLOW" "Installing zsh on Debian/Ubuntu..."
                        if ! safe_sudo apt update; then
                            print_color "$RED" "Failed to update package lists"
                            return 1
                        fi
                        if ! safe_sudo apt install -y zsh; then
                            print_color "$RED" "Failed to install zsh"
                            return 1
                        fi
                        ;;
                    arch|manjaro)
                        print_color "$YELLOW" "Installing zsh on Arch/Manjaro..."
                        if ! safe_sudo pacman -Syu --noconfirm zsh; then
                            print_color "$RED" "Failed to install zsh"
                            return 1
                        fi
                        ;;
                    fedora|centos|rhel)
                        print_color "$YELLOW" "Installing zsh on Fedora/CentOS..."
                        if ! safe_sudo dnf install -y zsh; then
                            print_color "$RED" "Failed to install zsh"
                            return 1
                        fi
                        ;;
                    *)
                        if command_exists apt; then
                            print_color "$YELLOW" "Installing zsh using apt..."
                            if ! safe_sudo apt update; then
                                print_color "$RED" "Failed to update package lists"
                                return 1
                            fi
                            if ! safe_sudo apt install -y zsh; then
                                print_color "$RED" "Failed to install zsh"
                                return 1
                            fi
                        elif command_exists pacman; then
                            print_color "$YELLOW" "Installing zsh using pacman..."
                            if ! safe_sudo pacman -Syu --noconfirm zsh; then
                                print_color "$RED" "Failed to install zsh"
                                return 1
                            fi
                        elif command_exists dnf; then
                            print_color "$YELLOW" "Installing zsh using dnf..."
                            if ! safe_sudo dnf install -y zsh; then
                                print_color "$RED" "Failed to install zsh"
                                return 1
                            fi
                        else
                            print_color "$RED" "Error: No supported package manager found"
                            print_color "$YELLOW" "Please install zsh manually using your package manager"
                            return 1
                        fi
                        ;;
                esac
                ;;
            windows)
                # Windows doesn't need zsh installation for universal installer
                print_color "$YELLOW" "Skipping zsh installation on Windows"
                return 0
                ;;
        esac
        
        # Verify zsh was installed
        if ! command_exists zsh; then
            print_color "$RED" "Error: Failed to install zsh"
            print_color "$YELLOW" "Please install zsh manually and run this script again"
            return 1
        fi
        
        print_color "$GREEN" "✓ Zsh installed successfully"
    fi
}

# Run the appropriate installer based on shell
run_installer() {
    print_color "$YELLOW" "🚀 Starting installation..."
    
    # Make scripts executable
    if [ -d "scripts" ]; then
        chmod +x scripts/*.sh 2>/dev/null || true
    fi
    
    # Check if interactive installer exists
    if [ -f "scripts/interactive-install.sh" ]; then
        print_color "$BLUE" "Running interactive installer..."
        
        # Install zsh if needed and we want to use it
        if [ "$SHELL_TYPE" = "zsh" ] && ! command_exists zsh; then
            if ! install_zsh_if_needed; then
                print_color "$YELLOW" "Warning: Could not install zsh, falling back to sh"
                SHELL_TYPE="sh"
            fi
        fi
        
        case "$SHELL_TYPE" in
            zsh)
                if command_exists zsh; then
                    zsh scripts/interactive-install.sh
                else
                    sh scripts/interactive-install.sh
                fi
                ;;
            bash)
                if command_exists bash; then
                    bash scripts/interactive-install.sh
                else
                    sh scripts/interactive-install.sh
                fi
                ;;
            *)
                sh scripts/interactive-install.sh
                ;;
        esac
    elif [ -f "scripts/install-unified.sh" ]; then
        print_color "$BLUE" "Running unified installer..."
        
        # Install zsh if needed and we want to use it
        if [ "$SHELL_TYPE" = "zsh" ] && ! command_exists zsh; then
            if ! install_zsh_if_needed; then
                print_color "$YELLOW" "Warning: Could not install zsh, falling back to sh"
                SHELL_TYPE="sh"
            fi
        fi
        
        case "$SHELL_TYPE" in
            zsh)
                if command_exists zsh; then
                    zsh scripts/install-unified.sh
                else
                    sh scripts/install-unified.sh
                fi
                ;;
            bash)
                if command_exists bash; then
                    bash scripts/install-unified.sh
                else
                    sh scripts/install-unified.sh
                fi
                ;;
            *)
                sh scripts/install-unified.sh
                ;;
        esac
    elif [ -f "Makefile" ]; then
        if command_exists make; then
            print_color "$BLUE" "Running make install..."
            make install
        else
            print_color "$RED" "Make not available"
            exit 1
        fi
    else
        if [ -f "scripts/stow.sh" ]; then
            print_color "$BLUE" "Running stow installer..."
            ./scripts/stow.sh install
        else
            print_color "$RED" "Error: No installation scripts found"
            exit 1
        fi
    fi
}

# Install VS Code and Zed editors
install_editors_universal() {
    print_color "$YELLOW" "🚀 Installing editors (VS Code, Zed)..."
    
    case "$PLATFORM" in
        macos)
            install_macos_editors_universal
            ;;
        linux)
            install_linux_editors_universal
            ;;
        windows)
            install_windows_editors_universal
            ;;
    esac
}

install_macos_editors_universal() {
    print_color "$YELLOW" "Installing macOS editors..."
    
    # Use Homebrew Cask for GUI applications
    if command_exists brew; then
        # Install Zed editor
        if ! command_exists zed; then
            print_color "$YELLOW" "Installing Zed editor..."
            if ! brew install --cask zed 2>/dev/null; then
                print_color "$RED" "Failed to install Zed via Homebrew Cask"
                print_color "$YELLOW" "You can install it manually from: https://zed.dev"
            else
                print_color "$GREEN" "✓ Zed editor installed"
            fi
        else
            print_color "$GREEN" "✓ Zed editor already installed"
        fi
        
        # Install Visual Studio Code
        if ! command_exists code; then
            print_color "$YELLOW" "Installing Visual Studio Code..."
            if ! brew install --cask visual-studio-code 2>/dev/null; then
                print_color "$RED" "Failed to install VS Code via Homebrew Cask"
                print_color "$YELLOW" "You can install it manually from: https://code.visualstudio.com"
            else
                print_color "$GREEN" "✓ Visual Studio Code installed"
            fi
        else
            print_color "$GREEN" "✓ Visual Studio Code already installed"
        fi
    else
        print_color "$RED" "Homebrew not available. Please install editors manually."
        print_color "$YELLOW" "Zed: https://zed.dev"
        print_color "$YELLOW" "VS Code: https://code.visualstudio.com"
    fi
}

install_linux_editors_universal() {
    print_color "$YELLOW" "Installing Linux editors..."
    
    # Try to install Zed editor
    if ! command_exists zed; then
        print_color "$YELLOW" "Installing Zed editor..."
        
        # Try official installation script
        if curl -fsSL https://zed.dev/install.sh | sh; then
            print_color "$GREEN" "✓ Zed editor installed"
        else
            print_color "$RED" "Failed to install Zed editor"
            print_color "$YELLOW" "You can install it manually from: https://zed.dev"
        fi
    else
        print_color "$GREEN" "✓ Zed editor already installed"
    fi
    
    # Try to install VS Code
    if ! command_exists code; then
        print_color "$YELLOW" "Installing Visual Studio Code..."
        
        # Try different installation methods based on distribution
        case "$DISTRO" in
            ubuntu|debian|linuxmint)
                if command_exists apt; then
                    # Add Microsoft's GPG key and repository
                    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | safe_sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null
                    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | safe_sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
                    
                    if safe_sudo apt update && safe_sudo apt install -y code; then
                        print_color "$GREEN" "✓ Visual Studio Code installed"
                    else
                        print_color "$RED" "Failed to install VS Code"
                        print_color "$YELLOW" "You can install it manually from: https://code.visualstudio.com"
                    fi
                else
                    print_color "$RED" "apt not available"
                    print_color "$YELLOW" "You can install it manually from: https://code.visualstudio.com"
                fi
                ;;
            arch|manjaro)
                if command_exists yay; then
                    if yay -S --noconfirm visual-studio-code-bin; then
                        print_color "$GREEN" "✓ Visual Studio Code installed"
                    else
                        print_color "$RED" "Failed to install VS Code"
                        print_color "$YELLOW" "You can install it manually from: https://code.visualstudio.com"
                    fi
                elif command_exists paru; then
                    if paru -S --noconfirm visual-studio-code-bin; then
                        print_color "$GREEN" "✓ Visual Studio Code installed"
                    else
                        print_color "$RED" "Failed to install VS Code"
                        print_color "$YELLOW" "You can install it manually from: https://code.visualstudio.com"
                    fi
                else
                    print_color "$RED" "AUR helper not available"
                    print_color "$YELLOW" "You can install it manually from: https://code.visualstudio.com"
                fi
                ;;
            fedora|centos|rhel)
                if command_exists dnf; then
                    safe_sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | safe_sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
                    
                    if safe_sudo dnf install -y code; then
                        print_color "$GREEN" "✓ Visual Studio Code installed"
                    else
                        print_color "$RED" "Failed to install VS Code"
                        print_color "$YELLOW" "You can install it manually from: https://code.visualstudio.com"
                    fi
                else
                    print_color "$RED" "dnf not available"
                    print_color "$YELLOW" "You can install it manually from: https://code.visualstudio.com"
                fi
                ;;
            *)
                print_color "$RED" "Unsupported Linux distribution"
                print_color "$YELLOW" "You can install manually:"
                print_color "$YELLOW" "VS Code: https://code.visualstudio.com"
                print_color "$YELLOW" "Zed: https://zed.dev"
                ;;
        esac
    else
        print_color "$GREEN" "✓ Visual Studio Code already installed"
    fi
}

install_windows_editors_universal() {
    print_color "$YELLOW" "Windows editors should be installed via package managers like scoop or winget"
    print_color "$YELLOW" "For scoop: scoop install vscode zed"
    print_color "$YELLOW" "For winget: winget install Microsoft.VisualStudioCode Zed.Zed"
}

# Function to check and request sudo access
check_sudo_access() {
    print_color "$YELLOW" "Checking sudo access..."
    
    # Check if we already have sudo access
    if sudo -n true 2>/dev/null; then
        print_color "$GREEN" "✓ Sudo access confirmed"
        return 0
    fi
    
    # Request sudo access
    print_color "$YELLOW" "This script requires sudo access for system-wide changes."
    print_color "$YELLOW" "Please enter your password when prompted."
    
    if ! sudo -v; then
        print_color "$RED" "Error: Failed to obtain sudo access"
        print_color "$RED" "Please ensure your user has administrative privileges."
        print_color "$YELLOW" "On macOS, you may need to:"
        print_color "$YELLOW" "1. Add your user to the admin group"
        print_color "$YELLOW" "2. Enable 'Administrator' privileges in System Preferences > Users & Groups"
        print_color "$YELLOW" "3. Or run this script with a user that has admin rights"
        return 1
    fi
    
    print_color "$GREEN" "✓ Sudo access obtained"
    return 0
}

# Function to keep sudo session alive
keep_sudo_alive() {
    print_color "$BLUE" "Maintaining sudo session..."
    # Keep-alive: update existing sudo time stamp until script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Function to safely run sudo commands with error handling
safe_sudo() {
    if ! sudo "$@" 2>/dev/null; then
        print_color "$RED" "Error: Failed to run command with sudo: $*"
        print_color "$YELLOW" "You may need to run this command manually:"
        print_color "$YELLOW" "sudo $*"
        return 1
    fi
    return 0
}

# Main installation process
main() {
    # Detect environment
    detect_shell
    detect_platform
    
    # Print header with detected information
    print_header
    
    # Ask user for confirmation
    printf "Do you want to proceed with the installation? [Y/n]: "
    read response < /dev/tty
    case "$response" in
        [nN][oO]|[nN])
            print_color "$YELLOW" "Installation cancelled."
            exit 0
            ;;
        *)
            ;;
    esac
    
    # Check for sudo access on Unix-like systems
    if [ "$PLATFORM" != "windows" ]; then
        if ! check_sudo_access; then
            print_color "$RED" "Error: Sudo access required for installation"
            exit 1
        fi
        keep_sudo_alive
    fi
    
    # Install prerequisites
    install_prerequisites
    
    # Clone dotfiles
    clone_dotfiles
    
    # Check for configuration conflicts
    check_config_conflicts
    
    # Install VS Code and Zed editors
    print_color "$YELLOW" "🚀 Installing editors (VS Code, Zed)..."
    install_editors_universal
    
    # Run installer
    run_installer
    
    print_color "$GREEN" ""
    print_color "$GREEN" "╔══════════════════════════════════════════════════════════════╗"
    print_color "$GREEN" "║                      Installation Complete!                  ║"
    print_color "$GREEN" "╚══════════════════════════════════════════════════════════════╝"
    print_color "$YELLOW" "Please restart your terminal to apply all changes."
    print_color "$BLUE" "You can manage your dotfiles with:"
    print_color "$CYAN" "  cd ~/.dotfiles && ./scripts/stow.sh [install|remove|list|status]"
    printf "\n"
    print_color "$GREEN" "🎉 Happy coding!"
}

# Uninstall function
uninstall_dotfiles() {
    print_color "$RED" "🗑️  Dotfiles Uninstaller"
    print_color "$YELLOW" "This will help you uninstall dotfiles packages"
    printf "\n"
    
    # Check if uninstall script exists
    if [ -f "$DOTFILES_DIR/scripts/uninstall.sh" ]; then
        print_color "$BLUE" "Running uninstall script..."
        chmod +x "$DOTFILES_DIR/scripts/uninstall.sh"
        "$DOTFILES_DIR/scripts/uninstall.sh" "$@"
    else
        print_color "$RED" "Error: Uninstall script not found"
        exit 1
    fi
}

# Main installation process
main() {
    # Check for uninstall flag
    if [ "$1" = "uninstall" ]; then
        detect_shell
        detect_platform
        DOTFILES_DIR="$HOME/.dotfiles"
        uninstall_dotfiles "${@:2}"
        return
    fi
    
    # Detect environment
    detect_shell
    detect_platform
    
    # Print header with detected information
    print_header
    
    # Ask user for confirmation
    printf "Do you want to proceed with the installation? [Y/n]: "
    read response < /dev/tty
    case "$response" in
        [nN][oO]|[nN])
            print_color "$YELLOW" "Installation cancelled."
            exit 0
            ;;
        *)
            ;;
    esac
    
    # Install prerequisites
    install_prerequisites
    
    # Clone dotfiles
    clone_dotfiles
    
    # Check for configuration conflicts
    check_config_conflicts
    
    # Run installer
    run_installer
    
    print_color "$GREEN" ""
    print_color "$GREEN" "╔══════════════════════════════════════════════════════════════╗"
    print_color "$GREEN" "║                      Installation Complete!                  ║"
    print_color "$GREEN" "╚══════════════════════════════════════════════════════════════╝"
    print_color "$YELLOW" "Please restart your terminal to apply all changes."
    print_color "$BLUE" "You can manage your dotfiles with:"
    print_color "$CYAN" "  cd ~/.dotfiles && ./scripts/stow.sh [install|remove|list|status]"
    print_color "$CYAN" "  cd ~/.dotfiles && ./scripts/uninstall.sh [package|complete|clean]"
    printf "\n"
    print_color "$GREEN" "🎉 Happy coding!"
}

# Run main function
main "$@"