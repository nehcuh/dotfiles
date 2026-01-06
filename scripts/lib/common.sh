#!/bin/sh
# Common functions for dotfiles scripts
# POSIX-compliant shell library for cross-platform compatibility
# NOTE: This file is not used by the current installer pipeline (`scripts/install.sh`).

# Ensure this script is sourced, not executed
if [ "$(basename "$0")" = "common.sh" ]; then
  echo "Error: This script should be sourced, not executed directly."
  exit 1
fi

# Version
DOTFILES_VERSION="1.0.0"

# Colors (POSIX-compatible)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  MAGENTA='\033[0;35m'
  NC='\033[0m' # No Color
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  CYAN=''
  MAGENTA=''
  NC=''
fi

# Print colored output (POSIX compatible)
print_color() {
  color="$1"
  message="$2"
  printf "%b%s%b\n" "$color" "$message" "$NC"
}

# Log levels
log_info() {
  print_color "$BLUE" "[INFO] $1"
}

log_success() {
  print_color "$GREEN" "[SUCCESS] $1"
}

log_warning() {
  print_color "$YELLOW" "[WARNING] $1"
}

log_error() {
  print_color "$RED" "[ERROR] $1" >&2
}

# Check if command exists (POSIX compatible)
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Safe command execution with error handling
safe_exec() {
  if ! "$@"; then
    log_error "Command failed: $*"
    return 1
  fi
  return 0
}

# Safe sudo execution with error handling
safe_sudo() {
  if ! sudo -n true 2>/dev/null; then
    log_warning "Sudo access required for: $*"
    log_warning "Please enter your password when prompted."
  fi
  
  if ! sudo "$@"; then
    log_error "Failed to run command with sudo: $*"
    log_warning "You may need to run this command manually: sudo $*"
    return 1
  fi
  return 0
}

# Keep sudo session alive
keep_sudo_alive() {
  log_info "Maintaining sudo session..."
  # Keep-alive: update existing sudo time stamp until script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  SUDO_PID=$!
}

# Clean up sudo session
cleanup_sudo() {
  if [ -n "$SUDO_PID" ]; then
    kill "$SUDO_PID" >/dev/null 2>&1 || true
  fi
}

# Platform detection (unified across all scripts)
detect_platform() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"
  DISTRO="unknown"
  
  case "$OS" in
    Linux)
      if [ -f /etc/os-release ]; then
        DISTRO=$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
      elif command_exists lsb_release; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
      fi
      PLATFORM="linux"
      ;;
    Darwin)
      PLATFORM="macos"
      DISTRO="macos"
      # Detect Apple Silicon vs Intel
      if [ "$ARCH" = "arm64" ]; then
        ARCH_TYPE="arm64"
      else
        ARCH_TYPE="x86_64"
      fi
      ;;
    CYGWIN*|MINGW*|MSYS*)
      PLATFORM="windows"
      DISTRO="windows"
      ;;
    *)
      log_error "Unsupported OS: $OS"
      return 1
      ;;
  esac
  
  # WSL detection
  if [ "$PLATFORM" = "linux" ] && grep -q Microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
  else
    IS_WSL=false
  fi
  
  # Export variables
  export OS
  export ARCH
  export PLATFORM
  export DISTRO
  export ARCH_TYPE
  export IS_WSL
  
  log_info "Platform detected: $PLATFORM ($DISTRO) on $ARCH"
  return 0
}

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
  
  export CURRENT_SHELL
  export SHELL_TYPE
  
  log_info "Shell detected: $CURRENT_SHELL ($SHELL_TYPE)"
  return 0
}

# Download file (try curl, then wget)
download_file() {
  url="$1"
  output="$2"
  
  if command_exists curl; then
    if ! curl -fsSL "$url" -o "$output"; then
      log_error "Failed to download: $url"
      return 1
    fi
  elif command_exists wget; then
    if ! wget -q "$url" -O "$output"; then
      log_error "Failed to download: $url"
      return 1
    fi
  else
    log_error "Neither curl nor wget is available"
    return 1
  fi
  
  return 0
}

# Verify checksum of a file
verify_checksum() {
  file="$1"
  expected_checksum="$2"
  algorithm="${3:-sha256}"
  
  if ! command_exists "${algorithm}sum"; then
    log_warning "${algorithm}sum not available, skipping verification"
    return 0
  fi
  
  actual_checksum=$(${algorithm}sum "$file" | cut -d ' ' -f 1)
  if [ "$actual_checksum" != "$expected_checksum" ]; then
    log_error "Checksum verification failed for $file"
    log_error "Expected: $expected_checksum"
    log_error "Actual: $actual_checksum"
    return 1
  fi
  
  log_success "Checksum verified for $file"
  return 0
}

# Create backup of a file
backup_file() {
  file="$1"
  backup_dir="${2:-$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"
  
  if [ ! -f "$file" ]; then
    log_warning "File does not exist, skipping backup: $file"
    return 0
  fi
  
  mkdir -p "$backup_dir"
  cp -f "$file" "$backup_dir/$(basename "$file")"
  
  if [ $? -eq 0 ]; then
    log_success "Backed up $file to $backup_dir"
    return 0
  else
    log_error "Failed to backup $file"
    return 1
  fi
}

# Load configuration from dotfiles.conf
load_config() {
  config_file="${1:-$HOME/.dotfiles/dotfiles.conf}"
  
  if [ ! -f "$config_file" ]; then
    log_warning "Configuration file not found: $config_file"
    return 1
  fi
  
  # Source the configuration file
  # shellcheck disable=SC1090
  . "$config_file"
  
  # Set default values for missing configurations
  : "${DOTFILES_DIR:=$HOME/.dotfiles}"
  : "${STOW_DIR:=$DOTFILES_DIR/stow-packs}"
  : "${TARGET_DIR:=$HOME}"
  : "${GITHUB_USERNAME:=nehcuh}"
  : "${DOTFILES_REPO:=https://github.com/$GITHUB_USERNAME/dotfiles.git}"
  
  export DOTFILES_DIR
  export STOW_DIR
  export TARGET_DIR
  export GITHUB_USERNAME
  export DOTFILES_REPO
  
  log_info "Configuration loaded from $config_file"
  return 0
}

# Check for configuration conflicts
check_config_conflicts() {
  log_info "Checking for configuration conflicts..."
  
  conflicts_found=false
  config_files="$HOME/.zshrc $HOME/.gitconfig $HOME/.config/starship.toml $HOME/.tmux.conf $HOME/.vimrc"
  
  for file in $config_files; do
    if [ -f "$file" ] && [ ! -L "$file" ]; then
      if [ "$conflicts_found" = false ]; then
        log_warning "Configuration conflicts detected:"
        conflicts_found=true
      fi
      log_error "  ✗ $file (existing file, not a symlink)"
    fi
  done
  
  if [ "$conflicts_found" = true ]; then
    return 1
  else
    log_success "No configuration conflicts found"
    return 0
  fi
}

# Handle configuration conflicts
handle_conflicts() {
  action="$1"  # backup, overwrite, or skip
  
  case "$action" in
    backup)
      backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
      log_info "Creating backup at $backup_dir..."
      mkdir -p "$backup_dir"
      
      config_files="$HOME/.zshrc $HOME/.gitconfig $HOME/.config/starship.toml $HOME/.tmux.conf $HOME/.vimrc"
      for file in $config_files; do
        if [ -f "$file" ] && [ ! -L "$file" ]; then
          cp "$file" "$backup_dir/$(basename "$file")"
          rm -f "$file"
          log_success "  ✓ Backed up $(basename "$file")"
        fi
      done
      log_success "Backup completed at $backup_dir"
      ;;
    overwrite)
      log_info "Removing conflicting files..."
      config_files="$HOME/.zshrc $HOME/.gitconfig $HOME/.config/starship.toml $HOME/.tmux.conf $HOME/.vimrc"
      for file in $config_files; do
        if [ -f "$file" ] && [ ! -L "$file" ]; then
          rm -f "$file"
          log_success "  ✓ Removed $(basename "$file")"
        fi
      done
      ;;
    skip)
      log_info "Skipping conflicting files..."
      ;;
    *)
      log_error "Invalid conflict action: $action"
      return 1
      ;;
  esac
  
  return 0
}

# Install Homebrew
install_homebrew() {
  log_info "Installing Homebrew..."
  
  # Check if Homebrew is already installed
  if command_exists brew; then
    log_success "Homebrew is already installed"
    return 0
  fi
  
  # Install Homebrew
  log_info "Installing Homebrew..."
  
  # Check for curl or wget
  if ! command_exists curl && ! command_exists wget; then
    log_error "Neither curl nor wget is available. Please install one of them first."
    return 1
  fi
  
  # Check for git
  if ! command_exists git; then
    log_error "Git is required to install Homebrew"
    return 1
  fi
  
  # Check if USE_TSINGHUA_MIRROR is already set in environment or config
  if [ -z "${USE_TSINGHUA_MIRROR}" ]; then
    # Check if we're in non-interactive mode
    if [ "${DOTFILES_NON_INTERACTIVE}" = "true" ]; then
      # Default to not using Tsinghua mirror in non-interactive mode
      use_tsinghua_mirror="n"
      log_info "Non-interactive mode: Not using Tsinghua mirror for Homebrew installation"
    else
      # Ask user if they want to use Tsinghua mirror (for users in China)
      log_info "Do you want to use Tsinghua mirror for faster installation in China? (y/n) [default: n]"
      read -r use_tsinghua_mirror
      
      # Default to not using Tsinghua mirror if no input is provided
      if [ -z "${use_tsinghua_mirror}" ]; then
        use_tsinghua_mirror="n"
      fi
    fi
  else
    # Use the value from environment or config
    use_tsinghua_mirror="${USE_TSINGHUA_MIRROR}"
    log_info "Using pre-configured setting for Tsinghua mirror: ${use_tsinghua_mirror}"
  fi
  
  if [ "${use_tsinghua_mirror}" = "y" ] || [ "${use_tsinghua_mirror}" = "Y" ]; then
    log_info "Using Tsinghua mirror for Homebrew installation..."
    
    # Set environment variables for Tsinghua mirror
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    export HOMEBREW_INSTALL_FROM_API=1
    
    # Create a temporary directory for installation
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Download the installation script from GitHub
    log_info "Downloading Homebrew installation script from GitHub..."
    if command_exists curl; then
      if ! curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "${temp_dir}/install.sh"; then
        log_error "Failed to download Homebrew installation script from GitHub"
        rm -rf "${temp_dir}"
        return 1
      fi
    else
      if ! wget -q https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -O "${temp_dir}/install.sh"; then
        log_error "Failed to download Homebrew installation script from GitHub"
        rm -rf "${temp_dir}"
        return 1
      fi
    fi
    
    # Run the installation script
    if ! /bin/bash "${temp_dir}/install.sh"; then
      log_error "Failed to install Homebrew"
      rm -rf "${temp_dir}"
      return 1
    fi
    
    # Clean up
    rm -rf "${temp_dir}"
    
    # Add Tsinghua mirror configuration to shell configuration files
    if [ "$SHELL_TYPE" = "zsh" ]; then
      if ! grep -q "HOMEBREW_BREW_GIT_REMOTE" "$HOME/.zshrc"; then
        {
          echo '# Homebrew Tsinghua mirror configuration'
          echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"'
          echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"'
          echo 'export HOMEBREW_INSTALL_FROM_API=1'
          echo 'export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"'
          echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"'
          echo 'export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"'
        } >> "$HOME/.zshrc"
      fi
    elif [ "$SHELL_TYPE" = "bash" ]; then
      if ! grep -q "HOMEBREW_BREW_GIT_REMOTE" "$HOME/.bashrc"; then
        {
          echo '# Homebrew Tsinghua mirror configuration'
          echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"'
          echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"'
          echo 'export HOMEBREW_INSTALL_FROM_API=1'
          echo 'export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"'
          echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"'
          echo 'export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"'
        } >> "$HOME/.bashrc"
      fi
    fi
    
    log_success "Homebrew installed successfully using Tsinghua mirror"
    log_info "Tsinghua mirror configuration has been added to your shell configuration file"
    log_info "Please restart your shell or source your configuration file to apply the changes"
  else
    log_info "Using official Homebrew installation method..."
    
    # Create a temporary directory for installation
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Download the installation script from GitHub
    log_info "Downloading Homebrew installation script from GitHub..."
    if command_exists curl; then
      if ! curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "${temp_dir}/install.sh"; then
        log_error "Failed to download Homebrew installation script from GitHub"
        rm -rf "${temp_dir}"
        return 1
      fi
    else
      if ! wget -q https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -O "${temp_dir}/install.sh"; then
        log_error "Failed to download Homebrew installation script from GitHub"
        rm -rf "${temp_dir}"
        return 1
      fi
    fi
    
    # Run the installation script
    if ! /bin/bash "${temp_dir}/install.sh"; then
      log_error "Failed to install Homebrew"
      rm -rf "${temp_dir}"
      return 1
    fi
    
    # Clean up
    rm -rf "${temp_dir}"
  fi
  
  # Add Homebrew to PATH based on platform and architecture
  case "$PLATFORM" in
    macos)
      if [ "$ARCH" = "arm64" ]; then
        # For Apple Silicon Macs
        if [ -d "/opt/homebrew/bin" ]; then
          log_info "Adding Homebrew to PATH for Apple Silicon Mac..."
          if [ "$SHELL_TYPE" = "zsh" ]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
          elif [ "$SHELL_TYPE" = "bash" ]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.bash_profile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
          fi
        fi
      else
        # For Intel Macs
        if [ -d "/usr/local/bin" ]; then
          log_info "Adding Homebrew to PATH for Intel Mac..."
          if [ "$SHELL_TYPE" = "zsh" ]; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/usr/local/bin/brew shellenv)"
          elif [ "$SHELL_TYPE" = "bash" ]; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.bash_profile"
            eval "$(/usr/local/bin/brew shellenv)"
          fi
        fi
      fi
      ;;
    linux)
      # For Linux
      if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
        log_info "Adding Homebrew to PATH for Linux..."
        if [ "$SHELL_TYPE" = "zsh" ]; then
          echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
          echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.profile"
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [ "$SHELL_TYPE" = "bash" ]; then
          echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bash_profile"
          echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.profile"
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
      fi
      ;;
  esac
  
  # Verify Homebrew is now in PATH
  if ! command_exists brew; then
    log_warning "Homebrew installed but not in PATH. You may need to restart your shell or source your profile."
    log_warning "Try running: source ~/.profile"
    
    # Try to add to PATH directly for this session
    if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
      export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    elif [ -d "/opt/homebrew/bin" ]; then
      export PATH="/opt/homebrew/bin:$PATH"
    elif [ -d "/usr/local/bin" ]; then
      export PATH="/usr/local/bin:$PATH"
    fi
    
    # Check again
    if ! command_exists brew; then
      log_error "Failed to add Homebrew to PATH"
      return 1
    fi
  fi
  
  log_success "Homebrew installed and configured successfully"
  return 0
}

# Detect package manager
detect_package_manager() {
  case "$PLATFORM" in
    linux)
      if command_exists brew; then
        PACKAGE_MANAGER="brew"
      elif command_exists apt; then
        PACKAGE_MANAGER="apt"
      elif command_exists pacman; then
        PACKAGE_MANAGER="pacman"
      elif command_exists dnf; then
        PACKAGE_MANAGER="dnf"
      elif command_exists yum; then
        PACKAGE_MANAGER="yum"
      elif command_exists zypper; then
        PACKAGE_MANAGER="zypper"
      else
        log_warning "No preferred package manager found, will attempt to install Homebrew"
        PACKAGE_MANAGER="brew"
      fi
      ;;
    macos)
      if command_exists brew; then
        PACKAGE_MANAGER="brew"
      else
        PACKAGE_MANAGER="brew"
        log_warning "Homebrew not found, will attempt to install it"
      fi
      ;;
    windows)
      if command_exists scoop; then
        PACKAGE_MANAGER="scoop"
      elif command_exists winget; then
        PACKAGE_MANAGER="winget"
      elif command_exists choco; then
        PACKAGE_MANAGER="choco"
      else
        PACKAGE_MANAGER="scoop"
        log_warning "No package manager found, will attempt to install Scoop"
      fi
      ;;
  esac
  
  export PACKAGE_MANAGER
  log_info "Package manager detected: $PACKAGE_MANAGER"
  return 0
}

# Install Docker
install_docker() {
  log_info "Installing Docker..."
  
  # Check if Docker is already installed
  if command_exists docker; then
    log_success "Docker is already installed"
    return 0
  fi
  
  case "$PLATFORM" in
    linux)
      case "$DISTRO" in
        ubuntu|debian|linuxmint)
          # Update package index
          if ! safe_sudo apt-get update; then
            log_error "Failed to update package lists"
            return 1
          fi
          
          # Install prerequisites
          if ! safe_sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release; then
            log_error "Failed to install Docker prerequisites"
            return 1
          fi
          
          # Add Docker's official GPG key
          if ! curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | safe_sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg; then
            log_error "Failed to add Docker GPG key"
            return 1
          fi
          
          # Set up the stable repository
          if ! echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | safe_sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; then
            log_error "Failed to add Docker repository"
            return 1
          fi
          
          # Update package index again
          if ! safe_sudo apt-get update; then
            log_error "Failed to update package lists after adding Docker repository"
            return 1
          fi
          
          # Install Docker Engine
          if ! safe_sudo apt-get install -y docker-ce docker-ce-cli containerd.io; then
            log_error "Failed to install Docker"
            return 1
          fi
          ;;
        fedora|centos|rhel)
          # Install prerequisites
          if ! safe_sudo dnf install -y dnf-plugins-core; then
            log_error "Failed to install Docker prerequisites"
            return 1
          fi
          
          # Add Docker repository
          if ! safe_sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo; then
            log_error "Failed to add Docker repository"
            return 1
          fi
          
          # Install Docker Engine
          if ! safe_sudo dnf install -y docker-ce docker-ce-cli containerd.io; then
            log_error "Failed to install Docker"
            return 1
          fi
          ;;
        arch|manjaro)
          # Install Docker
          if ! safe_sudo pacman -Syu --noconfirm docker; then
            log_error "Failed to install Docker"
            return 1
          fi
          ;;
        *)
          log_error "Unsupported Linux distribution for Docker installation: $DISTRO"
          log_warning "Please install Docker manually: https://docs.docker.com/engine/install/"
          return 1
          ;;
      esac
      
      # Start and enable Docker service
      if ! safe_sudo systemctl start docker; then
        log_error "Failed to start Docker service"
        return 1
      fi
      
      if ! safe_sudo systemctl enable docker; then
        log_error "Failed to enable Docker service"
        return 1
      fi
      
      # Add current user to docker group to avoid using sudo
      if ! safe_sudo usermod -aG docker "$USER"; then
        log_warning "Failed to add user to docker group"
        log_warning "You may need to use sudo with docker commands"
      else
        log_warning "You need to log out and log back in for docker group changes to take effect"
        log_warning "Alternatively, run: newgrp docker"
      fi
      ;;
    macos)
      log_warning "Docker installation on macOS requires Docker Desktop"
      log_warning "Please download and install Docker Desktop from: https://www.docker.com/products/docker-desktop"
      return 1
      ;;
    windows)
      if [ "$IS_WSL" = true ]; then
        log_warning "Docker installation in WSL requires Docker Desktop for Windows"
        log_warning "Please install Docker Desktop for Windows and enable WSL integration"
        log_warning "See: https://docs.docker.com/desktop/windows/wsl/"
        return 1
      else
        log_warning "Docker installation on Windows requires Docker Desktop"
        log_warning "Please download and install Docker Desktop from: https://www.docker.com/products/docker-desktop"
        return 1
      fi
      ;;
    *)
      log_error "Unsupported platform for Docker installation: $PLATFORM"
      return 1
      ;;
  esac
  
  log_success "Docker installed successfully"
  return 0
}

# Install Docker Compose
install_docker_compose() {
  log_info "Installing Docker Compose..."
  
  # Check if Docker Compose is already installed
  if command_exists docker-compose; then
    log_success "Docker Compose is already installed"
    return 0
  fi
  
  case "$PLATFORM" in
    linux)
      # Get latest Docker Compose version
      COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
      
      if [ -z "$COMPOSE_VERSION" ]; then
        COMPOSE_VERSION="v2.20.3"  # Fallback to a known version if API call fails
        log_warning "Could not determine latest Docker Compose version, using $COMPOSE_VERSION"
      fi
      
      # Download and install Docker Compose
      if ! safe_sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose; then
        log_error "Failed to download Docker Compose"
        return 1
      fi
      
      # Apply executable permissions
      if ! safe_sudo chmod +x /usr/local/bin/docker-compose; then
        log_error "Failed to set executable permissions on Docker Compose"
        return 1
      fi
      
      # Create symlink if needed
      if [ ! -e /usr/bin/docker-compose ]; then
        if ! safe_sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose; then
          log_warning "Failed to create Docker Compose symlink"
        fi
      fi
      ;;
    macos)
      if command_exists brew; then
        if ! brew install docker-compose; then
          log_error "Failed to install Docker Compose with Homebrew"
          return 1
        fi
      else
        log_warning "Homebrew not found, please install Docker Desktop which includes Docker Compose"
        return 1
      fi
      ;;
    windows)
      log_warning "Docker Compose is included with Docker Desktop for Windows"
      log_warning "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
      return 1
      ;;
    *)
      log_error "Unsupported platform for Docker Compose installation: $PLATFORM"
      return 1
      ;;
  esac
  
  log_success "Docker Compose installed successfully"
  return 0
}

# Install package with appropriate package manager
install_package() {
  package="$1"
  
  log_info "Installing package: $package"
  
  case "$PACKAGE_MANAGER" in
    apt)
      if ! safe_sudo apt-get update; then
        log_error "Failed to update package lists"
        return 1
      fi
      if ! safe_sudo apt-get install -y "$package"; then
        log_error "Failed to install $package"
        return 1
      fi
      ;;
    pacman)
      if ! safe_sudo pacman -Sy --noconfirm "$package"; then
        log_error "Failed to install $package"
        return 1
      fi
      ;;
    dnf)
      if ! safe_sudo dnf install -y "$package"; then
        log_error "Failed to install $package"
        return 1
      fi
      ;;
    yum)
      if ! safe_sudo yum install -y "$package"; then
        log_error "Failed to install $package"
        return 1
      fi
      ;;
    zypper)
      if ! safe_sudo zypper install -y "$package"; then
        log_error "Failed to install $package"
        return 1
      fi
      ;;
    brew)
      if ! brew install "$package"; then
        log_error "Failed to install $package"
        return 1
      fi
      ;;
    scoop)
      if ! scoop install "$package"; then
        log_error "Failed to install $package"
        return 1
      fi
      ;;
    winget)
      if ! winget install "$package"; then
        log_error "Failed to install $package"
        return 1
      fi
      ;;
    choco)
      if ! choco install -y "$package"; then
        log_error "Failed to install $package"
        return 1
      fi
      ;;
    *)
      log_error "Unsupported package manager: $PACKAGE_MANAGER"
      return 1
      ;;
  esac
  
  log_success "Package installed: $package"
  return 0
}

# Check if a package is installed
is_package_installed() {
  package="$1"
  
  case "$PACKAGE_MANAGER" in
    apt)
      dpkg -s "$package" >/dev/null 2>&1
      ;;
    pacman)
      pacman -Q "$package" >/dev/null 2>&1
      ;;
    dnf|yum)
      rpm -q "$package" >/dev/null 2>&1
      ;;
    zypper)
      zypper se -i "$package" >/dev/null 2>&1
      ;;
    brew)
      brew list "$package" >/dev/null 2>&1
      ;;
    scoop)
      scoop list | grep -q "$package"
      ;;
    winget)
      winget list | grep -q "$package"
      ;;
    choco)
      choco list --local-only | grep -q "$package"
      ;;
    *)
      log_error "Unsupported package manager: $PACKAGE_MANAGER"
      return 1
      ;;
  esac
  
  return $?
}

# Set up trap to clean up on exit
trap cleanup_sudo EXIT INT TERM

# Initialize
detect_platform
detect_shell
detect_package_manager
