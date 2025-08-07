# User Home Directory Management

这个包提供了完整的用户主目录文件管理方案，包括配置文件、历史文件、缓存文件等的统一管理。

## 📁 目录结构

```
stow-packs/user-home/
├── home/
│   ├── config/          # 配置文件（可提交到 git）
│   │   ├── .bashrc
│   │   ├── .bash_profile
│   │   ├── .bash_logout
│   │   ├── .profile
│   │   └── .pythonrc
│   ├── history/         # 历史文件（被 git 忽略）
│   │   ├── .bash_history
│   │   ├── .zsh_history
│   │   ├── .history
│   │   ├── .histfile
│   │   ├── .python_history
│   │   ├── .node_repl_history
│   │   └── .irb_history
│   ├── cache/           # 缓存文件（被 git 忽略）
│   │   ├── .zcompdump*
│   │   ├── .z
│   │   ├── .sudo_as_admin_successful
│   │   ├── .lesshst
│   │   └── .wget-hsts
│   ├── appdata/         # 应用数据（被 git 忽略）
│   └── system/          # 系统文件（被 git 忽略）
└── README.md           # 本文档
```

## 🚀 快速开始

### 1. 首次设置

```bash
# 运行迁移脚本（推荐）
./scripts/migrate-user-home.sh

# 或手动应用配置
cd ~/.dotfiles
stow -d stow-packs -t ~ user-home
```

### 2. 管理配置

```bash
# 查看状态
./scripts/manage-user-home.sh status

# 应用配置
./scripts/manage-user-home.sh install

# 清理缓存
./scripts/manage-user-home.sh clean

# 创建备份
./scripts/manage-user-home.sh backup
```

## 📋 文件分类

### 🔧 配置文件（可提交）
- **Shell 配置**: `.bashrc`, `.bash_profile`, `.bash_logout`, `.profile`
- **Python 配置**: `.pythonrc`
- **环境配置**: 各种环境变量和启动脚本

### 📊 历史文件（隐私保护）
- **Shell 历史**: `.bash_history`, `.zsh_history`, `.history`, `.histfile`
- **应用历史**: `.python_history`, `.node_repl_history`, `.irb_history`
- **目录历史**: `.z` (z 插件历史)

### 🗂️ 缓存文件（隐私保护）
- **Shell 缓存**: `.zcompdump*` (Zsh 补全缓存)
- **系统缓存**: `.sudo_as_admin_successful`, `.lesshst`, `.wget-hsts`
- **应用缓存**: `.fzf_history` 等

### 🔐 敏感文件（完全忽略）
- **密钥文件**: `.ssh/`, `.gnupg/`, `.aws/`, `.azure/`
- **应用数据**: `.local/`, `.cache/`, `.config/` 中的敏感文件
- **本地配置**: `*.local` 文件

## 🛡️ 隐私保护

### Git 忽略策略
- ✅ **配置文件**: 可以安全提交到仓库
- ❌ **历史文件**: 完全忽略，保护隐私
- ❌ **缓存文件**: 完全忽略，避免垃圾数据
- ❌ **敏感数据**: 完全忽略，保护安全

### 环境隔离
- 每个用户的文件保持独立
- 本地配置通过 `.local` 文件管理
- 敏感数据完全不会上传

## 🔧 管理脚本

### 迁移脚本 (`migrate-user-home.sh`)
- 自动备份现有文件
- 智能迁移文件到新结构
- 设置环境变量
- 应用 stow 配置

### 管理脚本 (`manage-user-home.sh`)
- `status`: 查看当前状态
- `install`: 应用配置
- `remove`: 移除配置
- `clean`: 清理缓存
- `backup`: 创建备份
- `restore`: 恢复备份

## 📝 使用示例

### 查看当前状态
```bash
./scripts/manage-user-home.sh status
```

输出示例：
```
User Home Directory Status

Configuration directory:  /Users/huchen/.dotfiles/stow-packs/user-home

Stow status:
✓ Configuration is properly applied

File status:
Configuration files:
  ✓ .bashrc -> symlinked
  ✓ .bash_profile -> symlinked
  ✓ .profile -> symlinked
  ⚠ .zshrc -> external symlink

History files:
  ✓ .bash_history -> exists (128K)
  ✓ .zsh_history -> exists (256K)
  ○ .history -> not found
```

### 清理缓存
```bash
./scripts/manage-user-home.sh clean
```

### 创建备份
```bash
./scripts/manage-user-home.sh backup
```

## ⚠️ 注意事项

1. **首次使用**: 强烈建议运行迁移脚本
2. **备份数据**: 迁移脚本会自动创建备份
3. **重启 shell**: 配置更改后需要重启 shell
4. **权限问题**: 确保对相关文件有适当权限
5. **本地配置**: 使用 `.local` 文件进行本地定制

## 🔧 故障排除

### Stow 配置问题
```bash
# 重新应用配置
stow -d stow-packs -t ~ -D user-home
stow -d stow-packs -t ~ user-home

# 检查冲突
stow -d stow-packs -t ~ user-home -v
```

### 配置不生效
```bash
# 重新加载配置
source ~/.bashrc    # bash
source ~/.zshrc    # zsh

# 检查环境变量
echo $HISTSIZE
echo $HISTFILE
```

### 权限问题
```bash
# 修复权限
chmod 644 ~/.bashrc ~/.bash_profile ~/.profile
chmod 600 ~/.bash_history ~/.zsh_history
```

## 🎯 优势

- **整洁的主目录**: 所有文件都有固定的位置
- **隐私保护**: 敏感文件不会被上传到 GitHub
- **配置管理**: 配置文件可以版本控制和分享
- **自动化**: 提供完整的管理脚本
- **跨平台**: 支持 Linux、macOS 和 Windows
- **备份支持**: 自动备份和恢复功能

## 🔄 更新和维护

- 定期运行 `./scripts/manage-user-home.sh clean` 清理缓存
- 使用 `./scripts/manage-user-home.sh backup` 定期备份
- 更新配置后重新应用 stow 配置
- 定期检查 `.gitignore` 规则是否完整