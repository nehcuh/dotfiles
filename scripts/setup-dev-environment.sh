#!/bin/bash
# Development Environment Setup Script
# Supports: Rust, Python, Go, Java, JavaScript/TypeScript, C/C++

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
log_header() { echo -e "${CYAN}[SETUP]${NC} $1"; }

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
fi

echo "========================================"
echo "    Development Environment Setup      "
echo "========================================"
echo
log_info "Operating system: $OS"
echo

# Check if running in installation context
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Running standalone
    INTERACTIVE=true
else
    # Being sourced
    INTERACTIVE=false
fi

# Install Rust
install_rust() {
    log_header "Setting up Rust development environment"
    
    if command -v rustc &> /dev/null; then
        log_info "Rust is already installed: $(rustc --version)"
        return 0
    fi
    
    log_info "Installing Rust via rustup..."
    if [[ "$INTERACTIVE" == "true" ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
    
    # Source Rust environment
    source ~/.cargo/env 2>/dev/null || true
    
    if command -v rustc &> /dev/null; then
        log_success "Rust installed successfully: $(rustc --version)"
        
        # Install common Rust tools
        log_info "Installing common Rust tools..."
        rustup component add rustfmt clippy
        cargo install cargo-edit cargo-watch cargo-tree
        
        log_success "Rust tools installed"
    else
        log_error "Failed to install Rust"
        return 1
    fi
}

# Install Python with pyenv and uv
install_python() {
    log_header "Setting up Python development environment"
    
    # Install pyenv
    if ! command -v pyenv &> /dev/null; then
        log_info "Installing pyenv..."
        
        if [[ "$OS" == "macos" ]]; then
            if command -v brew &> /dev/null; then
                brew install pyenv
            else
                curl https://pyenv.run | bash
            fi
        else
            curl https://pyenv.run | bash
        fi
        
        # Add pyenv to shell profile
        if [[ -f ~/.zshrc ]] && ! grep -q 'pyenv init' ~/.zshrc; then
            echo '' >> ~/.zshrc
            echo '# Pyenv configuration' >> ~/.zshrc
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
            echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
            echo 'eval "$(pyenv init -)"' >> ~/.zshrc
        fi
        
        # Source for current session
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)" 2>/dev/null || true
    else
        log_info "pyenv is already installed: $(pyenv --version)"
    fi
    
    # Install latest Python
    if command -v pyenv &> /dev/null; then
        log_info "Installing latest Python version..."
        PYTHON_VERSION=$(pyenv install --list | grep -E "^\s*3\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ')
        pyenv install -s "$PYTHON_VERSION"
        pyenv global "$PYTHON_VERSION"
        log_success "Python $PYTHON_VERSION installed and set as global"
    fi
    
    # Install uv
    if ! command -v uv &> /dev/null; then
        log_info "Installing uv (fast Python package manager)..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        
        # Add uv to current session
        export PATH="$HOME/.local/bin:$PATH"
        
        if command -v uv &> /dev/null; then
            log_success "uv installed successfully: $(uv --version)"
            
            # Install common Python tools with uv
            log_info "Installing common Python tools..."
            uv tool install black
            uv tool install flake8
            uv tool install mypy
            uv tool install pytest
            uv tool install ipython
            
            log_success "Python development tools installed"
        else
            log_error "Failed to install uv"
        fi
    else
        log_info "uv is already installed: $(uv --version)"
    fi
}

# Install Go
install_go() {
    log_header "Setting up Go development environment"
    
    if command -v go &> /dev/null; then
        log_info "Go is already installed: $(go version)"
        return 0
    fi
    
    log_info "Installing Go..."
    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install go
        else
            log_error "Homebrew not found, please install Go manually"
            return 1
        fi
    else
        # Linux installation
        GO_VERSION=$(curl -s https://api.github.com/repos/golang/go/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
        GO_VERSION=${GO_VERSION#go}
        
        cd /tmp
        wget "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
        
        # Add Go to PATH
        if [[ -f ~/.zshrc ]] && ! grep -q '/usr/local/go/bin' ~/.zshrc; then
            echo '' >> ~/.zshrc
            echo '# Go configuration' >> ~/.zshrc
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
            echo 'export GOPATH=$HOME/go' >> ~/.zshrc
            echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.zshrc
        fi
        
        export PATH=$PATH:/usr/local/go/bin
        export GOPATH=$HOME/go
        export PATH=$PATH:$GOPATH/bin
    fi
    
    if command -v go &> /dev/null; then
        log_success "Go installed successfully: $(go version)"
        
        # Install common Go tools
        log_info "Installing common Go tools..."
        go install golang.org/x/tools/gopls@latest
        go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
        go install github.com/air-verse/air@latest
        
        log_success "Go development tools installed"
    else
        log_error "Failed to install Go"
        return 1
    fi
}

# Install Java
install_java() {
    log_header "Setting up Java development environment"
    
    if command -v java &> /dev/null; then
        log_info "Java is already installed: $(java -version 2>&1 | head -1)"
        return 0
    fi
    
    log_info "Installing Java (OpenJDK)..."
    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install openjdk
            # Create symlink for system Java
            sudo ln -sfn $(brew --prefix)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk 2>/dev/null || true
        else
            log_error "Homebrew not found, please install Java manually"
            return 1
        fi
    else
        # Linux installation
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y openjdk-17-jdk maven gradle
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y java-17-openjdk-devel maven gradle
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm jdk17-openjdk maven gradle
        fi
    fi
    
    if command -v java &> /dev/null; then
        log_success "Java installed successfully"
        
        # Install Maven and Gradle on macOS
        if [[ "$OS" == "macos" ]] && command -v brew &> /dev/null; then
            log_info "Installing Maven and Gradle..."
            brew install maven gradle
            log_success "Java build tools installed"
        fi
    else
        log_error "Failed to install Java"
        return 1
    fi
}

# Install Node.js with NVM
install_nodejs() {
    log_header "Setting up Node.js development environment"
    
    # Install NVM
    if [[ ! -d ~/.nvm ]]; then
        log_info "Installing NVM (Node Version Manager)..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        
        # Source NVM
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    else
        log_info "NVM is already installed"
        # Source NVM for current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    # Install latest LTS Node.js
    if command -v nvm &> /dev/null; then
        log_info "Installing latest LTS Node.js..."
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
        
        if command -v node &> /dev/null; then
            log_success "Node.js installed successfully: $(node --version)"
            log_success "npm version: $(npm --version)"
            
            # Install common global packages
            log_info "Installing common Node.js tools..."
            npm install -g typescript tsx ts-node
            npm install -g @types/node
            npm install -g eslint prettier
            npm install -g yarn pnpm
            
            log_success "Node.js development tools installed"
        fi
    else
        log_error "Failed to install NVM/Node.js"
        return 1
    fi
}

# Install C/C++ development tools
install_cpp() {
    log_header "Setting up C/C++ development environment"
    
    if [[ "$OS" == "macos" ]]; then
        # Check for Xcode Command Line Tools
        if xcode-select -p &> /dev/null; then
            log_info "Xcode Command Line Tools already installed"
        else
            log_info "Installing Xcode Command Line Tools..."
            xcode-select --install
            log_warning "Please complete the Xcode Command Line Tools installation"
        fi
        
        # Install additional tools with Homebrew
        if command -v brew &> /dev/null; then
            log_info "Installing additional C/C++ tools..."
            brew install cmake ninja llvm
            log_success "C/C++ development tools installed"
        fi
    else
        # Linux installation
        log_info "Installing C/C++ development tools..."
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y build-essential cmake ninja-build clang llvm gdb valgrind
        elif command -v dnf &> /dev/null; then
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y cmake ninja-build clang llvm gdb valgrind
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm base-devel cmake ninja clang llvm gdb valgrind
        fi
        log_success "C/C++ development tools installed"
    fi
}

# Show help
show_help() {
    echo "Development Environment Setup"
    echo "Usage: $0 [options] [languages...]"
    echo ""
    echo "Options:"
    echo "  --help, -h        Show this help message"
    echo "  --all             Install all development environments"
    echo ""
    echo "Available languages:"
    echo "  rust              Rust with rustup and common tools"
    echo "  python            Python with pyenv and uv"
    echo "  go, golang        Go with common tools"
    echo "  java              Java (OpenJDK) with Maven and Gradle"
    echo "  node, nodejs      Node.js with NVM and common tools"
    echo "  cpp, c++          C/C++ with build tools"
    echo ""
    echo "Examples:"
    echo "  $0 --all          # Install all development environments"
    echo "  $0 rust python    # Install only Rust and Python"
    echo "  $0 node java      # Install only Node.js and Java"
}

# Main installation function
main() {
    local install_all=false
    local languages=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --all)
                install_all=true
                shift
                ;;
            rust|python|go|golang|java|node|nodejs|cpp|c++)
                languages+=("$1")
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # If no arguments, show help
    if [[ $install_all == false && ${#languages[@]} -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    # Install all if requested
    if [[ $install_all == true ]]; then
        languages=("rust" "python" "go" "java" "node" "cpp")
    fi
    
    # Install requested languages
    for lang in "${languages[@]}"; do
        case $lang in
            rust)
                install_rust
                ;;
            python)
                install_python
                ;;
            go|golang)
                install_go
                ;;
            java)
                install_java
                ;;
            node|nodejs)
                install_nodejs
                ;;
            cpp|c++)
                install_cpp
                ;;
        esac
        echo
    done
    
    log_success "Development environment setup completed!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
