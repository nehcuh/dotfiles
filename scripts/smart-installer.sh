#!/bin/bash
# Smart Package Installer - Intelligent software installation with caching and update management
# Avoids redundant downloads by checking existing installations and provides smart updates

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CACHE_DIR="$HOME/.cache/smart-installer"
STATE_DIR="$HOME/.local/state/smart-installer"
CONFIG_DIR="$HOME/.config/smart-installer"
DOWNLOAD_DIR="$CACHE_DIR/downloads"
BACKUP_DIR="$CACHE_DIR/backups"
LOG_FILE="$STATE_DIR/installer.log"

# Create necessary directories
mkdir -p "$CACHE_DIR" "$STATE_DIR" "$CONFIG_DIR" "$DOWNLOAD_DIR" "$BACKUP_DIR"

# Initialize log file
touch "$LOG_FILE"

# Package database with download URLs and verification
declare -A PACKAGE_DB=(
    # Development Tools
    ["git"]='{"name":"git","url":"https://github.com/git/git","type":"system","verify":"git --version"}'
    ["node"]='{"name":"node","url":"https://nodejs.org","type":"system","verify":"node --version"}'
    ["python"]='{"name":"python","url":"https://python.org","type":"system","verify":"python3 --version"}'
    ["go"]='{"name":"go","url":"https://golang.org","type":"system","verify":"go version"}'
    ["rust"]='{"name":"rust","url":"https://rust-lang.org","type":"custom","verify":"rustc --version"}'
    ["ruby"]='{"name":"ruby","url":"https://ruby-lang.org","type":"system","verify":"ruby --version"}'
    ["php"]='{"name":"php","url":"https://php.net","type":"system","verify":"php --version"}'
    ["java"]='{"name":"java","url":"https://java.com","type":"system","verify":"java -version"}'
    
    # Editors
    ["vim"]='{"name":"vim","url":"https://www.vim.org","type":"system","verify":"vim --version"}'
    ["nvim"]='{"name":"nvim","url":"https://neovim.io","type":"system","verify":"nvim --version"}'
    ["vscode"]='{"name":"vscode","url":"https://code.visualstudio.com","type":"custom","verify":"code --version"}'
    ["zed"]='{"name":"zed","url":"https://zed.dev","type":"custom","verify":"zed --version"}'
    ["sublime"]='{"name":"sublime","url":"https://sublimetext.com","type":"custom","verify":"subl --version"}'
    ["atom"]='{"name":"atom","url":"https://atom.io","type":"custom","verify":"atom --version"}'
    
    # Browsers
    ["firefox"]='{"name":"firefox","url":"https://www.mozilla.org/firefox","type":"system","verify":"firefox --version"}'
    ["chrome"]='{"name":"chrome","url":"https://www.google.com/chrome","type":"custom","verify":"google-chrome --version"}'
    ["brave"]='{"name":"brave","url":"https://brave.com","type":"custom","verify":"brave --version"}'
    ["edge"]='{"name":"edge","url":"https://www.microsoft.com/edge","type":"custom","verify":"microsoft-edge --version"}'
    ["opera"]='{"name":"opera","url":"https://opera.com","type":"custom","verify":"opera --version"}'
    
    # System Tools
    ["tmux"]='{"name":"tmux","url":"https://github.com/tmux/tmux","type":"system","verify":"tmux -V"}'
    ["zsh"]='{"name":"zsh","url":"https://www.zsh.org","type":"system","verify":"zsh --version"}'
    ["fish"]='{"name":"fish","url":"https://fishshell.com","type":"system","verify":"fish --version"}'
    ["bash"]='{"name":"bash","url":"https://www.gnu.org/software/bash","type":"system","verify":"bash --version"}'
    
    # Utilities
    ["curl"]='{"name":"curl","url":"https://curl.se","type":"system","verify":"curl --version"}'
    ["wget"]='{"name":"wget","url":"https://www.gnu.org/software/wget","type":"system","verify":"wget --version"}'
    ["jq"]='{"name":"jq","url":"https://stedolan.github.io/jq","type":"system","verify":"jq --version"}'
    ["ripgrep"]='{"name":"ripgrep","url":"https://github.com/BurntSushi/ripgrep","type":"system","verify":"rg --version"}'
    ["fd"]='{"name":"fd","url":"https://github.com/sharkdp/fd","type":"system","verify":"fd --version"}'
    ["exa"]='{"name":"exa","url":"https://the.exa.website","type":"system","verify":"exa --version"}'
    ["bat"]='{"name":"bat","url":"https://github.com/sharkdp/bat","type":"system","verify":"bat --version"}'
    ["htop"]='{"name":"htop","url":"https://htop.dev","type":"system","verify":"htop --version"}'
    ["ncdu"]='{"name":"ncdu","url":"https://dev.yorhel.nl/ncdu","type":"system","verify":"ncdu --version"}'
    ["tree"]='{"name":"tree","url":"http://mama.indstate.edu/users/ice/tree/","type":"system","verify":"tree --version"}'
    ["rsync"]='{"name":"rsync","url":"https://rsync.samba.org","type":"system","verify":"rsync --version"}'
    ["ssh"]='{"name":"ssh","url":"https://www.openssh.com","type":"system","verify":"ssh -V"}'
    ["git-lfs"]='{"name":"git-lfs","url":"https://git-lfs.github.com","type":"system","verify":"git lfs version"}'
    
    # Containers and Virtualization
    ["docker"]='{"name":"docker","url":"https://www.docker.com","type":"custom","verify":"docker --version"}'
    ["virtualbox"]='{"name":"virtualbox","url":"https://www.virtualbox.org","type":"custom","verify":"VBoxManage --version"}'
    ["vmware"]='{"name":"vmware","url":"https://www.vmware.com","type":"custom","verify":"vmware --version"}'
    ["vagrant"]='{"name":"vagrant","url":"https://www.vagrantup.com","type":"custom","verify":"vagrant --version"}'
    ["kubernetes"]='{"name":"kubernetes","url":"https://kubernetes.io","type":"custom","verify":"kubectl version --client"}'
    ["minikube"]='{"name":"minikube","url":"https://minikube.sigs.k8s.io","type":"custom","verify":"minikube version"}'
    
    # Development Tools
    ["make"]='{"name":"make","url":"https://www.gnu.org/software/make","type":"system","verify":"make --version"}'
    ["cmake"]='{"name":"cmake","url":"https://cmake.org","type":"system","verify":"cmake --version"}'
    ["ninja"]='{"name":"ninja","url":"https://ninja-build.org","type":"system","verify":"ninja --version"}'
    ["meson"]='{"name":"meson","url":"https://mesonbuild.com","type":"system","verify":"meson --version"}'
    ["gradle"]='{"name":"gradle","url":"https://gradle.org","type":"custom","verify":"gradle --version"}'
    ["maven"]='{"name":"maven","url":"https://maven.apache.org","type":"custom","verify":"mvn --version"}'
    ["ant"]='{"name":"ant","url":"https://ant.apache.org","type":"custom","verify":"ant -version"}'
    
    # Database
    ["mysql"]='{"name":"mysql","url":"https://mysql.com","type":"system","verify":"mysql --version"}'
    ["postgresql"]='{"name":"postgresql","url":"https://postgresql.org","type":"system","verify":"psql --version"}'
    ["sqlite"]='{"name":"sqlite","url":"https://sqlite.org","type":"system","verify":"sqlite3 --version"}'
    ["redis"]='{"name":"redis","url":"https://redis.io","type":"system","verify":"redis-server --version"}'
    ["mongodb"]='{"name":"mongodb","url":"https://mongodb.com","type":"custom","verify":"mongod --version"}'
    
    # Cloud and DevOps
    ["aws"]='{"name":"aws","url":"https://aws.amazon.com/cli","type":"custom","verify":"aws --version"}'
    ["gcloud"]='{"name":"gcloud","url":"https://cloud.google.com/sdk","type":"custom","verify":"gcloud --version"}'
    ["azure"]='{"name":"azure","url":"https://docs.microsoft.com/cli/azure","type":"custom","verify":"az --version"}'
    ["terraform"]='{"name":"terraform","url":"https://terraform.io","type":"custom","verify":"terraform --version"}'
    ["ansible"]='{"name":"ansible","url":"https://ansible.com","type":"system","verify":"ansible --version"}'
    ["puppet"]='{"name":"puppet","url":"https://puppet.com","type":"system","verify":"puppet --version"}'
    ["chef"]='{"name":"chef","url":"https://chef.io","type":"custom","verify":"chef-solo --version"}'
    
    # Monitoring and Logging
    ["prometheus"]='{"name":"prometheus","url":"https://prometheus.io","type":"custom","verify":"prometheus --version"}'
    ["grafana"]='{"name":"grafana","url":"https://grafana.com","type":"custom","verify":"grafana-server --version"}'
    ["elasticsearch"]='{"name":"elasticsearch","url":"https://elastic.co","type":"custom","verify":"elasticsearch --version"}'
    ["logstash"]='{"name":"logstash","url":"https://elastic.co","type":"custom","verify":"logstash --version"}'
    ["kibana"]='{"name":"kibana","url":"https://elastic.co","type":"custom","verify":"kibana --version"}'
)

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO" "$@"
    echo -e "${BLUE}$@${NC}"
}

log_success() {
    log "SUCCESS" "$@"
    echo -e "${GREEN}$@${NC}"
}

log_warning() {
    log "WARNING" "$@"
    echo -e "${YELLOW}$@${NC}"
}

log_error() {
    log "ERROR" "$@"
    echo -e "${RED}$@${NC}"
}

# Detect system and package manager
detect_system() {
    local OS="$(uname -s)"
    local PACKAGE_MANAGER=""
    local INSTALL_CMD=""
    local UPDATE_CMD=""
    local UPGRADE_CMD=""
    
    case "$OS" in
        Darwin)
            if command -v brew >/dev/null 2>&1; then
                PACKAGE_MANAGER="brew"
                INSTALL_CMD="brew install"
                UPDATE_CMD="brew update"
                UPGRADE_CMD="brew upgrade"
            fi
            ;;
        Linux)
            if command -v apt >/dev/null 2>&1; then
                PACKAGE_MANAGER="apt"
                INSTALL_CMD="sudo apt install -y"
                UPDATE_CMD="sudo apt update"
                UPGRADE_CMD="sudo apt upgrade -y"
            elif command -v apt-get >/dev/null 2>&1; then
                PACKAGE_MANAGER="apt-get"
                INSTALL_CMD="sudo apt-get install -y"
                UPDATE_CMD="sudo apt-get update"
                UPGRADE_CMD="sudo apt-get upgrade -y"
            elif command -v dnf >/dev/null 2>&1; then
                PACKAGE_MANAGER="dnf"
                INSTALL_CMD="sudo dnf install -y"
                UPDATE_CMD="sudo dnf check-update"
                UPGRADE_CMD="sudo dnf upgrade -y"
            elif command -v yum >/dev/null 2>&1; then
                PACKAGE_MANAGER="yum"
                INSTALL_CMD="sudo yum install -y"
                UPDATE_CMD="sudo yum check-update"
                UPGRADE_CMD="sudo yum upgrade -y"
            elif command -v pacman >/dev/null 2>&1; then
                PACKAGE_MANAGER="pacman"
                INSTALL_CMD="sudo pacman -S --noconfirm"
                UPDATE_CMD="sudo pacman -Sy"
                UPGRADE_CMD="sudo pacman -Su --noconfirm"
            elif command -v zypper >/dev/null 2>&1; then
                PACKAGE_MANAGER="zypper"
                INSTALL_CMD="sudo zypper install -y"
                UPDATE_CMD="sudo zypper refresh"
                UPGRADE_CMD="sudo zypper update -y"
            elif command -v emerge >/dev/null 2>&1; then
                PACKAGE_MANAGER="emerge"
                INSTALL_CMD="sudo emerge"
                UPDATE_CMD="sudo emerge --sync"
                UPGRADE_CMD="sudo emerge -uDU @world"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            if command -v scoop >/dev/null 2>&1; then
                PACKAGE_MANAGER="scoop"
                INSTALL_CMD="scoop install"
                UPDATE_CMD="scoop update"
                UPGRADE_CMD="scoop update *"
            elif command -v choco >/dev/null 2>&1; then
                PACKAGE_MANAGER="choco"
                INSTALL_CMD="choco install -y"
                UPDATE_CMD="choco upgrade all -y"
                UPGRADE_CMD="choco upgrade all -y"
            fi
            ;;
    esac
    
    echo "$PACKAGE_MANAGER:$INSTALL_CMD:$UPDATE_CMD:$UPGRADE_CMD"
}

# Check if package is already installed
is_package_installed() {
    local package="$1"
    local verify_cmd=$(echo "${PACKAGE_DB[$package]}" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('verify', ''))" 2>/dev/null)
    
    if [ -n "$verify_cmd" ]; then
        # Try to verify with specific command
        if eval "$verify_cmd" >/dev/null 2>&1; then
            return 0
        fi
    fi
    
    # Fallback: check if command exists
    if command -v "$package" >/dev/null 2>&1; then
        return 0
    fi
    
    # Check with package manager
    local package_manager_info=$(detect_system)
    local package_manager=$(echo "$package_manager_info" | cut -d: -f1)
    
    case "$package_manager" in
        brew)
            brew list --formula | grep -q "^${package}$"
            ;;
        apt|apt-get)
            dpkg -l | grep -q "^ii  $package"
            ;;
        dnf|yum)
            rpm -q "$package" >/dev/null 2>&1
            ;;
        pacman)
            pacman -Q "$package" >/dev/null 2>&1
            ;;
        zypper)
            zypper se -i "$package" | grep -q "^i.*$package"
            ;;
        emerge)
            qlist -I "$package" >/dev/null 2>&1
            ;;
        scoop)
            scoop list | grep -q "^ $package "
            ;;
        choco)
            choco list --local-only | grep -q "^$package "
            ;;
    esac
}

# Get package version
get_package_version() {
    local package="$1"
    local verify_cmd=$(echo "${PACKAGE_DB[$package]}" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('verify', ''))" 2>/dev/null)
    
    if [ -n "$verify_cmd" ]; then
        eval "$verify_cmd" 2>/dev/null | head -1 | awk '{print $NF}' || echo "unknown"
    else
        echo "unknown"
    fi
}

# Check for package updates
check_package_updates() {
    local package="$1"
    local package_manager_info=$(detect_system)
    local package_manager=$(echo "$package_manager_info" | cut -d: -f1)
    
    case "$package_manager" in
        brew)
            brew outdated | grep -q "^$package "
            ;;
        apt|apt-get)
            apt list --upgradable 2>/dev/null | grep -q "^$package/"
            ;;
        dnf|yum)
            dnf check-update "$package" 2>/dev/null | grep -q "^$package"
            ;;
        pacman)
            pacman -Qu "$package" >/dev/null 2>&1
            ;;
        zypper)
            zypper list-updates | grep -q "$package"
            ;;
        emerge)
            emerge -pu "$package" | grep -q '^\[ebuild'
            ;;
        scoop)
            scoop status | grep -q "$package.*outdated"
            ;;
        choco)
            choco outdated | grep -q "^$package "
            ;;
        *)
            false
            ;;
    esac
}

# Install package using system package manager
install_system_package() {
    local package="$1"
    local package_manager_info=$(detect_system)
    local package_manager=$(echo "$package_manager_info" | cut -d: -f1)
    local install_cmd=$(echo "$package_manager_info" | cut -d: -f2)
    
    if [ -z "$package_manager" ]; then
        log_error "No package manager found for system packages"
        return 1
    fi
    
    log_info "Installing $package using $package_manager..."
    
    if eval "$install_cmd $package"; then
        log_success "$package installed successfully"
        return 0
    else
        log_error "Failed to install $package using $package_manager"
        return 1
    fi
}

# Install package using custom method
install_custom_package() {
    local package="$1"
    local package_info="${PACKAGE_DB[$package]}"
    local url=$(echo "$package_info" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('url', ''))" 2>/dev/null)
    
    log_info "Installing $package using custom method..."
    log_info "Download URL: $url"
    
    # Create download directory for this package
    local package_download_dir="$DOWNLOAD_DIR/$package"
    mkdir -p "$package_download_dir"
    
    # Download package (this is a placeholder - actual download logic would vary by package)
    log_warning "Custom package installation not implemented for $package"
    log_info "Please install $package manually from: $url"
    
    return 1
}

# Update package
update_package() {
    local package="$1"
    local package_manager_info=$(detect_system)
    local package_manager=$(echo "$package_manager_info" | cut -d: -f1)
    local upgrade_cmd=$(echo "$package_manager_info" | cut -d: -f4)
    
    if [ -z "$package_manager" ]; then
        log_error "No package manager found"
        return 1
    fi
    
    log_info "Updating $package using $package_manager..."
    
    case "$package_manager" in
        brew)
            brew upgrade "$package"
            ;;
        apt|apt-get)
            sudo apt upgrade -y "$package"
            ;;
        dnf|yum)
            sudo dnf upgrade -y "$package"
            ;;
        pacman)
            sudo pacman -Su --noconfirm "$package"
            ;;
        zypper)
            sudo zypper update -y "$package"
            ;;
        emerge)
            sudo emerge -u "$package"
            ;;
        scoop)
            scoop update "$package"
            ;;
        choco)
            choco upgrade -y "$package"
            ;;
        *)
            log_error "Update not supported for $package_manager"
            return 1
            ;;
    esac
}

# Smart install package
smart_install() {
    local package="$1"
    
    # Check if package exists in database
    if [ -z "${PACKAGE_DB[$package]}" ]; then
        log_error "Package '$package' not found in database"
        return 1
    fi
    
    log_info "Smart installing $package..."
    
    # Check if already installed
    if is_package_installed "$package"; then
        local version=$(get_package_version "$package")
        log_success "$package is already installed (version: $version)"
        
        # Check for updates
        if check_package_updates "$package"; then
            log_warning "Update available for $package"
            read -p "Do you want to update $package? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if update_package "$package"; then
                    log_success "$package updated successfully"
                else
                    log_error "Failed to update $package"
                fi
            fi
        else
            log_success "$package is up to date"
        fi
    else
        # Install package
        local package_info="${PACKAGE_DB[$package]}"
        local install_type=$(echo "$package_info" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('type', 'system'))" 2>/dev/null)
        
        if [ "$install_type" = "system" ]; then
            if install_system_package "$package"; then
                log_success "$package installed successfully"
            else
                log_error "Failed to install $package"
                return 1
            fi
        else
            if install_custom_package "$package"; then
                log_success "$package installed successfully"
            else
                log_error "Failed to install $package"
                return 1
            fi
        fi
    fi
}

# Batch install multiple packages
batch_install() {
    local packages=("$@")
    local success_count=0
    local fail_count=0
    
    log_info "Batch installing ${#packages[@]} packages..."
    
    for package in "${packages[@]}"; do
        if smart_install "$package"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
        echo ""
    done
    
    log_info "Batch installation completed:"
    log_info "  Success: $success_count"
    log_info "  Failed: $fail_count"
    log_info "  Total: ${#packages[@]}"
}

# Show package status
show_package_status() {
    local package="$1"
    
    if [ -z "${PACKAGE_DB[$package]}" ]; then
        log_error "Package '$package' not found in database"
        return 1
    fi
    
    echo "Package: $package"
    echo "========"
    
    local package_info="${PACKAGE_DB[$package]}"
    local url=$(echo "$package_info" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('url', ''))" 2>/dev/null)
    local install_type=$(echo "$package_info" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('type', 'system'))" 2>/dev/null)
    
    echo "URL: $url"
    echo "Type: $install_type"
    
    if is_package_installed "$package"; then
        local version=$(get_package_version "$package")
        echo -e "Status: ${GREEN}Installed${NC}"
        echo "Version: $version"
        
        if check_package_updates "$package"; then
            echo -e "Updates: ${YELLOW}Available${NC}"
        else
            echo -e "Updates: ${GREEN}Up to date${NC}"
        fi
    else
        echo -e "Status: ${RED}Not installed${NC}"
    fi
}

# List all available packages
list_packages() {
    echo "Available packages:"
    echo "==================="
    
    for package in "${!PACKAGE_DB[@]}"; do
        local package_info="${PACKAGE_DB[$package]}"
        local install_type=$(echo "$package_info" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('type', 'system'))" 2>/dev/null)
        
        if is_package_installed "$package"; then
            local version=$(get_package_version "$package")
            echo -e "${GREEN}✓${NC} $package (${version}) - $install_type"
        else
            echo -e "${RED}✗${NC} $package - $install_type"
        fi
    done
}

# Show help
show_help() {
    echo "Smart Package Installer - Intelligent software installation with caching"
    echo ""
    echo "Usage: $0 [command] [package...]"
    echo ""
    echo "Commands:"
    echo "  install <package>     Install a package (smart install with update check)"
    echo "  batch <package...>    Install multiple packages"
    echo "  update <package>      Update a specific package"
    echo "  status <package>      Show package status"
    echo "  list                  List all available packages"
    echo "  clean-cache           Clean download cache"
    echo "  help                  Show this help"
    echo ""
    echo "Features:"
    echo "  • Smart installation - checks if package is already installed"
    echo "  • Update detection - checks for available updates"
    echo "  • Multiple installation methods - system package manager and custom"
    echo "  • Caching - avoids redundant downloads"
    echo "  • Batch installation - install multiple packages at once"
    echo ""
    echo "Examples:"
    echo "  $0 install git"
    echo "  $0 install node python go"
    echo "  $0 batch git node python tmux zsh"
    echo "  $0 status git"
    echo "  $0 list"
}

# Clean cache
clean_cache() {
    log_info "Cleaning cache..."
    
    # Keep only recent downloads (last 7 days)
    find "$DOWNLOAD_DIR" -type f -mtime +7 -delete 2>/dev/null || true
    find "$BACKUP_DIR" -type f -mtime +30 -delete 2>/dev/null || true
    
    # Clean empty directories
    find "$DOWNLOAD_DIR" -type d -empty -delete 2>/dev/null || true
    find "$BACKUP_DIR" -type d -empty -delete 2>/dev/null || true
    
    log_success "Cache cleaned"
}

# Main function
main() {
    local command="${1:-help}"
    shift
    
    case "$command" in
        install)
            if [ $# -eq 0 ]; then
                log_error "Please specify at least one package to install"
                exit 1
            fi
            for package in "$@"; do
                smart_install "$package"
            done
            ;;
        batch)
            if [ $# -eq 0 ]; then
                log_error "Please specify packages to install"
                exit 1
            fi
            batch_install "$@"
            ;;
        update)
            if [ $# -eq 0 ]; then
                log_error "Please specify a package to update"
                exit 1
            fi
            for package in "$@"; do
                update_package "$package"
            done
            ;;
        status)
            if [ $# -eq 0 ]; then
                log_error "Please specify a package to check"
                exit 1
            fi
            show_package_status "$1"
            ;;
        list)
            list_packages
            ;;
        clean-cache)
            clean_cache
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"