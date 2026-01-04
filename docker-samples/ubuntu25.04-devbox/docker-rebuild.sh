#!/bin/bash

# Docker Compose 重建和缓存清理脚本
# 解决基础镜像变化导致的构建异常问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
Docker Compose 重建和缓存清理脚本

用法: $0 [选项]

选项:
  -h, --help          显示此帮助信息
  -f, --full-clean    执行完整清理（包括系统清理）
  -q, --quick         快速重建（仅重建镜像）
  -v, --volumes       同时清理卷数据
  -s, --service NAME  仅重建指定服务

示例:
  $0                  # 标准重建流程
  $0 -f               # 完整清理后重建
  $0 -s devbox        # 仅重建 devbox 服务
  $0 -v               # 清理卷数据后重建
EOF
}

# 解析命令行参数
FULL_CLEAN=false
QUICK_BUILD=false
CLEAN_VOLUMES=false
SERVICE_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--full-clean)
            FULL_CLEAN=true
            shift
            ;;
        -q|--quick)
            QUICK_BUILD=true
            shift
            ;;
        -v|--volumes)
            CLEAN_VOLUMES=true
            shift
            ;;
        -s|--service)
            SERVICE_NAME="$2"
            shift 2
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 检查 docker-compose 文件是否存在
if [[ ! -f "docker-compose.yml" ]]; then
    log_error "当前目录下未找到 docker-compose.yml 文件"
    exit 1
fi

log_info "开始 Docker Compose 重建流程..."

# 1. 停止并清理现有容器
log_info "正在停止并清理现有容器..."
if [[ "$CLEAN_VOLUMES" == "true" ]]; then
    docker-compose down -v
    log_success "已停止容器并清理卷数据"
else
    docker-compose down
    log_success "已停止容器"
fi

# 2. 清理本地镜像
log_info "正在清理本地构建的镜像..."
docker-compose down --rmi local 2>/dev/null || true
log_success "已清理本地镜像"

# 3. 检查是否需要完整系统清理
if [[ "$FULL_CLEAN" == "true" ]]; then
    log_warning "执行完整系统清理..."
    
    # 清理未使用的镜像
    log_info "清理未使用的镜像..."
    docker image prune -f
    
    # 清理构建缓存
    log_info "清理构建缓存..."
    docker builder prune -f
    
    # 清理系统（慎重）
    read -p "是否要清理所有未使用的 Docker 资源？这会删除所有停止的容器、未使用的网络、镜像和构建缓存 [y/N]: " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker system prune -a -f
        log_success "已完成系统清理"
    fi
fi

# 4. 重新构建镜像
log_info "开始重新构建镜像..."

if [[ "$QUICK_BUILD" == "true" ]]; then
    # 快速构建
    if [[ -n "$SERVICE_NAME" ]]; then
        docker-compose build "$SERVICE_NAME"
        log_success "已重建服务: $SERVICE_NAME"
    else
        docker-compose build
        log_success "已重建所有服务"
    fi
else
    # 使用 --no-cache 完全重建
    if [[ -n "$SERVICE_NAME" ]]; then
        docker-compose build --no-cache "$SERVICE_NAME"
        log_success "已完全重建服务: $SERVICE_NAME"
    else
        docker-compose build --no-cache
        log_success "已完全重建所有服务"
    fi
fi

# 5. 启动服务
log_info "启动服务..."
if [[ -n "$SERVICE_NAME" ]]; then
    docker-compose up -d "$SERVICE_NAME"
    log_success "已启动服务: $SERVICE_NAME"
else
    docker-compose up -d
    log_success "已启动所有服务"
fi

# 6. 检查服务状态
log_info "检查服务状态..."
sleep 5
docker-compose ps

# 7. 显示服务健康状况
log_info "服务健康状况检查..."
for service in $(docker-compose config --services); do
    if docker-compose ps "$service" | grep -q "Up"; then
        log_success "✓ $service 服务运行正常"
    else
        log_error "✗ $service 服务启动失败"
        log_info "查看 $service 服务日志:"
        docker-compose logs --tail=10 "$service"
    fi
done

# 8. 提供有用的后续命令
echo
log_info "重建完成！以下是一些有用的命令:"
echo "  查看所有服务状态: docker-compose ps"
echo "  查看服务日志:     docker-compose logs [service_name]"
echo "  进入开发容器:     docker-compose exec devbox zsh"
echo "  重启特定服务:     docker-compose restart [service_name]"

# 9. 检查磁盘使用情况
echo
log_info "Docker 磁盘使用情况:"
docker system df

log_success "Docker Compose 重建流程完成！"
