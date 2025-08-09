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
