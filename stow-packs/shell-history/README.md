# Shell History Management

这个配置为 shell 历史文件提供了统一的管理方式，使用 stow 进行符号链接管理，同时保护用户隐私。

## 功能特性

- ✅ **统一管理**: 所有 shell 历史文件统一存放在 `stow-packs/shell-history/home/` 目录
- ✅ **隐私保护**: 历史文件被 `.gitignore` 忽略，不会上传到代码仓库
- ✅ **配置管理**: 历史相关的配置可以安全地提交到仓库
- ✅ **自动迁移**: 提供迁移脚本将现有历史文件移动到新结构

## 目录结构

```
stow-packs/shell-history/
├── home/
│   ├── .shell_history_config    # 历史配置文件（可提交）
│   ├── .bash_history           # bash 历史（被 gitignore）
│   ├── .zsh_history           # zsh 历史（被 gitignore）
│   ├── .history               # 通用历史文件（被 gitignore）
│   ├── .histfile              # histfile（被 gitignore）
│   └── README.md              # 说明文档
└── (stow 管理的符号链接目标)
```

## 使用方法

### 1. 首次设置

```bash
# 应用 stow 配置
cd ~/.dotfiles
stow -d stow-packs -t ~ shell-history

# 或者运行迁移脚本（推荐）
./scripts/migrate-history.sh
```

### 2. 迁移现有历史文件

```bash
# 运行迁移脚本
./scripts/migrate-history.sh
```

迁移脚本会：
- 备份现有的历史文件
- 将历史文件复制到 dotfiles 结构中
- 删除原始文件
- 在 shell 配置文件中添加配置源

### 3. 手动管理

如果你想手动管理历史文件：

```bash
# 应用配置
stow -d stow-packs -t ~ shell-history

# 移除配置
stow -d stow-packs -t ~ -D shell-history
```

## 配置说明

`.shell_history_config` 文件包含以下设置：

- `HISTSIZE=10000`: 内存中保存的历史记录数
- `HISTFILESIZE=20000`: 历史文件中保存的记录数
- `HISTCONTROL=ignoredups:erasedups`: 忽略重复命令
- `HISTIGNORE`: 忽略特定命令的历史记录
- `HISTTIMEFORMAT`: 显示历史记录的时间戳
- `setopt share_history`: 在 zsh 中共享历史记录
- `shopt -s histappend`: 在 bash 中追加历史记录

## 隐私保护

所有实际的历史文件都被 `.gitignore` 忽略：

- `.bash_history`
- `.zsh_history`
- `.history`
- `.histfile`
- `.python_history`
- `.irb_history`
- `.node_repl_history`

这意味着：
- 你的命令历史不会泄露到代码仓库
- 配置文件可以安全地分享和同步
- 每个用户的历史文件保持独立

## 注意事项

1. **首次使用**: 建议运行迁移脚本来移动现有的历史文件
2. **重启 shell**: 配置更改后需要重启 shell 或重新加载配置文件
3. **权限**: 确保你对历史文件有适当的读写权限
4. **备份**: 迁移脚本会自动创建备份，以防数据丢失

## 故障排除

### Stow 不工作

```bash
# 检查 stow 状态
stow -d stow-packs -t ~ shell-history -v

# 强制重新应用
stow -d stow-packs -t ~ -D shell-history
stow -d stow-packs -t ~ shell-history
```

### 配置不生效

```bash
# 重新加载配置
source ~/.bashrc    # 对于 bash
source ~/.zshrc    # 对于 zsh

# 或者手动加载配置
source ~/.dotfiles/stow-packs/shell-history/home/.shell_history_config
```

### 历史文件位置问题

如果历史文件没有出现在预期位置，检查：

1. 确认 `HISTFILE` 和 `BASH_HISTFILE` 环境变量设置正确
2. 确认历史文件目录存在且可写
3. 检查 shell 配置文件是否正确加载了配置