#!/bin/bash
# Setup Node.js development environment with nvm

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Node.js development environment...${NC}"

# Install nvm if not exists
if [ ! -d "$HOME/.nvm" ]; then
    echo -e "${YELLOW}Installing nvm...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    echo -e "${GREEN}✓ nvm installed${NC}"
fi

# Add nvm to shell configuration if not exists
if ! grep -q 'NVM_DIR' ~/.zshrc 2>/dev/null; then
    echo -e "${YELLOW}Adding nvm to shell configuration...${NC}"
    cat >> ~/.zshrc << 'EOF'

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
    echo -e "${GREEN}✓ nvm added to shell configuration${NC}"
fi

# Source nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install latest LTS Node.js
echo -e "${YELLOW}Installing latest LTS Node.js...${NC}"
nvm install --lts
nvm use --lts
nvm alias default lts/*

NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
echo -e "${GREEN}✓ Node.js $NODE_VERSION installed${NC}"
echo -e "${GREEN}✓ npm $NPM_VERSION installed${NC}"

# Install global packages
echo -e "${YELLOW}Installing global npm packages...${NC}"
npm install -g \
    typescript \
    ts-node \
    prettier \
    eslint \
    @typescript-eslint/parser \
    @typescript-eslint/eslint-plugin \
    nodemon \
    pm2 \
    yarn \
    pnpm

echo -e "${GREEN}✓ Global npm packages installed${NC}"

# Install pnpm and yarn
echo -e "${YELLOW}Setting up alternative package managers...${NC}"
npm install -g pnpm yarn
echo -e "${GREEN}✓ pnpm and yarn installed${NC}"

echo -e "${GREEN}🎉 Node.js environment setup complete!${NC}"
echo -e "${YELLOW}Please restart your terminal or run: source ~/.zshrc${NC}"
echo -e "${BLUE}Usage examples:${NC}"
echo -e "${CYAN}  nvm list                        # List installed Node.js versions${NC}"
echo -e "${CYAN}  nvm install 18.17.0             # Install specific Node.js version${NC}"
echo -e "${CYAN}  nvm use 18.17.0                 # Use specific Node.js version${NC}"
echo -e "${CYAN}  nvm alias default 18.17.0       # Set default Node.js version${NC}"
echo -e "${CYAN}  echo '18.17.0' > .nvmrc         # Set Node.js version for project${NC}"
echo -e "${CYAN}  nvm use                         # Use Node.js version from .nvmrc${NC}"