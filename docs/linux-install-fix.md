# Linux 安装修复说明

## 修复的问题

### 1. Homebrew 自动安装
- **问题**: Linux 上的 Homebrew 安装需要用户手动确认
- **修复**: 移除了交互式提示，现在会自动安装 Linux Homebrew

### 2. VS Code 安装改进
- **问题**: VS Code 安装可能因为权限或包管理器问题失败
- **修复**: 
  - 添加了 `wget` 依赖安装
  - 修复了 `sudo` 权限使用
  - 增加了 `.deb` 和 `.rpm` 包的直接安装方法
  - 改进了错误处理

### 3. Zed 编辑器安装
- **问题**: Zed 编辑器安装脚本可能失败
- **修复**: 使用官方安装脚本，确保更好的兼容性

## 测试安装

### 运行测试脚本
```bash
cd ~/.dotfiles
./scripts/test-linux-install.sh
```

### 运行完整安装
```bash
cd ~/.dotfiles
./scripts/install-unified.sh
```

## 安装过程

脚本现在会自动：

1. **检测系统环境** - 识别 Linux 发行版和包管理器
2. **安装基础包** - git, stow, curl, build-essential 等
3. **安装 Homebrew** - Linux 版本的 Homebrew（带清华镜像）
4. **安装编辑器** - VS Code 和 Zed 编辑器
5. **配置环境** - 设置 Python, Node.js, Git 等
6. **应用配置** - 通过 stow 应用所有 dotfiles

## 故障排除

### 如果 VS Code 安装失败
```bash
# 手动安装 VS Code (Ubuntu/Debian)
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update
sudo apt install -y code

# 手动安装 VS Code (Fedora/RHEL)
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install -y code
```

### 如果 Homebrew 安装失败
```bash
# 手动安装 Linux Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### 如果 Zed 安装失败
```bash
# 手动安装 Zed
curl -fsSL https://zed.dev/install.sh | sh
```

## 验证安装

安装完成后，检查以下命令是否可用：

```bash
# 检查 VS Code
code --version

# 检查 Zed
zed --version

# 检查 Homebrew
brew --version

# 检查其他工具
nvim --version
tmux -V
git --version
```

## 支持的 Linux 发行版

- **Ubuntu/Debian/Linux Mint**: 使用 apt 包管理器
- **Fedora/CentOS/RHEL**: 使用 dnf 包管理器  
- **Arch Linux/Manjaro**: 使用 pacman 包管理器
- **其他发行版**: 使用通用安装方法

## 注意事项

1. **需要网络连接** - 所有安装都需要从网络下载包
2. **需要 sudo 权限** - 系统级安装需要管理员权限
3. **可能需要重启终端** - 环境变量更改可能需要重启才能生效
4. **安装时间** - 完整安装可能需要 10-30 分钟，取决于网络速度