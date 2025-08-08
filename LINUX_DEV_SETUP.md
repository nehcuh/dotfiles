# Linux Development Environment Setup

这个文档详细说明了如何在 Linux 系统上设置完整的开发环境。

## 🚀 快速开始

### 基本安装（包含开发工具）
```bash
# 安装 dotfiles + 所有开发环境
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install-linux.sh | DEV_ALL=true bash

# 或者交互式选择开发环境
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install-linux.sh | DEV_ENV=true bash
```

### 分步骤安装
```bash
# 1. 先安装 dotfiles
curl -fsSL https://raw.githubusercontent.com/nehcuh/dotfiles/main/remote-install-linux.sh | bash

# 2. 然后单独设置开发环境
cd ~/.dotfiles
./scripts/setup-dev-environment.sh --all
```

## 🛠️ 开发环境详解

### 1. Homebrew for Linux
**安装的内容:**
- Homebrew 包管理器（仅 CLI 工具）
- 现代 Unix 工具：`bat`, `eza`, `fd`, `ripgrep`, `fzf`
- 开发工具：`neovim`, `tmux`, `starship`, `git-delta`
- 编程语言支持：Go, Rust 工具链

**验证安装:**
```bash
brew --version
which brew
brew list
```

### 2. Python 开发环境
**安装的内容:**
- `pyenv` - Python 版本管理器
- `uv` - 快速 Python 包管理器
- 最新 Python 版本
- 常用开发工具：`black`, `flake8`, `mypy`, `pytest`

**验证安装:**
```bash
python --version
pyenv versions
uv --version
which black flake8 mypy pytest
```

**使用示例:**
```bash
# 安装新的 Python 版本
pyenv install 3.12.0
pyenv global 3.12.0

# 使用 uv 创建项目环境
uv init my-project
cd my-project
uv add fastapi uvicorn
uv run python app.py
```

### 3. Java 开发环境
**安装的内容:**
- OpenJDK 17
- Maven 构建工具
- Gradle 构建工具

**验证安装:**
```bash
java -version
javac -version
mvn --version
gradle --version
```

### 4. Node.js 开发环境
**安装的内容:**
- `nvm` - Node.js 版本管理器
- 最新 LTS Node.js
- 常用全局包：`typescript`, `eslint`, `prettier`, `yarn`, `pnpm`

**验证安装:**
```bash
node --version
npm --version
nvm --version
which typescript eslint prettier yarn pnpm
```

**使用示例:**
```bash
# 安装和切换 Node.js 版本
nvm install 20
nvm use 20
nvm alias default 20
```

### 5. Go 开发环境
**安装的内容:**
- 最新 Go 编译器
- 开发工具：`gopls`, `golangci-lint`, `air`
- 正确的 GOPATH 配置

**验证安装:**
```bash
go version
echo $GOPATH
which gopls golangci-lint air
```

### 6. Rust 开发环境
**安装的内容:**
- Rust 工具链（通过 rustup）
- 常用工具：`rustfmt`, `clippy`
- Cargo 扩展：`cargo-edit`, `cargo-watch`, `cargo-tree`

**验证安装:**
```bash
rustc --version
cargo --version
rustup show
which cargo-edit cargo-watch
```

### 7. C/C++ 开发环境
**安装的内容:**
- GCC/Clang 编译器
- 构建工具：`cmake`, `ninja`
- 调试工具：`gdb`, `valgrind`
- 开发库和头文件

**验证安装:**
```bash
gcc --version
clang --version
cmake --version
gdb --version
```

## 🔧 故障排除

### Homebrew 安装问题
```bash
# 检查 Homebrew 是否正确安装
which brew
brew --version

# 如果命令不存在，手动添加到 PATH
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

### Python 环境问题
```bash
# 如果 pyenv 命令不存在
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# 重新安装 Python
pyenv install $(pyenv install --list | grep -E "^\s*3\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ')
```

### Node.js 环境问题
```bash
# 如果 nvm 命令不存在
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 重新安装 Node.js
nvm install --lts
nvm use --lts
nvm alias default lts/*
```

### Go 环境问题
```bash
# 如果 go 命令不存在，手动添加到 PATH
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# 添加到 shell 配置文件
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
echo 'export GOPATH=$HOME/go' >> ~/.zshrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.zshrc
```

## 📝 手动安装开发环境

如果自动安装失败，可以手动运行各个组件的安装：

```bash
cd ~/.dotfiles
./scripts/setup-dev-environment.sh rust      # 只安装 Rust
./scripts/setup-dev-environment.sh python    # 只安装 Python
./scripts/setup-dev-environment.sh java      # 只安装 Java
./scripts/setup-dev-environment.sh node      # 只安装 Node.js
./scripts/setup-dev-environment.sh go        # 只安装 Go
./scripts/setup-dev-environment.sh cpp       # 只安装 C/C++
```

## 🎯 验证完整安装

运行这个脚本来验证所有工具是否正确安装：

```bash
# 创建验证脚本
cat > ~/.dotfiles/verify-dev-env.sh << 'EOF'
#!/bin/bash

echo "🔍 Verifying development environment installation..."
echo

# Check Homebrew
if command -v brew &> /dev/null; then
    echo "✅ Homebrew: $(brew --version | head -1)"
else
    echo "❌ Homebrew: Not installed"
fi

# Check Python
if command -v python &> /dev/null; then
    echo "✅ Python: $(python --version)"
    echo "✅ pyenv: $(pyenv --version 2>/dev/null || echo 'Not found')"
    echo "✅ uv: $(uv --version 2>/dev/null || echo 'Not found')"
else
    echo "❌ Python: Not installed"
fi

# Check Java
if command -v java &> /dev/null; then
    echo "✅ Java: $(java -version 2>&1 | head -1)"
    echo "✅ Maven: $(mvn --version 2>/dev/null | head -1 || echo 'Not found')"
    echo "✅ Gradle: $(gradle --version 2>/dev/null | head -1 || echo 'Not found')"
else
    echo "❌ Java: Not installed"
fi

# Check Node.js
if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node --version)"
    echo "✅ npm: $(npm --version)"
    echo "✅ nvm: $(nvm --version 2>/dev/null || echo 'Not found')"
else
    echo "❌ Node.js: Not installed"
fi

# Check Go
if command -v go &> /dev/null; then
    echo "✅ Go: $(go version)"
else
    echo "❌ Go: Not installed"
fi

# Check Rust
if command -v rustc &> /dev/null; then
    echo "✅ Rust: $(rustc --version)"
    echo "✅ Cargo: $(cargo --version)"
else
    echo "❌ Rust: Not installed"
fi

# Check C/C++
if command -v gcc &> /dev/null; then
    echo "✅ GCC: $(gcc --version | head -1)"
else
    echo "❌ GCC: Not installed"
fi

if command -v clang &> /dev/null; then
    echo "✅ Clang: $(clang --version | head -1)"
else
    echo "❌ Clang: Not installed"
fi

echo
echo "🎉 Verification completed!"
EOF

chmod +x ~/.dotfiles/verify-dev-env.sh
~/.dotfiles/verify-dev-env.sh
```

## 🔄 更新和维护

### 更新 Homebrew 包
```bash
brew update && brew upgrade
```

### 更新 Python 工具
```bash
uv tool upgrade --all
```

### 更新 Node.js 全局包
```bash
npm update -g
```

### 更新 Go 工具
```bash
go install golang.org/x/tools/gopls@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### 更新 Rust 工具链
```bash
rustup update
cargo install-update -a  # 需要先安装: cargo install cargo-update
```

现在你的 Linux 开发环境就完全设置好了！🎉
