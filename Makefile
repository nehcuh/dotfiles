# Simple Dotfiles Makefile

# Variables
DOTFILES_DIR := $(CURDIR)
VERSION := 1.0.0

# Detect platform
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	PLATFORM := linux
else ifeq ($(UNAME_S),Darwin)
	PLATFORM := macos
else
	PLATFORM := unknown
endif

# Colors
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
.PHONY: help
help:
	@echo "$(BLUE)Simple Dotfiles Management v$(VERSION)$(NC)"
	@echo "================================="
	@echo ""
	@echo "$(BLUE)Platform:$(NC) $(PLATFORM)"
	@echo ""
	@echo "$(BLUE)Available commands:$(NC)"
	@echo "  $(GREEN)install$(NC)      - Install dotfiles"
	@echo "  $(GREEN)uninstall$(NC)    - Remove dotfiles"
	@echo "  $(GREEN)list$(NC)         - List available packages"
	@echo "  $(GREEN)status$(NC)       - Show current status" 
	@echo "  $(GREEN)update$(NC)       - Update repository"
	@echo "  $(GREEN)clean$(NC)        - Clean backup files"
	@echo "  $(GREEN)setup-dev$(NC)    - Setup development environments"
	@echo "  $(GREEN)setup-git$(NC)    - Setup Git configuration"
	@echo "  $(GREEN)optimize$(NC)     - Optimize editors and system settings"
	@echo "  $(GREEN)fonts$(NC)        - Install editor fonts"
	@echo "  $(GREEN)dev-tools$(NC)    - Install development tools"
	@echo ""
	@echo "$(BLUE)Examples:$(NC)"
	@echo "  make install      # Install all dotfiles"
	@echo "  make uninstall    # Remove all dotfiles"
	@echo "  make list         # Show available packages"

# Main installation
.PHONY: install
install:
	@echo "$(BLUE)Installing dotfiles...$(NC)"
	@./install.sh
	@echo "$(GREEN)✓ Installation complete!$(NC)"

# Uninstallation
.PHONY: uninstall
uninstall:
	@echo "$(BLUE)Uninstalling dotfiles...$(NC)"
	@./uninstall.sh
	@echo "$(GREEN)✓ Uninstallation complete!$(NC)"

# List packages
.PHONY: list
list:
	@./uninstall.sh list

# Status check
.PHONY: status
status:
	@echo "$(BLUE)Current status:$(NC)"
	@./scripts/stow.sh status

# Update repository
.PHONY: update
update:
	@echo "$(BLUE)Updating repository...$(NC)"
	@git pull origin main 2>/dev/null || git pull origin master
	@echo "$(GREEN)✓ Repository updated!$(NC)"

# Clean backup files
.PHONY: clean
clean:
	@echo "$(BLUE)Cleaning backup files...$(NC)"
	@find $(HOME) -name ".dotfiles-backup-*" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
	@find $(HOME) -name "*.broken" -type f -delete 2>/dev/null || true
	@find $(HOME) -name "*.old" -type f -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete!$(NC)"

# Git setup
.PHONY: setup-git
setup-git:
	@echo "$(BLUE)Setting up Git configuration...$(NC)"
	@./scripts/setup-git-config.sh
	@echo "$(GREEN)✓ Git setup complete!$(NC)"

# Development environment setup
.PHONY: setup-dev
setup-dev:
	@echo "$(BLUE)Setting up development environments...$(NC)"
	@./scripts/setup-dev-environment.sh
	@echo "$(GREEN)✓ Development environment setup complete!$(NC)"

# Editor and system optimization
.PHONY: optimize
optimize:
	@echo "$(BLUE)Running comprehensive editor and system optimization...$(NC)"
	@./scripts/setup-editor-optimization.sh
	@echo "$(GREEN)✓ Optimization complete!$(NC)"

# Install fonts only
.PHONY: fonts
fonts:
	@echo "$(BLUE)Installing editor fonts...$(NC)"
	@./scripts/setup-editor-fonts.sh
	@echo "$(GREEN)✓ Font installation complete!$(NC)"

# Install development tools only
.PHONY: dev-tools
dev-tools:
	@echo "$(BLUE)Installing development tools...$(NC)"
	@./scripts/setup-dev-tools.sh
	@echo "$(GREEN)✓ Development tools installation complete!$(NC)"

# Check requirements
.PHONY: check
check:
	@echo "$(BLUE)Checking requirements...$(NC)"
	@command -v git > /dev/null 2>&1 || (echo "$(YELLOW)Git not found$(NC)" && exit 1)
	@command -v stow > /dev/null 2>&1 || echo "$(YELLOW)GNU Stow not found - will be installed automatically$(NC)"
	@echo "$(GREEN)✓ Requirements check complete!$(NC)"
