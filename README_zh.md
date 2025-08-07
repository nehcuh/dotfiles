# 跨平台 Dotfiles

![跨平台](logo.png)

适用于 Linux、macOS 和 Windows 的完整开发环境配置。

## 特性

### 跨平台支持
- **Linux**: Ubuntu、Debian、Arch、Fedora 等
- **macOS**: 所有最新版本（使用 Homebrew）
- **Windows**: WSL、MSYS2、原生 PowerShell

### 包管理
- **Linux**: apt、pacman、dnf、Homebrew
- **macOS**: Homebrew
- **Windows**: Scoop、Winget

### 包含工具
- **Shell**: 带有 Zinit 插件管理器的 Zsh
- **终端**: 带有 Oh My Tmux 的 tmux
- **编辑器**: Neovim、Vim
- **实用工具**: fzf、ripgrep、eza、bat、starship、zoxide
- **Git**: 增强配置和别名

## 前提条件

- Linux、macOS、Windows (WSL/MSYS2)
- Git、Zsh/PowerShell、curl/wget
- 推荐: Neovim、tmux
- 可选: Vim

## 快速开始

### 交互式安装（推荐）

**所有平台:**
```bash
# 通用安装程序（自动检测您的 shell）
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/universal-install.sh | sh

# 或使用特定 shell
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh | bash
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh | zsh
```

这将启动一个交互式向导，自动检测您的 shell 并让您选择要安装的内容。

### 🔐 Sudo 权限处理

所有安装脚本都包含全面的 sudo 权限管理：

- **自动检测**: 脚本在需要之前检查 sudo 访问权限
- **用户友好提示**: 需要密码输入时提供清晰指示
- **会话管理**: 保持 sudo 会话活跃，防止长时间安装过程中超时
- **优雅的错误处理**: 如果 sudo 失败，提供详细的错误消息和手动执行建议
- **跨平台支持**: 在 Linux、macOS 和 Windows (WSL/MSYS2) 上无缝工作

**macOS 用户**: 如果遇到权限问题，请确保您的用户在系统偏好设置 > 用户与群组中拥有管理员权限。

### 一键安装

**Linux 和 macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/install.sh | bash

# 或使用 POSIX 兼容版本:
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/install.sh | sh
```

**Windows:**
```powershell
# 在 PowerShell 中运行
iwr -useb https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/install-windows-improved.ps1 | iex
```

### 手动安装

**Linux 和 macOS:**
```bash
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install.sh
```

**Windows:**
```powershell
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install-windows-improved.ps1
```

### 使用 Make

```bash
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

## 详细配置

### 🖥️ 系统包
**核心开发工具:**
- **Neovim**: 具有 LSP 支持的现代、可扩展文本编辑器
- **Zed**: 快速、协作的代码编辑器
- **Tmux**: 用于会话管理的终端复用器
- **Git**: 带有增强配置的版本控制
- **Zsh**: 强大的 shell，带有 Zinit 插件管理器
- **Starship**: 极简、快速、可定制的提示符

**现代命令行工具:**
- **eza**: 现代 `ls` 替代品，带有图标和 Git 集成
- **bat**: 带有语法高亮和 Git 集成的 cat 克隆
- **ripgrep**: 快速递归搜索，替代 `grep`
- **fd**: 简单、快速且用户友好的 `find` 替代品
- **fzf**: 命令行模糊查找器
- **zoxide**: 更智能的 `cd` 命令，学习您的习惯
- **delta**: 语法高亮的 Git 分页器
- **yazi**: 极速终端文件管理器

**开发工具:**
- **Go**: Go 编程语言及 gopls
- **Rust**: Rust 编程语言及 rust-analyzer
- **Python**: Python 语言服务器 (basedpyright, pyrefly for Zed)
- **Node.js**: TypeScript 和 JavaScript 语言服务器
- **OrbStack**: macOS 上的现代 Docker 替代品
- **Java**: OpenJDK 及 Maven 和 Gradle
- **C/C++**: GCC、Clang、CMake 和调试工具

**容器开发:**
- **Dev Containers**: VS Code 开发容器支持
- **Docker Compose**: 多容器开发环境
- **Ubuntu 开发环境**: 完整的 Ubuntu 24.04.2 LTS 开发容器

**系统监控:**
- **bottom**: 更好的 `top`，带有图表和 GPU 监控
- **procs**: 现代 `ps` 替代品
- **duf**: 更好的 `df`，带有彩色输出
- **dust**: 更直观的 `du` 版本
- **hyperfine**: 命令行基准测试工具
- **gping**: 带图形的 ping

## 管理

### 交互式管理
```bash
cd ~/.dotfiles
./scripts/interactive-install.sh  # 交互式安装向导
```

### 使用 stow.sh
```bash
cd ~/.dotfiles
./scripts/stow.sh install system zsh git tools vim nvim tmux
./scripts/stow.sh remove system zsh git tools vim nvim tmux
./scripts/stow.sh status
./scripts/stow.sh list
```

### 使用 Make
```bash
cd ~/.dotfiles
make setup-python        # 设置 Python 环境
make setup-node          # 设置 Node.js 环境
make setup-dev           # 设置 Python 和 Node.js
make install             # 安装所有 dotfiles
make remove              # 移除所有 dotfiles
make status              # 检查当前状态
make clean               # 清理过时文件
make update              # 更新仓库
```

## 平台特定说明

### Docker 开发环境
- **Ubuntu 24.04.2 LTS**: 容器中的完整开发环境
- **用户**: "huchen"，具有 sudo 权限
- **同步配置**: 您的 dotfiles 在容器内自动可用
- **持久存储**: 主目录在容器重启之间保持不变
- **端口映射**: 常见开发端口 (3000, 8000, 8080 等) 已映射
- **使用方法**: `docker-compose -f docker/docker-compose.ubuntu-dev.yml up -d`

### Windows
- 需要 Windows 10/11 和 PowerShell 5.1+
- 与 Windows Terminal 配合最佳
- 同时支持 WSL 和原生 Windows 环境
- 使用连接点作为符号链接

### Linux
- 支持所有主要发行版
- 自动包管理器检测
- 可选 Linux Homebrew 支持

### macOS
- 需要 Xcode 命令行工具
- 使用 Homebrew 进行包管理
- 包含 Apple Silicon Mac 支持

## 设置与安全

### 发布到 GitHub 前

1. **替换所有文件中的 `nehcuh`** 为您的实际 GitHub 用户名
2. **更新 `dotfiles.conf`** 中的 GitHub 用户名
3. **创建个人配置文件**:
   ```bash
   cp stow-packs/git/.gitconfig_local.template ~/.gitconfig_local
   # 编辑 ~/.gitconfig_local 添加您的姓名和邮箱
   ```

### 首次设置

#### 快速交互式设置（推荐）
```bash
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh | bash
```

#### 手动设置
1. **克隆仓库**
   ```bash
   git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **运行安装程序**
   ```bash
   # Linux 和 macOS
   ./scripts/install.sh
   
   # Windows
   ./scripts/install-windows-improved.ps1
   ```

3. **配置个人信息**
   ```bash
   # 编辑 git 配置模板
   nano ~/.gitconfig_local
   ```

4. **重启终端** 应用所有更改

### 安全最佳实践

- **模板文件** 用于需要个人信息的配置
- **`.local` 文件** 包含在 `.gitignore` 中，防止意外提交
- **个人配置** 应保存在 `~/.gitconfig_local`、`~/.zshrc.local`、`~/.tmux.conf.local`
- **API 密钥和令牌** 永远不应提交到仓库

## 自定义

### 环境变量

在 `~/.zshenv`（ZSH 推荐）中添加环境变量：

```bash
export PATH=/usr/local/sbin:$PATH
export PATH=$HOME/.rbenv/shims:$PATH
export PYTHONPATH=/usr/local/lib/python2.7/site-packages
```

### 本地配置

在这些本地文件中设置个人配置：

**Zsh:** `~/.zshrc.local`
```bash
# 额外的 zsh 插件
zinit snippet OMZP::golang
zinit snippet OMZP::python
zinit snippet OMZP::ruby
zinit light ptavares/zsh-direnv
```

**Git:** `~/.gitconfig.local`
```bash
[commit]
    # 使用 GPG 签名提交
    gpgsign = true

[user]
    name = 您的姓名
    email = your.email@example.com
    signingkey = XXXXXXXX
```

**tmux:** `~/.tmux.conf.local`
```bash
# 个人 tmux 设置
set -g mouse on
set -g status-interval 5
```

### 开发环境使用

**Python 开发:**
```bash
# 使用 pyenv 管理 Python 版本
pyenv versions                    # 列出已安装版本
pyenv install 3.11.0             # 安装特定版本
pyenv local 3.11.0               # 为当前目录设置版本

# 使用 direnv 管理项目特定环境
echo 'layout python' > .envrc    # 创建 Python 环境
direnv allow                      # 允许当前目录的 direnv

# 使用 uv 快速包管理
uv pip install package-name      # 快速安装包
```

**Node.js 开发:**
```bash
# 使用 nvm 管理 Node.js 版本
nvm list                          # 列出已安装版本
nvm install 18.17.0              # 安装特定版本
nvm use 18.17.0                  # 使用特定版本
echo '18.17.0' > .nvmrc          # 为项目设置版本
nvm use                          # 使用 .nvmrc 中的版本
```

**Docker 开发:**
```bash
# 启动开发环境
docker-compose -f docker/docker-compose.ubuntu-dev.yml up -d

# 访问环境
docker-compose -f docker/docker-compose.ubuntu-dev.yml exec ubuntu-dev zsh

# 停止环境
docker-compose -f docker/docker-compose.ubuntu-dev.yml down
```

## 致谢

本项目受到各种 dotfiles 仓库和社区的启发。
特别感谢：
- [GNU Stow](https://www.gnu.org/software/stow/) 提供符号链接管理
- 开源社区提供的优秀工具和配置

## 贡献

欢迎贡献！请随时提交问题和拉取请求。

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件