#!/bin/bash
# Package State Manager - Track and manage software package installations and updates

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
STATE_DIR="$HOME/.local/state/package-manager"
CONFIG_DIR="$HOME/.config/package-manager"
CACHE_DIR="$HOME/.cache/package-manager"
STATE_FILE="$STATE_DIR/packages.json"
CONFIG_FILE="$CONFIG_DIR/config.json"
HISTORY_FILE="$STATE_DIR/history.log"

# Create necessary directories
mkdir -p "$STATE_DIR" "$CONFIG_DIR" "$CACHE_DIR"

# Initialize files
touch "$HISTORY_FILE"

# Default configuration
DEFAULT_CONFIG='{
    "auto_update": false,
    "update_check_interval": 86400,
    "cache_expiry": 604800,
    "log_level": "info",
    "backup_enabled": true,
    "backup_count": 5,
    "notification_enabled": true,
    "update_sources": [
        "brew",
        "apt",
        "dnf",
        "pacman",
        "scoop",
        "choco"
    ]
}'

# Initialize config file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "$DEFAULT_CONFIG" > "$CONFIG_FILE"
fi

# Initialize state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo '{"packages": {}, "last_update": null, "system_info": {}}' > "$STATE_FILE"
fi

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$HISTORY_FILE"
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

# JSON helper functions
json_get() {
    local file="$1"
    local key="$2"
    python3 -c "
import json
with open('$file', 'r') as f:
    data = json.load(f)
result = data
for k in '$key'.split('.'):
    if isinstance(result, dict) and k in result:
        result = result[k]
    else:
        print(None)
        exit()
print(result)
" 2>/dev/null
}

json_set() {
    local file="$1"
    local key="$2"
    local value="$3"
    
    python3 -c "
import json
import sys

with open('$file', 'r') as f:
    data = json.load(f)

current = data
keys = '$key'.split('.')
for k in keys[:-1]:
    if k not in current:
        current[k] = {}
    current = current[k]

current[keys[-1]] = $value

with open('$file', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null
}

json_update() {
    local file="$1"
    local key="$2"
    local value="$3"
    
    python3 -c "
import json
import sys

with open('$file', 'r') as f:
    data = json.load(f)

current = data
keys = '$key'.split('.')
for k in keys[:-1]:
    if k not in current:
        current[k] = {}
    current = current[k]

current[keys[-1]] = '$value'

with open('$file', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null
}

# Get package information
get_package_info() {
    local package="$1"
    
    # Try different package managers to get package info
    if command -v brew >/dev/null 2>&1; then
        brew info "$package" 2>/dev/null | head -10
    elif command -v apt >/dev/null 2>&1; then
        apt show "$package" 2>/dev/null | head -10
    elif command -v dnf >/dev/null 2>&1; then
        dnf info "$package" 2>/dev/null | head -10
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Si "$package" 2>/dev/null | head -10
    elif command -v scoop >/dev/null 2>&1; then
        scoop info "$package" 2>/dev/null | head -10
    elif command -v choco >/dev/null 2>&1; then
        choco info "$package" 2>/dev/null | head -10
    else
        echo "Package info not available"
    fi
}

# Check if package is installed
is_package_installed() {
    local package="$1"
    
    # Check different package managers
    if command -v brew >/dev/null 2>&1; then
        brew list --formula | grep -q "^${package}$"
    elif command -v apt >/dev/null 2>&1; then
        dpkg -l | grep -q "^ii  $package"
    elif command -v dnf >/dev/null 2>&1; then
        rpm -q "$package" >/dev/null 2>&1
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Q "$package" >/dev/null 2>&1
    elif command -v scoop >/dev/null 2>&1; then
        scoop list | grep -q "^ $package "
    elif command -v choco >/dev/null 2>&1; then
        choco list --local-only | grep -q "^$package "
    else
        # Fallback: check if command exists
        command -v "$package" >/dev/null 2>&1
    fi
}

# Get package version
get_package_version() {
    local package="$1"
    
    if command -v brew >/dev/null 2>&1; then
        brew list --formula --versions "$package" | awk '{print $2}'
    elif command -v apt >/dev/null 2>&1; then
        apt-cache policy "$package" | grep 'Installed:' | awk '{print $2}'
    elif command -v dnf >/dev/null 2>&1; then
        rpm -q --queryformat '%{VERSION}-%{RELEASE}' "$package" 2>/dev/null
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Q "$package" | awk '{print $2}'
    elif command -v scoop >/dev/null 2>&1; then
        scoop list | grep "^ $package " | awk '{print $2}'
    elif command -v choco >/dev/null 2>&1; then
        choco list --local-only | grep "^$package " | awk '{print $2}'
    else
        # Fallback: use command version
        if command -v "$package" >/dev/null 2>&1; then
            "$package" --version 2>/dev/null | head -1 || echo "unknown"
        else
            echo "not-installed"
        fi
    fi
}

# Check for package updates
check_package_updates() {
    local package="$1"
    
    if command -v brew >/dev/null 2>&1; then
        brew outdated | grep -q "^$package "
    elif command -v apt >/dev/null 2>&1; then
        apt list --upgradable 2>/dev/null | grep -q "^$package/"
    elif command -v dnf >/dev/null 2>&1; then
        dnf check-update "$package" 2>/dev/null | grep -q "^$package"
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Qu "$package" >/dev/null 2>&1
    elif command -v scoop >/dev/null 2>&1; then
        scoop status | grep -q "$package.*outdated"
    elif command -v choco >/dev/null 2>&1; then
        choco outdated | grep -q "^$package "
    else
        false
    fi
}

# Record package state
record_package_state() {
    local package="$1"
    local action="$2"
    local version="$3"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Update state file
    python3 -c "
import json
import sys

with open('$STATE_FILE', 'r') as f:
    data = json.load(f)

if 'packages' not in data:
    data['packages'] = {}

data['packages']['$package'] = {
    'name': '$package',
    'version': '$version',
    'status': '$action',
    'last_updated': '$timestamp',
    'update_available': False
}

data['last_update'] = '$timestamp'

with open('$STATE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null
    
    log_info "Recorded package state: $package -> $action ($version)"
}

# Get package state from records
get_package_state() {
    local package="$1"
    
    python3 -c "
import json

try:
    with open('$STATE_FILE', 'r') as f:
        data = json.load(f)
    
    if 'packages' in data and '$package' in data['packages']:
        pkg_data = data['packages']['$package']
        print(f\"{pkg_data['status']}:{pkg_data['version']}:{pkg_data['last_updated']}\")
    else:
        print('unknown:not-installed:never')
except:
    print('unknown:not-installed:never')
" 2>/dev/null
}

# Show package status
show_package_status() {
    local package="$1"
    
    echo "Package: $package"
    echo "========"
    
    # Show installed status
    if is_package_installed "$package"; then
        local version=$(get_package_version "$package")
        echo -e "Status: ${GREEN}Installed${NC}"
        echo "Version: $version"
        
        # Check for updates
        if check_package_updates "$package"; then
            echo -e "Updates: ${YELLOW}Available${NC}"
        else
            echo -e "Updates: ${GREEN}Up to date${NC}"
        fi
        
        # Show recorded state
        local recorded_state=$(get_package_state "$package")
        local status=$(echo "$recorded_state" | cut -d: -f1)
        local recorded_version=$(echo "$recorded_state" | cut -d: -f2)
        local last_updated=$(echo "$recorded_state" | cut -d: -f3)
        
        echo "Recorded: $status ($recorded_version)"
        echo "Last updated: $last_updated"
    else
        echo -e "Status: ${RED}Not installed${NC}"
    fi
    
    echo ""
    
    # Show package info
    echo "Package Info:"
    echo "============="
    get_package_info "$package" | head -5
}

# Show all packages status
show_all_packages_status() {
    echo "All Packages Status:"
    echo "==================="
    
    # Get all installed packages from different package managers
    local packages=()
    
    if command -v brew >/dev/null 2>&1; then
        packages+=($(brew list --formula))
    elif command -v apt >/dev/null 2>&1; then
        packages+=($(dpkg -l | grep '^ii' | awk '{print $2}'))
    elif command -v dnf >/dev/null 2>&1; then
        packages+=($(rpm -qa | cut -d'-' -f1))
    elif command -v pacman >/dev/null 2>&1; then
        packages+=($(pacman -Q | cut -d' ' -f1))
    elif command -v scoop >/dev/null 2>&1; then
        packages+=($(scoop list | awk 'NR>1 {print $1}'))
    elif command -v choco >/dev/null 2>&1; then
        packages+=($(choco list --local-only | awk '{print $1}'))
    fi
    
    # Remove duplicates and sort
    IFS=$'\n' sorted_packages=($(sort -u <<<"${packages[*]}"))
    unset IFS
    
    local total_count=${#sorted_packages[@]}
    local update_count=0
    
    for package in "${sorted_packages[@]}"; do
        if is_package_installed "$package"; then
            local version=$(get_package_version "$package")
            
            if check_package_updates "$package"; then
                echo -e "${YELLOW}⚠${NC} $package (${version}) - ${YELLOW}Update available${NC}"
                ((update_count++))
            else
                echo -e "${GREEN}✓${NC} $package (${version}) - ${GREEN}Up to date${NC}"
            fi
        fi
    done
    
    echo ""
    echo "Summary:"
    echo "========"
    echo -e "Total packages: ${BLUE}$total_count${NC}"
    echo -e "Updates available: ${YELLOW}$update_count${NC}"
    echo -e "Up to date: ${GREEN}$((total_count - update_count))${NC}"
}

# Show system information
show_system_info() {
    echo "System Information:"
    echo "=================="
    
    # OS information
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    
    # Package manager information
    echo ""
    echo "Package Managers:"
    echo "================="
    
    if command -v brew >/dev/null 2>&1; then
        echo -e "Homebrew: ${GREEN}Installed${NC} ($(brew --version | head -1 | cut -d' ' -f2))"
    else
        echo -e "Homebrew: ${RED}Not installed${NC}"
    fi
    
    if command -v apt >/dev/null 2>&1; then
        echo -e "APT: ${GREEN}Installed${NC}"
    else
        echo -e "APT: ${RED}Not installed${NC}"
    fi
    
    if command -v dnf >/dev/null 2>&1; then
        echo -e "DNF: ${GREEN}Installed${NC}"
    else
        echo -e "DNF: ${RED}Not installed${NC}"
    fi
    
    if command -v pacman >/dev/null 2>&1; then
        echo -e "Pacman: ${GREEN}Installed${NC}"
    else
        echo -e "Pacman: ${RED}Not installed${NC}"
    fi
    
    if command -v scoop >/dev/null 2>&1; then
        echo -e "Scoop: ${GREEN}Installed${NC}"
    else
        echo -e "Scoop: ${RED}Not installed${NC}"
    fi
    
    if command -v choco >/dev/null 2>&1; then
        echo -e "Chocolatey: ${GREEN}Installed${NC}"
    else
        echo -e "Chocolatey: ${RED}Not installed${NC}"
    fi
}

# Check for updates
check_updates() {
    echo "Checking for package updates..."
    echo "============================="
    
    local update_count=0
    
    # Check different package managers
    if command -v brew >/dev/null 2>&1; then
        echo ""
        echo "Homebrew updates:"
        brew outdated | while read -r package version; do
            echo -e "  ${YELLOW}$package${NC} -> $version"
            ((update_count++))
        done
    fi
    
    if command -v apt >/dev/null 2>&1; then
        echo ""
        echo "APT updates:"
        apt list --upgradable 2>/dev/null | grep -v "Listing..." | while read -r line; do
            local package=$(echo "$line" | cut -d'/' -f1)
            local versions=$(echo "$line" | cut -d' ' -f2-)
            echo -e "  ${YELLOW}$package${NC} $versions"
            ((update_count++))
        done
    fi
    
    if command -v dnf >/dev/null 2>&1; then
        echo ""
        echo "DNF updates:"
        dnf check-update | grep -v "^$" | grep -v "^Last metadata" | while read -r package rest; do
            if [[ "$package" != *"Obsoleting"* ]] && [[ "$package" != *"Security:"* ]]; then
                echo -e "  ${YELLOW}$package${NC} $rest"
                ((update_count++))
            fi
        done
    fi
    
    if command -v pacman >/dev/null 2>&1; then
        echo ""
        echo "Pacman updates:"
        pacman -Qu | while read -r package version; do
            echo -e "  ${YELLOW}$package${NC} -> $version"
            ((update_count++))
        done
    fi
    
    if command -v scoop >/dev/null 2>&1; then
        echo ""
        echo "Scoop updates:"
        scoop status | grep "outdated" | while read -r line; do
            local package=$(echo "$line" | awk '{print $1}')
            echo -e "  ${YELLOW}$package${NC}"
            ((update_count++))
        done
    fi
    
    if command -v choco >/dev/null 2>&1; then
        echo ""
        echo "Chocolatey updates:"
        choco outdated | grep -v "Chocolatey" | grep -v "packages" | while read -r package version available; do
            echo -e "  ${YELLOW}$package${NC} $version -> $available"
            ((update_count++))
        done
    fi
    
    echo ""
    echo "Update Summary:"
    echo "==============="
    echo -e "Total updates available: ${YELLOW}$update_count${NC}"
    
    # Update state file
    json_update "$STATE_FILE" "last_update" "$(date '+%Y-%m-%d %H:%M:%S')"
}

# Show history
show_history() {
    echo "Package Management History:"
    echo "=========================="
    
    if [ -f "$HISTORY_FILE" ]; then
        tail -20 "$HISTORY_FILE" | while read -r line; do
            local level=$(echo "$line" | awk '{print $3}' | tr -d '[]')
            local message=$(echo "$line" | cut -d' ' -f4-)
            
            case "$level" in
                INFO)
                    echo -e "${BLUE}$message${NC}"
                    ;;
                SUCCESS)
                    echo -e "${GREEN}$message${NC}"
                    ;;
                WARNING)
                    echo -e "${YELLOW}$message${NC}"
                    ;;
                ERROR)
                    echo -e "${RED}$message${NC}"
                    ;;
            esac
        done
    else
        echo "No history available"
    fi
}

# Show help
show_help() {
    echo "Package State Manager - Track and manage software package installations"
    echo ""
    echo "Usage: $0 [command] [package]"
    echo ""
    echo "Commands:"
    echo "  status <package>     Show package status"
    echo "  status-all           Show all packages status"
    echo "  system-info          Show system information"
    echo "  check-updates        Check for package updates"
    echo "  history              Show package management history"
    echo "  record <package>     Record package installation"
    echo "  help                 Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 status git"
    echo "  $0 status-all"
    echo "  $0 check-updates"
    echo "  $0 system-info"
}

# Main function
main() {
    local command="${1:-help}"
    local package="$2"
    
    case "$command" in
        status)
            if [ -z "$package" ]; then
                log_error "Please specify a package"
                exit 1
            fi
            show_package_status "$package"
            ;;
        status-all)
            show_all_packages_status
            ;;
        system-info)
            show_system_info
            ;;
        check-updates)
            check_updates
            ;;
        history)
            show_history
            ;;
        record)
            if [ -z "$package" ]; then
                log_error "Please specify a package"
                exit 1
            fi
            if is_package_installed "$package"; then
                record_package_state "$package" "installed" "$(get_package_version "$package")"
            else
                log_error "Package $package is not installed"
                exit 1
            fi
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