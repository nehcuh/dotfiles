# Simple Dotfiles

一个简洁、轻量的 Linux 和 macOS dotfiles 配置。

## 快速开始

### 一键远程安装
```bash
# 安装默认配置包
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash

# 或者安装指定配置包
INSTALL_PACKAGES="git vim nvim zsh" curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install.sh | bash
```

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

## 支持的系统

- **macOS**: 所有近期版本
- **Linux**: Ubuntu、Debian、Arch、Fedora 及其衍生版本

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
