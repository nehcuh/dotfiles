# Zed Privacy Protection

这个配置为 Zed 编辑器提供了隐私保护的设计，将敏感数据和配置分离管理。

## 隐私保护的文件和目录

以下文件和目录会被 .gitignore 忽略，不会提交到代码仓库：

### Zed 配置和缓存
- `.zed/` - Zed 配置目录
- `.config/zed/` - Zed 配置目录（Linux）
- `Library/Application Support/Zed/` - Zed 用户数据目录（macOS）
- `zed.log` - Zed 日志文件

### 工作区相关
- `.zed-state/` - Zed 工作区状态
- `.zed-backup/` - Zed 备份文件
- `.zed-temp/` - Zed 临时文件

### 会话和历史
- `.zed-history` - Zed 命令历史
- `.zed-sessions/` - Zed 会话数据
- `.zed-recent/` - 最近打开的文件列表

## 安全配置

### 1. 禁用遥测
```json
{
    "telemetry": {
        "enabled": false,
        "metrics": false,
        "crash_reporting": false
    },
    "auto_update": false,
    "diagnostics": false,
    "collaboration": {
        "enabled": false
    }
}
```

### 2. 隐私设置
```json
{
    "ui": {
        "show_inline_completions": false,
        "show_ghost_text": false,
        "show_status_bar": true,
        "show_tab_bar": true
    },
    "file_watcher": {
        "use_git_ignore": true,
        "ignore_patterns": [
            "**/node_modules/**",
            "**/dist/**",
            "**/build/**",
            "**/.git/**"
        ]
    }
}
```

## 使用方法

### 1. 应用配置
```bash
cd ~/.dotfiles
stow -d stow-packs -t ~ zed-privacy
```

### 2. 迁移现有配置（可选）
```bash
./scripts/migrate-zed-privacy.sh
```

### 3. 手动管理
如果你想手动管理 Zed 隐私配置：

```bash
# 应用配置
stow -d stow-packs -t ~ zed-privacy

# 移除配置
stow -d stow-packs -t ~ -D zed-privacy
```

## 配置说明

`.zed_privacy_config` 文件包含以下隐私保护设置：

- **遥测禁用**: 完全禁用遥测数据收集
- **自动更新控制**: 禁用自动更新
- **协作功能**: 禁用在线协作功能
- **文件监视器**: 配置文件监视器的忽略模式
- **诊断信息**: 禁用诊断信息收集

## 环境变量

以下环境变量可以控制 Zed 的隐私行为：

- `ZED_TELEMETRY_DISABLED=1` - 禁用遥测
- `ZED_AUTO_UPDATE=0` - 禁用自动更新
- `ZED_DIAGNOSTICS=0` - 禁用诊断
- `ZED_COLLABORATION=0` - 禁用协作

## 注意事项

1. **首次使用**: 建议运行迁移脚本来移动现有的敏感配置
2. **重启 Zed**: 配置更改后需要重启 Zed
3. **扩展管理**: 某些扩展可能需要重新配置
4. **性能考虑**: 隐私模式可能会影响某些功能的性能

## 故障排除

### 配置不生效
```bash
# 重新加载配置
source ~/.zed_privacy_config

# 重启 Zed
zed --restart
```

### 扩展问题
某些扩展可能会在隐私模式下受限，这是正常的隐私保护行为。

### 性能问题
如果遇到性能问题，可以尝试：
```bash
# 清理缓存
zed_clean_cache
```