#!/bin/bash
# Docker Development Environment Setup Script
# Configures Docker, Docker Compose, and related development tools

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
log_header() { echo -e "${CYAN}[DOCKER]${NC} $1"; }

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
fi

echo "========================================"
echo "    Docker Environment Setup           "
echo "========================================"
echo
log_info "Operating system: $OS"
echo

# Check if OrbStack is installed and running
check_orbstack() {
    log_header "Checking OrbStack installation"
    
    if [[ "$OS" == "macos" ]]; then
        # Check if OrbStack is installed
        if [ -d "/Applications/OrbStack.app" ]; then
            log_success "OrbStack is installed"
            
            # Check if OrbStack is running
            if pgrep -x "OrbStack" > /dev/null; then
                log_success "OrbStack is running"
                
                # Check if docker command is available through OrbStack
                if command -v docker &> /dev/null; then
                    log_success "Docker command available via OrbStack: $(docker --version)"
                    return 0
                else
                    log_warning "Docker command not available, OrbStack may not be fully configured"
                    return 1
                fi
            else
                log_warning "OrbStack is not running. Starting OrbStack..."
                open -a OrbStack
                
                # Wait for OrbStack to start
                log_info "Waiting for OrbStack to start..."
                local wait_count=0
                while [ $wait_count -lt 30 ]; do
                    if command -v docker &> /dev/null; then
                        log_success "OrbStack started successfully"
                        return 0
                    fi
                    sleep 2
                    ((wait_count++))
                done
                
                log_warning "OrbStack may still be starting. Please wait a moment and try again."
                return 1
            fi
        else
            log_warning "OrbStack is not installed"
            return 1
        fi
    else
        log_info "OrbStack is macOS only, skipping check"
        return 1
    fi
}

# Configure Docker environment
setup_docker() {
    log_header "Setting up Docker development environment"
    
    # First check if OrbStack provides Docker
    if check_orbstack; then
        log_success "Docker is available via OrbStack"
        
        # Verify OrbStack shell integration
        if [ -f ~/.orbstack/shell/init.zsh ]; then
            log_success "OrbStack shell integration is configured"
        else
            log_warning "OrbStack shell integration not found"
        fi
        
    elif command -v docker &> /dev/null; then
        log_success "Docker is already installed: $(docker --version)"
        
        # Check if Docker daemon is running
        if docker info &> /dev/null; then
            log_success "Docker daemon is running"
        else
            log_warning "Docker daemon is not running"
            if [[ "$OS" == "macos" ]]; then
                log_info "Please start Docker Desktop or OrbStack"
            else
                log_info "Please start Docker service: sudo systemctl start docker"
            fi
        fi
        
    else
        log_warning "Docker not found"
        
        if [[ "$OS" == "macos" ]]; then
            log_info "For macOS, we recommend OrbStack or Docker Desktop:"
            log_info "- OrbStack (lightweight): https://orbstack.dev/"
            log_info "- Docker Desktop: https://www.docker.com/products/docker-desktop"
            log_info "OrbStack is already listed in your Brewfile and should be installed"
            return 1
        else
            log_info "Installing Docker for Linux..."
            # Use the Docker installation function from common.sh if available
            if [ -f "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh" ]; then
                source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
                if install_docker; then
                    log_success "Docker installed successfully"
                else
                    log_error "Failed to install Docker"
                    return 1
                fi
            else
                log_error "Docker installation script not found"
                log_info "Please install Docker manually: https://docs.docker.com/engine/install/"
                return 1
            fi
        fi
    fi
}

# Configure Docker Compose
setup_docker_compose() {
    log_header "Setting up Docker Compose"
    
    # Check if docker-compose or docker compose is available
    if command -v docker-compose &> /dev/null; then
        log_success "Docker Compose (standalone) is available: $(docker-compose --version)"
    elif docker compose version &> /dev/null 2>&1; then
        log_success "Docker Compose (plugin) is available: $(docker compose version)"
    else
        log_warning "Docker Compose not found"
        
        if [[ "$OS" == "macos" ]]; then
            if command -v brew &> /dev/null; then
                log_info "Installing Docker Compose via Homebrew..."
                brew install docker-compose
                
                if command -v docker-compose &> /dev/null; then
                    log_success "Docker Compose installed: $(docker-compose --version)"
                else
                    log_error "Failed to install Docker Compose"
                    return 1
                fi
            else
                log_warning "Homebrew not found, please install Docker Compose manually"
                return 1
            fi
        else
            # Use the Docker Compose installation function from common.sh if available
            if [ -f "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh" ]; then
                source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
                if install_docker_compose; then
                    log_success "Docker Compose installed successfully"
                else
                    log_error "Failed to install Docker Compose"
                    return 1
                fi
            else
                log_error "Docker Compose installation script not found"
                log_info "Please install Docker Compose manually: https://docs.docker.com/compose/install/"
                return 1
            fi
        fi
    fi
}

# Create useful Docker aliases and functions
setup_docker_aliases() {
    log_header "Setting up Docker aliases and functions"
    
    # Create Docker aliases file
    local aliases_file="$HOME/.dotfiles/stow-packs/zsh/.config/zsh/aliases/docker.zsh"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$aliases_file")"
    
    # Create Docker aliases
    cat > "$aliases_file" << 'EOF'
# Docker aliases and functions
# Convenient shortcuts for Docker development

# Basic Docker aliases
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs'
alias dlogf='docker logs -f'

# Docker Compose aliases
alias dcup='docker compose up'
alias dcupd='docker compose up -d'
alias dcdown='docker compose down'
alias dcbuild='docker compose build'
alias dcps='docker compose ps'
alias dclogs='docker compose logs'
alias dclogsf='docker compose logs -f'
alias dcexec='docker compose exec'

# Cleanup aliases
alias dprune='docker system prune -f'
alias dprunea='docker system prune -a -f'
alias dclean='docker container prune -f && docker image prune -f && docker volume prune -f && docker network prune -f'

# Docker functions
function dsh() {
    if [ $# -eq 0 ]; then
        echo "Usage: dsh <container_name_or_id> [shell]"
        echo "Example: dsh mycontainer bash"
        return 1
    fi
    
    local container=$1
    local shell=${2:-bash}
    
    docker exec -it "$container" "$shell"
}

function dbuild() {
    if [ $# -eq 0 ]; then
        echo "Usage: dbuild <image_name> [dockerfile_path]"
        echo "Example: dbuild myapp ."
        return 1
    fi
    
    local image_name=$1
    local path=${2:-.}
    
    docker build -t "$image_name" "$path"
}

function drun() {
    if [ $# -eq 0 ]; then
        echo "Usage: drun <image_name> [additional_args...]"
        echo "Example: drun ubuntu:latest -it bash"
        return 1
    fi
    
    local image_name=$1
    shift
    
    docker run --rm "$@" "$image_name"
}

# Docker development environment functions
function ddev() {
    if [ $# -eq 0 ]; then
        echo "Docker Development Environment Commands:"
        echo "  ddev up      - Start development containers"
        echo "  ddev down    - Stop development containers"
        echo "  ddev restart - Restart development containers"
        echo "  ddev logs    - Show development container logs"
        echo "  ddev shell   - Open shell in main container"
        return 0
    fi
    
    case "$1" in
        up)
            docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
            ;;
        down)
            docker compose -f docker-compose.yml -f docker-compose.dev.yml down
            ;;
        restart)
            docker compose -f docker-compose.yml -f docker-compose.dev.yml restart
            ;;
        logs)
            docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f
            ;;
        shell)
            local service=${2:-app}
            docker compose -f docker-compose.yml -f docker-compose.dev.yml exec "$service" bash
            ;;
        *)
            echo "Unknown command: $1"
            ddev
            ;;
    esac
}
EOF
    
    if [ -f "$aliases_file" ]; then
        log_success "Docker aliases created at $aliases_file"
        
        # Create the aliases directory structure in stow-packs if it doesn't exist
        local zsh_config_dir="$HOME/.dotfiles/stow-packs/zsh/.config/zsh"
        if [ ! -d "$zsh_config_dir" ]; then
            mkdir -p "$zsh_config_dir/aliases"
            log_info "Created zsh config directory structure"
        fi
        
        log_info "Docker aliases will be available after restarting your shell or running 'source ~/.zshrc'"
    else
        log_error "Failed to create Docker aliases file"
    fi
}

# Create sample Docker configuration files
create_sample_configs() {
    log_header "Creating sample Docker configuration files"
    
    # Create a samples directory
    local samples_dir="$HOME/.dotfiles/docker-samples"
    mkdir -p "$samples_dir"
    
    # Create sample Dockerfile
    cat > "$samples_dir/Dockerfile" << 'EOF'
# Sample Dockerfile for development
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
EOF
    
    # Create sample docker-compose.yml
    cat > "$samples_dir/docker-compose.yml" << 'EOF'
# Sample Docker Compose configuration
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
      - redis
    volumes:
      - ./src:/app/src
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    restart: unless-stopped

volumes:
  db_data:
EOF
    
    # Create sample docker-compose.dev.yml
    cat > "$samples_dir/docker-compose.dev.yml" << 'EOF'
# Development overrides for Docker Compose
version: '3.8'

services:
  app:
    build:
      target: development
    environment:
      - NODE_ENV=development
    volumes:
      - ./src:/app/src
      - /app/node_modules
    command: npm run dev
    ports:
      - "3000:3000"
      - "9229:9229"  # Debug port

  db:
    environment:
      POSTGRES_DB: myapp_dev
    ports:
      - "5433:5432"  # Different port for dev
EOF
    
    # Create sample .dockerignore
    cat > "$samples_dir/.dockerignore" << 'EOF'
# Docker ignore file
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.vscode
.DS_Store
*.log
EOF
    
    log_success "Sample Docker configuration files created in $samples_dir"
    log_info "You can copy these files to your projects and modify as needed"
}

# Test Docker installation
test_docker() {
    log_header "Testing Docker installation"
    
    # Test docker command
    if command -v docker &> /dev/null; then
        log_success "Docker command available: $(docker --version)"
        
        # Test Docker daemon connection
        if docker info &> /dev/null; then
            log_success "Docker daemon is accessible"
            
            # Test running a simple container
            log_info "Testing Docker with hello-world container..."
            if docker run --rm hello-world > /dev/null 2>&1; then
                log_success "Docker is working correctly"
            else
                log_warning "Docker run test failed, but Docker is accessible"
            fi
        else
            log_warning "Docker daemon is not accessible"
            return 1
        fi
    else
        log_error "Docker command not found"
        return 1
    fi
    
    # Test Docker Compose
    if command -v docker-compose &> /dev/null; then
        log_success "Docker Compose (standalone) available: $(docker-compose --version)"
    elif docker compose version &> /dev/null 2>&1; then
        log_success "Docker Compose (plugin) available: $(docker compose version)"
    else
        log_warning "Docker Compose not available"
    fi
}

# Main setup function
main() {
    log_info "Starting Docker development environment setup..."
    echo
    
    # Setup Docker
    if setup_docker; then
        log_success "Docker setup completed"
    else
        log_warning "Docker setup encountered issues"
    fi
    
    echo
    
    # Setup Docker Compose
    if setup_docker_compose; then
        log_success "Docker Compose setup completed"
    else
        log_warning "Docker Compose setup encountered issues"
    fi
    
    echo
    
    # Setup aliases
    setup_docker_aliases
    
    echo
    
    # Create sample configs
    create_sample_configs
    
    echo
    
    # Test installation
    if test_docker; then
        log_success "Docker environment test passed"
    else
        log_warning "Docker environment test encountered issues"
    fi
    
    echo
    log_success "Docker development environment setup completed!"
    log_info "Recommendations:"
    log_info "1. Restart your terminal or run 'source ~/.zshrc' to load Docker aliases"
    log_info "2. Check sample Docker configurations in ~/.dotfiles/docker-samples/"
    log_info "3. Run 'docker --version' and 'docker compose version' to verify installation"
    if [[ "$OS" == "macos" ]]; then
        log_info "4. Make sure OrbStack or Docker Desktop is running for Docker commands"
    fi
}

# Run main function
main "$@"
