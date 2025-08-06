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
                    sudo apt update
                    sudo apt install -y git stow curl build-essential
                    ;;
                arch|manjaro)
                    sudo pacman -Syu --noconfirm git stow curl base-devel
                    ;;
                fedora|centos|rhel)
                    sudo dnf install -y git stow curl @development-tools
                    ;;
                *)
                    if command_exists apt; then
                        sudo apt update
                        sudo apt install -y git stow curl build-essential
                    elif command_exists pacman; then
                        sudo pacman -Syu --noconfirm git stow curl base-devel
                    elif command_exists dnf; then
                        sudo dnf install -y git stow curl @development-tools
                    else
                        print_color "$RED" "Please install git, stow, curl, and build tools manually"
                        exit 1
                    fi
                    ;;
            esac
            ;;
        windows)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                sudo apt update && sudo apt install -y git stow curl
            elif command_exists pacman; then
                pacman -Syu --noconfirm git stow curl
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
        print_color "$YELLOW" "📁 Dotfiles directory already exists at $DOTFILES_DIR"
        printf "Do you want to update the existing dotfiles? [Y/n]: "
        read response < /dev/tty
        case "$response" in
            [nN][oO]|[nN])
                print_color "$YELLOW" "Using existing dotfiles configuration..."
                ;;
            *)
                print_color "$YELLOW" "Updating dotfiles repository..."
                cd "$DOTFILES_DIR"
                # Backup any local changes
                if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                    print_color "$YELLOW" "Backing up local changes..."
                    git stash push -m "Backup before update $(date)"
                fi
                # Pull latest changes
                git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || {
                    print_color "$RED" "Failed to update repository. Removing and re-cloning..."
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
        fi
    else
        print_color "$YELLOW" "Trying direct stow installation..."
        if [ -f "scripts/stow.sh" ]; then
            print_color "$BLUE" "Running stow installer..."
            ./scripts/stow.sh install
        else
            print_color "$RED" "No installation method available"
            exit 1
        fi
    fi
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
    printf "\n"
    print_color "$GREEN" "🎉 Happy coding!"
}

# Run main function
main "$@"