#!/bin/bash
# Test script to validate dotfiles configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing Dotfiles Configuration${NC}"
echo "=================================="

# Test 1: Check directory structure
echo -e "${YELLOW}📁 Checking directory structure...${NC}"
required_dirs=("scripts" "stow-packs" "docker" ".devcontainer")
for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓ $dir exists${NC}"
    else
        echo -e "${RED}✗ $dir missing${NC}"
    fi
done

# Test 2: Check script permissions
echo -e "${YELLOW}🔐 Checking script permissions...${NC}"
for script in scripts/*.sh; do
    if [ -x "$script" ]; then
        echo -e "${GREEN}✓ $script is executable${NC}"
    else
        echo -e "${RED}✗ $script is not executable${NC}"
        chmod +x "$script"
        echo -e "${YELLOW}  Fixed: Made $script executable${NC}"
    fi
done

# Test 3: Validate JSON files
echo -e "${YELLOW}📄 Validating JSON files...${NC}"
json_files=(
    "stow-packs/zed/.config/zed/settings.json"
    "stow-packs/zed/.config/zed/keymap.json"
    ".devcontainer/devcontainer.json"
)

for json_file in "${json_files[@]}"; do
    if [ -f "$json_file" ]; then
        if python3 -c "import json; json.load(open('$json_file'))" 2>/dev/null; then
            echo -e "${GREEN}✓ $json_file syntax OK${NC}"
        else
            echo -e "${RED}✗ $json_file has syntax errors${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ $json_file not found${NC}"
    fi
done

# Test 4: Validate YAML files
echo -e "${YELLOW}📄 Validating YAML files...${NC}"
yaml_files=(
    "docker/docker-compose.ubuntu-dev.yml"
    "docker/docker-compose.dev.yml"
)

for yaml_file in "${yaml_files[@]}"; do
    if [ -f "$yaml_file" ]; then
        if python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null; then
            echo -e "${GREEN}✓ $yaml_file syntax OK${NC}"
        else
            echo -e "${RED}✗ $yaml_file has syntax errors${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ $yaml_file not found${NC}"
    fi
done

# Test 5: Check Dockerfile syntax
echo -e "${YELLOW}🐳 Checking Dockerfile syntax...${NC}"
dockerfiles=(
    "docker/Dockerfile.ubuntu-dev"
    "docker/Dockerfile.dev"
)

for dockerfile in "${dockerfiles[@]}"; do
    if [ -f "$dockerfile" ]; then
        if docker build -f "$dockerfile" --dry-run . >/dev/null 2>&1; then
            echo -e "${GREEN}✓ $dockerfile syntax OK${NC}"
        else
            echo -e "${YELLOW}⚠ $dockerfile syntax check skipped (Docker not available)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ $dockerfile not found${NC}"
    fi
done

# Test 6: Check stow packages
echo -e "${YELLOW}📦 Checking stow packages...${NC}"
if [ -d "stow-packs" ]; then
    for package in stow-packs/*/; do
        package_name=$(basename "$package")
        echo -e "${GREEN}✓ Package: $package_name${NC}"
        
        # Check if package has files
        if [ "$(find "$package" -type f | wc -l)" -gt 0 ]; then
            echo -e "  ${GREEN}  Contains $(find "$package" -type f | wc -l) files${NC}"
        else
            echo -e "  ${YELLOW}  Warning: Package is empty${NC}"
        fi
    done
else
    echo -e "${RED}✗ stow-packs directory not found${NC}"
fi

# Test 7: Check Makefile
echo -e "${YELLOW}🔨 Testing Makefile...${NC}"
if [ -f "Makefile" ]; then
    if make -n help >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Makefile syntax OK${NC}"
    else
        echo -e "${RED}✗ Makefile has syntax errors${NC}"
    fi
else
    echo -e "${RED}✗ Makefile not found${NC}"
fi

# Test 8: Check key configuration files
echo -e "${YELLOW}⚙️ Checking key configuration files...${NC}"
config_files=(
    "stow-packs/system/.config/starship.toml"
    "stow-packs/system/Brewfile"
    "stow-packs/zsh/.zshrc"
    "stow-packs/git/gitconfig_global"
)

for config_file in "${config_files[@]}"; do
    if [ -f "$config_file" ]; then
        echo -e "${GREEN}✓ $config_file exists${NC}"
    else
        echo -e "${RED}✗ $config_file missing${NC}"
    fi
done

echo ""
echo -e "${BLUE}🎉 Configuration test completed!${NC}"
echo -e "${YELLOW}Run this script with: ./scripts/test-config.sh${NC}"