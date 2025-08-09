# Devbox 容器快速操作指南

现在 devbox 服务已配置为使用固定的容器名称 `devbox`，这样可以简化日常操作。

## 容器基本操作

### 进入开发容器
```bash
# 使用简洁的容器名称进入
docker exec -it devbox zsh

# 或者仍然可以使用 docker-compose
docker-compose exec devbox zsh
```

### 执行单次命令
```bash
# 直接在容器中执行命令
docker exec devbox whoami
docker exec devbox pwd
docker exec devbox ls -la /home/huchen

# 查看环境变量
docker exec devbox env | grep USER
```

### 文件传输
```bash
# 从主机复制文件到容器
docker cp /path/to/local/file devbox:/home/huchen/

# 从容器复制文件到主机  
docker cp devbox:/home/huchen/file /path/to/local/
```

## 开发工作流

### 快速访问
```bash
# 进入容器并切换到项目目录
docker exec -it devbox zsh -c "cd ~/Projects && zsh"

# 直接在 Projects 目录执行命令
docker exec -w /home/huchen/Projects devbox ls -la
```

### 端口访问
开发容器暴露了以下端口：
- `21-22`: SSH/FTP 端口
- `80`: HTTP 服务
- `443`: HTTPS 服务  
- `8080`: 开发服务器端口

```bash
# 测试端口连通性
curl http://localhost:8080
```

### 日志查看
```bash
# 查看容器日志
docker logs devbox

# 实时查看日志
docker logs -f devbox

# 查看最近的日志
docker logs --tail=50 devbox
```

## 数据库连接

从 devbox 容器内连接其他数据库服务：

### PostgreSQL
```bash
docker exec -it devbox psql -h postgres -U dev -d devdb
```

### Redis  
```bash
docker exec -it devbox redis-cli -h redis
```

### MongoDB
```bash
docker exec -it devbox mongo --host mongo -u root -p rootpass --authenticationDatabase admin
```

### ClickHouse
```bash
docker exec -it devbox clickhouse-client --host clickhouse
```

## 项目管理

### 检查挂载目录
```bash
# 查看 Projects 目录挂载
docker exec devbox ls -la /home/huchen/Projects

# 验证与主机同步
docker exec devbox touch /home/huchen/Projects/test-file
ls -la ~/Projects/test-file
```

### 开发工具
```bash
# 检查开发工具
docker exec devbox node --version
docker exec devbox python --version  
docker exec devbox go version
docker exec devbox rustc --version
```

## 服务管理

### 容器控制
```bash
# 启动 devbox
docker-compose up -d devbox

# 停止 devbox
docker-compose stop devbox

# 重启 devbox
docker-compose restart devbox

# 查看状态
docker-compose ps devbox
```

### 资源监控
```bash
# 查看容器资源使用
docker stats devbox

# 查看容器进程
docker exec devbox ps aux
```

## 故障排查

### 检查容器状态
```bash
# 检查容器是否运行
docker ps | grep devbox

# 查看容器详细信息
docker inspect devbox

# 检查网络连接
docker exec devbox ping postgres
docker exec devbox ping redis
```

### 重建容器
```bash
# 如果遇到问题，重建 devbox
docker-compose stop devbox
docker-compose rm -f devbox
docker-compose up -d devbox
```

## 便利别名

可以在主机的 `.bashrc` 或 `.zshrc` 中添加以下别名：

```bash
# Devbox 相关别名
alias devbox='docker exec -it devbox zsh'
alias devbox-root='docker exec -it --user root devbox bash'
alias devbox-logs='docker logs -f devbox'
alias devbox-restart='docker-compose restart devbox'
```

使用别名后：
```bash
# 直接进入开发容器
devbox

# 以 root 身份进入（用于系统管理）
devbox-root

# 查看日志
devbox-logs

# 重启容器
devbox-restart
```

## 最佳实践

1. **数据持久化**: 重要数据保存在 `~/Projects` 目录，它与主机同步
2. **配置管理**: dotfiles 配置在容器重建时会保留
3. **端口规划**: 开发服务使用 8080 端口避免冲突
4. **资源限制**: 必要时可以在 docker-compose.yml 中添加资源限制
5. **网络隔离**: 所有服务在同一网络中，便于内部通信

现在您可以更便捷地使用 `devbox` 作为您的开发环境了！
