# Dotfiles - Linux Branch

这是 dotfiles 项目的 Linux 适配版本，专门为 Linux 系统设计，提供完整的开发环境配置。

## Linux 适配特性

### 1. Homebrew 支持
- 安装 Linux 版本的 Homebrew
- 使用 CLI 工具，不包含 cask 软件包
- 自动配置 Homebrew 环境变量

### 2. 原生包管理器支持
支持多种 Linux 发行版的包管理器：
- **Ubuntu/Debian**: `apt`
- **Fedora**: `dnf`
- **Arch/Manjaro**: `pacman`
- **openSUSE**: `zypper`

### 3. 图形化软件安装

#### Visual Studio Code
- **Ubuntu/Debian**: 通过 Microsoft 官方源安装，包含 GPG 错误修复
- **Fedora**: 通过 Microsoft 官方 RPM 源安装
- **Arch/Manjaro**: 通过 AUR 安装（支持 yay 和 paru）
- **其他发行版**: 通过官方 tarball 安装

#### Zed 编辑器
- 使用官方安装脚本：`curl -f https://zed.dev/install.sh | sh`

#### Google Chrome
- **Ubuntu/Debian**: 通过 Google 官方源安装
- **Fedora**: 通过 Google 官方 RPM 源安装
- **Arch/Manjaro**: 通过 AUR 安装

### 4. 开发工具
通过 Homebrew 和原生包管理器安装：
- 现代 Unix 工具：`bat`, `eza`, `fd`, `ripgrep`, `fzf` 等
- 编程语言支持：Go, Rust, Python (pyenv), Node.js (nvm)
- 语言服务器：各种 LSP 服务器
- 开发字体：Fira Code, Hack Nerd Font 等

## 安装方法

### 1. 一键远程安装（推荐）
```bash
# 一键 Linux 优化安装
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/linux/remote-install-linux.sh | bash

# 安装所有开发环境
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/linux/remote-install-linux.sh | bash -s -- --dev-all

# 非交互式安装（用于自动化）
NON_INTERACTIVE=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/linux/remote-install-linux.sh | bash -s -- --dev-all

# 安装特定开发环境
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/linux/remote-install-linux.sh | bash -s -- python java go
```

### 2. 手动安装
```bash
# 克隆仓库并切换到 Linux 分支
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git checkout linux

# 运行安装脚本
./install.sh
```

安装脚本将自动：
1. 检测 Linux 发行版
2. 安装必要的系统包
3. 安装和配置 Homebrew
4. 安装开发工具和 CLI 工具
5. 安装图形化应用程序
6. 配置 shell 环境

### 3. 手动安装特定组件
如果只想安装特定组件：

```bash
# 只安装 Linux 包
./scripts/setup-linux-packages.sh

# 只安装配置文件
./install.sh zsh git nvim tmux
```

## 目录结构

```
.dotfiles/
├── install.sh                          # 主安装脚本
├── scripts/
│   └── setup-linux-packages.sh         # Linux 包安装脚本
└── stow-packs/
    ├── linux/
    │   ├── home/.Brewfile.linux         # Linux Homebrew 包列表
    │   └── home/.config/linux/linux.sh  # Linux 特定配置
    ├── zsh/                            # Zsh 配置
    ├── git/                            # Git 配置
    ├── nvim/                           # Neovim 配置
    └── ...                             # 其他配置包
```

## 配置说明

### Linux 特定配置
`~/.config/linux/linux.sh` 包含：
- Homebrew 环境变量设置
- Linux 特定别名
- 包管理器别名（根据发行版自动设置）
- XDG Base Directory 规范支持
- 开发环境路径配置

### 包管理器别名
根据检测到的发行版，自动设置便捷别名：
```bash
update    # 系统更新
install   # 安装包
search    # 搜索包
remove    # 删除包
```

### VS Code GPG 错误修复
脚本包含了针对 Microsoft GPG 密钥问题的自动修复：
1. 自动下载和安装正确的 GPG 密钥
2. 正确配置软件源
3. 处理密钥冲突和更新失败问题

## 支持的发行版

✅ **完全支持**:
- Ubuntu 20.04+
- Debian 11+
- Fedora 35+
- Arch Linux
- Manjaro

⚠️ **部分支持**:
- openSUSE Tumbleweed
- CentOS Stream

## 故障排除

### Homebrew 安装失败
```bash
# 手动安装 Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### VS Code GPG 错误
```bash
# 手动修复 GPG 密钥
sudo rm /etc/apt/sources.list.d/vscode.list
wget -qO - https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update && sudo apt install code
```

### 字体显示问题
```bash
# 刷新字体缓存
fc-cache -fv
```

## 贡献

如果你发现 bug 或想要添加对新发行版的支持，欢迎提交 Issue 或 Pull Request。

## 许可证

MIT License
