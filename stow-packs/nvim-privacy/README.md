# Neovim Privacy Protection

这个配置为 Neovim 编辑器提供了隐私保护的设计，将敏感数据和配置分离管理。

## 隐私保护的文件和目录

以下文件和目录会被 .gitignore 忽略，不会提交到代码仓库：

### Neovim 配置和状态
- `.config/nvim/session/` - Neovim 会话文件
- `.config/nvim/swap/` - Neovim 交换文件
- `.config/nvim/backup/` - Neovim 备份文件
- `.config/nvim/undo/` - Neovim 撤销文件
- `.config/nvim/view/` - Neovim 视图文件
- `.local/share/nvim/` - Neovim 共享数据
- `.local/state/nvim/` - Neovim 状态数据
- `.cache/nvim/` - Neovim 缓存数据

### 插件相关
- `.config/nvim/lazy-lock.json` - 插件锁定文件
- `.config/nvim/plugin/` - 插件特定数据
- `.config/nvim/after/plugin/` - 插件配置

### 历史和日志
- `.config/nvim/shada/` - Neovim 历史文件
- `.config/nvim/log/` - Neovim 日志文件
- `.viminfo` - Vim 信息文件
- `.viminfo.tmp` - Vim 信息临时文件

## 安全配置

### 1. 禁用遥测和诊断
```lua
-- 禁用遥测
vim.g.enable_coc_diagnostic = false
vim.g.enable_coc_suggestion = false
vim.g.enable_coc_hover = false

-- 禁用在线功能
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
```

### 2. 隐私设置
```lua
-- 禁用文件监视器
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 禁用自动更新
vim.g.auto_update = false
vim.g.check_updates = false

-- 禁用在线功能
vim.g.enable_ai_features = false
vim.g.enable_cloud_sync = false
```

## 使用方法

### 1. 应用配置
```bash
cd ~/.dotfiles
stow -d stow-packs -t ~ nvim-privacy
```

### 2. 迁移现有配置（可选）
```bash
./scripts/migrate-nvim-privacy.sh
```

### 3. 手动管理
如果你想手动管理 Neovim 隐私配置：

```bash
# 应用配置
stow -d stow-packs -t ~ nvim-privacy

# 移除配置
stow -d stow-packs -t ~ -D nvim-privacy
```

## 配置说明

`.nvim_privacy_config` 文件包含以下隐私保护设置：

- **遥测禁用**: 禁用各种遥测数据收集
- **自动更新控制**: 禁用插件自动更新
- **在线功能**: 禁用在线功能和云同步
- **文件管理**: 配置文件和目录管理
- **插件管理**: 控制插件行为和数据存储

## 环境变量

以下环境变量可以控制 Neovim 的隐私行为：

- `NVIM_DISABLE_TELEMETRY=1` - 禁用遥测
- `NVIM_DISABLE_AUTO_UPDATE=1` - 禁用自动更新
- `NVIM_DISABLE_ONLINE_FEATURES=1` - 禁用在线功能
- `NVIM_DISABLE_AI=1` - 禁用 AI 功能

## 注意事项

1. **首次使用**: 建议运行迁移脚本来移动现有的敏感配置
2. **重启 Neovim**: 配置更改后需要重启 Neovim
3. **插件管理**: 某些插件可能需要重新配置
4. **性能考虑**: 隐私模式可能会影响某些功能的性能

## 故障排除

### 配置不生效
```bash
# 重新加载配置
:source ~/.nvim_privacy_config

# 重启 Neovim
:qa!
nvim
```

### 插件问题
某些插件可能会在隐私模式下受限，这是正常的隐私保护行为。

### 性能问题
如果遇到性能问题，可以尝试：
```bash
# 清理缓存
nvim_clean_cache
```

## 安全建议

1. **定期清理**: 定期清理会话、交换和备份文件
2. **禁用在线功能**: 除非必要，否则禁用所有在线功能
3. **使用本地插件**: 优先使用本地插件而非在线插件
4. **监控文件访问**: 定期检查 Neovim 创建的文件和目录