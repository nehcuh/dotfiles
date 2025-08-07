#!/bin/sh
# Interactive script to build a development Docker container
# This script allows customizing username, UID, GID, and password

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

# Source common library if available
if [ -f "$SCRIPT_DIR/../lib/common.sh" ]; then
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
else
  # Define minimal logging functions if common.sh is not available
  log_info() {
    echo "[INFO] $1"
  }
  
  log_success() {
    echo "[SUCCESS] $1"
  }
  
  log_warning() {
    echo "[WARNING] $1"
  }
  
  log_error() {
    echo "[ERROR] $1" >&2
  }
  
  # Define color codes
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  NC='\033[0m' # No Color
  
  print_color() {
    color=$1
    shift
    printf "%b%s%b\n" "$color" "$*" "$NC"
  }
  
  command_exists() {
    command -v "$1" >/dev/null 2>&1
  }
  
  # Get current user
  get_current_user() {
    if command_exists whoami; then
      whoami
    elif [ -n "$USER" ]; then
      echo "$USER"
    else
      echo "unknown"
    fi
  }
  
  # Get current UID
  get_current_uid() {
    if command_exists id; then
      id -u
    else
      echo "1000"
    fi
  }
  
  # Get current GID
  get_current_gid() {
    if command_exists id; then
      id -g
    else
      echo "1000"
    fi
  }
fi

# Print header
print_header() {
  print_color "$CYAN" "╔══════════════════════════════════════════════════════════════╗"
  print_color "$CYAN" "║                Development Container Builder                 ║"
  print_color "$CYAN" "╚══════════════════════════════════════════════════════════════╝"
  printf "\n"
}

# Check if Docker is installed
check_docker() {
  log_info "Checking if Docker is installed..."
  
  if ! command_exists docker; then
    log_error "Docker is not installed"
    log_info "Please install Docker first: https://docs.docker.com/get-docker/"
    return 1
  fi
  
  if ! command_exists docker-compose; then
    log_warning "docker-compose is not installed"
    log_info "We recommend installing docker-compose: https://docs.docker.com/compose/install/"
  fi
  
  log_success "Docker is installed"
  return 0
}

# Get user input with default value
get_input() {
  prompt=$1
  default=$2
  
  printf "%s [%s]: " "$prompt" "$default"
  read -r input
  
  if [ -z "$input" ]; then
    echo "$default"
  else
    echo "$input"
  fi
}

# Get password input
get_password() {
  prompt=$1
  default=$2
  
  # Try to use stty to disable echo
  if command_exists stty; then
    stty_orig=$(stty -g)
    stty -echo
    printf "%s: " "$prompt"
    read -r password
    stty "$stty_orig"
    echo
  else
    # Fallback to regular read
    printf "%s [%s]: " "$prompt" "$default"
    read -r password
  fi
  
  if [ -z "$password" ]; then
    echo "$default"
  else
    echo "$password"
  fi
}

# Get user configuration
get_user_config() {
  log_info "Please provide user configuration for the development container"
  
  # Get current user info for defaults
  current_user=$(get_current_user)
  current_uid=$(get_current_uid)
  current_gid=$(get_current_gid)
  
  # Get username
  USERNAME=$(get_input "Username" "$current_user")
  
  # Get UID
  USER_UID=$(get_input "User UID" "$current_uid")
  
  # Get GID
  USER_GID=$(get_input "User GID" "$current_gid")
  
  # Get password
  USER_PASSWORD=$(get_password "Password (will be visible in Dockerfile)" "password")
  
  # Get image name
  IMAGE_NAME=$(get_input "Image name" "dev-environment")
  
  # Get container name
  CONTAINER_NAME=$(get_input "Container name" "dev-container")
  
  # Get workspace path
  WORKSPACE_PATH=$(get_input "Workspace path" "$(pwd)")
  
  log_success "User configuration complete"
}

# Generate docker-compose.yml
generate_docker_compose() {
  log_info "Generating docker-compose.yml..."
  
  # Create docker directory if it doesn't exist
  mkdir -p "$DOTFILES_DIR/docker"
  
  # Create docker-compose.yml
  cat > "$DOTFILES_DIR/docker/docker-compose.yml" << EOF
version: '3.8'

services:
  dev:
    build:
      context: ..
      dockerfile: docker/Dockerfile.ubuntu-dev
      args:
        USERNAME: ${USERNAME}
        USER_UID: ${USER_UID}
        USER_GID: ${USER_GID}
        USER_PASSWORD: ${USER_PASSWORD}
    container_name: ${CONTAINER_NAME}
    hostname: ubuntu-dev
    volumes:
      # Mount workspace
      - ${WORKSPACE_PATH}:/workspace:cached
      # Mount home directory
      - ~/:/home/${USERNAME}/host-home:cached
      # Mount SSH keys (read-only)
      - ~/.ssh:/home/${USERNAME}/.ssh:ro
      # Mount git config (read-only)
      - ~/.gitconfig:/home/${USERNAME}/.gitconfig:ro
      # Persistent home directory
      - dev-home:/home/${USERNAME}
      # Mount Docker socket if available
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      # Common development ports
      - "3000:3000"   # React/Next.js
      - "8000:8000"   # Django/FastAPI
      - "8080:8080"   # Spring Boot
      - "5000:5000"   # Flask
      - "4000:4000"   # Jekyll
      - "9000:9000"   # Various services
    environment:
      - TERM=xterm-256color
      - COLORTERM=truecolor
      # Python environment
      - PYTHONPATH=/workspace
      - PYTHONDONTWRITEBYTECODE=1
      - PYTHONUNBUFFERED=1
      # Node.js environment
      - NODE_ENV=development
      # Java environment
      - JAVA_HOME=/home/linuxbrew/.linuxbrew/opt/openjdk@21
    stdin_open: true
    tty: true
    command: zsh
    networks:
      - dev-network

networks:
  dev-network:
    driver: bridge

volumes:
  # Persistent home directory
  dev-home:
    driver: local
EOF
  
  log_success "docker-compose.yml generated at $DOTFILES_DIR/docker/docker-compose.yml"
}

# Generate Dockerfile
generate_dockerfile() {
  log_info "Generating Dockerfile..."
  
  # Create docker directory if it doesn't exist
  mkdir -p "$DOTFILES_DIR/docker"
  
  # Copy template to Dockerfile.ubuntu-dev
  if [ -f "$DOTFILES_DIR/docker/Dockerfile.ubuntu-dev.template.improved" ]; then
    cp "$DOTFILES_DIR/docker/Dockerfile.ubuntu-dev.template.improved" "$DOTFILES_DIR/docker/Dockerfile.ubuntu-dev"
  elif [ -f "$DOTFILES_DIR/docker/Dockerfile.ubuntu-dev.template" ]; then
    cp "$DOTFILES_DIR/docker/Dockerfile.ubuntu-dev.template" "$DOTFILES_DIR/docker/Dockerfile.ubuntu-dev"
  else
    log_error "Dockerfile template not found"
    return 1
  fi
  
  log_success "Dockerfile generated at $DOTFILES_DIR/docker/Dockerfile.ubuntu-dev"
}

# Build Docker image
build_image() {
  log_info "Building Docker image..."
  
  cd "$DOTFILES_DIR" || exit 1
  
  if command_exists docker-compose; then
    docker-compose -f docker/docker-compose.yml build
  else
    docker build \
      --build-arg USERNAME="$USERNAME" \
      --build-arg USER_UID="$USER_UID" \
      --build-arg USER_GID="$USER_GID" \
      --build-arg USER_PASSWORD="$USER_PASSWORD" \
      -t "$IMAGE_NAME" \
      -f docker/Dockerfile.ubuntu-dev .
  fi
  
  if [ $? -eq 0 ]; then
    log_success "Docker image built successfully"
  else
    log_error "Failed to build Docker image"
    return 1
  fi
}

# Start container
start_container() {
  log_info "Starting container..."
  
  cd "$DOTFILES_DIR" || exit 1
  
  if command_exists docker-compose; then
    docker-compose -f docker/docker-compose.yml up -d
  else
    docker run -d \
      --name "$CONTAINER_NAME" \
      -v "$WORKSPACE_PATH:/workspace" \
      -v "$HOME:/home/$USERNAME/host-home" \
      -v "$HOME/.ssh:/home/$USERNAME/.ssh:ro" \
      -v "$HOME/.gitconfig:/home/$USERNAME/.gitconfig:ro" \
      -p 3000:3000 -p 8000:8000 -p 8080:8080 -p 5000:5000 -p 4000:4000 -p 9000:9000 \
      -e TERM=xterm-256color \
      -e COLORTERM=truecolor \
      -e PYTHONPATH=/workspace \
      -e PYTHONDONTWRITEBYTECODE=1 \
      -e PYTHONUNBUFFERED=1 \
      -e NODE_ENV=development \
      -e JAVA_HOME=/home/linuxbrew/.linuxbrew/opt/openjdk@21 \
      --hostname ubuntu-dev \
      -it \
      "$IMAGE_NAME" \
      zsh
  fi
  
  if [ $? -eq 0 ]; then
    log_success "Container started successfully"
    
    if command_exists docker-compose; then
      log_info "To access the container, run: docker-compose -f $DOTFILES_DIR/docker/docker-compose.yml exec dev zsh"
    else
      log_info "To access the container, run: docker exec -it $CONTAINER_NAME zsh"
    fi
  else
    log_error "Failed to start container"
    return 1
  fi
}

# Show help
show_help() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help     Show this help message"
  echo "  -b, --build    Build the Docker image only"
  echo "  -s, --start    Start the container only"
  echo "  -a, --all      Build and start (default)"
  echo ""
}

# Main function
main() {
  # Set default action
  action="all"
  
  # Parse command line arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        show_help
        exit 0
        ;;
      -b|--build)
        action="build"
        shift
        ;;
      -s|--start)
        action="start"
        shift
        ;;
      -a|--all)
        action="all"
        shift
        ;;
      *)
        log_error "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
  done
  
  # Print header
  print_header
  
  # Check if Docker is installed
  if ! check_docker; then
    exit 1
  fi
  
  # Set dotfiles directory
  DOTFILES_DIR="$HOME/.dotfiles"
  if [ ! -d "$DOTFILES_DIR" ]; then
    DOTFILES_DIR=$(dirname "$(dirname "$SCRIPT_DIR")")
  fi
  
  # Get user configuration
  get_user_config
  
  # Generate docker-compose.yml
  generate_docker_compose
  
  # Generate Dockerfile
  generate_dockerfile
  
  # Build image if requested
  if [ "$action" = "build" ] || [ "$action" = "all" ]; then
    if ! build_image; then
      exit 1
    fi
  fi
  
  # Start container if requested
  if [ "$action" = "start" ] || [ "$action" = "all" ]; then
    if ! start_container; then
      exit 1
    fi
  fi
  
  log_success "Done"
}

# Run main function
main "$@"