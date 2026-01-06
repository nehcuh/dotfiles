# Local customizations
# These are machine-specific configurations that shouldn't be tracked by git

# LM Studio CLI
export PATH="$PATH:/Users/huchen/.lmstudio/bin"

# OpenCode
export PATH=/Users/huchen/.opencode/bin:$PATH

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Bun completions
[ -s "/Users/huchen/.bun/_bun" ] && source "/Users/huchen/.bun/_bun"

# Kiro terminal integration
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
