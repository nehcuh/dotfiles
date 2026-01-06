# Personal Configuration Package

这个包用于管理个人配置文件。这些文件会被 GNU Stow 链接到主目录，并且**会被 Git 跟踪**。

## 应该放在这里的文件类型

### 1. 个人偏好配置
- `home/.Brewfile.apps` - 个人应用列表（非基础工具）
- `home/.Brewfile.base` - 基础包选择（如果与系统默认不同）

### 2. 编辑器个人配置
- `config/Code/User/settings.json` - VS Code 个人设置
- `config/zed/settings.json` - Zed 编辑器个人设置

### 3. 应用配置
- `home/.gitconfig_global` - Git 全局配置（非敏感部分）
- 其他非敏感的应用配置

## 与 sensitive 包的区别

| 特性 | personal 包 | sensitive 包 |
|------|------------|--------------|
| Git 跟踪 | ✅ 是 | ❌ 否 |
| 包含内容 | 个人偏好设置 | API 密钥、密码等 |
| 示例 | Brewfile、编辑器配置 | SSH 密钥、token |

## 使用方法

### 1. 创建个人配置文件
```bash
# 创建个人 Brewfile
cat > ~/.dotfiles/stow-packs/personal/home/.Brewfile.apps << 'EOF'
# Personal applications
cask "slack"
cask "figma"
EOF

# 使用 stow 创建链接
cd ~/.dotfiles
stow -R stow-packs/personal
```

### 2. 验证链接
```bash
ls -la ~/.Brewfile.apps  # 应该显示链接到 .dotfiles
```

## 目录结构

```
stow-packs/personal/
├── home/           # 主目录文件（~）
│   └── .Brewfile.apps
└── config/         # .config 目录文件（~/.config）
    └── Code/User/  # VS Code 配置
```

## 注意事项

- 这个包的内容会被 Git 跟踪
- 不要在个人配置中包含敏感信息
- 如果不确定文件应该放哪个包，优先选择 sensitive
