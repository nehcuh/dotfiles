# uv - 现代 Python 包管理器使用指南

**为什么选择 uv 而不是 pyenv？**

| 特性 | uv | pyenv + pip + venv |
|------|-----|-------------------|
| **速度** | 🟢 极快 (Rust) | 🟡 慢 (Shell) |
| **依赖管理** | 🟢 内置 (类似 npm) | 🔌 需要 pip-tools |
| **虚拟环境** | 🟢 自动管理 | 🔌 手动 venv |
| **锁文件** | 🟢 uv.lock | 🔌 需额外工具 |
| **版本切换** | 🟢 项目级别 | 🟢 全局级别 |
| **安装速度** | 🟢 快 10-100 倍 | 🟡 常规速度 |
| **兼容性** | 🟢 100% pip 兼容 | 🟢 标准 |

**Linus 的评价**:
> **"uv 才是正确的方向。用 Rust 重写 Python 工具链？他妈的 genius。"**

---

## 📦 当前配置

### 已移除
- ❌ `pyenv` (Python 版本管理)
- ❌ `.pyenv` 配置
- ❌ pyenv 初始化脚本

### 已保留
- ✅ `uv` (通过 Homebrew 安装)
- ✅ PATH 配置 (`~/.local/bin`)

---

## 🚀 uv 快速开始

### 1. 基本使用

#### 创建新项目
```bash
# 创建项目（自动设置虚拟环境）
uv init myproject
cd myproject

# 添加依赖
uv add requests pandas

# 添加开发依赖
uv add --dev pytest black ruff

# 运行 Python
uv run python main.py

# 运行脚本
uv run script.py
```

#### 在现有项目中使用
```bash
cd existing-project

# 初始化（创建 uv.lock）
uv init

# 安装 requirements.txt
uv pip install -r requirements.txt

# 或从 requirements.txt 转换
uv add -r requirements.txt
```

---

### 2. 依赖管理

#### 查看依赖
```bash
# 列出所有依赖
uv pip list

# 查看依赖树
uv pip tree

# 检查过期包
uv pip list --outdated

# 查看包详情
uv pip show requests
```

#### 添加/删除依赖
```bash
# 添加包（自动更新 pyproject.toml 和 uv.lock）
uv add django

# 指定版本
uv add "django>=4.0,<5.0"

# 从 git 安装
uv add "git+https://github.com/user/repo.git"

# 删除包
uv remove requests

# 更新所有依赖
uv lock --upgrade
```

---

### 3. 虚拟环境管理

#### uv 自动管理虚拟环境
```bash
# uv 在项目目录中自动创建和管理虚拟环境
# 位置: .venv/

# 查看虚拟环境路径
uv venv --verbose

# 手动创建虚拟环境
uv venv

# 删除并重新创建
uv venv --clear
```

#### 激活虚拟环境（可选）
```bash
# 通常不需要！uv run 会自动处理

# 但如果需要：
source .venv/bin/activate  # Linux/macOS
.venv\Scripts\activate     # Windows

# 退出
deactivate
```

---

### 4. 运行命令

#### 使用 uv run
```bash
# 运行 Python 脚本（自动使用虚拟环境）
uv run python main.py
uv run python script.py

# 运行测试
uv run pytest

# 运行任何命令
uv run flask run
uv run jupyter notebook

# 传递参数
uv run python script.py --arg value
```

#### 使用 uv pip
```bash
# 标准 pip 命令都支持
uv pip install package
uv pip uninstall package
uv pip freeze > requirements.txt
uv pip list
```

---

### 5. Python 版本管理

#### uv 的版本管理方式
```bash
# uv 不管理全局 Python 版本（不像 pyenv）
# 它使用系统已有的 Python 或自动下载

# 查看当前 Python 版本
uv run python --version

# 指定 Python 版本（创建项目时）
uv init --python 3.12 myproject

# 或在 pyproject.toml 中指定
cat >> pyproject.toml << EOF
[project.requires-python]
">=3.11"
EOF
```

#### 结合系统 Python
```bash
# macOS (Homebrew)
brew install python@3.12
brew install python@3.11

# uv 会自动找到这些版本
uv run --python 3.12 python --version
uv run --python 3.11 python --version
```

---

### 6. 项目模板

#### Web 项目
```bash
# FastAPI 项目
uv init myapi
cd myapi
uv add fastapi uvicorn[standard]
uv add --dev pytest

# 创建 main.py
cat > main.py << 'EOF'
from fastapi import FastAPI
app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}
EOF

# 运行
uv run uvicorn main:app --reload
```

#### 数据科学项目
```bash
# Data Science 项目
uv init datascience
cd datascience
uv add pandas numpy matplotlib seaborn jupyter
uv add --dev pytest black ruff

# 启动 Jupyter
uv run jupyter notebook
```

#### 脚本项目
```bash
# 简单脚本（不需要项目结构）
mkdir ~/scripts
cd ~/scripts

# 安装包到用户目录
uv pip install --user requests click

# 直接运行
python script.py  # Python 会找到用户包
```

---

### 7. 性能优势

#### 对比安装速度
```bash
# 安装 Django 项目依赖
time uv pip install -r requirements.txt
# uv: ~2 秒

time pip install -r requirements.txt
# pip: ~20 秒

# uv 快 10 倍！
```

#### 对比依赖解析
```bash
# 解析复杂依赖
time uv add django pandas numpy
# uv: ~1 秒

time pip install django pandas numpy
# pip: ~15 秒
```

---

### 8. 与其他工具集成

#### Docker
```dockerfile
FROM python:3.12-slim

# 安装 uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# 复制项目文件
COPY . /app
WORKDIR /app

# 同步依赖
RUN uv sync

# 运行
CMD ["uv", "run", "python", "main.py"]
```

#### CI/CD (GitHub Actions)
```yaml
name: Test

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install uv
        uses: astral-sh/setup-uv@v1
      - name: Install dependencies
        run: uv sync
      - name: Run tests
        run: uv run pytest
```

#### Makefile
```makefile
.PHONY: install dev test lint

install:
	uv sync

dev:
	uv run flask run --debug

test:
	uv run pytest

lint:
	uv run ruff check .
	uv run black --check .

format:
	uv run ruff check . --fix
	uv run black .
```

---

### 9. 常用命令速查

```bash
# 项目初始化
uv init project-name
cd project-name

# 依赖管理
uv add package                    # 添加包
uv add --dev package              # 添加开发依赖
uv remove package                 # 删除包
uv lock --upgrade                 # 更新所有依赖

# 运行
uv run python script.py           # 运行脚本
uv run pytest                     # 运行测试
uv run command                    # 运行任何命令

# 虚拟环境
uv venv                           # 创建虚拟环境
uv venv --clear                   # 重建虚拟环境

# 包管理
uv pip list                       # 列出包
uv pip freeze                     # 冻结依赖
uv pip show package              # 查看包详情

# 缓存管理
uv cache clean                    # 清理缓存
uv cache prune                    # 清理过期缓存
```

---

### 10. 最佳实践

#### 项目结构
```
myproject/
├── .venv/              # 虚拟环境（不要提交）
├── .python-version     # Python 版本（可选）
├── pyproject.toml      # 项目配置（提交）
├── uv.lock             # 锁定版本（提交）
├── src/
│   └── myproject/
│       └── __init__.py
└── tests/
    └── test_main.py
```

#### .gitignore
```gitignore
.venv/
__pycache__/
*.pyc
*.pyo
.pytest_cache/
.coverage
htmlcov/
dist/
build/
*.egg-info/
```

#### pyproject.toml 示例
```toml
[project]
name = "myproject"
version = "0.1.0"
description = "My awesome project"
requires-python = ">=3.11"
dependencies = [
    "requests>=2.31.0",
    "click>=8.1.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "black>=23.7.0",
    "ruff>=0.0.280",
]

[project.scripts]
mycli = "myproject.cli:main"

[tool.black]
line-length = 88
target-version = ['py311']

[tool.ruff]
line-length = 88
select = ["E", "F", "I", "N", "W"]
```

---

### 11. 从 pyenv/pip 迁移

#### 迁移步骤
```bash
# 1. 导出现有依赖
pip freeze > requirements.txt

# 2. 退出 pyenv 环境
deactivate  # 如果在 pyenv 环境中

# 3. 创建新项目
uv init newproject
cd newproject

# 4. 安装依赖
uv add -r ../requirements.txt

# 5. 测试
uv run pytest

# 6. 删除旧的虚拟环境
rm -rf ~/.pyenv/versions/3.11.0/envs/oldproject
```

#### 卸载 pyenv
```bash
# macOS (Homebrew)
brew uninstall pyenv

# 删除配置
rm -rf ~/.pyenv

# 从 shell 配置中移除 pyenv 行
# ✅ 已自动完成（我们刚才做的）
```

---

## 🔧 故障排除

### 常见问题

#### 1. uv 命令未找到
```bash
# 检查安装
which uv

# 重新安装
brew install uv

# 或通过官方脚本
curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### 2. 找不到 Python 版本
```bash
# 查看可用的 Python
uv python list

# 安装特定版本
uv python install 3.12

# 指定版本运行
uv run --python 3.12 python script.py
```

#### 3. 虚拟环境问题
```bash
# 重建虚拟环境
uv venv --clear

# 删除缓存
uv cache clean
```

#### 4. 依赖冲突
```bash
# 查看冲突
uv add package  # 会显示冲突

# 解决：更新 uv.lock
uv lock --upgrade

# 或手动解决依赖版本
uv add "package==1.2.3"
```

---

## 📚 资源链接

- **官方文档**: https://docs.astral.sh/uv/
- **GitHub**: https://github.com/astral-sh/uv
- **对比 pip**: https://docs.astral.sh/uv/comparison/pip/
- **最佳实践**: https://docs.astral.sh/uv/guides/

---

## 💡 Linus 的最后一句话

> **"uv 解决了 Python 生态最糟糕的部分：慢、复杂、不可靠。用 Rust 重写才是正道。这才是他妈的实用主义。"**

**评分**: 🟢 **10/10** - Python 工具链的未来

---

## ✅ 已完成的配置

- ✅ 移除 pyenv 配置
- ✅ 移除 pyenv 初始化脚本
- ✅ 保留 uv 安装（Homebrew）
- ✅ PATH 配置正确

**下一步**: 尝试上面的命令，开始使用 uv！
