#!/bin/sh
# Test script for dotfiles configuration
# This script tests the dotfiles configuration for common issues

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
  print_color "$CYAN" "╔══════════════════════════════════════════════════════════════╗"
  print_color "$CYAN" "║                    Dotfiles Configuration Test               ║"
  print_color "$CYAN" "╚══════════════════════════════════════════════════════════════╝"
  printf "\n"
  log_info "Platform: $PLATFORM ($DISTRO) on $ARCH"
  log_info "Shell: $CURRENT_SHELL ($SHELL_TYPE)"
  printf "\n"
}

# Test stow configuration
test_stow_config() {
  log_info "Testing stow configuration..."
  
  # Check if stow is installed
  if ! command_exists stow; then
    log_error "GNU Stow is not installed"
    return 1
  fi
  
  # Check if stow directory exists
  if [ ! -d "$STOW_DIR" ]; then
    log_error "Stow directory not found: $STOW_DIR"
    return 1
  fi
  
  # Check if there are any packages
  if [ -z "$(ls -A "$STOW_DIR" 2>/dev/null)" ]; then
    log_error "No packages found in $STOW_DIR"
    return 1
  fi
  
  log_success "Stow configuration is valid"
  return 0
}

# Test shell configuration
test_shell_config() {
  log_info "Testing shell configuration..."
  
  # Check if zsh is installed
  if ! command_exists zsh; then
    log_warning "Zsh is not installed"
  else
    log_success "Zsh is installed"
  fi
  
  # Check if zinit is installed
  if [ ! -d "$HOME/.zinit" ]; then
    log_warning "Zinit is not installed"
  else
    log_success "Zinit is installed"
  fi
  
  # Check if .zshrc exists
  if [ ! -f "$HOME/.zshrc" ]; then
    log_warning ".zshrc not found"
  else
    log_success ".zshrc exists"
  fi
  
  # Check if .zshrc is a symlink
  if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    log_warning ".zshrc is not a symlink"
  fi
  
  return 0
}

# Test git configuration
test_git_config() {
  log_info "Testing git configuration..."
  
  # Check if git is installed
  if ! command_exists git; then
    log_error "Git is not installed"
    return 1
  fi
  
  # Check if .gitconfig exists
  if [ ! -f "$HOME/.gitconfig" ]; then
    log_warning ".gitconfig not found"
  else
    log_success ".gitconfig exists"
  fi
  
  # Check if .gitconfig is a symlink
  if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
    log_warning ".gitconfig is not a symlink"
  fi
  
  # Check if .gitconfig_local exists
  if [ ! -f "$HOME/.gitconfig_local" ]; then
    log_warning ".gitconfig_local not found"
  else
    log_success ".gitconfig_local exists"
  fi
  
  # Check if user.name and user.email are set
  if command_exists git; then
    if ! git config --get user.name >/dev/null 2>&1; then
      log_warning "Git user.name is not set"
    else
      log_success "Git user.name is set: $(git config --get user.name)"
    fi
    
    if ! git config --get user.email >/dev/null 2>&1; then
      log_warning "Git user.email is not set"
    else
      log_success "Git user.email is set: $(git config --get user.email)"
    fi
  fi
  
  return 0
}

# Test tmux configuration
test_tmux_config() {
  log_info "Testing tmux configuration..."
  
  # Check if tmux is installed
  if ! command_exists tmux; then
    log_warning "Tmux is not installed"
    return 0
  fi
  
  # Check if .tmux.conf exists
  if [ ! -f "$HOME/.tmux.conf" ]; then
    log_warning ".tmux.conf not found"
  else
    log_success ".tmux.conf exists"
  fi
  
  # Check if .tmux.conf is a symlink
  if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
    log_warning ".tmux.conf is not a symlink"
  fi
  
  # Check if .tmux.conf.local exists
  if [ ! -f "$HOME/.tmux.conf.local" ]; then
    log_warning ".tmux.conf.local not found"
  else
    log_success ".tmux.conf.local exists"
  fi
  
  return 0
}

# Test neovim configuration
test_nvim_config() {
  log_info "Testing neovim configuration..."
  
  # Check if neovim is installed
  if ! command_exists nvim; then
    log_warning "Neovim is not installed"
    return 0
  fi
  
  # Check if .config/nvim exists
  if [ ! -d "$HOME/.config/nvim" ]; then
    log_warning ".config/nvim directory not found"
  else
    log_success ".config/nvim directory exists"
  fi
  
  # Check if init.lua or init.vim exists
  if [ ! -f "$HOME/.config/nvim/init.lua" ] && [ ! -f "$HOME/.config/nvim/init.vim" ]; then
    log_warning "Neovim init file not found"
  else
    if [ -f "$HOME/.config/nvim/init.lua" ]; then
      log_success "Neovim init.lua exists"
    fi
    if [ -f "$HOME/.config/nvim/init.vim" ]; then
      log_success "Neovim init.vim exists"
    fi
  fi
  
  return 0
}

# Test vim configuration
test_vim_config() {
  log_info "Testing vim configuration..."
  
  # Check if vim is installed
  if ! command_exists vim; then
    log_warning "Vim is not installed"
    return 0
  fi
  
  # Check if .vimrc exists
  if [ ! -f "$HOME/.vimrc" ]; then
    log_warning ".vimrc not found"
  else
    log_success ".vimrc exists"
  fi
  
  # Check if .vimrc is a symlink
  if [ -f "$HOME/.vimrc" ] && [ ! -L "$HOME/.vimrc" ]; then
    log_warning ".vimrc is not a symlink"
  fi
  
  return 0
}

# Test tools configuration
test_tools_config() {
  log_info "Testing tools configuration..."
  
  # Check if common tools are installed
  tools="fzf ripgrep bat eza zoxide starship"
  for tool in $tools; do
    if ! command_exists "$tool"; then
      log_warning "$tool is not installed"
    else
      log_success "$tool is installed"
    fi
  done
  
  return 0
}

# Test system configuration
test_system_config() {
  log_info "Testing system configuration..."
  
  # Check if dotfiles.conf exists
  if [ ! -f "$DOTFILES_DIR/dotfiles.conf" ]; then
    log_warning "dotfiles.conf not found"
  else
    log_success "dotfiles.conf exists"
  fi
  
  return 0
}

# Test symlinks
test_symlinks() {
  log_info "Testing symlinks..."
  
  # Check if common dotfiles are symlinks
  dotfiles=".zshrc .gitconfig .tmux.conf .vimrc"
  for dotfile in $dotfiles; do
    if [ -f "$HOME/$dotfile" ]; then
      if [ -L "$HOME/$dotfile" ]; then
        log_success "$dotfile is a symlink"
      else
        log_warning "$dotfile is not a symlink"
      fi
    fi
  done
  
  return 0
}

# Main function
main() {
  print_header
  
  # Load configuration
  if [ -f "$DOTFILES_DIR/dotfiles.conf" ]; then
    load_config "$DOTFILES_DIR/dotfiles.conf"
  fi
  
  # Run tests
  test_stow_config
  test_shell_config
  test_git_config
  test_tmux_config
  test_nvim_config
  test_vim_config
  test_tools_config
  test_system_config
  test_symlinks
  
  log_success "All tests completed"
}

# Run main function
main "$@"