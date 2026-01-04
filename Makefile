# Simple Dotfiles Makefile

# Variables
DOTFILES_DIR := $(CURDIR)
STOW_SCRIPT := ./scripts/stow.sh

# Colors
GREEN := \033[0;32m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
.PHONY: help
help:
	@echo "$(BLUE)Dotfiles Management$(NC)"
	@echo "===================="
	@echo ""
	@echo "  $(GREEN)make install$(NC)      - Install all packages (using stow)"
	@echo "  $(GREEN)make uninstall$(NC)    - Remove all packages"
	@echo "  $(GREEN)make list$(NC)         - List available packages"
	@echo "  $(GREEN)make status$(NC)       - Show stow status" 
	@echo ""

# Main installation
.PHONY: install
install:
	@echo "$(BLUE)Installing dotfiles...$(NC)"
	@$(STOW_SCRIPT) install
	@echo "$(GREEN)✓ Installation complete!$(NC)"

# Uninstallation
.PHONY: uninstall
uninstall:
	@echo "$(BLUE)Uninstalling dotfiles...$(NC)"
	@$(STOW_SCRIPT) remove
	@echo "$(GREEN)✓ Uninstallation complete!$(NC)"

# List packages
.PHONY: list
list:
	@$(STOW_SCRIPT) list

# Status check
.PHONY: status
status:
	@echo "$(BLUE)Current status:$(NC)"
	@$(STOW_SCRIPT) status

# Update repository
.PHONY: update
update:
	@echo "$(BLUE)Updating repository...$(NC)"
	@git pull origin main 2>/dev/null || git pull origin master
	@echo "$(GREEN)✓ Repository updated!$(NC)"
