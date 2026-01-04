# Ubuntu 25.04 开发环境

**Good taste**: start simple, add only what you need.

---

## 快速开始

### 前置要求

```bash
# 安装 OrbStack（推荐）或 Docker Desktop
brew install orbstack
```

### 启动开发环境

```bash
# 启动容器
make up

# 进入容器
make shell
```

---

## 常用命令

| 操作 | 命令 |
|------|------|
| 启动 | `make up` |
| 停止 | `make down` |
| 进入 | `make shell` |
| 日志 | `make logs` |
| 状态 | `make status` |
| 测试 | `make test` |

---

## 架构

### 默认配置（原生 ARM64）

所有服务运行在 ARM64 架构，无需转译：

- ✅ devbox: Ubuntu 25.04 (ARM64)
- ✅ PostgreSQL 16 (ARM64)
- ✅ Redis 7 (ARM64)
- ✅ ClickHouse 24.7 (ARM64)
- ✅ MongoDB 8.0 (ARM64)

### 切换到 AMD64

如需 AMD64，在 `docker-compose.yml` 中添加：

```yaml
services:
  devbox:
    platform: linux/amd64  # 强制 AMD64
```

验证架构：
```bash
docker exec devbox uname -m
```
输出 `aarch64` = ARM64，`x86_64` = AMD64

---

## 数据库服务

```bash
# 基础数据库（PostgreSQL + Redis）
docker-compose -f docker-compose.yml -f docker-compose.db.yml up -d

# 完整服务（+ ClickHouse + MongoDB）
docker-compose -f docker-compose.yml -f docker-compose.db.yml -f docker-compose.extra.yml up -d
```

---

## 端口映射

- `2222` - SSH
- `5432` - PostgreSQL
- `6379` - Redis
- `8123` - ClickHouse
- `27017` - MongoDB
- `8080` - 应用端口

---

## 开发工具

容器包含：
- **语言**: Go 1.24, Git 2.48
- **工具**: curl, wget, vim, build-essential, cmake
- **Shell**: zsh + Starship prompt
- **项目**: `~/Projects` 挂载到容器的 `/home/devuser/Projects`

---

## 配置文件说明

```
.
├── docker-compose.yml       # 主配置
├── docker-compose.db.yml    # 数据库服务
├── docker-compose.extra.yml # 额外服务
├── Dockerfile               # 镜像定义
├── entrypoint.sh            # 启动脚本
├── Makefile                 # 命令快捷方式
└── README.md                # 本文档
```

---

## 哲学

**Linus 的原则**：
- 从简单开始
- 组合而非臃肿
- 不做硬编码
- 实用至上

> **"Theory and practice sometimes clash. Theory loses. Every single time."**
> — Linus Torvalds
