# Sensitive Files Package

这个包用于管理敏感配置文件。这些文件会被 GNU Stow 链接到主目录，**但不会被 Git 跟踪**。

## 应该放在这里的文件类型

### 1. SSH 配置
- `home/.ssh/config` - SSH 配置文件
- `home/.ssh/id_*` - SSH 私钥（**绝对不要提交到 Git**）

### 2. 本地配置文件
- `home/.gitconfig_local` - Git 本地配置（用户名、邮箱等）
- `home/.zshrc.local` - Zsh 本地配置（个人环境变量等）

### 3. API 密钥和凭证
- `home/.claude.json` - Claude API 配置
- `config/gh/` - GitHub CLI 配置（包含 token）
- `config/aws/` - AWS 配置

### 4. 其他敏感信息
- 任何包含密码、token、私钥的文件
- 个人身份信息
- 公司内部配置

## 目录结构

```
stow-packs/sensitive/
├── home/           # 主目录文件（~）
│   ├── .ssh/       # SSH 配置和密钥
│   ├── .gitconfig_local
│   ├── .zshrc.local
│   └── .claude.json
└── config/         # .config 目录文件（~/.config）
    ├── gh/
    └── aws/
```

## 使用方法

### 1. 复制模板文件（如果存在）
```bash
cp ~/.gitconfig_local.template ~/.gitconfig_local
cp ~/.zshrc.local.template ~/.zshrc.local
```

### 2. 移动现有敏感文件到这个包
```bash
# 移动 SSH 配置
mv ~/.ssh/config ~/.dotfiles/stow-packs/sensitive/home/.ssh/

# 移动 Claude 配置
mv ~/.claude.json ~/.dotfiles/stow-packs/sensitive/home/

# 移动 GitHub CLI 配置
mv ~/.config/gh ~/.dotfiles/stow-packs/sensitive/config/

# 使用 stow 创建链接
cd ~/.dotfiles
stow -R stow-packs/sensitive
```

### 3. 验证链接
```bash
ls -la ~/.ssh/config  # 应该显示链接到 .dotfiles
ls -la ~/.claude.json  # 应该显示链接到 .dotfiles
```

## 安全注意事项

⚠️ **重要**：
- 这些文件包含敏感信息，**绝对不要提交到 Git**
- 这个目录已被 `.gitignore` 规则排除
- 定期检查 `git status` 确保没有意外提交敏感文件
- 考虑使用密码管理器（如 1Password、Bitwarden）存储真正的密钥

## 模板文件

对于某些配置，项目提供了模板文件（`.template` 后缀）：
- `~/.gitconfig_local.template`
- `~/.zshrc.local.template`

这些模板文件是安全的，会被 Git 跟踪。
