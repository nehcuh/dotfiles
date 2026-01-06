# Makefile 命令参考

本文档提供所有 Makefile 命令的详细参考。

## 📋 目录

- [基本操作](#基本操作)
- [文件迁移](#文件迁移)
- [文件管理](#文件管理)
- [文档和帮助](#文档和帮助)
- [开发和维护](#开发和维护)
- [常用工作流](#常用工作流)

---

## 基本操作

### `make help`
显示帮助信息和所有可用命令。

```bash
make help
```

### `make install`
安装所有配置包。

```bash
make install
```

**作用**：
- 检查系统依赖
- 安装默认配置包（system, zsh, git, tools 等）
- 创建符号链接到主目录
- 跳过 Brewfile 安装（在非交互式环境）

**提示**：使用 `SKIP_BREWFILE=true make install` 跳过 Brewfile

### `make uninstall`
卸载所有配置包。

```bash
make uninstall
```

**作用**：
- 删除所有符号链接
- 保留配置文件在仓库中

### `make update`
更新仓库到最新版本。

```bash
make update
```

**作用**：
- `git pull` 最新代码
- 显示更新状态

### `make status`
查看当前管理状态。

```bash
make status
```

**输出**：
- 已链接的文件列表
- 各包的链接状态（✓ linked / ○ not linked）

---

## 文件迁移

### `make scan`
扫描未管理的配置文件。

```bash
make scan
```

**输出示例**：
```
▸ .claude.json
  类型: sensitive
  说明: Claude AI 配置（包含 API 密钥）

▸ .config/gh/
  类型: sensitive
  说明: GitHub CLI 配置（包含认证 token）
```

**用途**：查看哪些配置文件还没有被管理

### `make migrate`
交互式迁移配置文件。

```bash
make migrate
```

**流程**：
1. 显示每个文件的详细信息
2. 询问是否迁移
3. 移动文件到相应的包
4. 重新链接包
5. 验证链接

**交互选项**：
- `Y` - 迁移文件
- `n` - 跳过文件
- `s` - 跳过剩余所有文件
- `q` - 退出

### `make auto-migrate`
自动迁移所有识别的文件。

```bash
make auto-migrate
```

**作用**：
- 自动迁移所有可识别的文件
- 无需确认
- 适合批量操作

**提示**：先运行 `make scan` 查看哪些文件会被迁移

### `make list-unmanaged`
列出未管理的文件（简化版）。

```bash
make list-unmanaged
```

**用途**：快速查看未管理文件列表

---

## 文件管理

### `make list`
列出已管理的配置文件。

```bash
make list
```

**输出示例**：
```
Linked files:
  ✓ .zshrc → zsh
  ✓ .gitconfig_global → git
  ✓ .Brewfile → system

Linked directories (.config):
  ✓ .config/zsh → zsh
  ✓ .config/starship.toml → system

Available packages:
  git (7 files)
  zsh (11 files)
  system (2 files)
```

### `make add FILE=~/.path/to/file PACKAGE=sensitive`
添加文件到指定包。

```bash
# 添加 Claude 配置到 sensitive 包
make add FILE=~/.claude.json PACKAGE=sensitive

# 添加 Git 配置到 git 包
make add FILE=~/.config/git PACKAGE=git

# 添加个人配置到 personal 包
make add FILE=~/.alma PACKAGE=personal
```

**可用包**：
- `sensitive` - 敏感文件（不会被 git 跟踪）
- `personal` - 个人配置
- `system` - 系统配置
- `git` - Git 配置
- `zsh` - Zsh 配置
- `tools` - 开发工具
- `nvim` - Neovim 配置
- `vscode` - VS Code 配置
- `zed` - Zed 配置
- `tmux` - Tmux 配置

**作用**：
1. 移动文件到指定包
2. 重新链接包
3. 验证符号链接

### `make check FILE=~/.path/to/file`
检查文件管理状态。

```bash
make check FILE=~/.zshrc
make check FILE=~/.claude.json
make check FILE=~/.config/gh
```

**输出示例**：
```
Checking file: ~/.zshrc

  Type: Symbolic link
  Target: .dotfiles/stow-packs/zsh/.zshrc
  Status: Managed by dotfiles
```

**状态说明**：
- **Symbolic link** - 符号链接
- **Regular file** - 普通文件（未管理）
- **Directory** - 目录（未管理）
- **Managed by dotfiles** - 已被管理
- **External symlink** - 外部符号链接
- **Not managed** - 未管理

### `make clean PACKAGE=sensitive`
删除指定包的配置。

```bash
make clean PACKAGE=sensitive
make clean PACKAGE=git
make clean PACKAGE=zsh
```

**流程**：
1. 显示将要删除的文件列表
2. 询问确认
3. 删除符号链接（保留文件在仓库中）

**注意**：
- 只删除符号链接
- 不会删除仓库中的文件
- 可以重新使用 `make install` 恢复

---

## 文档和帮助

### `make docs`
查看所有可用文档。

```bash
make docs
```

**输出**：
```
Quick Start:
  QUICKSTART.md              - 快速开始指南
  QUICKSTART_MIGRATION.md    - 快速迁移指南

Complete Guides:
  README.md                  - 项目总览
  MIGRATION_GUIDE.md         - 完整迁移文档
  DOTFILES_MANAGEMENT.md     - 配置管理文档

Specific Topics:
  ZSH_CHEATSHEET.md          - Zsh 配置说明
  NVIM_ASTRO_CONFIG.md       - Neovim 配置
  UV_GUIDE.md                - Python UV 指南
```

### `make read-doc DOC=README.md`
阅读指定文档。

```bash
make read-doc DOC=README.md
make read-doc DOC=MIGRATION_GUIDE.md
make read-doc DOC=QUICKSTART.md
```

**说明**：
- 如果安装了 `bat`，使用语法高亮显示
- 否则使用 `cat` 显示

---

## 开发和维护

### `make test`
运行系统测试。

```bash
make test
```

**检查项**：
- GNU Stow 是否安装
- 包结构是否正确
- Git 状态

### `make backup`
创建配置文件备份。

```bash
make backup
```

**作用**：
- 备份主目录的所有 dot 文件
- 创建带时间戳的备份目录

**输出示例**：
```
✓ Backup created: 20240105_143022_dotfiles_backup
```

### `make doctor`
运行诊断检查。

```bash
make doctor
```

**输出信息**：
- 系统信息（OS、Shell）
- 必需工具状态（stow、git）
- 包管理状态
- Git 状态

**用途**：排查问题时使用

---

## 常用工作流

### 工作流 1：首次设置

```bash
# 1. 安装所有配置
make install

# 2. 扫描未管理的文件
make scan

# 3. 迁移文件（如需要）
make migrate

# 4. 检查状态
make status

# 5. 查看已管理的文件
make list
```

### 工作流 2：添加新配置

```bash
# 1. 检查文件状态
make check FILE=~/.new-config

# 2. 添加到相应的包
make add FILE=~/.new-config PACKAGE=sensitive

# 3. 验证
make check FILE=~/.new-config
```

### 工作流 3：定期维护

```bash
# 1. 更新仓库
make update

# 2. 检查未管理的文件
make scan

# 3. 迁移新文件
make migrate

# 4. 查看状态
make doctor
```

### 工作流 4：清理配置

```bash
# 1. 查看已管理的文件
make list

# 2. 删除不需要的包
make clean PACKAGE=sensitive

# 3. 重新安装
make install
```

### 工作流 5：故障排除

```bash
# 1. 运行诊断
make doctor

# 2. 检查特定文件
make check FILE=~/.problematic-file

# 3. 查看文档
make docs

# 4. 重新安装
make uninstall
make install
```

---

## 命令速查表

| 命令 | 说明 |
|------|------|
| `make help` | 显示帮助 |
| `make install` | 安装所有配置 |
| `make uninstall` | 卸载所有配置 |
| `make update` | 更新仓库 |
| `make status` | 查看状态 |
| `make scan` | 扫描未管理文件 |
| `make migrate` | 交互式迁移 |
| `make auto-migrate` | 自动迁移 |
| `make list` | 列出已管理文件 |
| `make add FILE=~/.x PACKAGE=y` | 添加文件 |
| `make check FILE=~/.x` | 检查文件 |
| `make clean PACKAGE=x` | 删除包配置 |
| `make docs` | 查看文档 |
| `make doctor` | 诊断检查 |
| `make backup` | 创建备份 |

---

## 包分类参考

| 包 | Git 跟踪 | 用途 | 示例 |
|---|---|---|---|
| `sensitive` | ❌ 否 | 敏感信息 | API 密钥、token、SSH |
| `personal` | ✅ 是 | 个人偏好 | 主题、应用列表 |
| `system` | ✅ 是 | 系统配置 | Brewfile、Starship |
| `git` | ✅ 是 | Git 配置 | .gitconfig、.gitignore |
| `zsh` | ✅ 是 | Shell 配置 | .zshrc、.zshenv |
| `tools` | ✅ 是 | 开发工具 | npm、pip、cargo |
| `nvim` | ✅ 是 | Neovim | nvim 配置 |
| `vscode` | ✅ 是 | VS Code | settings.json |
| `zed` | ✅ 是 | Zed | zed 配置 |
| `tmux` | ✅ 是 | Tmux | .tmux.conf |

---

## 提示和技巧

### 1. 安全第一

- 在添加文件前，先检查：`make check FILE=~/.file`
- 确认敏感文件放在 `sensitive` 包中
- 定期运行 `git status` 确保没有意外提交敏感文件

### 2. 批量操作

- 使用 `make scan` 查看所有未管理文件
- 使用 `make auto-migrate` 批量迁移
- 使用 `make clean` 批量删除包配置

### 3. 调试问题

- 使用 `make doctor` 诊断问题
- 使用 `make status` 查看链接状态
- 使用 `make check FILE=~/.file` 检查特定文件

### 4. 备份和恢复

- 重要操作前运行 `make backup`
- 备份创建在当前目录
- 可以手动恢复备份文件

### 5. 学习使用

- 不确定命令时运行 `make help`
- 查看文档：`make docs`
- 阅读特定文档：`make read-doc DOC=README.md`

---

## 相关文档

- **[README.md](./README.md)** - 项目总览
- **[QUICKSTART.md](./QUICKSTART.md)** - 快速开始
- **[MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)** - 迁移指南
- **[DOTFILES_MANAGEMENT.md](./DOTFILES_MANAGEMENT.md)** - 管理文档
