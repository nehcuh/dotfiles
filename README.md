# Dotfiles

这里是我的个人配置文件仓库，使用 GNU Stow 进行统一管理。

## 目录结构

这个仓库使用 GNU Stow 管理所有配置文件，按功能和敏感度分类。

```
.dotfiles/
├── README.md                   # 本文档
├── Makefile                    # 常用命令快捷方式
├── stow-packs/                 # 核心目录：所有配置文件
│   ├── sensitive/              # 敏感文件（SSH 密钥、API token）❌ Git不跟踪
│   ├── personal/               # 个人配置（应用列表、主题）✅ Git跟踪
│   ├── system/                 # 系统配置
│   ├── git/                    # Git 配置
│   ├── zsh/                    # Zsh 配置
│   ├── tools/                  # 开发工具配置
│   ├── nvim/                   # Neovim 配置
│   ├── vscode/                 # VS Code 配置
│   └── ...
├── scripts/                    # 管理脚本
│   ├── install.sh              # 安装脚本
│   ├── uninstall.sh            # 卸载脚本
│   ├── dotfile-manager.sh      # 文件管理工具 ⭐
│   └── dotfile-migrate.sh      # 迁移工具 ⭐
└── docs/                       # 📚 文档目录
    ├── guides/                 # 使用指南
    │   ├── QUICKSTART.md       # 快速开始
    │   └── MIGRATION_GUIDE.md  # 迁移指南
    ├── config/                 # 配置说明
    │   ├── DOTFILES_MANAGEMENT.md
    │   └── TERMINAL_FONT_CONFIG.md
    └── tools/                  # 工具文档
        ├── MAKEFILE_COMMANDS.md
        ├── NVIM_ASTRO_CONFIG.md
        ├── UV_GUIDE.md
        └── ZSH_CHEATSHEET.md
```

## 特性

- ✅ **统一管理**: 所有 dot 文件都在项目中管理
- 🔒 **安全隔离**: 敏感文件不会被 Git 跟踪
- 🔄 **易于同步**: 配置文件可在多台机器间同步
- 🛠️ **自动化**: 提供完整的管理脚本和工具

## 快速开始

### 1. 安装依赖

macOS:
```bash
brew install stow
```

Linux:
```bash
sudo apt install stow  # Debian/Ubuntu
sudo yum install stow  # RHEL/CentOS
```

### 2. 安装所有配置

```bash
make install
```

### 3. 迁移外部应用配置（新功能！）

**扫描未管理的文件**：
```bash
~/.dotfiles/scripts/dotfile-migrate.sh scan
```

**交互式迁移**：
```bash
~/.dotfiles/scripts/dotfile-migrate.sh migrate
```

**自动迁移**：
```bash
~/.dotfiles/scripts/dotfile-migrate.sh auto -y
```

### 4. 管理敏感文件

查看未管理的文件：
```bash
~/.dotfiles/scripts/dotfile-manager.sh --list
```

移动敏感文件到 sensitive 包（不会被 git 跟踪）：
```bash
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.ssh/config sensitive
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.claude.json sensitive
```

查看管理状态：
```bash
make status
# 或
~/.dotfiles/scripts/dotfile-manager.sh --status
```

### 5. 卸载配置

```bash
make uninstall
```

## 配置管理

### 📁 包分类说明

#### Sensitive 包（敏感文件）
- **位置**: `stow-packs/sensitive/`
- **Git 跟踪**: ❌ 否
- **用途**: SSH 密钥、API token、本地配置
- **示例**: `.ssh/`, `.gitconfig_local`, `.claude.json`

#### Personal 包（个人配置）
- **位置**: `stow-packs/personal/`
- **Git 跟踪**: ✅ 是
- **用途**: 个人偏好、主题设置
- **示例**: `.Brewfile.apps`, 编辑器主题

#### System 包（系统配置）
- **位置**: `stow-packs/system/`
- **Git 跟踪**: ✅ 是
- **用途**: 系统级配置、基础工具
- **示例**: `.Brewfile`, `.config/starship.toml`

### 🛠️ 文件管理工具

使用 `dotfile-manager.sh` 脚本轻松管理你的配置文件：

```bash
# 查看帮助
~/.dotfiles/scripts/dotfile-manager.sh --help

# 列出未管理的文件
~/.dotfiles/scripts/dotfile-manager.sh --list

# 移动文件到包
~/.dotfiles/scripts/dotfile-manager.sh --move <文件> <类型>

# 获取管理建议
~/.dotfiles/scripts/dotfile-manager.sh --check
```

### ➕ 添加新的配置

1. 确定文件类型（sensitive/personal/system 等）
2. 移动文件到相应的包：
   ```bash
   ~/.dotfiles/scripts/dotfile-manager.sh --move ~/path/to/file type
   ```
3. 验证链接：
   ```bash
   ls -la ~/path/to/file  # 应该显示为符号链接
   ```

### ✏️ 修改现有配置

所有安装的文件都是指向 `stow-packs` 的软链接，你可以：

1. **直接编辑**：修改 `~/.zshrc` 等文件（会自动同步到仓库）
2. **编辑源文件**：修改 `stow-packs/` 下的文件

### 🗑️ 删除某个配置

```bash
cd ~/.dotfiles
stow -D stow-packs/package-name
```

## 📚 文档

### 📖 使用指南 (docs/guides/)
- **[QUICKSTART.md](./docs/guides/QUICKSTART.md)** - 快速开始指南
- **[MIGRATION_GUIDE.md](./docs/guides/MIGRATION_GUIDE.md)** - 完整迁移文档 ⭐

### ⚙️ 配置说明 (docs/config/)
- **[DOTFILES_MANAGEMENT.md](./docs/config/DOTFILES_MANAGEMENT.md)** - 配置管理系统文档
- **[TERMINAL_FONT_CONFIG.md](./docs/config/TERMINAL_FONT_CONFIG.md)** - 终端字体配置指南 ⭐

### 🛠️ 工具文档 (docs/tools/)
- **[MAKEFILE_COMMANDS.md](./docs/tools/MAKEFILE_COMMANDS.md)** - Makefile 命令参考 ⭐
- **[ZSH_CHEATSHEET.md](./docs/tools/ZSH_CHEATSHEET.md)** - Zsh 配置速查表
- **[NVIM_ASTRO_CONFIG.md](./docs/tools/NVIM_ASTRO_CONFIG.md)** - Neovim Astro 配置指南
- **[UV_GUIDE.md](./docs/tools/UV_GUIDE.md)** - Python UV 包管理指南

### 快速命令参考

| 命令 | 说明 | 文档 |
|------|------|------|
| `make help` | 显示所有命令 | [MAKEFILE_COMMANDS.md](./docs/tools/MAKEFILE_COMMANDS.md) |
| `make scan` | 扫描未管理文件 | [MIGRATION_GUIDE.md](./docs/guides/MIGRATION_GUIDE.md) |
| `make migrate` | 交互式迁移 | [MIGRATION_GUIDE.md](./docs/guides/MIGRATION_GUIDE.md) |
| `make list` | 列出已管理文件 | [MAKEFILE_COMMANDS.md](./docs/tools/MAKEFILE_COMMANDS.md) |
| `make add FILE PACKAGE` | 添加文件 | [MAKEFILE_COMMANDS.md](./docs/tools/MAKEFILE_COMMANDS.md) |
| `make clean PACKAGE` | 删除配置 | [MAKEFILE_COMMANDS.md](./docs/tools/MAKEFILE_COMMANDS.md) |
| `make font-config` | 配置终端字体 | [TERMINAL_FONT_CONFIG.md](./docs/config/TERMINAL_FONT_CONFIG.md) |
| `make font-test` | 测试 Nerd Font | [TERMINAL_FONT_CONFIG.md](./docs/config/TERMINAL_FONT_CONFIG.md) |

## 故障排除

### 冲突错误

如果遇到 "conflict" 错误，说明目标位置已存在真实文件。解决方法：

1. **自动备份**（推荐）：
   ```bash
   make install  # 脚本会自动备份冲突文件
   ```

2. **手动处理**：
   ```bash
   # 备份原文件
   mv ~/.config_file ~/.config_file.backup

   # 重新安装
   make install
   ```

### 敏感文件检查

确保没有意外提交敏感文件：

```bash
cd ~/.dotfiles
git status
git ls-files | grep -E 'sensitive/(home|config)/'
```

### 常见问题

**Q: 如何检查哪些文件应该被管理但还没被？**
```bash
~/.dotfiles/scripts/dotfile-manager.sh --check
```

**Q: 如何查看当前管理状态？**
```bash
~/.dotfiles/scripts/dotfile-manager.sh --status
```

**Q: sensitive 包的文件会被提交到 Git 吗？**
不会。`.gitignore` 已经配置为排除这些文件。
