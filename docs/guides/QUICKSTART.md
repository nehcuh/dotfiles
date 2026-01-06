# Dotfiles 快速使用指南

## 📌 管理你的敏感文件

你的系统中有以下文件应该被纳入 dotfiles 管理：

### 当前未管理的文件

1. **~/.claude.json** - Claude API 配置
2. **~/.config/gh/** - GitHub CLI 配置（可能包含 token）

### 快速操作

```bash
# 1. 移动 Claude 配置到 sensitive 包
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.claude.json sensitive

# 2. 移动 GitHub CLI 配置到 sensitive 包
~/.dotfiles/scripts/dotfile-manager.sh --move ~/.config/gh sensitive

# 3. 检查状态
~/.dotfiles/scripts/dotfile-manager.sh --status
```

## 📝 包分类说明

### Sensitive 包（敏感信息）
- **Git 跟踪**: ❌ 否
- **用途**: SSH 密钥、API token、本地配置
- **示例**: `.ssh/`, `.claude.json`, `.gitconfig_local`

### Personal 包（个人偏好）
- **Git 跟踪**: ✅ 是
- **用途**: 个人应用列表、主题设置
- **示例**: `.Brewfile.apps`, 编辑器主题

### System 包（系统配置）
- **Git 跟踪**: ✅ 是
- **用途**: 系统级配置、基础工具
- **示例**: `.Brewfile`, `.config/starship.toml`

## 🔧 常用命令

```bash
# 查看管理状态
~/.dotfiles/scripts/dotfile-manager.sh --status

# 列出未管理的文件
~/.dotfiles/scripts/dotfile-manager.sh --list

# 移动文件到包
~/.dotfiles/scripts/dotfile-manager.sh --move <文件路径> <包类型>

# 获取管理建议
~/.dotfiles/scripts/dotfile-manager.sh --check

# 使用 Makefile
make install    # 安装所有包
make status     # 查看 stow 状态
make list       # 列出可用包
```

## ⚠️ 安全提醒

1. **定期检查**: `cd ~/.dotfiles && git status`
2. **敏感文件**: 使用 `sensitive` 包，不会被 git 跟踪
3. **模板文件**: 使用 `.template` 后缀的文件可以安全提交

详细文档：[DOTFILES_MANAGEMENT.md](../config/DOTFILES_MANAGEMENT.md)
