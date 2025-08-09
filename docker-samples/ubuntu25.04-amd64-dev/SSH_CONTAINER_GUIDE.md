# SSH 连接与容器配置指南

## SSH 连接方式

### 1. 通过 SSH 连接到容器
```bash
# 连接到 devbox 容器
ssh huchen@localhost -p 22

# 密码: 123456
```

### 2. 直接进入容器 (推荐)
```bash
# 使用 docker exec 进入
docker exec -it devbox zsh

# 使用 docker-compose 进入
docker-compose exec devbox zsh
```

## 容器配置特性

### ✅ 自动重启策略
- **策略**: `restart: unless-stopped`
- **作用**: 容器会在系统重启后自动启动，保留所有中间配置
- **好处**: 不用担心丢失容器内的临时配置和安装的软件

### ✅ 固定容器名称
- **名称**: `devbox`
- **好处**: 命令更简洁，无需记住长名称

### ✅ SSH 服务器
- **端口**: 22 (映射到主机 22 端口)
- **用户**: huchen
- **密码**: 123456
- **功能**: 可以通过 SSH 客户端连接，支持远程开发

### ✅ 挂载配置
- **主机 ~/Projects** → **容器 /home/huchen/Projects**
- **主机整个 HOME** → **容器 /host-home** (备用访问)

## 开发环境工具

容器中已安装的开发工具：
- **Shell**: Zsh + Starship prompt
- **语言**: Python, Node.js, Go, Rust, Java
- **工具**: Git, Docker CLI, Build tools
- **编辑器**: 可安装 vim/nano 或通过 SSH 使用主机编辑器

## 数据库连接

从容器内连接其他服务：

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

## SSH 安全配置

### 当前配置 (开发友好)
- ✅ 密码认证已启用
- ✅ Root 登录已启用 (便于管理)
- ⚠️ 使用简单密码 (123456)

### 生产环境建议
如果要在生产环境使用，建议修改安全配置：

```bash
# 1. 禁用密码认证，仅使用密钥
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# 2. 禁用 root 登录
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# 3. 配置 SSH 密钥
mkdir -p ~/.ssh
# 将公钥添加到 ~/.ssh/authorized_keys

# 4. 重启 SSH 服务
sudo systemctl restart sshd
```

## 容器持久化

### 自动保留的数据
- ✅ **~/Projects** - 与主机同步，完全持久化
- ✅ **容器内安装的软件** - 由于 `restart: unless-stopped` 策略保留
- ✅ **用户配置修改** - 如 ~/.zshrc, ~/.gitconfig 等

### 手动备份建议
对于重要的系统级配置，建议定期备份：

```bash
# 备份用户配置
docker cp devbox:/home/huchen/.zshrc ~/backup/
docker cp devbox:/home/huchen/.gitconfig ~/backup/

# 备份已安装的包列表
docker exec devbox dpkg -l > ~/backup/installed-packages.txt
```

## 常用操作

### 管理容器
```bash
# 查看状态
docker-compose ps

# 重启容器 (保留数据)
docker-compose restart devbox

# 停止容器
docker-compose stop devbox

# 启动容器
docker-compose start devbox

# 查看日志
docker logs devbox
```

### 文件传输
```bash
# 主机 → 容器
docker cp /path/to/file devbox:/home/huchen/

# 容器 → 主机
docker cp devbox:/home/huchen/file /path/to/local/

# 使用 SSH 传输 (如果配置了密钥)
scp file.txt huchen@localhost:~/
```

### 端口说明
- **22**: SSH 服务
- **21**: FTP (如需要)
- **80**: HTTP 服务
- **443**: HTTPS 服务
- **8080**: 开发服务器

## 故障排查

### SSH 连接问题
```bash
# 检查 SSH 服务状态
docker exec devbox ps aux | grep sshd

# 查看 SSH 配置
docker exec devbox cat /etc/ssh/sshd_config | grep -E "(Password|Root|Port)"

# 重启 SSH 服务
docker exec devbox sudo /usr/sbin/sshd -D &
```

### 容器重启问题
```bash
# 检查重启策略
docker inspect devbox | grep -A 5 RestartPolicy

# 手动设置重启策略
docker update --restart=unless-stopped devbox
```

## 最佳实践

1. **代码存储**: 所有项目代码放在 `~/Projects`，确保数据安全
2. **配置备份**: 定期备份重要配置文件
3. **软件安装**: 在容器内安装的开发工具会自动保留
4. **网络访问**: 使用服务名访问其他容器 (如 postgres, redis)
5. **安全意识**: 生产环境请修改默认密码和SSH配置

现在您的开发环境已完全配置好，支持 SSH 连接和自动重启！
