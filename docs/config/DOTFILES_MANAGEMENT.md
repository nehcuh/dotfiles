# Dotfiles 管理指南

这个项目使用 **GNU Stow** 管理你主目录的所有 dot 文件，同时确保 Git 只跟踪配置相关内容，不包含敏感信息。

## 📋 目录

- [架构概述](#架构概述)
- [包分类](#包分类)
- [快速开始](#快速开始)
- [日常使用](#日常使用)
- [安全最佳实践](#安全最佳实践)

## 🏗️ 架构概述

```
.dotfiles/
├── stow-packs/          # 所有配置包（通过 Stow 管理）
│   ├── sensitive/       # 敏感文件（Git 不跟踪）
│   ├── personal/        # 个人配置（Git 跟踪）
│   ├── system/          # 系统配置
│   ├── git/             # Git 配置
│   ├── zsh/             # Zsh 配置
│   ├── tools/           # 开发工具配置
│   ├── nvim/            # Neovim 配置
│   ├── vscode/          # VS Code 配置
│   ├── zed/             # Zed 配置
│   └── macos/           # macOS 特定配置
├── scripts/             # 管理脚本
│   └── dotfile-manager.sh  # 文件管理工具
├── Makefile            # 快捷命令
└── .gitignore          # 确保不跟踪敏感文件
```

## 📦 包分类

### 1. Sensitive 包（敏感文件）

**位置**: `stow-packs/sensitive/`
**Git 跟踪**: ❌ 否
**用途**: 包含敏感信息的文件

包含内容：
- SSH 密钥和配置 (`.ssh/`)
- Git 本地配置 (`.gitconfig_local`)
- Zsh 本地配置 (`.zshrc.local`)
- API 密钥 (`.claude.json`, `.config/gh/`)
- 其他凭证 (`.aws/credentials`)

### 2. Personal 包（个人配置）

**位置**: `stow-packs/personal/`
**Git 跟踪**: ✅ 是
**用途**: 个人偏好设置，非敏感

包含内容：
- 个人应用列表 (`.Brewfile.apps`)
- 编辑器个人设置
- 主题和外观配置

### 3. System 包（系统配置）

**位置**: `stow-packs/system/`
**Git 跟踪**: ✅ 是
**用途**: 系统级配置

包含内容：
- Homebrew 配置 (`.Brewfile`)
- Shell 提示符 (`.config/starship.toml`)

### 4. 其他配置包

- **git**: Git 全局配置
- **zsh**: Zsh shell 配置和插件
- **tools**: 开发工具配置
- **nvim**: Neovim 编辑器配置
- **vscode/zed**: IDE 配置

## 🚀 快速开始

### 1. 初始安装

```bash
# 克隆仓库
git clone <your-repo> ~/.dotfiles

# 运行安装
cd ~/.dotfiles
make install
```

### 2. 设置敏感文件

```bash
# 复制模板文件
cp ~/.gitconfig_local.template ~/.gitconfig_local
cp ~/.zshrc.local.template ~/.zshrc.local

# 编辑配置文件
vim ~/.gitconfig_local
vim ~/.zshrc.local

# 移动到 sensitive 包
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.gitconfig_local sensitive
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.zshrc.local sensitive
```

### 3. 设置 SSH 密钥（可选）

```bash
# 如果你有现有的 SSH 密钥
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.ssh/config sensitive

# 如果你有 .ssh 目录中的其他文件
mv ~/.ssh/id_ed25519 ~/.dotfiles/stow-packs/sensitive/home/.ssh/

# 重新链接 sensitive 包
cd ~/.dotfiles
stow -R stow-packs/sensitive
```

## 📚 日常使用

### 查看未管理的文件

```bash
~/.dotfiles/scripts/dotfile-manager.sh --list
```

### 移动文件到相应的包

```bash
# 移动敏感文件
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.claude.json sensitive

# 移动个人配置
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.Brewfile.apps personal

# 移动 Git 配置
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.gitconfig_global git
```

### 查看管理状态

```bash
~/.dotfiles/scripts/dotfile-manager.sh --status
```

### 获取管理建议

```bash
~/.dotfiles/scripts/dotfile-manager.sh --check
```

### 添加新的配置文件

当你想添加一个新的配置文件到 dotfiles 管理：

1. **确定文件类型**（sensitive/personal/system 等）
2. **移动文件**：
   ```bash
   ~/.dotfiles/scripts/dotfile-manager.sh --move ~/path/to/file type
   ```
3. **验证链接**：
   ```bash
   ls -la ~/path/to/file  # 应该显示为符号链接
   ```

### 使用 Makefile 快捷命令

```bash
# 列出所有可用的 make 命令
make help

# 安装所有包
make install

# 查看状态
make status

# 列出可用包
make list
```

## 🔒 安全最佳实践

### 1. 定期检查 Git 状态

```bash
cd ~/.dotfiles
git status
```

确保没有意外提交敏感文件。如果看到 `stow-packs/sensitive/` 下的文件被跟踪，立即检查 `.gitignore`。

### 2. 使用模板文件

对于需要本地配置的文件，提供 `.template` 后缀的模板：

```bash
# 用户复制模板
cp ~/.gitconfig_local.template ~/.gitconfig_local

# 编辑实际文件
vim ~/.gitconfig_local

# 移动到 sensitive 包
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.gitconfig_local sensitive
```

### 3. .gitignore 规则

项目的主 `.gitignore` 已经配置为排除：
- `stow-packs/sensitive/` 下的所有文件
- `*.local` 和 `*.personal` 文件
- SSH 密钥 (`.ssh/id_*`)
- 各种历史和缓存文件

### 4. 敏感文件检查

如果你想检查是否有敏感文件被意外跟踪：

```bash
cd ~/.dotfiles

# 检查是否有 SSH 密钥被跟踪
git ls-files | grep -E '\.ssh/id_'

# 检查是否有 .local 文件被跟踪
git ls-files | grep -E '\.local$'

# 检查 sensitive 包是否有文件被跟踪
git ls-files stow-packs/sensitive/
```

### 5. 使用 pre-commit hook（可选）

在 `.git/hooks/pre-commit` 添加检查：

```bash
#!/bin/bash
# 检查是否意外添加了敏感文件

if git diff --cached --name-only | grep -E 'stow-packs/sensitive/(home|config)/'; then
    echo "警告：你正在尝试提交 sensitive 包中的文件！"
    echo "这些文件可能包含敏感信息。"
    echo "如果确实要提交，请使用 --no-verify 跳过此检查。"
    exit 1
fi
```

## 📖 工作流示例

### 场景 1：在新机器上设置

```bash
# 1. 克隆仓库
git clone <your-repo> ~/.dotfiles
cd ~/.dotfiles

# 2. 运行安装
make install

# 3. 设置敏感文件
cp ~/.gitconfig_local.template ~/.gitconfig_local
vim ~/.gitconfig_local  # 添加你的名字和邮箱

~/.dotfiles/scripts/dotfile-manager.sh --move ~/.gitconfig_local sensitive

# 4. 设置 SSH
mkdir -p ~/.dotfiles/stow-packs/sensitive/home/.ssh
cp /path/to/your/ssh/key ~/.dotfiles/stow-packs/sensitive/home/.ssh/id_ed25519
chmod 600 ~/.dotfiles/stow-packs/sensitive/home/.ssh/id_ed25519

cd ~/.dotfiles
stow -R stow-packs/sensitive

# 5. 检查状态
~/.dotfiles/scripts/dotfile-manager.sh --status
```

### 场景 2：添加新的应用配置

假设你想管理 `.tigrc` (tig 配置):

```bash
# 1. 查看文件分类建议
~/.dotfiles/scripts/dotfile-manager.sh --check

# 2. 如果包含敏感信息，移动到 sensitive
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.tigrc sensitive

# 或者如果是普通配置，移动到 tools
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.tigrc tools
```

### 场景 3：更新配置并提交

```bash
# 1. 编辑配置（通过符号链接）
vim ~/.config/starship.toml

# 2. 测试配置是否正常
starship explain

# 3. 提交到 git
cd ~/.dotfiles
git add stow-packs/system/.config/starship.toml
git commit -m "feat: 更新 starship 配置"
git push
```

## 🎯 最佳实践总结

1. **明确分类**：在添加文件前，明确它应该属于哪个包
2. **敏感优先**：如果不确定文件类型，优先选择 `sensitive` 包
3. **使用模板**：为需要本地配置的文件提供 `.template` 文件
4. **定期检查**：使用 `dotfile-manager.sh --status` 定期检查管理状态
5. **Git 警惕**：提交前检查 `git status`，确保没有敏感文件
6. **文档更新**：添加新包时，记得更新 README

## 🆘 常见问题

### Q: 我不小心把敏感文件提交到 Git 了怎么办？

A: 立即从历史中删除：
```bash
# 从 git 历史中删除文件
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch stow-packs/sensitive/home/.ssh/id_rsa" \
  --prune-empty --tag-name-filter cat -- --all

# 强制推送（如果已经推送到远程）
git push origin --force --all
```

### Q: 如何在多台机器间同步配置？

A:
1. `sensitive` 和 `personal` 包中的文件会被 git 同步（sensitive 包的内容实际上不会被跟踪）
2. 对于敏感文件，使用安全的方式传输（如 USB、加密邮件）
3. 或者使用密码管理器存储敏感信息

### Q: 有些文件我不想管理怎么办？

A: 将它们添加到 `.gitignore`，或者不要移动到任何 stow 包中。

## 📝 总结

这个系统让你能够：
- ✅ 管理主目录的所有 dot 文件
- ✅ 通过 Git 同步配置
- ✅ 保护敏感信息安全
- ✅ 轻松地在多台机器间同步
- ✅ 快速恢复开发环境

记住：**配置文件可以共享，敏感信息必须保密**。
