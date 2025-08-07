# Docker Privacy Protection

这个配置为 Docker 提供了隐私保护的设计，将敏感数据和配置分离管理。

## 隐私保护的文件和目录

以下文件和目录会被 .gitignore 忽略，不会提交到代码仓库：

### Docker 配置和缓存
- `.docker/` - Docker 配置目录
- `.docker/config.json` - Docker 客户端配置
- `.docker/daemon.json` - Docker 守护进程配置
- `.docker/certs/` - Docker 证书目录
- `.docker/contexts/` - Docker 上下文配置

### Docker 数据和日志
- `.local/share/docker/` - Docker 数据目录
- `.cache/docker/` - Docker 缓存目录
- `.local/state/docker/` - Docker 状态数据
- `Library/Group\ Containers/group.com.docker/` - Docker Desktop 数据（macOS）

### 容器和镜像相关
- `docker-compose.override.yml` - Docker Compose 覆盖配置
- `docker-compose.prod.yml` - 生产环境配置
- `.dockerignore` - Docker 构建忽略文件
- `Dockerfile.*` - 特定环境的 Dockerfile

## 安全配置

### 1. 禁用遥测和数据收集
```json
{
    "experimental": "disabled",
    "features": {
        "buildkit": false
    },
    "plugins": {
        "scan": {
            "disable": true
        }
    }
}
```

### 2. 启用内容信任和 TLS 验证
```json
{
    "disable-legacy-registry": true,
    "userland-proxy": false,
    "no-new-privileges": true,
    "icc": false,
    "ip-forward": false,
    "ip-masq": false
}
```

### 3. 网络隔离配置
```json
{
    "iptables": false,
    "userns-remap": "default",
    "selinux-enabled": false,
    "seccomp-profile": ""
}
```

## 使用方法

### 1. 应用配置
```bash
cd ~/.dotfiles
stow -d stow-packs -t ~ docker-privacy
```

### 2. 迁移现有配置（可选）
```bash
./scripts/migrate-docker-privacy.sh
```

### 3. 手动管理
如果你想手动管理 Docker 隐私配置：

```bash
# 应用配置
stow -d stow-packs -t ~ docker-privacy

# 移除配置
stow -d stow-packs -t ~ -D docker-privacy
```

## 配置说明

`.docker_privacy_config` 文件包含以下隐私保护设置：

- **内容信任**: 启用 Docker 内容信任验证
- **TLS 验证**: 强制使用 TLS 验证所有连接
- **构建禁用**: 禁用 BuildKit 和实验性功能
- **扫描禁用**: 禁用 Docker 扫描建议
- **网络隔离**: 禁用容器间通信和网络转发
- **权限限制**: 限制容器权限和能力
- **缓存管理**: 配置缓存和日志管理

## 环境变量

以下环境变量可以控制 Docker 的隐私行为：

- `DOCKER_CONTENT_TRUST=1` - 启用内容信任
- `DOCKER_TLS_VERIFY=1` - 启用 TLS 验证
- `DOCKER_BUILDKIT=0` - 禁用 BuildKit
- `DOCKER_SCAN_SUGGEST=false` - 禁用扫描建议
- `DOCKER_CLI_EXPERIMENTAL=disabled` - 禁用实验性功能
- `DOCKER_HIDE_LEGACY_COMMANDS=1` - 隐藏遗留命令

## 可用命令

### 基础命令
- `docker-safe` - 安全的 Docker 命令
- `docker-private` - 私有模式的 Docker 命令
- `docker-offline` - 离线模式的 Docker 命令

### 清理命令
- `docker_clean_cache` - 清理 Docker 缓存
- `docker_clean_logs` - 清理 Docker 日志
- `docker_clean_images` - 清理未使用的镜像
- `docker_clean_containers` - 清理已停止的容器
- `docker_clean_networks` - 清理未使用的网络
- `docker_clean_volumes` - 清理未使用的卷
- `docker_reset_privacy` - 重置所有隐私设置

### 状态检查
- `docker_show_privacy_status` - 显示隐私状态
- `docker_privacy_check` - 检查隐私设置

### 安全操作
- `docker_secure_run` - 运行安全容器
- `docker_secure_build` - 构建安全镜像

## 安全建议

### 1. 镜像安全
- 使用官方镜像或受信任的镜像
- 定期更新镜像
- 扫描镜像中的漏洞
- 使用多阶段构建减少镜像大小

### 2. 容器安全
- 使用只读文件系统
- 限制容器能力
- 使用非特权用户运行容器
- 隔离网络访问

### 3. 网络安全
- 使用私有网络
- 限制端口暴露
- 使用加密通信
- 监控网络流量

### 4. 数据安全
- 使用卷而非绑定挂载
- 加密敏感数据
- 定期备份数据
- 清理敏感文件

## 注意事项

1. **首次使用**: 建议运行迁移脚本来移动现有的敏感配置
2. **重启 Docker**: 配置更改后需要重启 Docker 守护进程
3. **权限管理**: 某些隐私设置可能需要管理员权限
4. **性能考虑**: 隐私模式可能会影响 Docker 的某些功能性能

## 故障排除

### 配置不生效
```bash
# 重新加载配置
source ~/.docker_privacy_config

# 重启 Docker 守护进程
sudo systemctl restart docker
```

### 权限问题
```bash
# 检查 Docker 权限
docker info

# 修复 Docker 权限
sudo usermod -aG docker $USER
```

### 网络问题
```bash
# 重置 Docker 网络
docker network prune -f

# 检查网络配置
docker network ls
```

### 内容信任问题
```bash
# 初始化内容信任
docker trust key generate

# 检查信任状态
docker trust inspect
```

## 迁移指南

### 从现有配置迁移
1. 备份现有 Docker 配置
2. 运行迁移脚本
3. 重启 Docker 守护进程
4. 验证隐私设置

### 回滚配置
1. 停止 Docker 守护进程
2. 恢复备份的配置
3. 重启 Docker 守护进程
4. 移除隐私配置

## 与其他工具的集成

### Docker Compose
- 使用 `docker-compose-safe` 别名
- 在 compose 文件中添加隐私设置
- 使用环境变量控制行为

### Kubernetes
- 使用 Pod 安全策略
- 配置网络策略
- 使用秘密管理

### CI/CD
- 在构建脚本中使用隐私设置
- 清理构建缓存
- 使用安全的镜像扫描

## 监控和审计

### 日志监控
- 定期检查 Docker 日志
- 监控异常行为
- 设置日志轮转

### 安全审计
- 定期检查容器权限
- 审计网络访问
- 检查镜像来源

### 性能监控
- 监控资源使用
- 检查容器性能
- 优化配置参数