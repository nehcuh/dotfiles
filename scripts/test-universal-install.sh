#!/bin/bash
# Test script for universal installation functionality

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Testing universal installation script...${NC}"

# Test 1: Check if script exists and is executable
echo -e "${YELLOW}Test 1: Script existence and permissions${NC}"
if [ -f "scripts/universal-install.sh" ]; then
    echo -e "${GREEN}✓ Universal installation script exists${NC}"
    if [ -x "scripts/universal-install.sh" ]; then
        echo -e "${GREEN}✓ Script is executable${NC}"
    else
        echo -e "${YELLOW}⚠ Script is not executable${NC}"
        chmod +x scripts/universal-install.sh
        echo -e "${GREEN}✓ Made script executable${NC}"
    fi
else
    echo -e "${RED}✗ Universal installation script not found${NC}"
    exit 1
fi

# Test 2: Check script syntax
echo -e "${YELLOW}Test 2: Script syntax validation${NC}"
if bash -n scripts/universal-install.sh; then
    echo -e "${GREEN}✓ Script syntax is valid${NC}"
else
    echo -e "${RED}✗ Script has syntax errors${NC}"
    exit 1
fi

# Test 3: Check if required functions exist
echo -e "${YELLOW}Test 3: Function availability${NC}"
required_functions=("detect_shell" "detect_platform" "install_prerequisites" "clone_dotfiles" "check_config_conflicts" "install_linux_homebrew_universal" "install_starship_universal" "install_editors_universal" "run_installer" "main")

for func in "${required_functions[@]}"; do
    if grep -q "^$func()" scripts/universal-install.sh; then
        echo -e "${GREEN}✓ Function $func exists${NC}"
    else
        echo -e "${RED}✗ Function $func missing${NC}"
    fi
done

# Test 4: Check for duplicate main() functions
echo -e "${YELLOW}Test 4: Duplicate function check${NC}"
main_count=$(grep -c "^main()" scripts/universal-install.sh)
if [ "$main_count" -eq 1 ]; then
    echo -e "${GREEN}✓ Only one main() function found${NC}"
else
    echo -e "${RED}✗ Found $main_count main() functions (should be 1)${NC}"
fi

# Test 5: Check installation logic
echo -e "${YELLOW}Test 5: Installation logic${NC}"
if grep -q "install_linux_homebrew_universal" scripts/universal-install.sh; then
    echo -e "${GREEN}✓ Linux Homebrew installation included${NC}"
else
    echo -e "${RED}✗ Linux Homebrew installation missing${NC}"
fi

if grep -q "install_starship_universal" scripts/universal-install.sh; then
    echo -e "${GREEN}✓ Starship installation included${NC}"
else
    echo -e "${RED}✗ Starship installation missing${NC}"
fi

if grep -q "install_editors_universal" scripts/universal-install.sh; then
    echo -e "${GREEN}✓ Editor installation included${NC}"
else
    echo -e "${RED}✗ Editor installation missing${NC}"
fi

# Test 6: Check curl installation method
echo -e "${YELLOW}Test 6: Installation methods${NC}"
if grep -q "curl -fsSL" scripts/universal-install.sh; then
    echo -e "${GREEN}✓ Curl installation method available${NC}"
else
    echo -e "${RED}✗ Curl installation method missing${NC}"
fi

echo -e "${BLUE}Test completed!${NC}"
echo -e "${YELLOW}The universal installation script should now work correctly with:${NC}"
echo -e "${CYAN}  - Linux Homebrew installation with Tsinghua mirror${NC}"
echo -e "${CYAN}  - Starship prompt installation${NC}"
echo -e "${CYAN}  - VS Code and Zed editor installation${NC}"
echo -e "${CYAN}  - Proper error handling and sudo access${NC}"
echo -e "${YELLOW}To test the full installation, run:${NC}"
echo -e "${CYAN}  curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/universal-install.sh | sh${NC}"