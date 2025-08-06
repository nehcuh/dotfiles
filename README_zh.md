# 跨平台 Dotfiles 配置

![跨平台](logo.png)

适用于 Linux、macOS 和 Windows 的完整开发环境配置。

## 前置要求

- Linux、macOS、Windows (WSL/MSYS2)
- Git、Zsh/PowerShell、curl/wget
- 推荐：Neovim、tmux
- 可选：Vim

## 快速开始

### 交互式安装（推荐）

**所有平台:**
```bash
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/interactive-install.sh | bash
```

这将启动一个交互式向导，让你选择需要安装的组件。

### 一键安装（推荐）

**Linux & macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/scripts/install-unified.sh | bash
```

**Windows:**
```powershell
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install.bat
```

### 手动安装

**Linux & macOS:**
```bash
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install-unified.sh
```

**Windows:**
```powershell
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/install.bat
```

### 使用 Make

```bash
git clone https://github.com/nehcuh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

## 功能特性

### 跨平台支持
- **Linux**: Ubuntu、Debian、Arch、Fedora 等
- **macOS**: 所有支持 Homebrew 的版本
- **Windows**: WSL、MSYS2、原生 PowerShell

### 包管理
- **Linux**: apt、pacman、dnf、Homebrew
- **macOS**: Homebrew
- **Windows**: Scoop、Winget

### 包含的工具
- **Shell**: Zsh 配合 Zinit 插件管理器
- **终端**: tmux 配合 Oh My Tmux
- **编辑器**: Neovim、Vim、Zed
- **实用工具**: fzf、ripgrep、eza、bat、starship、zoxide
- **Git**: 增强的配置和别名

## 详细配置说明

### 🖥️ 系统软件包
**核心开发工具:**
- **Neovim**: 现代、可扩展的文本编辑器，支持 LSP
- **Tmux**: 终端复用器，用于会话管理
- **Git**: 版本控制，增强配置
- **Zsh**: 强大的 shell，使用 Zinit 插件管理器
- **Starship**: 极简、快速、可定制的提示符

**现代命令行工具:**
- **eza**: 现代 `ls` 替代品，支持图标和 Git 集成
- **bat**: 支持 Git 集成和语法高亮的 `cat` 克隆
- **ripgrep**: 替代 `grep` 的快速递归搜索工具
- **fd**: 简单、快速、用户友好的 `find` 替代品
- **fzf**: 命令行模糊查找器
- **zoxide**: 智能的 `cd` 命令，学习你的习惯
- **delta**: Git 的语法高亮分页器
- **yazi**: 极速终端文件管理器

**现代工具与传统工具对比:**
| 传统工具 | 现代替代 | 主要优势 |
|---------|---------|---------|
| `ls` | `eza` | 彩色输出、图标、Git 状态、树形视图 |
| `cat` | `bat` | 语法高亮、行号、Git 集成、分页 |
| `grep` | `ripgrep` | 速度快 10-100 倍、智能忽略、Unicode 支持 |
| `find` | `fd` | 简洁语法、并行搜索、智能忽略 |
| `cd` | `zoxide` | 智能跳转、频率学习、模糊匹配 |
| `top` | `bottom/btop` | 更好的界面、GPU 监控、可交互 |
| `du` | `dust` | 可视化输出、更直观的大小显示 |
| `df` | `duf` | 彩色输出、更清晰的格式 |
| `ps` | `procs` | 彩色输出、树形视图、更多信息 |
| `ping` | `gping` | 实时图表、多目标、统计信息 |

**开发工具:**
- **Go**: Go 编程语言，包含 gopls
- **Rust**: Rust 编程语言，包含 rust-analyzer
- **Python**: Python 语言服务器 (basedpyright, pyrefly for Zed)
- **Node.js**: TypeScript 和 JavaScript 语言服务器
- **Java**: OpenJDK 多版本支持，Maven 和 Gradle
- **C/C++**: GCC, Clang, CMake 和调试工具
- **OrbStack**: 现代 Docker 替代品（macOS）

**系统监控:**
- **bottom**: 更好的 `top`，包含图表和 GPU 监控
- **procs**: 现代 `ps` 替代品
- **duf**: 更好的 `df`，彩色输出
- **dust**: 更直观的 `du` 版本
- **hyperfine**: 命令行基准测试工具
- **gping**: 带图表的 ping

**容器化开发:**
- **Dev Containers**: VS Code 开发容器支持
- **Docker Compose**: 多容器开发环境  
- **Ubuntu 开发环境**: 完整的 Ubuntu 24.04.2 LTS 开发容器，用户名 "huchen"
- **OrbStack**: macOS 上的现代 Docker 替代品，性能更佳

**Python 开发环境:**
- **Pyenv**: Python 版本管理
- **Anaconda3**: 通过 pyenv 全局安装最新版本
- **uv**: 现代 Python 包安装器和解析器
- **direnv**: 目录特定的环境变量管理
- **语言服务器**: 通用使用 basedpyright，Zed 编辑器使用 pyrefly

**Node.js 开发环境:**
- **NVM**: Node 版本管理器，轻松切换 Node.js 版本
- **Node.js LTS**: 默认安装最新 LTS 版本
- **包管理器**: 支持 npm、yarn、pnpm
- **开发工具**: 预配置 TypeScript、Prettier、ESLint

### 🎨 Shell 配置
**Zsh 功能:**
- **Zinit**: 快速插件管理器，支持 Turbo 模式
- **语法高亮**: 实时命令语法高亮
- **自动建议**: 智能命令补全
- **历史搜索**: 使用 fzf 进行交互式历史搜索
- **目录导航**: 使用 zoxide 进行智能跳转
- **Git 集成**: 提示符中显示状态和别名

**快捷键:**
- `Alt-c`: 模糊目录选择和导航
- `Ctrl-r`: 交互式命令历史搜索
- `Ctrl-t`: 模糊文件选择和插入
- `Tab`: 使用 fzf-tab 进行智能补全

### 🧠 Git 配置
**增强功能:**
- **Delta**: 美观的 Git diff 输出，支持语法高亮
- **别名**: 简化常用 Git 操作
- **合并工具**: Neovim 集成用于冲突解决
- **全局忽略**: 跨项目的一致忽略模式
- **安全设置**: 安全的默认配置

**实用别名:**
- `gco` → `git checkout`
- `gcm` → `git commit -m`
- `ga` → `git add`
- `gs` → `git status`
- `gp` → `git push`
- `gl` → `git pull`

### 🎯 终端复用器 (Tmux)
**功能:**
- **会话持久化**: 分离和重新连接会话
- **面板**: 高效分割终端窗口
- **状态栏**: 显示系统信息的自定义状态栏
- **复制模式**: Vim 风格的复制粘贴
- **鼠标支持**: 可点击面板和滚动

### ⚡ 性能优势
- **快速启动**: Zsh 优化的插件加载
- **最小开销**: 轻量级工具，不会拖慢系统
- **并行处理**: 高效利用系统资源
- **内存高效**: 工具设计轻量快速

### 🎨 视觉增强
- **一致主题**: 跨所有 shell 的 Starship 提示符
- **语法高亮**: 所有工具支持颜色和语法
- **图标**: 列表和提示符中的文件类型图标
- **Git 集成**: 处处可见的视觉 Git 状态

### 🔧 开发体验
- **LSP 支持**: 多种编程语言的语言服务器
- **IntelliSense**: 智能代码补全和建议
- **错误检查**: 实时语法和错误高亮
- **格式化**: 代码格式化工具集成
- **调试**: 可用的调试适配器支持

### 🎯 编辑器支持
- **Zed**: 现代协作代码编辑器，优化配置
- **Neovim**: 现代、可扩展的文本编辑器
- **VS Code**: 通过 Dev Containers 支持
- **字体**: Google Sans Code 字体配置

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
make setup-dev            # 设置 Python 和 Node.js 环境
make install          # 安装所有 dotfiles
make remove           # 移除所有 dotfiles
make status           # 检查当前状态
make clean            # 清理过时文件
make update           # 更新仓库
```

### Shell 快捷键
- `Alt-c`: 进入选中的目录
- `Ctrl-r`: 粘贴历史命令
- `Ctrl-t`: 粘贴选中的文件路径
- `Tab`: 智能补全

### Docker 开发环境管理
```bash
cd ~/.dotfiles
make docker-build        # 构建开发环境
make docker-up           # 启动开发环境
make docker-down         # 停止开发环境
make docker-shell        # 进入开发环境
```

## 平台特定说明

### Docker 开发环境
- **Ubuntu 24.04.2 LTS**: 完整的开发环境容器
- **用户**: "huchen" 具有 sudo 权限
- **同步配置**: 你的 dotfiles 自动在容器内可用
- **持久化存储**: 用户目录在容器重启间保持
- **端口映射**: 常用开发端口（3000, 8000, 8080 等）已映射
- **使用方法**: `docker-compose -f docker/docker-compose.ubuntu-dev.yml up -d`

### Windows
- 需要 Windows 10/11 和 PowerShell 5.1+
- 在 Windows Terminal 中效果最佳
- 支持 WSL 和原生 Windows 环境
- 使用 junction points 创建符号链接

### Linux
- 支持所有主要发行版
- 自动包管理器检测
- 可选的 Linux Homebrew 支持

### macOS
- 需要 Xcode Command Line Tools
- 使用 Homebrew 进行包管理
- 包含 Apple Silicon Mac 支持

## 设置与安全

### 发布到 GitHub 前

1. **替换 `nehcuh`** 为你的 GitHub 用户名
2. **更新 `dotfiles.conf`** 为你的 GitHub 用户名
3. **创建个人配置文件**：
   ```bash
   cp stow-packs/git/.gitconfig_local.template ~/.gitconfig_local
   # 编辑 ~/.gitconfig_local 填入你的姓名和邮箱
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

2. **运行安装器**
   ```bash
   # Linux & macOS
   ./scripts/install-unified.sh
   
   # Windows
   ./scripts/install.bat
   ```

3. **配置个人信息**
   ```bash
   # 编辑 git 配置模板
   nano ~/.gitconfig_local
   ```

4. **重启终端** 应用所有更改

### 安全最佳实践

- **模板文件**用于需要个人信息的配置
- **`.local` 文件**已包含在 `.gitignore` 中防止意外提交
- **个人配置**应保存在 `~/.gitconfig_local`、`~/.zshrc.local`、`~/.tmux.conf.local`
- **API 密钥和令牌**绝不应提交到仓库

## 自定义

### 环境变量

在 `~/.zshenv` 中添加环境变量（ZSH 官方推荐）：

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

**Git:** `~/.gitconfig_local`
```bash
[commit]
    # 使用 GPG 签名提交
    gpgsign = true

[user]
    name = 你的名字
    email = your.email@example.com
    signingkey = XXXXXXXX
```

**tmux:** `~/.tmux.conf.local`
```bash
# 个人 tmux 设置
set -g mouse on
set -g status-interval 5
```

## 致谢

本项目受到各种 dotfiles 仓库和社区的启发。
特别感谢：
- [GNU Stow](https://www.gnu.org/software/stow/) 的符号链接管理
- 为这些出色工具和配置做出贡献的开源社区

## 贡献

欢迎贡献！请随时提交问题和拉取请求。

## 许可证

本项目基于 MIT 许可证 - 详情请查看 [LICENSE](LICENSE) 文件。