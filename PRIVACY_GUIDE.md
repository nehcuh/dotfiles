# 隐私保护使用指南

## 概述

本指南介绍了如何使用 dotfiles 中的隐私保护包来保护您的数字隐私。所有隐私保护包都遵循统一的设计模式，将敏感数据与配置数据分离管理。

## 可用的隐私保护包

### 1. Shell History Management
- **包名**: `shell-history`
- **功能**: 统一管理 shell 历史文件
- **适用**: bash, zsh, fish 等所有 shell

### 2. VS Code Privacy Protection
- **包名**: `vscode-privacy`
- **功能**: 禁用遥测、自动更新、在线功能
- **适用**: Visual Studio Code

### 3. Zed Editor Privacy Protection
- **包名**: `zed-privacy`
- **功能**: 禁用遥测、自动更新、协作功能
- **适用**: Zed Editor

### 4. Neovim Privacy Protection
- **包名**: `nvim-privacy`
- **功能**: 禁用在线功能、插件遥测、文件监视器
- **适用**: Neovim

### 5. Vim Privacy Protection
- **包名**: `vim-privacy`
- **功能**: 禁用 Netrw、在线功能、自动更新
- **适用**: Vim

### 6. Privacy Template (通用模板)
- **包名**: `privacy-template`
- **功能**: 为其他软件提供隐私保护模板
- **适用**: 任何需要隐私保护的软件

## 快速开始

### 1. 应用隐私保护配置

```bash
# 进入 dotfiles 目录
cd ~/.dotfiles

# 应用所有隐私保护配置
stow -d stow-packs -t ~ shell-history
stow -d stow-packs -t ~ vscode-privacy
stow -d stow-packs -t ~ zed-privacy
stow -d stow-packs -t ~ nvim-privacy
stow -d stow-packs -t ~ vim-privacy
```

### 2. 运行迁移脚本

```bash
# 运行 shell 历史迁移
./scripts/migrate-history.sh

# 运行 VS Code 隐私迁移
./scripts/migrate-vscode-privacy.sh

# 运行 Zed 隐私迁移
./scripts/migrate-zed-privacy.sh

# 运行 Neovim 隐私迁移
./scripts/migrate-nvim-privacy.sh

# 运行 Vim 隐私迁移
./scripts/migrate-vim-privacy.sh
```

### 3. 重启相关软件

```bash
# 重启 shell
exec $SHELL

# 重启编辑器
# 根据您使用的编辑器重启
```

## 详细使用说明

### Shell History Management

#### 配置文件
- `~/.bashrc` 或 `~/.zshrc`: 包含历史文件设置
- `~/.history/`: 历史文件存储目录
- `~/.config/histfile/`: 配置文件目录

#### 可用命令
```bash
# 查看历史设置
history_settings

# 清理历史文件
clean_history

# 备份历史文件
backup_history

# 恢复历史文件
restore_history
```

#### 环境变量
```bash
export HISTFILE="$HOME/.history/bash_history"
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL="ignoredups:ignorespace"
export HISTIGNORE="ls:cd:pwd:clear:history"
```

### VS Code Privacy Protection

#### 配置文件
- `~/.config/Code/User/settings.json`: VS Code 设置
- `~/.vscode-privacy/`: 隐私配置目录

#### 可用命令
```bash
# 安全模式启动 VS Code
code-safe

# 私有模式启动 VS Code
code-private

# 离线模式启动 VS Code
code-offline

# 清理 VS Code 缓存
vscode_clean_cache

# 显示 VS Code 隐私状态
vscode_show_privacy_status
```

#### 环境变量
```bash
export VSCODE_TELEMETRY_DISABLED="1"
export VSCODE_DISABLE_EXTENSIONS="1"
export VSCODE_DISABLE_CRASH_REPORTER="1"
export VSCODE_DISABLE_UPDATE_CHECK="1"
```

### Zed Editor Privacy Protection

#### 配置文件
- `~/.config/zed/settings.json`: Zed 设置
- `~/.zed-privacy/`: 隐私配置目录

#### 可用命令
```bash
# 安全模式启动 Zed
zed-safe

# 私有模式启动 Zed
zed-private

# 离线模式启动 Zed
zed-offline

# 清理 Zed 缓存
zed_clean_cache

# 显示 Zed 隐私状态
zed_show_privacy_status
```

#### 环境变量
```bash
export ZED_TELEMETRY_DISABLED="1"
export ZED_DISABLE_AUTO_UPDATE="1"
export ZED_DISABLE_COLLABORATION="1"
export ZED_DISABLE_CRASH_REPORTING="1"
```

### Neovim Privacy Protection

#### 配置文件
- `~/.config/nvim/init.lua`: Neovim 配置
- `~/.nvim-privacy/`: 隐私配置目录

#### 可用命令
```bash
# 安全模式启动 Neovim
nvim-safe

# 私有模式启动 Neovim
nvim-private

# 离线模式启动 Neovim
nvim-offline

# 清理 Neovim 缓存
nvim_clean_cache

# 显示 Neovim 隐私状态
nvim_show_privacy_status
```

#### 环境变量
```bash
export NVIM_TELEMETRY_DISABLED="1"
export NVIM_DISABLE_AUTO_UPDATE="1"
export NVIM_DISABLE_REMOTE_PLUGINS="1"
export NVIM_DISABLE_FILE_WATCHER="1"
```

### Vim Privacy Protection

#### 配置文件
- `~/.vimrc`: Vim 配置
- `~/.vim-privacy/`: 隐私配置目录

#### 可用命令
```bash
# 安全模式启动 Vim
vim-safe

# 私有模式启动 Vim
vim-private

# 离线模式启动 Vim
vim-offline

# 清理 Vim 缓存
vim_clean_cache

# 显示 Vim 隐私状态
vim_show_privacy_status
```

#### 环境变量
```bash
export VIM_TELEMETRY_DISABLED="1"
export VIM_DISABLE_AUTO_UPDATE="1"
export VIM_DISABLE_NETRW="1"
export VIM_DISABLE_FILE_WATCHER="1"
```

## 通用隐私保护功能

### 环境变量
```bash
# 通用隐私环境变量
export TELEMETRY_DISABLED="1"
export AUTO_UPDATE_DISABLED="1"
export DIAGNOSTICS_DISABLED="1"
export ONLINE_FEATURES_DISABLED="1"
export DATA_COLLECTION_DISABLED="1"
export CLOUD_SYNC_DISABLED="1"
export COLLABORATION_DISABLED="1"
export CRASH_REPORTING_DISABLED="1"
export USAGE_TRACKING_DISABLED="1"
```

### 通用命令模式
```bash
# 安全模式
software-safe

# 私有模式
software-private

# 离线模式
software-offline

# 清理缓存
software_clean_cache

# 显示隐私状态
software_show_privacy_status

# 隐私检查
software_privacy_check
```

## 自定义隐私保护

### 使用 Privacy Template

1. **复制模板**
```bash
cp -r stow-packs/privacy-template stow-packs/new-software-privacy
```

2. **自定义配置**
```bash
cd stow-packs/new-software-privacy
# 编辑配置文件
```

3. **创建迁移脚本**
```bash
cp scripts/migrate-privacy-template.sh scripts/migrate-new-software.sh
# 编辑脚本以匹配新软件
```

4. **更新 .gitignore**
```bash
# 添加新软件的隐私保护模式
```

### 创建新的隐私保护包

1. **分析软件隐私风险**
   - 识别敏感文件和目录
   - 了解数据收集机制
   - 确定在线功能

2. **创建配置文件**
   - 环境变量设置
   - 配置文件修改
   - 别名和函数

3. **创建迁移脚本**
   - 备份现有数据
   - 清理敏感数据
   - 应用新配置

4. **测试配置**
   - 验证隐私设置
   - 测试软件功能
   - 检查 .gitignore

## 维护和监控

### 定期维护
```bash
# 定期清理缓存
clean_all_cache

# 检查隐私设置
privacy_check_all

# 备份重要数据
backup_sensitive_data
```

### 监控工具
```bash
# 检查文件访问
monitor_file_access

# 检查网络连接
monitor_network_connections

# 审计配置更改
audit_config_changes
```

### 自动化任务
```bash
# 自动清理缓存（添加到 crontab）
0 2 * * * ~/.dotfiles/scripts/clean-all-cache.sh

# 自动隐私检查
0 6 * * 1 ~/.dotfiles/scripts/privacy-check-all.sh
```

## 故障排除

### 常见问题

1. **配置不生效**
   - 检查文件权限
   - 重启软件
   - 检查环境变量

2. **迁移脚本失败**
   - 检查备份文件
   - 手动清理敏感数据
   - 重新运行脚本

3. **软件功能异常**
   - 检查隐私设置是否过于严格
   - 调整配置级别
   - 查看软件日志

### 恢复方法
```bash
# 恢复备份
restore_backup

# 重置配置
reset_privacy_config

# 禁用隐私保护
disable_privacy_protection
```

## 最佳实践

### 1. 渐进式部署
- 先测试一个软件包
- 逐步应用到所有软件
- 监控系统稳定性

### 2. 定期更新
- 跟踪软件更新
- 更新隐私配置
- 检查新的隐私风险

### 3. 用户教育
- 了解隐私保护的重要性
- 学习使用隐私工具
- 定期检查隐私状态

### 4. 备份策略
- 定期备份重要数据
- 保留多个备份版本
- 测试备份恢复

## 扩展阅读

- [隐私保护设计体系](PRIVACY_SUMMARY.md)
- [Shell History 管理](stow-packs/shell-history/README.md)
- [VS Code 隐私保护](stow-packs/vscode-privacy/README.md)
- [Zed 隐私保护](stow-packs/zed-privacy/README.md)
- [Neovim 隐私保护](stow-packs/nvim-privacy/README.md)
- [Vim 隐私保护](stow-packs/vim-privacy/README.md)
- [隐私保护模板](stow-packs/privacy-template/README.md)

## 支持

如果您在使用隐私保护包时遇到问题，请：

1. 查看相关软件的 README 文件
2. 检查迁移脚本的输出
3. 查看软件的日志文件
4. 尝试恢复到之前的配置

## 贡献

欢迎贡献新的隐私保护包或改进现有配置：

1. Fork 项目
2. 创建新的隐私保护包
3. 测试配置
4. 提交 Pull Request

---

**记住：隐私保护是一个持续的过程，需要定期维护和更新。**