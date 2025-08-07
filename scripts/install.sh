#!/bin/sh
# Universal cross-platform dotfiles installer
# Compatible with sh, bash, zsh, and other POSIX shells

set -e

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
  clear
  print_color "$CYAN" "╔══════════════════════════════════════════════════════════════╗"
  print_color "$CYAN" "║                    Cross-Platform Dotfiles                   ║"
  print_color "$CYAN" "║                    Universal Installer v$DOTFILES_VERSION                ║"
  print_color "$CYAN" "║                    Linux • macOS • Windows                   ║"
  print_color "$CYAN" "╚══════════════════════════════════════════════════════════════╝"
  printf "\n"
  log_info "Platform: $PLATFORM ($DISTRO) on $ARCH"
  log_info "Shell: $CURRENT_SHELL ($SHELL_TYPE)"
  printf "\n"
}

# Install prerequisites based on platform
install_prerequisites() {
  log_info "Installing prerequisites..."
  
  case "$PLATFORM" in
    macos)
      # Check if Xcode Command Line Tools are installed
      if ! command_exists xcode-select; then
        log_warning "Installing Xcode Command Line Tools..."
        xcode-select --install
        log_warning "Please press Enter when Xcode installation is complete"
        read -r dummy
      fi

      # Install Homebrew if not exists
      if ! command_exists brew; then
        install_homebrew
      fi

      # Install GNU Stow
      if ! command_exists stow; then
        brew install stow
      fi
      ;;
    linux)
      # Install basic dependencies first
      case "$DISTRO" in
        ubuntu|debian|linuxmint)
          if ! safe_sudo apt update; then
            log_error "Failed to update package lists"
            return 1
          fi
          if ! safe_sudo apt install -y git curl build-essential; then
            log_error "Failed to install required packages"
            return 1
          fi
          ;;
        arch|manjaro)
          if ! safe_sudo pacman -Syu --noconfirm git curl base-devel; then
            log_error "Failed to install required packages"
            return 1
          fi
          ;;
        fedora|centos|rhel)
          if ! safe_sudo dnf install -y git curl @development-tools; then
            log_error "Failed to install required packages"
            return 1
          fi
          ;;
        *)
          if command_exists apt; then
            if ! safe_sudo apt update; then
              log_error "Failed to update package lists"
              return 1
            fi
            if ! safe_sudo apt install -y git curl build-essential; then
              log_error "Failed to install required packages"
              return 1
            fi
          elif command_exists pacman; then
            if ! safe_sudo pacman -Syu --noconfirm git curl base-devel; then
              log_error "Failed to install required packages"
              return 1
            fi
          elif command_exists dnf; then
            if ! safe_sudo dnf install -y git curl @development-tools; then
              log_error "Failed to install required packages"
              return 1
            fi
          else
            log_error "Please install git, curl, and build tools manually"
            return 1
          fi
          ;;
      esac
      
      # Ask if user wants to install Homebrew
      printf "Do you want to install Homebrew? (recommended) [Y/n]: "
      read -r install_brew_response
      case "$install_brew_response" in
        [nN][oO]|[nN])
          log_info "Skipping Homebrew installation"
          
          # Install stow using native package manager
          if ! command_exists stow; then
            log_info "Installing GNU Stow using native package manager..."
            install_package stow
          fi
          ;;
        *)
          # Install Homebrew
          if ! command_exists brew; then
            install_homebrew
          fi
          
          # Install GNU Stow using Homebrew
          if ! command_exists stow; then
            log_info "Installing GNU Stow using Homebrew..."
            brew install stow
          fi
          ;;
      esac
      ;;
    windows)
      if [ "$IS_WSL" = true ]; then
        if ! safe_sudo apt update; then
          log_error "Failed to update package lists in WSL"
          return 1
        fi
        if ! safe_sudo apt install -y git curl; then
          log_error "Failed to install packages in WSL"
          return 1
        fi
        
        # Ask if user wants to install Homebrew in WSL
        printf "Do you want to install Homebrew in WSL? (recommended) [Y/n]: "
        read -r install_brew_wsl_response
        case "$install_brew_wsl_response" in
          [nN][oO]|[nN])
            log_info "Skipping Homebrew installation in WSL"
            
            # Install stow using apt
            if ! command_exists stow; then
              log_info "Installing GNU Stow using apt..."
              safe_sudo apt install -y stow
            fi
            ;;
          *)
            # Install Homebrew in WSL
            if ! command_exists brew; then
              install_homebrew
            fi
            
            # Install GNU Stow using Homebrew
            if ! command_exists stow; then
              log_info "Installing GNU Stow using Homebrew..."
              brew install stow
            fi
            ;;
        esac
      elif command_exists pacman; then
        if ! pacman -Syu --noconfirm git curl; then
          log_error "Failed to install packages in MSYS2"
          return 1
        fi
        
        # Install stow in MSYS2
        if ! command_exists stow; then
          if ! pacman -Syu --noconfirm stow; then
            log_error "Failed to install stow in MSYS2"
            return 1
          fi
        fi
      else
        # Native Windows - try to use PowerShell to install Scoop
        if command_exists powershell.exe; then
          log_info "Attempting to install Scoop package manager..."
          powershell.exe -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser; iwr -useb get.scoop.sh | iex"
          if command_exists scoop; then
            scoop install git curl
          else
            log_error "Failed to install Scoop. Please install Git and Curl manually."
            return 1
          fi
        else
          log_error "PowerShell not found. Please install Git and Curl manually."
          return 1
        fi
      fi
      ;;
  esac
  
  log_success "Prerequisites installed"
  return 0
}

# Clone dotfiles repository
clone_dotfiles() {
  if [ -z "$DOTFILES_DIR" ]; then
    DOTFILES_DIR="$HOME/.dotfiles"
  fi
  
  if [ ! -d "$DOTFILES_DIR" ]; then
    log_info "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    log_success "Dotfiles cloned to $DOTFILES_DIR"
  else
    log_warning "Dotfiles directory already exists"
    printf "Do you want to update the existing dotfiles? [Y/n]: "
    read -r response
    case "$response" in
      [nN][oO]|[nN])
        log_info "Using existing dotfiles..."
        ;;
      *)
        log_info "Updating dotfiles..."
        cd "$DOTFILES_DIR"
        # Backup any local changes
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
          log_warning "Stashing local changes..."
          git stash push -m "Backup before update $(date)"
        fi
        # Pull latest changes
        git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || {
          log_warning "Update failed. Re-cloning repository..."
          cd "$HOME"
          rm -rf "$DOTFILES_DIR"
          git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        }
        log_success "Dotfiles updated"
        ;;
    esac
  fi
  
  cd "$DOTFILES_DIR" || exit 1
  
  # Create configuration file if it doesn't exist
  if [ ! -f "$DOTFILES_DIR/dotfiles.conf" ]; then
    if [ -f "$DOTFILES_DIR/dotfiles.conf.template" ]; then
      log_info "Creating configuration file from template..."
      cp "$DOTFILES_DIR/dotfiles.conf.template" "$DOTFILES_DIR/dotfiles.conf"
      log_success "Configuration file created: $DOTFILES_DIR/dotfiles.conf"
      log_warning "You may want to customize it for your needs"
    else
      log_warning "Configuration template not found, creating minimal configuration..."
      cat > "$DOTFILES_DIR/dotfiles.conf" << EOF
# Dotfiles Configuration
GITHUB_USERNAME="nehcuh"
DOTFILES_REPO="https://github.com/nehcuh/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
STOW_DIR="\${DOTFILES_DIR}/stow-packs"
TARGET_DIR="$HOME"
EOF
      log_success "Minimal configuration file created: $DOTFILES_DIR/dotfiles.conf"
    fi
  fi
  
  # Load configuration
  load_config "$DOTFILES_DIR/dotfiles.conf"
}

# Install zsh if not exists
install_zsh_if_needed() {
  if ! command_exists zsh; then
    log_warning "Zsh not found. Installing zsh..."
    
    case "$PLATFORM" in
      macos)
        if command_exists brew; then
          log_warning "Installing zsh with Homebrew..."
          brew install zsh
        else
          log_warning "Installing zsh with Xcode Command Line Tools..."
          # On macOS, zsh is usually installed with Xcode CLT
          if ! command_exists xcode-select; then
            xcode-select --install
            log_warning "Please press Enter when Xcode installation is complete"
            read -r dummy
          fi
        fi
        ;;
      linux)
        install_package zsh
        ;;
      windows)
        # Windows doesn't need zsh installation for universal installer
        log_warning "Skipping zsh installation on Windows"
        return 0
        ;;
    esac
    
    # Verify zsh was installed
    if ! command_exists zsh; then
      log_error "Failed to install zsh"
      log_warning "Please install zsh manually and run this script again"
      return 1
    fi
    
    log_success "Zsh installed successfully"
  fi
  
  return 0
}

# Install dotfiles using stow
install_dotfiles() {
  log_info "Installing dotfiles..."
  
  # Check for configuration conflicts first
  if ! check_config_conflicts; then
    log_warning "Configuration conflicts detected"
    printf "How would you like to handle these conflicts?\n"
    printf "1) Backup existing files and install dotfiles\n"
    printf "2) Overwrite existing files\n"
    printf "3) Skip conflicting files\n"
    printf "Enter your choice [1-3]: "
    read -r choice
    
    case "$choice" in
      1) handle_conflicts "backup" ;;
      2) handle_conflicts "overwrite" ;;
      3) handle_conflicts "skip" ;;
      *) 
        log_error "Invalid choice. Using default: backup"
        handle_conflicts "backup"
        ;;
    esac
  fi
  
  # Determine which packages to install based on platform
  case "$PLATFORM" in
    linux)
      PACKAGES="$DEFAULT_PACKAGES_LINUX"
      ;;
    macos)
      PACKAGES="$DEFAULT_PACKAGES_MACOS"
      ;;
    windows)
      PACKAGES="$DEFAULT_PACKAGES_WINDOWS"
      ;;
    *)
      PACKAGES="system,zsh,git,tools,vim,nvim,tmux"
      ;;
  esac
  
  # Install packages using stow
  log_info "Installing packages: $PACKAGES"
  
  # Convert comma-separated list to space-separated for stow.sh
  PACKAGES_SPACE=$(echo "$PACKAGES" | tr ',' ' ')
  
  # Run stow.sh to install packages
  if [ -f "$DOTFILES_DIR/scripts/stow.sh" ]; then
    if ! "$DOTFILES_DIR/scripts/stow.sh" install $PACKAGES_SPACE; then
      log_error "Failed to install some packages"
      return 1
    fi
  else
    log_error "stow.sh script not found"
    return 1
  fi
  
  log_success "Dotfiles installed successfully"
  return 0
}

# Set up development environment
setup_dev_environment() {
  log_info "Setting up development environment..."
  
  # Ask user which environments to set up
  printf "Which development environments would you like to set up?\n"
  printf "1) Python environment (Pyenv + Anaconda + uv + direnv)\n"
  printf "2) Node.js environment (NVM + LTS Node)\n"
  printf "3) Docker development environment\n"
  printf "4) All of the above\n"
  printf "5) None\n"
  printf "Enter your choice [1-5]: "
  read -r choice
  
  case "$choice" in
    1)
      setup_python_env
      ;;
    2)
      setup_node_env
      ;;
    3)
      setup_docker_env
      ;;
    4)
      setup_python_env
      setup_node_env
      setup_docker_env
      ;;
    5)
      log_info "Skipping development environment setup"
      ;;
    *)
      log_error "Invalid choice. Skipping development environment setup"
      ;;
  esac
  
  return 0
}

# Set up Python environment
setup_python_env() {
  log_info "Setting up Python environment..."
  
  if [ -f "$DOTFILES_DIR/scripts/setup-python-env.sh" ]; then
    if ! "$DOTFILES_DIR/scripts/setup-python-env.sh"; then
      log_error "Failed to set up Python environment"
      return 1
    fi
  else
    log_error "setup-python-env.sh script not found"
    return 1
  fi
  
  log_success "Python environment set up successfully"
  return 0
}

# Set up Node.js environment
setup_node_env() {
  log_info "Setting up Node.js environment..."
  
  if [ -f "$DOTFILES_DIR/scripts/setup-node-env.sh" ]; then
    if ! "$DOTFILES_DIR/scripts/setup-node-env.sh"; then
      log_error "Failed to set up Node.js environment"
      return 1
    fi
  else
    log_error "setup-node-env.sh script not found"
    return 1
  fi
  
  log_success "Node.js environment set up successfully"
  return 0
}

# Set up Docker environment
setup_docker_env() {
  log_info "Setting up Docker environment..."
  
  if [ -f "$DOTFILES_DIR/docker/docker-compose.ubuntu-dev.yml" ]; then
    log_info "Building Docker development environment..."
    
    if command_exists docker && command_exists docker-compose; then
      cd "$DOTFILES_DIR" || exit 1
      if ! docker-compose -f docker/docker-compose.ubuntu-dev.yml build; then
        log_error "Failed to build Docker environment"
        return 1
      fi
      
      log_success "Docker environment built successfully"
      log_info "To start the environment: docker-compose -f docker/docker-compose.ubuntu-dev.yml up -d"
      log_info "To access the environment: docker-compose -f docker/docker-compose.ubuntu-dev.yml exec ubuntu-dev zsh"
    else
      log_error "Docker or docker-compose not found"
      log_warning "Please install Docker and docker-compose first"
      return 1
    fi
  else
    log_error "Docker compose file not found"
    return 1
  fi
  
  return 0
}

# Set up Git configuration
setup_git_config() {
  log_info "Setting up Git configuration..."
  
  if [ -f "$DOTFILES_DIR/scripts/setup-git-config.sh" ]; then
    if ! "$DOTFILES_DIR/scripts/setup-git-config.sh"; then
      log_error "Failed to set up Git configuration"
      return 1
    fi
  else
    # Fallback to manual Git configuration
    log_warning "setup-git-config.sh script not found, setting up Git configuration manually..."
    
    # Check if Git is installed
    if ! command_exists git; then
      log_error "Git not installed"
      return 1
    fi
    
    # Check if .gitconfig_local template exists
    if [ -f "$DOTFILES_DIR/stow-packs/git/.gitconfig_local.template" ]; then
      # Create .gitconfig_local if it doesn't exist
      if [ ! -f "$HOME/.gitconfig_local" ]; then
        cp "$DOTFILES_DIR/stow-packs/git/.gitconfig_local.template" "$HOME/.gitconfig_local"
        log_success "Created ~/.gitconfig_local from template"
        log_warning "Please edit ~/.gitconfig_local with your name and email"
      else
        log_info "~/.gitconfig_local already exists"
      fi
    else
      log_warning ".gitconfig_local template not found"
      
      # Ask for Git user information
      printf "Please enter your Git username: "
      read -r git_name
      printf "Please enter your Git email: "
      read -r git_email
      
      # Create .gitconfig_local
      cat > "$HOME/.gitconfig_local" << EOF
[user]
    name = $git_name
    email = $git_email
EOF
      log_success "Created ~/.gitconfig_local with provided information"
    fi
  fi
  
  log_success "Git configuration set up successfully"
  return 0
}

# Change default shell to zsh if needed
change_default_shell() {
  if [ "$PLATFORM" = "windows" ]; then
    log_info "Skipping shell change on Windows"
    return 0
  fi
  
  if [ "$CURRENT_SHELL" != "zsh" ] && command_exists zsh; then
    log_info "Changing default shell to zsh..."
    
    # Get zsh path
    ZSH_PATH=$(command -v zsh)
    
    # Check if zsh is in /etc/shells
    if ! grep -q "$ZSH_PATH" /etc/shells; then
      log_warning "Adding $ZSH_PATH to /etc/shells"
      echo "$ZSH_PATH" | safe_sudo tee -a /etc/shells
    fi
    
    # Change shell
    if ! chsh -s "$ZSH_PATH"; then
      log_error "Failed to change shell to zsh"
      log_warning "You can change it manually with: chsh -s $ZSH_PATH"
      return 1
    fi
    
    log_success "Default shell changed to zsh"
  else
    log_info "Already using zsh or zsh not available"
  fi
  
  return 0
}

# Main installation process
main() {
  print_header
  
  # Check for sudo access on Unix-like systems
  if [ "$PLATFORM" != "windows" ]; then
    if ! sudo -n true 2>/dev/null; then
      log_warning "Sudo access required for some operations"
      log_warning "Please enter your password when prompted"
      if ! sudo -v; then
        log_error "Failed to obtain sudo access"
        log_error "Some operations may fail"
      else
        keep_sudo_alive
      fi
    fi
  fi
  
  # Install prerequisites
  if ! install_prerequisites; then
    log_error "Failed to install prerequisites"
    exit 1
  fi
  
  # Clone dotfiles repository
  if ! clone_dotfiles; then
    log_error "Failed to clone dotfiles repository"
    exit 1
  fi
  
  # Install zsh if needed
  if ! install_zsh_if_needed; then
    log_warning "Failed to install zsh, continuing with current shell"
  fi
  
  # Install dotfiles
  if ! install_dotfiles; then
    log_error "Failed to install dotfiles"
    exit 1
  fi
  
  # Set up Git configuration
  if ! setup_git_config; then
    log_warning "Failed to set up Git configuration"
  fi
  
  # Ask if user wants to set up development environment
  printf "Do you want to set up development environments? [y/N]: "
  read -r response
  case "$response" in
    [yY][eE][sS]|[yY])
      if ! setup_dev_environment; then
        log_warning "Failed to set up some development environments"
      fi
      ;;
    *)
      log_info "Skipping development environment setup"
      ;;
  esac
  
  # Change default shell to zsh if needed
  if ! change_default_shell; then
    log_warning "Failed to change default shell"
  fi
  
  # Final message
  log_success "Installation complete!"
  log_info "Please restart your terminal to apply all changes"
  log_info "You can manage your dotfiles with:"
  log_info "  cd ~/.dotfiles"
  log_info "  ./scripts/stow.sh install|remove|status|list [package...]"
  log_info "  make install|remove|status|list"
  log_info "Happy coding!"
}

# Run main function
main "$@"