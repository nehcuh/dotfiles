# Docker 权限问题解决指南

## 1. 检查 UID/GID 匹配

### 查看主机用户信息
```bash
# 获取当前用户 UID 和 GID
id

# 或者
echo "UID: $(id -u), GID: $(id -g)"

# 查看具体用户信息
getent passwd $USER
```

### 在容器内检查用户信息
```bash
# 进入运行中的容器
docker-compose exec devbox bash

# 查看容器内用户信息
id
whoami
```

## 2. 修复 Docker Compose 配置

### 方法1：动态传递 UID/GID（推荐）
```yaml
# docker-compose.yml 中的 devbox 服务
services:
  devbox:
    build:
      args:
        USERNAME: ${USER:-devuser}
        USER_UID: ${UID:-1000}
        USER_GID: ${GID:-1000}
    user: "${UID:-1000}:${GID:-1000}"  # 运行时指定用户
    volumes:
      - ${HOME}:/host-home
      - ${HOME}/Projects:/home/${USER:-devuser}/Projects
```

### 方法2：环境变量设置
```bash
# 在启动前设置环境变量
export UID=$(id -u)
export GID=$(id -g)
export USER=$(whoami)

# 然后启动服务
docker-compose up -d
```

### 方法3：.env 文件配置
```bash
# 创建 .env 文件
cat << EOF > .env
UID=$(id -u)
GID=$(id -g)
USER=$(whoami)
EOF
```

## 3. 修复 Dockerfile 用户权限

### 确保用户创建正确
```dockerfile
# 使用构建参数
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=1000

# 创建组和用户（如果不存在）
RUN if getent group ${USER_GID}; then \
      GROUP_NAME=$(getent group ${USER_GID} | cut -d: -f1); \
    else \
      groupadd --gid ${USER_GID} ${USERNAME} && GROUP_NAME=${USERNAME}; \
    fi && \
    if getent passwd ${USER_UID}; then \
      EXISTING_USER=$(getent passwd ${USER_UID} | cut -d: -f1) && \
      usermod -l ${USERNAME} -d /home/${USERNAME} -m -g ${GROUP_NAME} $EXISTING_USER; \
    else \
      useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME}; \
    fi

# 设置目录权限
RUN mkdir -p /home/${USERNAME} && \
    chown -R ${USERNAME}:${USER_GID} /home/${USERNAME}

USER ${USERNAME}
```

## 4. 卷权限修复

### 方法1：使用 init 容器
```yaml
services:
  init-permissions:
    image: busybox
    user: root
    volumes:
      - postgres_data:/data
    command: |
      sh -c "
        chown -R ${UID:-1000}:${GID:-1000} /data &&
        chmod -R 755 /data
      "

  devbox:
    depends_on:
      - init-permissions
    # ... 其他配置
```

### 方法2：entrypoint 脚本修复
```bash
#!/bin/bash
# entrypoint.sh

# 修复权限（如果需要）
if [ "$(id -u)" = "0" ]; then
    # 如果以 root 运行，修复权限后切换用户
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}
    exec gosu ${USERNAME} "$@"
else
    # 直接执行
    exec "$@"
fi
```

## 5. 常见权限问题排查

### 检查文件权限
```bash
# 检查挂载卷的权限
ls -la /path/to/volume

# 检查容器内权限
docker-compose exec devbox ls -la /home/devuser

# 检查进程运行用户
docker-compose exec devbox ps aux
```

### 修复权限问题
```bash
# 在容器内修复权限
docker-compose exec --user root devbox chown -R devuser:devuser /home/devuser

# 修复挂载目录权限
sudo chown -R $(id -u):$(id -g) ~/Projects
```

## 6. 特殊情况处理

### macOS 系统兼容性
```yaml
# docker-compose.yml
services:
  devbox:
    platform: linux/amd64  # 强制使用 amd64 架构
    volumes:
      # macOS 使用 :cached 优化性能
      - ${HOME}/Projects:/home/devuser/Projects:cached
```

### Windows WSL2 环境
```yaml
services:
  devbox:
    environment:
      # WSL2 环境变量
      - WSLENV=HOME:PATH
    volumes:
      # 使用 WSL 路径
      - /mnt/c/Users/${USER}/Projects:/home/devuser/Projects
```

## 7. 测试权限配置

### 创建测试脚本
```bash
#!/bin/bash
# test-permissions.sh

echo "=== 权限测试 ==="
echo "Host UID/GID: $(id -u)/$(id -g)"
echo "Host User: $(whoami)"

docker-compose exec devbox bash -c "
echo 'Container UID/GID: \$(id -u)/\$(id -g)'
echo 'Container User: \$(whoami)'
echo 'Testing file creation...'
touch /home/\${USERNAME}/test-file
ls -la /home/\${USERNAME}/test-file
rm -f /home/\${USERNAME}/test-file
echo 'Permission test completed successfully'
"
```

### 执行测试
```bash
chmod +x test-permissions.sh
./test-permissions.sh
```
