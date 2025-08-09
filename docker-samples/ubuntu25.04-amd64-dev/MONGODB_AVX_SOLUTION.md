# MongoDB AVX 兼容性问题解决方案

## 问题描述

MongoDB 5.0+ 需要 CPU 支持 AVX (Advanced Vector Extensions) 指令集，但某些 CPU 或虚拟环境不支持 AVX，导致启动失败并出现以下错误：

```
WARNING: MongoDB 5.0+ requires a CPU with AVX support, and your current system does not appear to have that!
/usr/local/bin/docker-entrypoint.sh: line 416: 28 Illegal instruction "${mongodHackedArgs[@]}" --fork
```

## 根本原因

根据 MongoDB 官方文档：
- MongoDB 5.0+ 要求 x86_64 架构的 CPU 支持 AVX 指令集
- 通常 Sandy Bridge 或更新的 Intel CPU 支持 AVX
- Core i3/i5/i7/i9 系列通常支持，但 Pentium 和 Celeron 系列通常不支持
- 某些虚拟化环境可能不支持或未启用 AVX

## 解决方案

### 方案1：使用 MongoDB 4.4 版本（推荐）

这是最简单和可靠的解决方案，已在配置中实施：

```yaml
# docker-compose.yml
services:
  mongo:
    image: mongo:4.4.29  # 降级到 4.4 最新稳定版
    platform: linux/amd64
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: rootpass
    volumes:
      - mongo_data:/data/db
    ports:
      - "27017:27017"
```

**优点**：
- ✅ 不需要 AVX 支持
- ✅ 稳定且经过充分测试
- ✅ 与大多数应用程序兼容
- ✅ 安装配置简单

**缺点**：
- ❌ 缺少 MongoDB 5.0+ 的新功能
- ❌ 安全更新周期较短

### 方案2：使用兼容性镜像

某些第三方构建了兼容性版本：

```yaml
services:
  mongo:
    image: mongo:5.0-focal  # 使用 Ubuntu focal 基础镜像
    # 或者
    image: bitnami/mongodb:5.0  # Bitnami 版本可能有更好兼容性
```

### 方案3：从源码构建（高级）

如果需要 MongoDB 5.0+ 功能：

```dockerfile
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y build-essential
# 使用特定的编译参数构建
ENV CCFLAGS="-march=nehalem"
# ... 构建 MongoDB
```

**注意**：此方案复杂且不推荐用于生产环境。

### 方案4：检测并切换

创建启动脚本自动检测 AVX 支持：

```bash
#!/bin/bash
# detect-mongo-version.sh

check_avx_support() {
    if docker run --rm --platform linux/amd64 ubuntu:20.04 \
        sh -c 'apt update && apt install -y cpuid && cpuid | grep AVX' > /dev/null 2>&1; then
        echo "mongo:7"  # 支持 AVX，使用最新版
    else
        echo "mongo:4.4.29"  # 不支持 AVX，使用兼容版本
    fi
}

MONGO_VERSION=$(check_avx_support)
export MONGO_VERSION
docker-compose up -d
```

然后在 docker-compose.yml 中使用：

```yaml
services:
  mongo:
    image: ${MONGO_VERSION:-mongo:4.4.29}
```

## CPU 兼容性检查

### 检查主机 CPU 支持

```bash
# Linux 系统
grep -o avx /proc/cpuinfo | head -1

# macOS 系统
sysctl -a | grep machdep.cpu.features

# 在容器中检查
docker run --rm ubuntu:20.04 \
  sh -c 'apt update && apt install -y cpuid && cpuid | grep AVX'
```

### 检查虚拟化环境

```bash
# 检查虚拟化类型
docker run --rm ubuntu:20.04 cat /proc/cpuinfo | grep hypervisor

# 在不同平台测试 MongoDB
docker run --rm --platform linux/amd64 mongo:5.0 mongod --version
docker run --rm --platform linux/amd64 mongo:4.4.29 mongod --version
```

## 版本对比

| MongoDB 版本 | AVX 要求 | 发布状态 | 推荐使用场景 |
|-------------|---------|----------|------------|
| 4.4.x       | ❌ 不需要 | 稳定维护 | 兼容性优先 |
| 5.0.x       | ✅ 需要   | 长期支持 | 新功能需求 |
| 6.0.x       | ✅ 需要   | 当前版本 | 最新功能   |
| 7.0.x       | ✅ 需要   | 最新版本 | 生产不推荐 |

## 测试验证

修复后的验证命令：

```bash
# 检查服务状态
docker-compose ps mongo

# 测试连接（MongoDB 4.4 使用 mongo 客户端）
docker-compose exec mongo mongo --eval "db.runCommand('ping')"

# 查看启动日志
docker-compose logs mongo

# 检查版本
docker-compose exec mongo mongo --eval "db.version()"
```

## 故障排查

如果仍然遇到问题：

1. **检查平台设置**：
   ```yaml
   services:
     mongo:
       platform: linux/amd64  # 确保使用 x64 架构
   ```

2. **清理旧容器**：
   ```bash
   docker-compose down -v
   docker-compose pull mongo
   docker-compose up -d mongo
   ```

3. **查看详细日志**：
   ```bash
   docker-compose logs --tail=50 mongo
   ```

4. **尝试不同版本**：
   ```bash
   # 测试不同版本
   docker run --rm mongo:4.4.29 mongod --version
   docker run --rm mongo:5.0 mongod --version
   ```

## 生产环境建议

- ✅ 使用 MongoDB 4.4.29（最后的稳定版本）
- ✅ 定期备份数据
- ✅ 监控服务状态
- ✅ 计划未来的迁移策略
- ❌ 避免在生产环境中使用实验性解决方案

## 总结

MongoDB AVX 兼容性问题最简单的解决方案是使用 MongoDB 4.4.29 版本。这个版本：
- 不需要 AVX 支持
- 功能完整且稳定
- 广泛兼容各种环境
- 维护成本低

当前配置已经实施了这个解决方案，所有服务现在都能正常运行。
