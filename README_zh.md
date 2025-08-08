# 🏠 Dotfiles

一个全面的跨平台 dotfiles 配置，支持 **macOS** 和 **Linux** 系统，具备智能环境检测和自动配置功能。

## ⚡ 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash
```

> 🎆 支持 macOS 和 Linux，自动检测操作系统并进行智能配置！

## 🚀 快速开始

### ⚡ 统一一键安装（推荐）
```bash
# 适用于 macOS 和 Linux，自动检测系统
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash

# 安装所有开发环境
DEV_ALL=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash

# 非交互式安装（适用于自动化）
NON_INTERACTIVE=true DEV_ALL=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash

# 只安装指定配置包
INSTALL_PACKAGES="git vim tmux zsh" curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash
```

### 传统安装方法

### 一键远程安装
```bash
# 安装默认配置包（交互式）
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# 安装指定配置包
INSTALL_PACKAGES="git vim nvim zsh" curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# 非交互式安装（用于自动化）
NON_INTERACTIVE=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash
```

**macOS 用户注意**：安装器会自动安装 Homebrew（如果不存在），这需要管理员权限。安装过程中可能会提示您输入密码。

**Brewfile 集成**：在 macOS 上，安装器会自动检测并询问是否安装 `~/.Brewfile` 中的软件包。包括 CLI 工具、应用程序和字体。可以使用 `SKIP_BREWFILE=true` 跳过。

### 本地安装
```bash
# 克隆并一键安装
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./install.sh

# 或者分步安装
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh

# 或者使用 make
make install
```

## 包含的配置

- **Shell**: Zsh 配置，包含现代化提示符
- **Git**: 增强的 git 别名和设置
- **编辑器**: Vim 和 Neovim 配置
- **终端**: Tmux 配置
- **工具**: 现代化命令行工具和实用程序

## 可用配置包

- `system` - 系统全局配置
- `zsh` - Zsh shell 配置
- `git` - Git 配置和别名
- `vim` - Vim 配置
- `nvim` - Neovim 配置
- `tmux` - 终端复用器配置
- `tools` - 命令行工具配置
- `vscode` - Visual Studio Code 设置
- `zed` - Zed 编辑器配置
- `linux` - Linux 特定配置
- `macos` - macOS 特定配置

## 开发环境设置

dotfiles 包含可选的开发环境设置，可安装和配置多种编程语言和工具：

### 支持的语言和工具
- **Rust**: 最新稳定版 Rust 和 cargo
- **Python**: pyenv + uv 快速 Python 包管理
- **Go**: 最新 Go 版本，正确配置 GOPATH
- **Java**: OpenJDK 和 JAVA_HOME 配置
- **Node.js**: NVM 和最新 LTS Node.js
- **C/C++**: 构建工具和常用开发工具

### 安装方法
```bash
# 安装 dotfiles 和开发环境（交互式选择）
./install.sh --dev-env

# 自动安装所有开发环境
./install.sh --dev-all

# 一键远程安装包含开发环境
DEV_ENV=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# 单独运行开发环境设置
./scripts/setup-dev-environment.sh
```

**📖 详细的开发环境文档，请查看 [DEVELOPMENT_ENVIRONMENTS.md](DEVELOPMENT_ENVIRONMENTS.md)**

## 环境变量

安装器支持多个环境变量用于自动化和定制：

### 远程安装变量
```bash
# 跳过所有确认提示（自动安装所有内容）
NON_INTERACTIVE=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# 跳过 Brewfile 安装
SKIP_BREWFILE=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# 只安装指定配置包
INSTALL_PACKAGES="git vim zsh" curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# 设置开发环境
DEV_ENV=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash
DEV_ALL=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# 组合多个选项
NON_INTERACTIVE=true DEV_ALL=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash
```

### 本地安装变量
```bash
# 本地跳过 Brewfile 安装
SKIP_BREWFILE=true ./install.sh

# 非交互式本地安装
NON_INTERACTIVE=true ./install.sh
```

### 可用变量
- **`NON_INTERACTIVE`**: 设为 `true` 跳过所有确认提示
- **`SKIP_BREWFILE`**: 设为 `true` 跳过 Homebrew 包安装
- **`INSTALL_PACKAGES`**: 指定要安装的包（空格分隔）
- **`DEV_ENV`**: 设为 `true` 设置开发环境（交互式）
- **`DEV_ALL`**: 设为 `true` 安装所有开发环境
- **`DOTFILES_REPO`**: 自定义仓库 URL（默认：`https://github.com/nehcuh/dotfiles.git`）
- **`DOTFILES_DIR`**: 自定义安装目录（默认：`~/.dotfiles`）

## Homebrew 包管理 (macOS)

在 macOS 上，dotfiles 包含一个完整的 `Brewfile`，可安装重要的工具和应用：

### Brewfile 包含的内容
- **CLI 工具**: bat, eza, fzf, ripgrep, neovim, git-delta 等
- **开发工具**: go, rust, pyenv, nvm, maven, gradle 等
- **应用程序**: Zed 编辑器, Obsidian, Raycast, Rectangle 等
- **字体**: Fira Code, Hack Nerd Font, SF Mono 等

### Brewfile 安装
```bash
# dotfiles 设置时自动安装（需确认）
./install.sh

# 安装时跳过 Brewfile
SKIP_BREWFILE=true ./install.sh

# 稍后手动安装 Brewfile
brew bundle --global

# 非交互式远程安装（包括 Brewfile）
NON_INTERACTIVE=true curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash
```

## 使用方法

### 安装指定配置包
```bash
./install.sh git vim nvim  # 只安装 git、vim 和 nvim
```

### 列出可用配置包
```bash
make list
# 或者
./uninstall.sh list
```

### 移除配置
```bash
./uninstall.sh           # 移除所有配置包
./uninstall.sh vim nvim   # 移除指定配置包
make uninstall           # 移除所有配置包
```

### 更新仓库
```bash
make update
```

## 个性化定制

### 本地配置文件
创建这些文件来进行个人设置（这些文件不会被 git 跟踪）：

- `~/.gitconfig.local` - 个人 git 设置
- `~/.zshrc.local` - 额外的 zsh 配置
- `~/.tmux.conf.local` - 个人 tmux 设置

### ~/.gitconfig.local 示例
```ini
[user]
    name = 你的名字
    email = your.email@example.com
[commit]
    gpgsign = true
[user]
    signingkey = YOUR_GPG_KEY
```

## 系统要求

- Git
- GNU Stow（如果没有会自动安装）
- Zsh（可选，但推荐）

## 🌟 跨平台支持

✅ **统一代码库** - 单个仓库支持两个操作系统  
✅ **智能检测** - 自动检测并为您的操作系统配置  
✅ **平台特定优化** - 为每个系统量身定制的配置  

### 支持的系统

| 操作系统 | 版本 | 包管理器 | 字体安装 | 开发工具 |
|-----------|------|------------|------------|----------|
| **macOS** | 10.15+ (Catalina+) | Homebrew | Homebrew Casks | 全面支持 |
| **Linux** | Ubuntu 20.04+, Fedora 35+, Arch 等 | Homebrew + 原生 | 直接下载 | 全面支持 |

### Linux 特定功能

🐧 **main 分支现在包含完整的 Linux 支持：**

- ✅ **自动字体安装** - 下载并安装 Nerd Fonts 和 Google Fonts
- ✅ **Homebrew for Linux** - CLI 工具加智能原生包管理器回退
- ✅ **原生包管理器支持** - 支持 apt, dnf, pacman, zypper
- ✅ **智能依赖检测** - 自动安装缺少的依赖
- ✅ **跨平台 Shell 配置** - 统一的 zsh 设置加操作系统特定优化

### 安装（适用于两个系统）

```bash
# 一键安装（自动检测操作系统）
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/unified-install.sh | bash

# 本地安装
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh

# 包含开发环境
./install.sh --dev-all
```

## 文件结构

```
~/.dotfiles/
├── install.sh          # 主安装脚本
├── uninstall.sh        # 卸载脚本
├── Makefile            # Make 任务
├── stow-packs/         # 配置包
│   ├── git/           # Git 配置
│   ├── zsh/           # Zsh 配置
│   ├── vim/           # Vim 配置
│   ├── nvim/          # Neovim 配置
│   ├── tmux/          # Tmux 配置
│   └── ...
└── scripts/            # 辅助脚本
```

## 故障排除

### 与现有文件冲突
安装器会自动将冲突的文件备份到 `~/.dotfiles-backup-TIMESTAMP/`。

### 从备份恢复
```bash
# 列出可用备份
ls -la ~/.dotfiles-backup-*

# 手动恢复
cp ~/.dotfiles-backup-TIMESTAMP/.vimrc ~/.vimrc
```

### 清理旧备份
```bash
make clean  # 删除 30 天前的备份
```

## 许可证

MIT 许可证 - 查看 [LICENSE](LICENSE) 文件获取详细信息。
