#!/bin/bash
# Setup Python development environment with pyenv and anaconda

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Python development environment...${NC}"

# Install pyenv if not exists
if ! command -v pyenv >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing pyenv...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install pyenv
    else
        curl https://pyenv.run | bash
    fi
    echo -e "${GREEN}✓ pyenv installed${NC}"
fi

# Add pyenv to shell configuration
if ! grep -q 'pyenv init' ~/.zshrc 2>/dev/null; then
    echo -e "${YELLOW}Adding pyenv to shell configuration...${NC}"
    cat >> ~/.zshrc << 'EOF'

# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
    echo -e "${GREEN}✓ pyenv added to shell configuration${NC}"
fi

# Source the configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Install anaconda3 latest version
echo -e "${YELLOW}Installing anaconda3 latest version...${NC}"
ANACONDA_VERSION=$(pyenv install --list | grep -E "^\s*anaconda3-" | tail -1 | tr -d ' ')
if [ -n "$ANACONDA_VERSION" ]; then
    pyenv install $ANACONDA_VERSION
    pyenv global $ANACONDA_VERSION
    echo -e "${GREEN}✓ anaconda3 $ANACONDA_VERSION installed and set as global${NC}"
else
    echo -e "${RED}✗ Failed to find anaconda3 version${NC}"
    exit 1
fi

# Install uv
if ! command -v uv >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing uv...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install uv
    else
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    echo -e "${GREEN}✓ uv installed${NC}"
fi

# Install direnv
if ! command -v direnv >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing direnv...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install direnv
    else
        sudo apt-get update && sudo apt-get install -y direnv
    fi
    echo -e "${GREEN}✓ direnv installed${NC}"
fi

# Add direnv to shell configuration
if ! grep -q 'direnv hook' ~/.zshrc 2>/dev/null; then
    echo -e "${YELLOW}Adding direnv to shell configuration...${NC}"
    echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
    echo -e "${GREEN}✓ direnv added to shell configuration${NC}"
fi

# Install common Python development tools
echo -e "${YELLOW}Installing Python development tools...${NC}"
pip install --upgrade pip
pip install \
    black \
    isort \
    mypy \
    ruff \
    poetry \
    jupyter \
    ipython \
    pytest \
    pre-commit

echo -e "${GREEN}✓ Python development tools installed${NC}"

echo -e "${GREEN}🎉 Python environment setup complete!${NC}"
echo -e "${YELLOW}Please restart your terminal or run: source ~/.zshrc${NC}"
echo -e "${BLUE}Usage examples:${NC}"
echo -e "${CYAN}  pyenv versions                 # List installed Python versions${NC}"
echo -e "${CYAN}  pyenv install 3.11.0           # Install specific Python version${NC}"
echo -e "${CYAN}  pyenv local 3.11.0             # Set Python version for current directory${NC}"
echo -e "${CYAN}  echo 'layout python' > .envrc  # Use direnv for project-specific Python${NC}"
echo -e "${CYAN}  direnv allow                    # Allow direnv for current directory${NC}"