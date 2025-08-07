#!/usr/bin/env sh
# Universal cross-platform dotfiles installer
# Compatible with sh, bash, zsh, and other POSIX shells

set -e

# Global variables
PACKAGES_UPDATED=false

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
                
                # Create a temporary directory for installation
                local temp_dir
                temp_dir=$(mktemp -d)
                
                # Download the installation script from GitHub
                print_color "$YELLOW" "Downloading Homebrew installation script from GitHub..."
                if command_exists curl; then
                    if ! curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "${temp_dir}/install.sh"; then
                        print_color "$RED" "Failed to download Homebrew installation script from GitHub"
                        rm -rf "${temp_dir}"
                        return 1
                    fi
                else
                    if ! wget -q https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -O "${temp_dir}/install.sh"; then
                        print_color "$RED" "Failed to download Homebrew installation script from GitHub"
                        rm -rf "${temp_dir}"
                        return 1
                    fi
                fi
                
                # Run the installation script
                if ! /bin/bash "${temp_dir}/install.sh"; then
                    print_color "$RED" "Failed to install Homebrew"
                    rm -rf "${temp_dir}"
                    return 1
                fi
                
                # Clean up
                rm -rf "${temp_dir}"
                
                # Add Homebrew to PATH based on architecture
                if [ "$(uname -m)" = "arm64" ]; then
                    # For Apple Silicon Macs
                    if [ -d "/opt/homebrew/bin" ]; then
                        print_color "$YELLOW" "Adding Homebrew to PATH for Apple Silicon Mac..."
                        if [ "$SHELL_TYPE" = "zsh" ]; then
                            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
                            # Apply immediately
                            export PATH="/opt/homebrew/bin:$PATH"
                            export HOMEBREW_REPOSITORY="/opt/homebrew"
                            export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
                            export HOMEBREW_PREFIX="/opt/homebrew"
                            # Also try to run the shellenv command if possible
                            if [ -x "/opt/homebrew/bin/brew" ]; then
                                eval "$(/opt/homebrew/bin/brew shellenv)" || true
                            fi
                        elif [ "$SHELL_TYPE" = "bash" ]; then
                            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
                            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bashrc
                            # Apply immediately
                            export PATH="/opt/homebrew/bin:$PATH"
                            export HOMEBREW_REPOSITORY="/opt/homebrew"
                            export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
                            export HOMEBREW_PREFIX="/opt/homebrew"
                            # Also try to run the shellenv command if possible
                            if [ -x "/opt/homebrew/bin/brew" ]; then
                                eval "$(/opt/homebrew/bin/brew shellenv)" || true
                            fi
                        fi
                    fi
                else
                    # For Intel Macs
                    if [ -d "/usr/local/bin" ]; then
                        print_color "$YELLOW" "Adding Homebrew to PATH for Intel Mac..."
                        if [ "$SHELL_TYPE" = "zsh" ]; then
                            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
                            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
                            # Apply immediately
                            export PATH="/usr/local/bin:$PATH"
                            export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
                            export HOMEBREW_CELLAR="/usr/local/Cellar"
                            export HOMEBREW_PREFIX="/usr/local"
                            # Also try to run the shellenv command if possible
                            if [ -x "/usr/local/bin/brew" ]; then
                                eval "$(/usr/local/bin/brew shellenv)" || true
                            fi
                        elif [ "$SHELL_TYPE" = "bash" ]; then
                            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile
                            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bashrc
                            # Apply immediately
                            export PATH="/usr/local/bin:$PATH"
                            export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
                            export HOMEBREW_CELLAR="/usr/local/Cellar"
                            export HOMEBREW_PREFIX="/usr/local"
                            # Also try to run the shellenv command if possible
                            if [ -x "/usr/local/bin/brew" ]; then
                                eval "$(/usr/local/bin/brew shellenv)" || true
                            fi
                        fi
                    fi
                fi
            fi

            # Install GNU Stow
            if ! command_exists stow; then
                brew install stow
            fi
            ;;
        linux)
            if ! update_package_lists; then
                return 1
            fi
            
            case "$DISTRO" in
                ubuntu|debian|linuxmint)
                    if ! safe_sudo apt install -y git stow curl build-essential; then
                        print_color "$RED" "Failed to install required packages"
                        return 1
                    fi
                    ;;
                arch|manjaro)
                    # Already updated in update_package_lists
                    if ! safe_sudo pacman -S --noconfirm git stow curl base-devel; then
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
                        if ! safe_sudo apt install -y git stow curl build-essential; then
                            print_color "$RED" "Failed to install required packages"
                            return 1
                        fi
                    elif command_exists pacman; then
                        if ! safe_sudo pacman -S --noconfirm git stow curl base-devel; then
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
                if ! update_package_lists; then
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
                        if ! safe_sudo apt install -y zsh; then
                            print_color "$RED" "Failed to install zsh"
                            return 1
                        fi
                        ;;
                    arch|manjaro)
                        print_color "$YELLOW" "Installing zsh on Arch/Manjaro..."
                        if ! safe_sudo pacman -S --noconfirm zsh; then
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
                            if ! safe_sudo apt install -y zsh; then
                                print_color "$RED" "Failed to install zsh"
                                return 1
                            fi
                        elif command_exists pacman; then
                            print_color "$YELLOW" "Installing zsh using pacman..."
                            if ! safe_sudo pacman -S --noconfirm zsh; then
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
                    print_color "$YELLOW" "Adding Microsoft GPG key for VS Code..."
                    # Download GPG key
                    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc > /tmp/microsoft.asc
                    
                    # Try to import GPG key using apt-key first (preferred method)
                    if command_exists apt-key && safe_sudo apt-key add /tmp/microsoft.asc; then
                        print_color "$GREEN" "✓ GPG key imported using apt-key"
                    else
                        # Fallback to manual GPG key installation
                        print_color "$YELLOW" "Trying alternative GPG key import method..."
                        if ! curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | safe_sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null; then
                            print_color "$RED" "Failed to import Microsoft GPG key"
                            print_color "$YELLOW" "You can install VS Code manually from: https://code.visualstudio.com"
                            rm -f /tmp/microsoft.asc
                            return 1
                        fi
                        print_color "$GREEN" "✓ GPG key imported using manual method"
                    fi
                    rm -f /tmp/microsoft.asc
                    
                    print_color "$YELLOW" "Adding VS Code repository..."
                    # Check if we need to use signed-by parameter (for manual GPG method)
                    if [ -f "/etc/apt/trusted.gpg.d/microsoft.gpg" ]; then
                        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /tmp/vscode.list
                    else
                        echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/repos/code stable main" > /tmp/vscode.list
                    fi
                    if ! safe_sudo cp /tmp/vscode.list /etc/apt/sources.list.d/vscode.list; then
                        print_color "$RED" "Failed to add VS Code repository"
                        print_color "$YELLOW" "You can install VS Code manually from: https://code.visualstudio.com"
                        rm -f /tmp/vscode.list
                        return 1
                    fi
                    rm -f /tmp/vscode.list
                    
                    if safe_sudo apt install -y code; then
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
                    print_color "$YELLOW" "Importing Microsoft GPG key for VS Code..."
                    if ! safe_sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc; then
                        print_color "$RED" "Failed to import Microsoft GPG key"
                        print_color "$YELLOW" "You can install VS Code manually from: https://code.visualstudio.com"
                        return 1
                    fi
                    
                    print_color "$YELLOW" "Adding VS Code repository..."
                    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /tmp/vscode.repo
                    if ! safe_sudo cp /tmp/vscode.repo /etc/yum.repos.d/vscode.repo; then
                        print_color "$RED" "Failed to add VS Code repository"
                        print_color "$YELLOW" "You can install VS Code manually from: https://code.visualstudio.com"
                        rm -f /tmp/vscode.repo
                        return 1
                    fi
                    rm -f /tmp/vscode.repo
                    
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
    
    # Request sudo access interactively
    print_color "$YELLOW" "This script requires sudo access for system-wide changes."
    print_color "$YELLOW" "Please enter your password when prompted."
    
    # Try to get sudo access with a user-friendly prompt
    if ! sudo -v; then
        print_color "$RED" "Error: Failed to obtain sudo access"
        print_color "$YELLOW" "Possible solutions:"
        print_color "$YELLOW" "1. Ensure your user has sudo/administrator privileges"
        print_color "$YELLOW" "2. Enter the correct password when prompted"
        print_color "$YELLOW" "3. On macOS: Check System Preferences > Users & Groups"
        print_color "$YELLOW" "4. On Linux: Ensure you're in the sudo group"
        print_color "$YELLOW" "5. Try running: sudo -v to test your sudo access"
        return 1
    fi
    
    print_color "$GREEN" "✓ Sudo access obtained"
    return 0
}

# Function to keep sudo session alive
keep_sudo_alive() {
    # Keep-alive: update existing sudo time stamp until script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Function to update package lists (only once)
update_package_lists() {
    if [ "$PACKAGES_UPDATED" = "true" ]; then
        return 0
    fi
    
    print_color "$YELLOW" "🔄 Updating package lists..."
    
    case "$PLATFORM" in
        linux)
            case "$DISTRO" in
                ubuntu|debian|linuxmint)
                    if ! safe_sudo apt update; then
                        print_color "$RED" "Failed to update package lists"
                        return 1
                    fi
                    ;;
                arch|manjaro)
                    if ! safe_sudo pacman -Syu --noconfirm; then
                        print_color "$RED" "Failed to update package lists"
                        return 1
                    fi
                    ;;
                fedora|centos|rhel)
                    if ! safe_sudo dnf check-update; then
                        print_color "$YELLOW" "Package list check completed (some errors are normal)"
                    fi
                    ;;
            esac
            ;;
    esac
    
    PACKAGES_UPDATED=true
    print_color "$GREEN" "✓ Package lists updated"
    return 0
}

# Function to safely run sudo commands with error handling
safe_sudo() {
    # Check if we have cached credentials
    if ! sudo -n true 2>/dev/null; then
        # Try to refresh sudo credentials silently
        if ! sudo -v 2>/dev/null; then
            print_color "$YELLOW" "Sudo access required for: $*"
            print_color "$YELLOW" "Please enter your password when prompted."
        fi
    fi
    
    # Try to run the sudo command
    if ! sudo "$@"; then
        print_color "$RED" "Error: Failed to run command with sudo: $*"
        print_color "$YELLOW" "This command requires administrative privileges."
        print_color "$YELLOW" "You may need to:"
        print_color "$YELLOW" "1. Ensure your user has sudo rights"
        print_color "$YELLOW" "2. Enter the correct password when prompted"
        print_color "$YELLOW" "3. Or run this command manually: sudo $*"
        return 1
    fi
    return 0
}

# Install Homebrew on Linux with Tsinghua mirror
install_linux_homebrew_universal() {
    if [ "$PLATFORM" != "linux" ]; then
        return 0
    fi
    
    if command_exists brew; then
        print_color "$GREEN" "✓ Homebrew already installed"
        return 0
    fi
    
    print_color "$YELLOW" "Installing Linux Homebrew with Tsinghua mirror..."
    
    # Install Homebrew with Tsinghua mirror
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    
    # Install Homebrew using the official script
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        print_color "$RED" "Failed to install Homebrew with Tsinghua mirror"
        return 1
    fi
    
    # Add Homebrew to PATH and apply immediately
    if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
        # Add to shell config files
        if [ "$SHELL_TYPE" = "zsh" ]; then
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
        elif [ "$SHELL_TYPE" = "bash" ]; then
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bash_profile
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
        else
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
        fi
        
        # Apply immediately to current shell
        export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
        export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
        export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
        export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
        
        # Also try to run the shellenv command if possible
        if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" || true
        fi
    fi
    
    # Configure Tsinghua mirror for existing Homebrew installation
    # First check if brew command is available
    if command_exists brew; then
        # Try to configure Tsinghua mirror, but don't fail if it doesn't work
        brew git -C "$(brew --repo)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git 2>/dev/null || true
        
        # Only try to configure homebrew/core if it exists
        if [ -d "$(brew --repo homebrew/core 2>/dev/null)" ]; then
            brew git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git 2>/dev/null || true
        fi
    fi
    
    # Configure bottle domain in all relevant shell config files
    if [ "$SHELL_TYPE" = "zsh" ]; then
        echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> ~/.zprofile
        echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> ~/.zshrc
    elif [ "$SHELL_TYPE" = "bash" ]; then
        echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> ~/.bash_profile
        echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> ~/.bashrc
    else
        echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> ~/.profile
    fi
    
    # Apply immediately to current shell
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    
    print_color "$GREEN" "✓ Linux Homebrew installed with Tsinghua mirror"
    return 0
}

# Install Starship prompt
install_starship_universal() {
    if command_exists starship; then
        print_color "$GREEN" "✓ Starship already installed"
        return 0
    fi
    
    print_color "$YELLOW" "Installing Starship prompt..."
    
    # Try different installation methods
    if command_exists curl; then
        # Install via curl
        if curl -fsSL https://starship.rs/install.sh | sh; then
            print_color "$GREEN" "✓ Starship installed"
            return 0
        fi
    elif command_exists wget; then
        # Install via wget
        if wget -qO- https://starship.rs/install.sh | sh; then
            print_color "$GREEN" "✓ Starship installed"
            return 0
        fi
    fi
    
    # Try package manager installation
    case "$PLATFORM" in
        macos)
            if command_exists brew; then
                if brew install starship; then
                    print_color "$GREEN" "✓ Starship installed via Homebrew"
                    return 0
                fi
            fi
            ;;
        linux)
            case "$DISTRO" in
                ubuntu|debian|linuxmint)
                    if command_exists apt && safe_sudo apt install -y starship; then
                        print_color "$GREEN" "✓ Starship installed via apt"
                        return 0
                    fi
                    ;;
                arch|manjaro)
                    if command_exists pacman && safe_sudo pacman -Syu --noconfirm starship; then
                        print_color "$GREEN" "✓ Starship installed via pacman"
                        return 0
                    fi
                    ;;
                fedora|centos|rhel)
                    if command_exists dnf && safe_sudo dnf install -y starship; then
                        print_color "$GREEN" "✓ Starship installed via dnf"
                        return 0
                    fi
                    ;;
            esac
            ;;
    esac
    
    print_color "$RED" "Failed to install Starship"
    print_color "$YELLOW" "You can install it manually from: https://starship.rs"
    return 1
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
    
    # Install Linux Homebrew (if on Linux)
    if [ "$PLATFORM" = "linux" ]; then
        print_color "$YELLOW" "🍺 Installing Linux Homebrew..."
        install_linux_homebrew_universal
    fi
    
    # Install Starship prompt
    print_color "$YELLOW" "🚀 Installing Starship prompt..."
    install_starship_universal
    
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
    print_color "$CYAN" "  cd ~/.dotfiles && ./scripts/uninstall.sh [package|complete|clean]"
    printf "\n"
    print_color "$GREEN" "🎉 Happy coding!"
}

# Run main function
main "$@"