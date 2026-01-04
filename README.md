# Dotfiles

这里是我的个人配置文件仓库，使用 GNU Stow 进行统一管理。

## 目录结构

这个仓库尽量保持简洁，所有配置文件都位于 `stow-packs/` 目录下，按照软件名称分类。

```
~/Projects/dotfiles/
├── README.md           # 你正在阅读的文档
├── Makefile            # 常用命令快捷方式
├── stow-packs/         # 核心目录：放置所有的配置文件
│   ├── git/            # Git 配置
│   ├── zsh/            # Zsh 配置
│   ├── vim/            # Vim 配置
│   ├── nvim/           # Neovim 配置
│   ├── tmux/           # Tmux 配置
│   └── ...
├── scripts/            # 辅助脚本
└── docs/               # 归档文档
```

## 快速开始

你需要先安装 `stow` (macOS: `brew install stow`)。然后可以使用 `make` 命令来快速管理配置。

### 安装所有配置

```bash
make install
```

### 查看已安装的配置

```bash
make status
```

### 卸载所有配置

```bash
make uninstall
```

## 配置指南

### 如何添加新的配置？

1. 在 `stow-packs/` 下创建一个以软件名命名的目录，例如 `my-app`。
2. 在该目录下按照 Home 目录的结构放置文件。
   - 例如，如果你想管理 `~/.config/my-app/config.toml`：
   - 你应该创建文件：`stow-packs/my-app/.config/my-app/config.toml`
3. 运行 `make install` 或手动运行 `stow` 将其链接到 Home 目录。

### 如何修改现有配置？

所有安装的文件实际上都是指向 `stow-packs` 目录的软链接。你可以：

1. **直接修改生效**：去 `stow-packs/` 目录下找到对应的文件进行修改。
2. **在原位修改**：直接修改你的 `~/.zshrc` 等文件（如果它已经是指向本仓库的软链），修改会直接同步到本仓库。

### 如何删除某个配置？

如果你想停止管理某个软件的配置（例如 `vim`），可以使用：

```bash
cd stow-packs
stow -D vim
```

## 故障排除

如果遇到 "conflict" 错误，说明目标位置已经存在真实文件，Stow 不敢覆盖它。你需要先备份或删除该文件，然后再运行安装命令。

`make install` 脚本通常会自动处理备份，具体的备份逻辑可以查看 `scripts/stow.sh`。
