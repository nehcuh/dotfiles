# Zsh configuration
# Modular, maintainable, simple

# Paths
export DOTFILES=$HOME/.dotfiles
export NVIMD=$HOME/.config/nvim

# Load OS-specific configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
    [[ -f "$HOME/.zshrc.macos" ]] && source "$HOME/.zshrc.macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    [[ -f "$HOME/.config/linux/linux.sh" ]] && source "$HOME/.config/linux/linux.sh"
fi

# Initialize Starship prompt
eval "$(starship init zsh)"

# Source modular configurations
CONFIG_DIR="$HOME/.config/zsh"
[[ -d "$CONFIG_DIR" ]] && {
    source "$CONFIG_DIR/plugins.zsh"
    source "$CONFIG_DIR/dev.zsh"
    source "$CONFIG_DIR/fzf.zsh"
    source "$CONFIG_DIR/git.zsh"
    source "$CONFIG_DIR/aliases.zsh"
}

# Optional: Load local customizations
# These files are NOT tracked by git - use them for personal settings
[[ -f "$CONFIG_DIR/local.zsh" ]] && source "$CONFIG_DIR/local.zsh"
[[ -f "$CONFIG_DIR/proxy.zsh" ]] && source "$CONFIG_DIR/proxy.zsh"
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
