#!/bin/bash
# Check and install prerequisites (git, stow, brew)

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check git
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed"
        if [[ "$OS" == "macos" ]]; then
            log_info "Installing Xcode Command Line Tools..."
            xcode-select --install
            log_info "Please complete the installation and run again"
            exit 1
        else
            log_error "Please install Git first"
            exit 1
        fi
    fi

    # Check/install stow
    if ! command -v stow &> /dev/null; then
        log_info "Installing GNU Stow..."
        case "$OS" in
            linux)
                if command -v apt &> /dev/null; then
                    sudo apt update && sudo apt install -y stow
                elif command -v pacman &> /dev/null; then
                    sudo pacman -S --noconfirm stow
                elif command -v dnf &> /dev/null; then
                    sudo dnf install -y stow
                else
                    log_error "Unable to install stow. Please install manually."
                    exit 1
                fi
                ;;
            macos)
                if ! command -v brew &> /dev/null; then
                    log_info "Installing Homebrew..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

                    # Add Homebrew to PATH
                    if [[ -f "/opt/homebrew/bin/brew" ]]; then
                        export PATH="/opt/homebrew/bin:$PATH"
                        eval "$(/opt/homebrew/bin/brew shellenv)"
                    elif [[ -f "/usr/local/bin/brew" ]]; then
                        export PATH="/usr/local/bin:$PATH"
                        eval "$(/usr/local/bin/brew shellenv)"
                    fi
                fi
                brew install stow
                ;;
        esac
    fi

    log_success "Prerequisites OK"
}
