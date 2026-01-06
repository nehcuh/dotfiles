# Dotfiles 迁移指南

本文档介绍如何使用迁移工具统一管理外部应用创建的配置文件。

## 📋 目录

- [快速开始](#快速开始)
- [工具使用](#工具使用)
- [应用分类](#应用分类)
- [工作流示例](#工作流示例)
- [常见问题](#常见问题)

## 🚀 快速开始

### 1. 扫描未管理的文件

```bash
~/.dotfiles/scripts/dotfile-migrate.sh scan
```

这个命令会扫描你的主目录，显示所有未被 dotfiles 管理的配置文件。

**示例输出**：
```
▶ 扫描主目录中的配置文件...

发现以下未管理的配置文件:
══════════════════════════════════════════════════════════════

▸ .claude.json
  类型: sensitive
  说明: Claude AI 配置（包含 API 密钥）

▸ .config/gh/
  类型: sensitive
  说明: GitHub CLI 配置（包含认证 token）

▸ .config/git/
  类型: git
  说明: Git 配置

══════════════════════════════════════════════════════════════
```

### 2. 选择迁移方式

#### 方式一：交互式迁移（推荐）

逐个选择要迁移的文件：

```bash
~/.dotfiles/scripts/dotfile-migrate.sh migrate
```

#### 方式二：自动迁移

一次性迁移所有识别的文件：

```bash
# 预览模式（不实际执行）
~/.dotfiles/scripts/dotfile-migrate.sh auto --dry-run

# 实际执行
~/.dotfiles/scripts/dotfile-migrate.sh auto -y
```

### 3. 验证迁移结果

```bash
~/.dotfiles/scripts/dotfile-migrate.sh status
```

## 🛠️ 工具使用

### 命令参考

```bash
~/.dotfiles/scripts/dotfile-migrate.sh [命令] [选项]
```

#### 命令

| 命令 | 说明 |
|------|------|
| `scan` | 扫描主目录中未管理的配置文件 |
| `migrate` | 交互式迁移文件 |
| `auto` | 自动迁移所有识别的文件 |
| `status` | 显示迁移状态 |
| `--help` | 显示帮助信息 |

#### 选项

| 选项 | 说明 |
|------|------|
| `-d, --dry-run` | 预览操作但不执行 |
| `-y, --yes` | 自动确认所有提示 |
| `-f, --force` | 强制覆盖已存在的文件 |
| `-b, --backup` | 迁移前自动备份 |

### 示例

```bash
# 扫描未管理的文件
~/.dotfiles/scripts/dotfile-migrate.sh scan

# 交互式迁移
~/.dotfiles/scripts/dotfile-migrate.sh migrate

# 自动迁移预览
~/.dotfiles/scripts/dotfile-migrate.sh auto --dry-run

# 自动迁移（实际执行）
~/.dotfiles/scripts/dotfile-migrate.sh auto -y

# 查看状态
~/.dotfiles/scripts/dotfile-migrate.sh status
```

## 📦 应用分类

迁移工具会自动将配置文件分类到相应的包：

### Sensitive（敏感文件）

**包含内容**：
- API 密钥和 token
- 认证凭证
- SSH 密钥
- 本地配置

**示例应用**：
- `.claude.json` - Claude AI 配置
- `.config/gh/` - GitHub CLI 配置
- `.ssh/` - SSH 密钥
- `.aws/` - AWS 配置

**Git 跟踪**：❌ 否

### Personal（个人配置）

**包含内容**：
- 个人偏好设置
- 主题配置
- 应用列表

**示例应用**：
- `.alma/` - Alma 期刊管理器
- `.config/iterm2/` - iTerm2 配置
- `.Brewfile.apps` - 个人应用列表

**Git 跟踪**：✅ 是

### Git（版本控制）

**包含内容**：
- Git 配置
- Git 相关工具

**示例应用**：
- `.config/git/` - Git 配置
- `.config/tig/` - Tig 配置

**Git 跟踪**：✅ 是

### System（系统配置）

**包含内容**：
- 系统级配置
- Shell 工具

**示例应用**：
- `.config/starship` - Starship 提示符
- `.config/systemd/` - Systemd 配置

**Git 跟踪**：✅ 是

### Tools（开发工具）

**包含内容**：
- 编辑器配置
- 开发工具设置

**示例应用**：
- `.config/nvim/` - Neovim 配置
- `.config/vim/` - Vim 配置
- `.docker/` - Docker 配置

**Git 跟踪**：✅ 是

## 💼 工作流示例

### 场景 1：首次设置迁移系统

```bash
# 1. 扫描可迁移的文件
~/.dotfiles/scripts/dotfile-migrate.sh scan

# 2. 查看有哪些文件
# 输出会显示所有未管理的配置文件

# 3. 选择迁移方式
# 对于重要文件，使用交互式迁移
~/.dotfiles/scripts/dotfile-migrate.sh migrate

# 4. 验证结果
~/.dotfiles/scripts/dotfile-migrate.sh status
```

### 场景 2：迁移特定应用

假设你想迁移 `.alma` 目录（Alma 期刊管理器）：

```bash
# 1. 先扫描查看
~/.dotfiles/scripts/dotfile-migrate.sh scan | grep alma

# 2. 使用 dotfile-manager 手动迁移
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.alma personal

# 3. 验证
ls -la ~/.alma  # 应该显示为符号链接
```

### 场景 3：批量迁移安全文件

如果你想一次性迁移所有非敏感的配置：

```bash
# 1. 预览
~/.dotfiles/scripts/dotfile-migrate.sh auto --dry-run

# 2. 确认后执行
~/.dotfiles/scripts/dotfile-migrate.sh auto -y
```

### 场景 4：添加新的应用分类

如果工具有没有识别的应用：

1. **编辑脚本添加分类**：
   ```bash
   vim ~/.dotfiles/scripts/dotfile-migrate.sh
   ```

2. **在相应的分类数组中添加**：
   ```bash
   SENSITIVE_APPS=(
       ".your-app"        # 添加这一行
       # ... 其他应用
   )
   ```

3. **重新扫描**：
   ```bash
   ~/.dotfiles/scripts/dotfile-migrate.sh scan
   ```

## 🔍 深入了解

### 迁移过程

当你选择迁移一个文件时，工具会：

1. **移动文件**：将文件从主目录移动到相应的 stow 包
2. **创建符号链接**：使用 GNU Stow 重新链接包
3. **验证链接**：确保符号链接正确创建

### 示例：迁移 .claude.json

```bash
# 原始位置
~/.claude.json

# 迁移后位置
~/.dotfiles/stow-packs/sensitive/home/.claude.json

# 符号链接
~/.claude.json -> ~/.dotfiles/stow-packs/sensitive/home/.claude.json
```

### 文件路径映射

| 原始位置 | 迁移后位置 |
|---------|----------|
| `~/.claude.json` | `stow-packs/sensitive/home/.claude.json` |
| `~/.config/gh/` | `stow-packs/sensitive/config/gh/` |
| `~/.alma` | `stow-packs/personal/home/.alma` |
| `~/.config/git/` | `stow-packs/git/config/git/` |

### 安全机制

1. **默认敏感**：未识别的文件默认分类为 `sensitive`
2. **备份保护**：迁移前建议备份
3. **符号链接验证**：迁移后验证链接是否正确
4. **Git 保护**：sensitive 包不会被 git 跟踪

## ❓ 常见问题

### Q: 迁移会删除原文件吗？

A: 是的，迁移会移动文件到 stow 包，但会创建符号链接指向原位置，所以你仍然可以通过原来的路径访问。

### Q: 如何撤销迁移？

```bash
# 1. 删除符号链接
rm ~/.your-file

# 2. 从 stow 包移回文件
mv ~/.dotfiles/stow-packs/category/home/.your-file ~/

# 3. 重新 stow
cd ~/.dotfiles
stow -R stow-packs/category
```

### Q: 某个文件分类错了怎么办？

```bash
# 1. 移动到正确的包
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.your-file correct-category

# 或手动移动
mv ~/.dotfiles/stow-packs/wrong-category/.your-file \
   ~/.dotfiles/stow-packs/correct-category/home/

# 2. 重新 stow
cd ~/.dotfiles
stow -D stow-packs/wrong-category
stow -R stow-packs/correct-category
```

### Q: 如何跳过某些文件？

A: 在交互式迁移时选择 `n`（否）或 `s`（跳过所有）。

### Q: 迁移后应用还能正常工作吗？

A: 是的，因为迁移后创建了符号链接，应用不会感知到任何变化。

### Q: 敏感文件会被提交到 Git 吗？

A: 不会。`sensitive` 包的文件已被 `.gitignore` 排除。

### Q: 如何添加新的应用识别规则？

编辑 `~/.dotfiles/scripts/dotfile-migrate.sh`，在相应的分类数组中添加：

```bash
SENSITIVE_APPS=(
    ".your-new-app"      # 添加这一行
    # ... 现有应用
)
```

## 📚 相关文档

- **[DOTFILES_MANAGEMENT.md](./DOTFILES_MANAGEMENT.md)** - 完整的 dotfiles 管理文档
- **[QUICKSTART.md](./QUICKSTART.md)** - 快速使用指南
- **[README.md](./README.md)** - 项目总览

## 🎯 最佳实践

1. **先扫描再迁移**：使用 `scan` 命令了解有哪些文件
2. **交互式迁移重要文件**：使用 `migrate` 命令逐个确认
3. **批量迁移非敏感文件**：使用 `auto` 命令处理个人配置
4. **定期检查状态**：使用 `status` 命令查看管理状态
5. **验证符号链接**：迁移后使用 `ls -la` 确认链接正确
6. **备份数据**：迁移前备份重要配置

## 🔒 安全提醒

- ⚠️ 迁移前备份重要配置
- ✅ 验证 `.gitignore` 正确排除敏感文件
- 🔍 定期运行 `git status` 检查是否有敏感文件被跟踪
- 📝 对于包含 API 密钥的文件，确保它们被分类为 `sensitive`

---

迁移工具让你能够轻松地将所有外部应用的配置统一管理，同时确保敏感信息的安全！
