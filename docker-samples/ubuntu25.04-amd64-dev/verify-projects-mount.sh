#!/bin/bash

# Projects 目录挂载验证脚本

set -e

echo "🔍 验证 devbox 容器的 Projects 目录挂载..."

# 检查容器是否运行
if ! docker ps --format "table {{.Names}}" | grep -q "^devbox$"; then
    echo "❌ 错误: devbox 容器未运行"
    echo "请先启动容器: docker-compose up -d devbox"
    exit 1
fi

# 检查主机 Projects 目录
if [ ! -d "$HOME/Projects" ]; then
    echo "❌ 错误: 主机 ~/Projects 目录不存在"
    echo "正在创建目录..."
    mkdir -p "$HOME/Projects"
    echo "✅ 已创建 ~/Projects 目录"
fi

# 检查容器内 Projects 目录
echo "📂 检查容器内 Projects 目录..."
if docker exec devbox test -d /home/huchen/Projects; then
    echo "✅ 容器内 /home/huchen/Projects 目录存在"
else
    echo "❌ 容器内 /home/huchen/Projects 目录不存在"
    exit 1
fi

# 检查挂载点
echo "🔗 检查挂载点..."
MOUNT_INFO=$(docker exec devbox mount | grep "/home/huchen/Projects" || echo "")
if [ -n "$MOUNT_INFO" ]; then
    echo "✅ Projects 目录已正确挂载:"
    echo "   $MOUNT_INFO"
else
    echo "❌ Projects 目录未挂载"
    exit 1
fi

# 测试文件同步
echo "🔄 测试文件同步..."
TEST_FILE="mount-test-$(date +%s).txt"

# 从容器创建文件
docker exec devbox bash -c "echo 'Created from container' > /home/huchen/Projects/$TEST_FILE"
if [ -f "$HOME/Projects/$TEST_FILE" ]; then
    echo "✅ 容器 → 主机 文件同步正常"
else
    echo "❌ 容器 → 主机 文件同步失败"
    exit 1
fi

# 从主机创建文件
echo "Created from host" > "$HOME/Projects/host-$TEST_FILE"
if docker exec devbox test -f "/home/huchen/Projects/host-$TEST_FILE"; then
    echo "✅ 主机 → 容器 文件同步正常"
else
    echo "❌ 主机 → 容器 文件同步失败"
    exit 1
fi

# 清理测试文件
rm -f "$HOME/Projects/$TEST_FILE" "$HOME/Projects/host-$TEST_FILE"
echo "🧹 已清理测试文件"

# 显示目录内容
echo ""
echo "📋 主机 ~/Projects 目录内容:"
ls -la "$HOME/Projects/" 2>/dev/null || echo "  目录为空或无权访问"

echo ""
echo "📋 容器 /home/huchen/Projects 目录内容:"
docker exec devbox ls -la /home/huchen/Projects/ 2>/dev/null || echo "  目录为空或无权访问"

echo ""
echo "🎉 Projects 目录挂载验证完成！"
echo ""
echo "📝 使用说明:"
echo "  - 主机路径: ~/Projects"
echo "  - 容器路径: /home/huchen/Projects"
echo "  - 文件在两端实时同步"
echo "  - 可以通过以下方式访问:"
echo "    • 直接进入: docker exec -it devbox zsh"
echo "    • SSH 连接: ssh huchen@localhost -p 22 (密码: 123456)"
