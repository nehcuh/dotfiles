# Cross-Platform Dotfiles Makefile
# This Makefile provides convenient targets for managing dotfiles

# Variables
DOTFILES_DIR := $(CURDIR)
STOW_DIR := $(DOTFILES_DIR)/stow-packs
TARGET_DIR := $(HOME)

# Detect platform
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	PLATFORM := linux
else ifeq ($(UNAME_S),Darwin)
	PLATFORM := macos
else
	PLATFORM := windows
endif

# Colors
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
NC := \033[0m # No Color

# Default target
.PHONY: help
help:
	@echo "$(CYAN)Cross-Platform Dotfiles Management$(NC)"
	@echo "=================================="
	@echo ""
	@echo "$(BLUE)Available targets:$(NC)"
	@echo "  $(GREEN)install$(NC)     - Install dotfiles (default)"
	@echo "  $(GREEN)install-all$(NC) - Install all packages"
	@echo "  $(GREEN)install-system$(NC) - Install system packages"
	@echo "  $(GREEN)install-shell$(NC) - Install shell configuration"
	@echo "  $(GREEN)install-dev$(NC)  - Install development tools"
	@echo "  $(GREEN)install-editors$(NC) - Install editors"
	@echo "  $(GREEN)remove$(NC)      - Remove dotfiles"
	@echo "  $(GREEN)status$(NC)      - Show current status"
	@echo "  $(GREEN)list$(NC)        - List available packages"
	@echo "  $(GREEN)clean$(NC)       - Clean up obsolete files"
	@echo "  $(GREEN)update$(NC)      - Update dotfiles repository"
	@echo "  $(GREEN)setup-git$(NC)   - Setup git configuration"
	@echo ""
	@echo "$(BLUE)Platform-specific targets:$(NC)"
	@echo "  $(GREEN)install-linux$(NC)  - Linux-specific installation"
	@echo "  $(GREEN)install-macos$(NC)  - macOS-specific installation"
	@echo "  $(GREEN)install-windows$(NC) - Windows-specific installation"
	@echo ""
	@echo "$(BLUE)Quick installation:$(NC)"
	@echo "  make install     # Install all dotfiles"
	@echo "  make clean       # Clean up before installation"
	@echo "  make status      # Check current status"

# Installation targets
.PHONY: install
install: install-system install-shell install-dev install-editors setup-git
	@echo "$(GREEN)✓ Dotfiles installation complete!$(NC)"
	@echo "$(YELLOW)Please restart your terminal to apply all changes.$(NC)"

.PHONY: install-all
install-all: install

.PHONY: install-system
install-system:
	@echo "$(BLUE)Installing system packages...$(NC)"
	@./scripts/stow.sh install system

.PHONY: install-shell
install-shell:
	@echo "$(BLUE)Installing shell configuration...$(NC)"
	@./scripts/stow.sh install zsh

.PHONY: install-dev
install-dev:
	@echo "$(BLUE)Installing development tools...$(NC)"
	@./scripts/stow.sh install git tools

.PHONY: install-editors
install-editors:
	@echo "$(BLUE)Installing editors...$(NC)"
	@./scripts/stow.sh install vim nvim tmux

.PHONY: install-linux
install-linux:
	@if [ "$(PLATFORM)" = "linux" ]; then \
		echo "$(BLUE)Installing Linux-specific packages...$(NC)"; \
		./scripts/stow.sh install system; \
		if [ -f "install_$$(lsb_release -si | tr '[:upper:]' '[:lower:]').sh" ]; then \
			./install_$$(lsb_release -si | tr '[:upper:]' '[:lower:]').sh; \
		fi; \
	else \
		echo "$(RED)This target is only for Linux systems.$(NC)"; \
		exit 1; \
	fi

.PHONY: install-macos
install-macos:
	@if [ "$(PLATFORM)" = "macos" ]; then \
		echo "$(BLUE)Installing macOS-specific packages...$(NC)"; \
		./scripts/stow.sh install system; \
		if command -v brew >/dev/null 2>&1; then \
			brew bundle --global; \
		fi; \
	else \
		echo "$(RED)This target is only for macOS systems.$(NC)"; \
		exit 1; \
	fi

.PHONY: install-windows
install-windows:
	@if [ "$(PLATFORM)" = "windows" ]; then \
		echo "$(BLUE)Installing Windows-specific packages...$(NC)"; \
		./scripts/stow.sh install windows; \
	else \
		echo "$(RED)This target is only for Windows systems.$(NC)"; \
		exit 1; \
	fi

# Removal targets
.PHONY: remove
remove: remove-system remove-shell remove-dev remove-editors
	@echo "$(GREEN)✓ Dotfiles removed!$(NC)"

.PHONY: remove-system
remove-system:
	@echo "$(YELLOW)Removing system packages...$(NC)"
	@./scripts/stow.sh remove system

.PHONY: remove-shell
remove-shell:
	@echo "$(YELLOW)Removing shell configuration...$(NC)"
	@./scripts/stow.sh remove zsh

.PHONY: remove-dev
remove-dev:
	@echo "$(YELLOW)Removing development tools...$(NC)"
	@./scripts/stow.sh remove git tools

.PHONY: remove-editors
remove-editors:
	@echo "$(YELLOW)Removing editors...$(NC)"
	@./scripts/stow.sh remove vim nvim tmux

# Status and information targets
.PHONY: status
status:
	@echo "$(BLUE)Current stow status:$(NC)"
	@./scripts/stow.sh status

.PHONY: list
list:
	@echo "$(BLUE)Available packages:$(NC)"
	@./scripts/stow.sh list

.PHONY: clean
clean:
	@echo "$(YELLOW)Cleaning up obsolete files...$(NC)"
	@find $(TARGET_DIR) -name "*.broken" -type f -delete 2>/dev/null || true
	@find $(TARGET_DIR) -name "*.old" -type f -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete!$(NC)"

.PHONY: update
update:
	@echo "$(BLUE)Updating dotfiles repository...$(NC)"
	@git pull origin main 2>/dev/null || git pull origin master
	@echo "$(GREEN)✓ Dotfiles updated!$(NC)"

.PHONY: setup-git
setup-git:
	@echo "$(BLUE)Setting up git configuration...$(NC)"
	@./scripts/setup-git-config.sh
	@echo "$(GREEN)✓ Git configuration setup complete!$(NC)"

# Development targets
.PHONY: test
test:
	@echo "$(BLUE)Running tests...$(NC)"
	@echo "$(YELLOW)No tests defined yet.$(NC)"

.PHONY: lint
lint:
	@echo "$(BLUE)Running linter...$(NC)"
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck *.sh; \
	else \
		echo "$(YELLOW)shellcheck not installed. Skipping linting.$(NC)"; \
	fi

# Quick install targets
.PHONY: quick-install
quick-install: install

.PHONY: fresh-install
fresh-install: clean install

# Platform detection
.PHONY: detect-platform
detect-platform:
	@echo "$(CYAN)Platform Detection$(NC)"
	@echo "OS: $(UNAME_S)"
	@echo "Platform: $(PLATFORM)"
	@echo "Dotfiles directory: $(DOTFILES_DIR)"
	@echo "Target directory: $(TARGET_DIR)"

# Check requirements
.PHONY: check-requirements
check-requirements:
	@echo "$(BLUE)Checking requirements...$(NC)"
	@if command -v stow >/dev/null 2>&1; then \
		echo "$(GREEN)✓ GNU Stow is installed$(NC)"; \
	else \
		echo "$(RED)✗ GNU Stow is not installed$(NC)"; \
		echo "$(YELLOW)Please install GNU Stow first.$(NC)"; \
		exit 1; \
	fi
	@if command -v git >/dev/null 2>&1; then \
		echo "$(GREEN)✓ Git is installed$(NC)"; \
	else \
		echo "$(RED)✗ Git is not installed$(NC)"; \
		echo "$(YELLOW)Please install Git first.$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ All requirements met!$(NC)"

# Bootstrap target for new installations
.PHONY: bootstrap
bootstrap: check-requirements install
	@echo "$(GREEN)🎉 Bootstrap complete!$(NC)"
	@echo "$(YELLOW)Please restart your terminal.$(NC)"