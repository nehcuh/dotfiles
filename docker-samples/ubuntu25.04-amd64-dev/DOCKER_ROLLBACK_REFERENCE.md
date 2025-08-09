# Docker Compose 回滚清理快速参考

## 基本清理命令

### 1. 标准回滚流程
```bash
# 停止容器并删除卷
docker-compose down -v

# 删除本地构建的镜像  
docker-compose down --rmi local

# 重新启动（如果需要）
docker-compose up -d
```

### 2. 完整清理流程
```bash
# 使用提供的脚本进行完整重建
./docker-rebuild.sh -f

# 或手动执行
docker-compose down -v
docker-compose down --rmi local
docker-compose build --no-cache
docker-compose up -d
```

## 权限问题解决

### 检查 UID/GID 匹配
```bash
# 主机用户信息
echo "Host: UID=$(id -u), GID=$(id -g)"

# 容器用户信息（需要容器运行）
docker-compose exec devbox bash -c "echo 'Container: UID=\$(id -u), GID=\$(id -g)'"
```

### 设置环境变量（启动前）
```bash
export UID=$(id -u)
export GID=$(id -g)
export USER=$(whoami)
docker-compose up -d
```

### 修复挂载目录权限
```bash
# 主机端修复
sudo chown -R $(id -u):$(id -g) ~/Projects

# 容器内修复
docker-compose exec --user root devbox chown -R devuser:devuser /home/devuser
```

## 构建缓存问题

### 强制重新构建
```bash
# 清理构建缓存
docker builder prune -f

# 无缓存重建所有服务
docker-compose build --no-cache

# 无缓存重建单个服务
docker-compose build --no-cache devbox
```

### 处理基础镜像更新
```bash
# 拉取最新基础镜像
docker pull ubuntu@sha256:95a416ad2446813278ec13b7efdeb551190c94e12028707dd7525632d3cec0d1

# 无缓存重建
docker-compose build --no-cache --pull

# 使用脚本重建
./docker-rebuild.sh --full-clean
```

## 常用诊断命令

### 检查服务状态
```bash
# 查看所有服务状态
docker-compose ps

# 查看服务日志
docker-compose logs devbox
docker-compose logs --tail=50 -f postgres

# 检查资源使用
docker-compose top
docker stats
```

### 进入容器调试
```bash
# 进入开发容器
docker-compose exec devbox zsh

# 以 root 身份进入
docker-compose exec --user root devbox bash

# 运行单次命令
docker-compose exec devbox whoami
```

## 快速脚本使用

### 提供的脚本选项
```bash
# 标准重建
./docker-rebuild.sh

# 完整清理重建
./docker-rebuild.sh -f

# 快速重建（保留缓存）
./docker-rebuild.sh -q

# 清理卷数据重建
./docker-rebuild.sh -v

# 仅重建特定服务
./docker-rebuild.sh -s devbox

# 查看帮助
./docker-rebuild.sh -h
```

## 磁盘空间清理

### 检查 Docker 磁盘使用
```bash
docker system df
docker system df -v
```

### 清理未使用资源
```bash
# 清理停止的容器
docker container prune -f

# 清理未使用镜像
docker image prune -f

# 清理构建缓存
docker builder prune -f

# 清理所有未使用资源（慎用）
docker system prune -a -f
```

## 故障排查流程

### 1. 检查服务状态
```bash
docker-compose ps
```

### 2. 查看错误日志
```bash
docker-compose logs [service_name]
```

### 3. 检查网络连接
```bash
docker network ls
docker-compose exec devbox ping postgres
```

### 4. 验证权限设置
```bash
docker-compose exec devbox ls -la /home/
docker-compose exec devbox id
```

### 5. 重建问题服务
```bash
docker-compose stop [service_name]
docker-compose rm [service_name]
docker-compose up -d [service_name]
```

## 紧急情况处理

### 完全重置环境
```bash
# 停止所有服务
docker-compose down -v --rmi all

# 清理系统
docker system prune -a -f

# 重新构建
./docker-rebuild.sh -f
```

### 数据恢复（如有备份）
```bash
# 恢复卷数据
docker volume create postgres_data
docker run --rm -v postgres_data:/data -v /path/to/backup:/backup alpine cp -r /backup/* /data/

# 重新启动服务
docker-compose up -d
```
