#!/bin/bash
# Test script to verify development tools configuration
# Checks if pyenv, NVM, and other development tools are properly configured

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
log_header() { echo -e "${CYAN}[TEST]${NC} $1"; }

echo "========================================"
echo "    Development Tools Configuration     "
echo "         Verification Test              "
echo "========================================"
echo

# Test Pyenv configuration
test_pyenv() {
    log_header "Testing Pyenv Configuration"
    
    # Check PYENV_ROOT
    if [[ -n "$PYENV_ROOT" ]]; then
        log_success "PYENV_ROOT is set: $PYENV_ROOT"
    else
        log_warning "PYENV_ROOT not set"
    fi
    
    # Check if pyenv is in PATH
    if command -v pyenv >/dev/null 2>&1; then
        log_success "pyenv found in PATH: $(which pyenv)"
        log_info "pyenv version: $(pyenv --version)"
        
        # Test pyenv init
        if pyenv init --path >/dev/null 2>&1; then
            log_success "pyenv init --path works"
        else
            log_warning "pyenv init --path failed"
        fi
        
        # Check if pyenv shims are in PATH
        if [[ ":$PATH:" == *":$HOME/.pyenv/shims:"* ]]; then
            log_success "pyenv shims are in PATH"
        else
            log_info "pyenv shims not in PATH (may be normal if no Python versions installed)"
        fi
        
    else
        log_warning "pyenv not found in PATH"
    fi
    
    echo
}

# Test NVM configuration
test_nvm() {
    log_header "Testing NVM Configuration"
    
    # Check NVM_DIR
    if [[ -n "$NVM_DIR" ]]; then
        log_success "NVM_DIR is set: $NVM_DIR"
    else
        log_warning "NVM_DIR not set"
    fi
    
    # Check if NVM directory exists
    if [[ -d "$HOME/.nvm" ]]; then
        log_success "NVM directory exists: $HOME/.nvm"
        
        # Check if nvm.sh exists
        if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
            log_success "nvm.sh script exists"
            
            # Source NVM for testing
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            
            # Test NVM command
            if command -v nvm >/dev/null 2>&1; then
                log_success "nvm command available: $(nvm --version)"
            else
                log_warning "nvm command not available after sourcing"
            fi
        else
            log_warning "nvm.sh script not found"
        fi
        
        # Check bash completion
        if [[ -s "$HOME/.nvm/bash_completion" ]]; then
            log_success "NVM bash completion available"
        else
            log_info "NVM bash completion not found"
        fi
        
    else
        log_warning "NVM directory not found at $HOME/.nvm"
    fi
    
    echo
}

# Test other development tools
test_other_tools() {
    log_header "Testing Other Development Tools"
    
    # Detect OS
    local os="unknown"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os="macos"
    fi
    
    log_info "Detected OS: $os"
    
    # Test Homebrew
    if command -v brew >/dev/null 2>&1; then
        log_success "Homebrew available: $(brew --version | head -1)"
    else
        if [[ "$os" == "linux" ]]; then
            log_info "Homebrew not found (optional on Linux)"
        else
            log_warning "Homebrew not found (recommended on macOS)"
        fi
    fi
    
    # Test Go
    if command -v go >/dev/null 2>&1; then
        log_success "Go available: $(go version)"
        if [[ -n "$GOPATH" ]]; then
            log_info "GOPATH set: $GOPATH"
        fi
    else
        log_info "Go not installed"
    fi
    
    # Test Rust
    if command -v rustc >/dev/null 2>&1; then
        log_success "Rust available: $(rustc --version)"
    else
        log_info "Rust not installed"
    fi
    
    # Test Java
    if command -v java >/dev/null 2>&1; then
        log_success "Java available: $(java -version 2>&1 | head -1)"
    else
        log_info "Java not installed"
    fi
    
    # Test uv (Python package manager)
    if command -v uv >/dev/null 2>&1; then
        log_success "uv available: $(uv --version)"
    else
        log_info "uv not installed"
    fi
    
    echo
}

# Test shell configuration files
test_shell_config() {
    log_header "Testing Shell Configuration Files"
    
    # Check .zshenv
    if [[ -L ~/.zshenv ]]; then
        log_success ".zshenv is a symlink: $(readlink ~/.zshenv)"
    elif [[ -f ~/.zshenv ]]; then
        log_info ".zshenv exists as regular file"
    else
        log_warning ".zshenv not found"
    fi
    
    # Check .zshrc
    if [[ -L ~/.zshrc ]]; then
        log_success ".zshrc is a symlink: $(readlink ~/.zshrc)"
    elif [[ -f ~/.zshrc ]]; then
        log_info ".zshrc exists as regular file"
    else
        log_warning ".zshrc not found"
    fi
    
    # Check .zprofile
    if [[ -L ~/.zprofile ]]; then
        log_success ".zprofile is a symlink: $(readlink ~/.zprofile)"
    elif [[ -f ~/.zprofile ]]; then
        log_info ".zprofile exists as regular file"
    else
        log_warning ".zprofile not found"
    fi
    
    echo
}

# Test PATH configuration
test_path() {
    log_header "Testing PATH Configuration"
    
    echo "Current PATH entries:"
    echo "$PATH" | tr ':' '\n' | nl
    
    echo
    log_info "Homebrew paths in PATH:"
    echo "$PATH" | tr ':' '\n' | grep -E "(homebrew|/opt/)" | nl || log_info "No Homebrew paths found"
    
    echo
    log_info "Development tool paths in PATH:"
    echo "$PATH" | tr ':' '\n' | grep -E "(pyenv|cargo|go|local)" | nl || log_info "No development tool paths found"
    
    echo
}

# Main test function
main() {
    test_pyenv
    test_nvm
    test_other_tools
    test_shell_config
    test_path
    
    log_header "Test Summary"
    log_success "Development tools configuration test completed!"
    log_info "Check the output above for any warnings or issues"
    echo
    log_info "To install development tools, run:"
    log_info "  ./scripts/setup-dev-environment.sh --all"
    echo
}

# Run tests
main "$@"
