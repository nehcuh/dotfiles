# Docker Development Environments

这个目录包含了预配置的 Docker 开发环境，可以快速搭建完整的开发环境。

## 可用环境

### Ubuntu 25.04 开发环境 (推荐)
**目录**: `ubuntu25.04-amd64-dev/`

**特性**:
- ✅ **完整开发环境**: Python, Node.js, Go, Rust, Java
- ✅ **SSH 支持**: 可通过 SSH 连接到容器 (端口 22, 用户: huchen, 密码: 123456)
- ✅ **自动重启**: 系统重启后自动启动，保留容器内配置
- ✅ **数据持久化**: `~/Projects` 目录与主机同步到容器 `/home/huchen/Projects`
- ✅ **数据库支持**: PostgreSQL, Redis, MongoDB 4.4, ClickHouse
- ✅ **固定容器名**: 容器名固定为 `devbox`

**快速开始**:
```bash
cd ubuntu25.04-amd64-dev
docker-compose up -d

# 进入开发容器
docker exec -it devbox zsh

# 或通过 SSH 连接
ssh huchen@localhost -p 22  # 密码: 123456
```

### Ubuntu 24.04 开发环境
**目录**: `ubuntu24.04-amd64-dev/`

**特性**:
- 基于 Ubuntu 24.04 LTS
- 包含基本开发工具
- 简化版配置，适合轻量级使用

## 使用指南

### 1. 环境要求
- Docker 和 Docker Compose
- 至少 8GB 可用磁盘空间
- 主机需要创建 `~/Projects` 目录

### 2. 启动环境
```bash
# 进入选择的环境目录
cd ubuntu25.04-amd64-dev

# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps
```

### 3. 连接到开发环境
```bash
# 方式1: 直接进入容器 (推荐)
docker exec -it devbox zsh

# 方式2: SSH 连接
ssh huchen@localhost -p 22

# 方式3: VS Code Remote Containers
# 在 VS Code 中安装 Remote-Containers 扩展
# 然后 "Attach to Running Container" → devbox
```

### 4. 数据库连接
所有数据库服务都可以从开发容器内访问：

```bash
# PostgreSQL
psql -h postgres -U dev -d devdb

# Redis
redis-cli -h redis

# MongoDB
mongo --host mongo -u root -p rootpass --authenticationDatabase admin

# ClickHouse
clickhouse-client --host clickhouse
```

## 环境管理

### 重启服务
```bash
# 重启开发容器
docker-compose restart devbox

# 重启所有服务
docker-compose restart
```

### 停止和清理
```bash
# 停止服务
docker-compose down

# 停止并删除数据卷 (危险操作)
docker-compose down -v
```

### 重建环境
```bash
# 使用提供的重建脚本 (ubuntu25.04 环境)
./docker-rebuild.sh

# 或手动重建
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 故障排查

### 常见问题

1. **MongoDB 启动失败 (AVX 错误)**
   - 已解决：使用 MongoDB 4.4.29 版本，无需 AVX 支持

2. **权限问题**
   - 检查主机 `~/Projects` 目录权限
   - 参考 `DOCKER_PERMISSIONS_GUIDE.md`

3. **SSH 连接失败**
   - 确认容器正在运行: `docker ps | grep devbox`
   - 检查 SSH 服务: `docker exec devbox ps aux | grep sshd`

### 获取帮助

详细文档请查看各环境目录中的说明文件：
- `SSH_CONTAINER_GUIDE.md` - SSH 连接指南
- `DEVBOX_USAGE.md` - 容器使用指南  
- `MONGODB_AVX_SOLUTION.md` - MongoDB 问题解决
- `DOCKER_PERMISSIONS_GUIDE.md` - 权限问题指南

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这些开发环境配置。

## 许可证

本项目采用与主仓库相同的许可证。
