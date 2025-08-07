# Vim Privacy Protection

这个配置为 Vim 编辑器提供了隐私保护的设计，将敏感数据和配置分离管理。

## 隐私保护的文件和目录

以下文件和目录会被 .gitignore 忽略，不会提交到代码仓库：

### Vim 配置和状态
- `.vim/session/` - Vim 会话文件
- `.vim/swap/` - Vim 交换文件
- `.vim/backup/` - Vim 备份文件
- `.vim/undo/` - Vim 撤销文件
- `.vim/view/` - Vim 视图文件
- `.viminfo` - Vim 信息文件
- `.viminfo.tmp` - Vim 信息临时文件

### 插件相关
- `.vim/plugged/` - 插件目录
- `.vim/bundle/` - 插件目录
- `.vim/autoload/` - 自动加载目录
- `.vim/after/` - 插件配置

### 缓存和临时文件
- `.vim/netrwhist` - Netrw 历史文件
- `.vim/tmp/` - 临时文件目录
- `.vim/cache/` - 缓存目录

## 安全配置

### 1. 禁用在线功能
```vim
" 禁用 Netrw 文件监视器
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let g:loaded_netrwSettings = 1
let g:loaded_netrwFileHandlers = 1

" 禁用插件管理器在线功能
let g:plug_threads = 1
let g:plug_timeout = 60
let g:plug_retries = 1
```

### 2. 隐私设置
```vim
" 禁用自动更新
let g:auto_update = 0
let g:check_updates = 0

" 禁用遥测和诊断
let g:enable_coc_diagnostic = 0
let g:enable_coc_suggestion = 0
let g:enable_coc_hover = 0

" 禁用文件监视器
set noautoread
set noswapfile
set nobackup
set noundofile
set novisualbell
```

## 使用方法

### 1. 应用配置
```bash
cd ~/.dotfiles
stow -d stow-packs -t ~ vim-privacy
```

### 2. 迁移现有配置（可选）
```bash
./scripts/migrate-vim-privacy.sh
```

### 3. 手动管理
如果你想手动管理 Vim 隐私配置：

```bash
# 应用配置
stow -d stow-packs -t ~ vim-privacy

# 移除配置
stow -d stow-packs -t ~ -D vim-privacy
```

## 配置说明

`.vim_privacy_config` 文件包含以下隐私保护设置：

- **遥测禁用**: 禁用各种遥测数据收集
- **自动更新控制**: 禁用插件自动更新
- **在线功能**: 禁用在线功能和文件监视器
- **文件管理**: 配置文件和目录管理
- **插件管理**: 控制插件行为和数据存储

## 环境变量

以下环境变量可以控制 Vim 的隐私行为：

- `VIM_DISABLE_TELEMETRY=1` - 禁用遥测
- `VIM_DISABLE_AUTO_UPDATE=1` - 禁用自动更新
- `VIM_DISABLE_ONLINE_FEATURES=1` - 禁用在线功能
- `VIM_DISABLE_NETRW=1` - 禁用 Netrw

## 注意事项

1. **首次使用**: 建议运行迁移脚本来移动现有的敏感配置
2. **重启 Vim**: 配置更改后需要重启 Vim
3. **插件管理**: 某些插件可能需要重新配置
4. **性能考虑**: 隐私模式可能会影响某些功能的性能

## 故障排除

### 配置不生效
```bash
# 重新加载配置
:source ~/.vim_privacy_config

# 重启 Vim
:qa!
vim
```

### 插件问题
某些插件可能会在隐私模式下受限，这是正常的隐私保护行为。

### 性能问题
如果遇到性能问题，可以尝试：
```bash
# 清理缓存
vim_clean_cache
```

## 安全建议

1. **定期清理**: 定期清理会话、交换和备份文件
2. **禁用在线功能**: 除非必要，否则禁用所有在线功能
3. **使用本地插件**: 优先使用本地插件而非在线插件
4. **监控文件访问**: 定期检查 Vim 创建的文件和目录

## 与 Neovim 的区别

Vim 和 Neovim 的隐私保护配置略有不同：

- **配置文件**: Vim 使用 `.vimrc`，Neovim 使用 `init.vim`
- **插件管理**: Vim 使用插件管理器如 Vundle 或 Plug，Neovim 使用 Packer 或 Lazy
- **Lua 支持**: Neovim 原生支持 Lua，Vim 需要额外配置
- **API 功能**: Neovim 有更多内置 API 功能，需要更多禁用选项