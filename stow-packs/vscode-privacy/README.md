# VS Code Privacy Protection

这个配置为 VS Code 提供了隐私保护的设计，将敏感数据和配置分离管理。

## 隐私保护的文件和目录

以下文件和目录会被 .gitignore 忽略，不会提交到代码仓库：

### 工作区相关
- `.vscode/` - 项目特定的 VS Code 配置
- `code-insiders.log` - VS Code Insiders 日志文件
- `code.log` - VS Code 日志文件

### 扩展和缓存
- `.vscode-insiders/` - VS Code Insiders 配置目录
- `.vscode-server/` - VS Code Server 配置目录
- `vscode-cmd-*` - VS Code 命令行工具临时文件

### 用户数据
- `Library/Application Support/Code/` - VS Code 用户数据目录（macOS）
- `.config/Code/User/globalStorage/` - 扩展全局存储
- `.config/Code/User/workspaceStorage/` - 工作区存储

## 安全配置

### 1. 禁用遥测
```json
{
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "extensions.autoUpdate": false,
    "extensions.autoCheckUpdates": false
}
```

### 2. 隐私设置
```json
{
    "workbench.settings.enableNaturalLanguageSearch": false,
    "workbench.quickOpen.enableNaturalLanguageSearch": false,
    "git.enableCommitSigning": false,
    "git.enableSmartCommit": true,
    "git.autofetch": true
}
```

## 使用方法

### 1. 应用配置
```bash
cd ~/.dotfiles
stow -d stow-packs -t ~ vscode-privacy
```

### 2. 迁移现有配置（可选）
```bash
./scripts/migrate-vscode-privacy.sh
```

### 3. 手动管理
如果你想手动管理 VS Code 隐私配置：

```bash
# 应用配置
stow -d stow-packs -t ~ vscode-privacy

# 移除配置
stow -d stow-packs -t ~ -D vscode-privacy
```

## 配置说明

`.vscode_privacy_config` 文件包含以下隐私保护设置：

- **遥测禁用**: 完全禁用遥测数据收集
- **自动更新控制**: 禁用扩展自动更新
- **工作区隔离**: 隔离不同工作区的数据
- **缓存管理**: 配置缓存文件位置
- **安全设置**: 启用各种安全相关的设置

## 注意事项

1. **首次使用**: 建议运行迁移脚本来移动现有的敏感配置
2. **重启 VS Code**: 配置更改后需要重启 VS Code
3. **扩展配置**: 某些扩展可能需要重新配置
4. **工作区设置**: 项目特定的 `.vscode/` 目录仍然需要手动管理

## 故障排除

### 配置不生效
```bash
# 重新加载配置
code --reload-window

# 或者手动加载配置
source ~/.vscode_privacy_config
```

### 扩展问题
某些扩展可能会在隐私模式下受限，这是正常的隐私保护行为。