# Dotfiles Management Makefile

# Variables
DOTFILES_DIR := $(CURDIR)
INSTALL_SCRIPT := ./scripts/install.sh
UNINSTALL_SCRIPT := ./scripts/uninstall.sh
MIGRATE_SCRIPT := ./scripts/dotfile-migrate.sh
MANAGER_SCRIPT := ./scripts/dotfile-manager.sh

# Colors
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[1;33m
CYAN := \033[0;36m
BOLD := \033[1m
NC := \033[0m # No Color

# Default target
.PHONY: help
help:
	@echo "$(BOLD)$(CYAN)Dotfiles Management$(NC)"
	@echo "===================="
	@echo ""
	@echo "$(BOLD)基本操作:$(NC)"
	@echo "  $(GREEN)make install$(NC)           - 安装所有配置包"
	@echo "  $(GREEN)make uninstall$(NC)         - 卸载所有配置包"
	@echo "  $(GREEN)make update$(NC)            - 更新仓库到最新版本"
	@echo "  $(GREEN)make status$(NC)            - 查看当前管理状态"
	@echo ""
	@echo "$(BOLD)文件迁移:$(NC)"
	@echo "  $(GREEN)make scan$(NC)              - 扫描未管理的配置文件"
	@echo "  $(GREEN)make migrate$(NC)           - 交互式迁移配置文件"
	@echo "  $(GREEN)make auto-migrate$(NC)      - 自动迁移所有识别的文件"
	@echo "  $(GREEN)make list-unmanaged$(NC)    - 列出未管理的文件"
	@echo ""
	@echo "$(BOLD)文件管理:$(NC)"
	@echo "  $(GREEN)make list$(NC)              - 列出已管理的配置文件"
	@echo "  $(GREEN)make add FILE PACKAGE$(NC)  - 添加文件到指定包"
	@echo "  $(GREEN)make clean PACKAGE$(NC)     - 删除指定包的配置"
	@echo "  $(GREEN)make check FILE$(NC)        - 检查文件管理状态"
	@echo ""
	@echo "$(BOLD)示例:$(NC)"
	@echo "  make scan                           # 扫描可迁移的文件"
	@echo "  make migrate                        # 交互式迁移"
	@echo "  make add ~/.claude.json sensitive   # 添加 Claude 配置"
	@echo "  make clean sensitive                # 删除 sensitive 包"
	@echo "  make list                           # 查看已管理的文件"
	@echo "  make font-config                    # 配置终端字体"
	@echo ""
	@echo "$(BOLD)文档:$(NC)"
	@echo "  $(GREEN)make docs$(NC)              - 查看所有文档"
	@echo ""

# ============================================================================
# 基本操作
# ============================================================================

.PHONY: install
install:
	@echo "$(BLUE)Installing dotfiles...$(NC)"
	@$(INSTALL_SCRIPT)
	@echo "$(GREEN)✓ Installation complete!$(NC)"

.PHONY: uninstall
uninstall:
	@echo "$(BLUE)Uninstalling dotfiles...$(NC)"
	@$(UNINSTALL_SCRIPT)
	@echo "$(GREEN)✓ Uninstallation complete!$(NC)"

.PHONY: update
update:
	@echo "$(BLUE)Updating repository...$(NC)"
	@git pull origin main 2>/dev/null || git pull origin master
	@echo "$(GREEN)✓ Repository updated!$(NC)"

.PHONY: status
status:
	@echo "$(BLUE)Current management status:$(NC)"
	@echo ""
	@if command -v stow >/dev/null 2>&1; then \
		stow -d "$(DOTFILES_DIR)" -nv . 2>&1 | grep -E "(LINK:|Unlinked)" || echo "  No packages currently installed"; \
	else \
		echo "  $(YELLOW)GNU Stow not installed$(NC)"; \
		echo "  Install with: brew install stow"; \
	fi
	@echo ""
	@echo "$(BLUE)Package status:$(NC)"
	@for pkg in $$(ls -d stow-packs/*/ 2>/dev/null | xargs -n1 basename); do \
		if stow -d "$(DOTFILES_DIR)" -n "$$pkg" >/dev/null 2>&1; then \
			echo "  $(GREEN)✓$$pkg$(NC) (linked)"; \
		else \
			echo "  $(YELLOW)○$$pkg$(NC) (not linked)"; \
		fi \
	done

# ============================================================================
# 文件迁移
# ============================================================================

.PHONY: scan
scan:
	@echo "$(BLUE)Scanning for unmanaged configuration files...$(NC)"
	@echo ""
	@$(MIGRATE_SCRIPT) scan

.PHONY: migrate
migrate:
	@echo "$(BLUE)Interactive migration wizard$(NC)"
	@echo ""
	@$(MIGRATE_SCRIPT) migrate

.PHONY: auto-migrate
auto-migrate:
	@echo "$(BLUE)Auto-migrating all recognized files...$(NC)"
	@echo ""
	@$(MIGRATE_SCRIPT) auto -y

.PHONY: list-unmanaged
list-unmanaged:
	@echo "$(BLUE)Unmanaged configuration files:$(NC)"
	@echo ""
	@$(MANAGER_SCRIPT) --list

# ============================================================================
# 文件管理
# ============================================================================

.PHONY: list
list:
	@echo "$(BLUE)Managed configuration files:$(NC)"
	@echo ""
	@echo "$(CYAN)Linked files:$(NC)"
	@if command -v stow >/dev/null 2>&1; then \
		find ~ -maxdepth 1 -name '.*' -type l -lname '*.dotfiles*' 2>/dev/null | while read file; do \
			target=$$(readlink "$$file"); \
			basename=$$(basename "$$file"); \
			pkg=$$(echo "$$target" | grep -o 'stow-packs/[^/]*' | cut -d'/' -f2); \
			echo "  $(GREEN)✓$(NC) $$basename → $(YELLOW)$$pkg$(NC)"; \
		done; \
		echo ""; \
		echo "$(CYAN)Linked directories (.config):$(NC)"; \
		find ~/.config -maxdepth 1 -type l -lname '*.dotfiles*' 2>/dev/null | while read dir; do \
			target=$$(readlink "$$dir"); \
			basename=$$(basename "$$dir"); \
			pkg=$$(echo "$$target" | grep -o 'stow-packs/[^/]*' | cut -d'/' -f2); \
			echo "  $(GREEN)✓$(NC) .config/$$basename → $(YELLOW)$$pkg$(NC)"; \
		done; \
	else \
		echo "  $(YELLOW)GNU Stow not installed$(NC)"; \
	fi
	@echo ""
	@echo "$(CYAN)Available packages:$(NC)"
	@for pkg in $$(ls -d stow-packs/*/ 2>/dev/null | xargs -n1 basename); do \
		count=$$(find "stow-packs/$$pkg" -type f -o -type l 2>/dev/null | wc -l | tr -d ' '); \
		echo "  $$pkg ($$count files)"; \
	done

.PHONY: add
add:
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: FILE parameter required$(NC)"; \
		echo "Usage: make add FILE=~/.path/to/file PACKAGE=sensitive"; \
		exit 1; \
	fi
	@if [ -z "$(PACKAGE)" ]; then \
		echo "$(RED)Error: PACKAGE parameter required$(NC)"; \
		echo "Usage: make add FILE=~/.path/to/file PACKAGE=sensitive"; \
		echo ""; \
		echo "Available packages: sensitive, personal, system, git, zsh, tools, nvim, vscode, zed, tmux"; \
		exit 1; \
	fi
	@echo "$(BLUE)Adding $(FILE) to $(PACKAGE) package...$(NC)"
	@$(MANAGER_SCRIPT) --move $(FILE) $(PACKAGE)

.PHONY: check
check:
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: FILE parameter required$(NC)"; \
		echo "Usage: make check FILE=~/.path/to/file"; \
		exit 1; \
	fi
	@echo "$(BLUE)Checking file: $(FILE)$(NC)"
	@echo ""
	@expanded_file="$$(echo "$(FILE)" | sed 's|^~/|$(HOME)/|')"; \
	if [ -L "$$expanded_file" ]; then \
		target=$$(readlink "$$expanded_file"); \
		echo "  Type: $$(echo '\033[0;32m')Symbolic link$$(echo '\033[0m')"; \
		echo "  Target: $$target"; \
		if echo "$$target" | grep -q '\.dotfiles'; then \
			echo "  Status: $$(echo '\033[0;32m')Managed by dotfiles$$(echo '\033[0m')"; \
		else \
			echo "  Status: $$(echo '\033[1;33m')External symlink$$(echo '\033[0m')"; \
		fi \
	elif [ -f "$$expanded_file" ]; then \
		echo "  Type: $$(echo '\033[1;33m')Regular file$$(echo '\033[0m')"; \
		echo "  Status: $$(echo '\033[1;33m')Not managed$$(echo '\033[0m')"; \
		echo "  To add: $$(echo '\033[0;32m')make add FILE=$(FILE) PACKAGE=<package>$$(echo '\033[0m')"; \
	elif [ -d "$$expanded_file" ]; then \
		echo "  Type: $$(echo '\033[1;33m')Directory$$(echo '\033[0m')"; \
		echo "  Status: $$(echo '\033[1;33m')Not managed$$(echo '\033[0m')"; \
		echo "  To add: $$(echo '\033[0;32m')make add FILE=$(FILE) PACKAGE=<package>$$(echo '\033[0m')"; \
	else \
		echo "  Status: $$(echo '\033[0;31m')File does not exist$$(echo '\033[0m')"; \
	fi

.PHONY: clean
clean:
	@if [ -z "$(PACKAGE)" ]; then \
		echo "$(RED)Error: PACKAGE parameter required$(NC)"; \
		echo "Usage: make clean PACKAGE=sensitive"; \
		echo ""; \
		echo "Available packages:"; \
		for pkg in $$(ls -d stow-packs/*/ 2>/dev/null | xargs -n1 basename); do \
			echo "  - $$pkg"; \
		done; \
		exit 1; \
	fi
	@echo "$(YELLOW)Warning: This will unlink the $(PACKAGE) package$(NC)"
	@echo ""
	@if [ -d "stow-packs/$(PACKAGE)" ]; then \
		echo "Files to be unlinked:"; \
		find "stow-packs/$(PACKAGE)" -type f -o -type l 2>/dev/null | head -10 | while read file; do \
			basename=$$(echo "$$file" | sed 's|stow-packs/$(PACKAGE)/||'); \
			echo "  ~/$$basename"; \
		done; \
		echo ""; \
		read -p "Continue? [y/N] " -n 1 -r; \
		echo ""; \
		if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
			echo "$(BLUE)Unlinking $(PACKAGE) package...$(NC)"; \
			cd $(DOTFILES_DIR) && stow -D "stow-packs/$(PACKAGE)" 2>/dev/null || echo "$(YELLOW)Failed to unlink (package may not be linked)$(NC)"; \
			echo "$(GREEN)✓ Package unlinked$(NC)"; \
		else \
			echo "$(YELLOW)Aborted$(NC)"; \
		fi \
	else \
		echo "$(RED)Error: Package '$(PACKAGE)' not found$(NC)"; \
		exit 1; \
	fi

# ============================================================================
# 文档和帮助
# ============================================================================

.PHONY: docs
docs:
	@echo "$(BLUE)Available documentation:$(NC)"
	@echo ""
	@echo "$(CYAN)Quick Start:$(NC)"
	@echo "  QUICKSTART.md              - 快速开始指南"
	@echo "  QUICKSTART_MIGRATION.md    - 快速迁移指南"
	@echo ""
	@echo "$(CYAN)Complete Guides:$(NC)"
	@echo "  README.md                  - 项目总览"
	@echo "  MIGRATION_GUIDE.md         - 完整迁移文档"
	@echo "  DOTFILES_MANAGEMENT.md     - 配置管理文档"
	@echo ""
	@echo "$(CYAN)Specific Topics:$(NC)"
	@echo "  ZSH_CHEATSHEET.md          - Zsh 配置说明"
	@echo "  NVIM_ASTRO_CONFIG.md       - Neovim 配置"
	@echo "  UV_GUIDE.md                - Python UV 指南"
	@echo ""
	@echo "$(BOLD)Read with:$(NC) make read-doc DOC=<name>"
	@echo ""

.PHONY: read-doc
read-doc:
	@if [ -z "$(DOC)" ]; then \
		echo "$(RED)Error: DOC parameter required$(NC)"; \
		echo "Usage: make read-doc DOC=README.md"; \
		echo ""; \
		make docs; \
		exit 1; \
	fi
	@if [ -f "$(DOC)" ]; then \
		command -v bat >/dev/null 2>&1 && bat "$(DOC)" || cat "$(DOC)"; \
	else \
		echo "$(RED)Error: Document '$(DOC)' not found$(NC)"; \
		exit 1; \
	fi

# ============================================================================
# 开发和维护
# ============================================================================

.PHONY: test
test:
	@echo "$(BLUE)Running tests...$(NC)"
	@echo ""
	@echo "✓ Checking GNU Stow..."
	@command -v stow >/dev/null 2>&1 || echo "  ✗ stow not installed"
	@echo "✓ Checking package structure..."
	@for pkg in $$(ls -d stow-packs/*/ 2>/dev/null); do \
		basename=$$(basename "$$pkg"); \
		if [ -f "$$pkg/home/.gitkeep" ] || [ -f "$$pkg/home/.gitignore" ] || [ -d "$$pkg/home" ]; then \
			echo "  ✓ $$basename"; \
		else \
			echo "  ⚠ $$basename (missing home/)"; \
		fi \
	done
	@echo "✓ Checking git status..."
	@git status --short | head -5 || echo "  ✓ Clean working tree"

.PHONY: backup
backup:
	@echo "$(BLUE)Creating backup...$(NC)"
	@backup_dir="$$(date '+%Y%m%d_%H%M%S')_dotfiles_backup"; \
	mkdir -p "$$backup_dir"; \
	find ~ -maxdepth 1 -name '.*' -type f \( ! -name '.DS_Store' \) -exec cp {} "$$backup_dir/" \; 2>/dev/null; \
	echo "$(GREEN)✓ Backup created: $$backup_dir$(NC)"

.PHONY: doctor
doctor:
	@echo "$(BOLD)$(CYAN)Dotfiles Diagnostics$(NC)"
	@echo "===================="
	@echo ""
	@echo "$(BOLD)System:$(NC)"
	@echo "  OS: $$(uname -s)"
	@echo "  Shell: $$(basename $$SHELL)"
	@echo ""
	@echo "$(BOLD)Required Tools:$(NC)"
	@command -v stow >/dev/null 2>&1 && echo "  $(GREEN)✓$(NC) stow" || echo "  $(RED)✗$(NC) stow (not installed)"
	@command -v git >/dev/null 2>&1 && echo "  $(GREEN)✓$(NC) git" || echo "  $(RED)✗$(NC) git (not installed)"
	@echo ""
	@echo "$(BOLD)Package Status:$(NC)"
	@$(MAKE) --silent status
	@echo ""
	@echo "$(BOLD)Font Status:$(NC)"
	@if system_profiler SPFontsDataType 2>/dev/null | grep -qi "Hack Nerd Font"; then \
		echo "  $(GREEN)✓$(NC) Hack Nerd Font installed"; \
	else \
		echo "  $(YELLOW)○$(NC) Hack Nerd Font not installed"; \
	fi
	@echo ""
	@echo "$(BOLD)Git Status:$(NC)"
	@git status --short 2>/dev/null | head -5 || echo "  Not in git repo"

.PHONY: font-config
font-config:
	@echo "$(BLUE)Configuring terminal to use Hack Nerd Font...$(NC)"
	@echo ""
	@$(DOTFILES_DIR)/scripts/configure-terminal-font.sh

.PHONY: font-test
font-test:
	@echo "$(BLUE)Testing Nerd Font icons...$(NC)"
	@echo ""
	@$(DOTFILES_DIR)/scripts/configure-terminal-font.sh --test

.PHONY: font-status
font-status:
	@echo "$(BLUE)Font installation status:$(NC)"
	@echo ""
	@if system_profiler SPFontsDataType 2>/dev/null | grep -qi "Hack Nerd Font"; then \
		echo "  $(GREEN)✓$(NC) Hack Nerd Font is installed"; \
		echo ""; \
		echo "Terminal configuration:"; \
		if [[ -f "$(HOME)/Library/Preferences/com.apple.Terminal.plist" ]]; then \
			echo "  $(GREEN)✓$(NC) Terminal.app configured"; \
		else \
			echo "  $(YELLOW)○$(NC) Terminal.app not configured"; \
		fi; \
		if [[ -d "/Applications/iTerm.app" ]] || [[ -d "$$HOME/Applications/iTerm.app" ]]; then \
			if defaults read com.googlecode.iterm2 "Normal Font" 2>/dev/null | grep -q "HackNerdFont"; then \
				echo "  $(GREEN)✓$(NC) iTerm2 configured"; \
			else \
				echo "  $(YELLOW)○$(NC) iTerm2 not configured"; \
			fi; \
		fi; \
	else \
		echo "  $(RED)✗$(NC) Hack Nerd Font not installed"; \
		echo ""; \
		echo "Install with:"; \
		echo "  $(GREEN)brew install --cask font-hack-nerd-font$(NC)"; \
	fi
	@echo ""
	@echo "Configure with: $(GREEN)make font-config$(NC)"
