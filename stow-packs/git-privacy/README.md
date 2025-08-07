# Git Privacy Protection

这个配置为 Git 提供了隐私保护的设计，将敏感数据和配置分离管理，禁用遥测和数据收集功能。

## 隐私保护的文件和目录

以下文件和目录会被 .gitignore 忽略，不会提交到代码仓库：

### Git 凭据和认证
- `.git-credentials` - Git 凭据文件
- `.git-credential-cache` - 凭据缓存文件
- `.git-credential-store` - 凭据存储文件
- `.git-credential-*` - 各种凭据管理器文件

### Git 配置和状态
- `.gitconfig_local` - 本地 Git 配置
- `.git_history` - Git 命令历史
- `.git_cache` - Git 缓存目录
- `.git_temp` - Git 临时文件
- `.git/logs/` - Git 日志目录
- `.git/hooks/` - Git 钩子目录

### Git LFS 和大文件
- `.git/lfs/` - Git LFS 目录
- `.gitattributes` - Git 属性文件
- `.git/info/` - Git 信息目录

### Git 工作树和临时目录
- `.git/worktrees/` - Git 工作树
- `.git/rewritten/` - 重写历史
- `.git/rebase-*` - 变基目录
- `.git/MERGE_*` - 合并状态文件

## 安全配置

### 1. 禁用遥测和数据收集
```bash
# 环境变量
export GIT_DISABLE_TELEMETRY="1"
export GIT_DISABLE_SEND_DATA="1"
export GIT_DISABLE_AUTO_UPDATE="1"
export GIT_DISABLE_USAGE_TRACKING="1"
```

### 2. 禁用网络功能
```bash
export GIT_DISABLE_NETWORK_FEATURES="1"
export GIT_DISABLE_CREDENTIAL_HELPER="1"
export GIT_DISABLE_ASKPASS="1"
export GIT_DISABLE_GPG_UI="1"
```

### 3. 配置文件设置
```ini
[core]
    pager = ""
    askpass = ""
    untrackedcache = false
    splitindex = false

[commit]
    gpgsign = false
    verbose = false

[tag]
    gpgsign = false

[credential]
    helper = ""
    askpass = ""
    prompt = false

[advice]
    statushints = false
    commitbeforemerge = false
    resolveconflict = false
```

### 4. 隐私保护的别名
```bash
# 基础隐私别名
alias git='git --no-pager'
alias git-safe='git --no-askpass --no-optional-locks'
alias git-private='git --no-askpass --no-optional-locks --no-gpg-sign'
alias git-offline='git --no-askpass --no-optional-locks --no-gpg-sign --no-verify'
alias git-no-network='git --no-askpass --no-optional-locks --no-gpg-sign --no-verify --no-commit-id'
```

## 使用方法

### 1. 应用配置
```bash
cd ~/.dotfiles
stow -d stow-packs -t ~ git-privacy
```

### 2. 迁移现有配置（可选）
```bash
./scripts/migrate-git-privacy.sh
```

### 3. 手动管理
如果你想手动管理 Git 隐私配置：

```bash
# 应用配置
stow -d stow-packs -t ~ git-privacy

# 移除配置
stow -d stow-packs -t ~ -D git-privacy
```

## 配置说明

`.git_privacy_config` 文件包含以下隐私保护设置：

- **遥测禁用**: 完全禁用 Git 遥测数据收集
- **网络控制**: 禁用自动网络操作和凭据管理
- **缓存管理**: 配置 Git 缓存和临时文件管理
- **安全设置**: 禁用 GPG 签名和其他安全功能
- **别名系统**: 提供隐私保护的 Git 命令别名

## 可用命令

### 清理命令
```bash
git_clean_cache          # 清理 Git 缓存
git_clean_history        # 清理 Git 命令历史
git_clean_temp           # 清理 Git 临时文件
git_reset_credentials    # 重置 Git 凭据
```

### 配置命令
```bash
git_disable_gpg          # 禁用 GPG 签名
git_disable_network      # 禁用网络操作
git_show_privacy_status  # 显示隐私状态
git_privacy_audit        # 执行隐私审计
```

### 仓库设置
```bash
git_setup_private_repo   # 设置私有仓库
```

## 环境变量

以下环境变量可以控制 Git 的隐私行为：

- `GIT_DISABLE_TELEMETRY=1` - 禁用遥测
- `GIT_DISABLE_SEND_DATA=1` - 禁用数据发送
- `GIT_DISABLE_AUTO_UPDATE=1` - 禁用自动更新
- `GIT_DISABLE_USAGE_TRACKING=1` - 禁用使用跟踪
- `GIT_DISABLE_NETWORK_FEATURES=1` - 禁用网络功能
- `GIT_DISABLE_CREDENTIAL_HELPER=1` - 禁用凭据助手
- `GIT_DISABLE_ASKPASS=1` - 禁用密码询问
- `GIT_DISABLE_GPG_UI=1` - 禁用 GPG 用户界面

## 隐私功能

### 1. 命令历史保护
- 禁用 Git 命令历史记录
- 清理会话文件和临时文件
- 防止命令泄露敏感信息

### 2. 凭据管理
- 禁用自动凭据存储
- 清理凭据缓存文件
- 防止凭据意外泄露

### 3. 网络操作控制
- 禁用自动网络操作
- 防止意外数据发送
- 控制远程仓库访问

### 4. GPG 和签名
- 禁用 GPG 签名功能
- 防止密钥泄露
- 简化提交过程

### 5. 缓存和临时文件
- 自动清理缓存文件
- 管理临时文件
- 防止敏感数据残留

## 注意事项

1. **首次使用**: 建议运行迁移脚本来移动现有的敏感配置
2. **重启 Shell**: 配置更改后需要重启 Shell 或重新加载配置
3. **功能限制**: 某些 Git 功能可能会受到限制，这是正常的隐私保护行为
4. **手动操作**: 某些操作可能需要手动执行，特别是在处理敏感数据时

## 故障排除

### 配置不生效
```bash
# 重新加载配置
source ~/.git_privacy_config

# 检查环境变量
env | grep GIT_DISABLE

# 检查 Git 配置
git config --global --list | grep -E "(telemetry|credential|gpg)"
```

### 网络问题
```bash
# 测试网络连接
git ls-remote https://github.com/user/repo.git

# 手动设置代理（如果需要）
git config --global http.proxy http://proxy.example.com:8080
```

### 凭据问题
```bash
# 清理凭据
git_reset_credentials

# 手动设置凭据（如果需要）
git config --global credential.helper store
```

### GPG 问题
```bash
# 禁用 GPG 签名
git_disable_gpg

# 检查 GPG 配置
git config --global --get commit.gpgsign
git config --global --get tag.gpgsign
```

## 安全建议

1. **定期清理**: 定期运行清理命令删除缓存和临时文件
2. **监控配置**: 定期检查 Git 配置和环境变量
3. **使用别名**: 优先使用隐私保护的 Git 别名
4. **避免自动操作**: 避免使用自动网络操作和凭据存储
5. **手动验证**: 重要操作前手动验证配置和状态

## 最佳实践

### 1. 日常使用
```bash
# 使用隐私保护的别名
git-safe status
git-private commit -m "message"
git-offline log --oneline
```

### 2. 敏感项目
```bash
# 为敏感项目设置私有仓库
git_setup_private_repo ~/private-project

# 使用离线模式
git-no-network add .
git-no-network commit -m "private changes"
```

### 3. 定期维护
```bash
# 定期清理
git_clean_cache
git_clean_history
git_clean_temp

# 定期审计
git_privacy_audit
```

## 高级功能

### 1. 自定义配置
可以通过修改 `.git_privacy_config` 文件来自定义隐私设置。

### 2. 项目特定配置
可以为特定项目创建额外的隐私配置文件。

### 3. 自动化脚本
可以创建自动化脚本来定期执行隐私保护操作。

### 4. 集成工具
可以与其他隐私保护工具集成使用。

## 更新和维护

### 配置更新
当 Git 版本更新时，可能需要更新隐私配置以适应新的功能。

### 安全补丁
定期检查并应用 Git 的安全补丁。

### 配置审查
定期审查和更新隐私配置以适应新的威胁和需求。

## 支持

如果遇到问题或需要帮助，请：

1. 检查故障排除部分
2. 运行隐私审计命令
3. 查看日志文件（如果有）
4. 联系维护者

## 许可证

本配置采用 MIT 许可证。