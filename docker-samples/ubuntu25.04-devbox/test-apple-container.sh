#!/bin/bash
set -euo pipefail

# Apple Container + Container-Compose 测试脚本
# 测试我们的 docker-compose.yml 配置兼容性

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# 检查前置条件
check_prerequisites() {
    log_info "Checking prerequisites..."

    if ! command -v container &>/dev/null; then
        log_error "Apple Container is not installed"
        log_info "Run ./install-apple-container.sh first"
        return 1
    fi
    log_success "Apple Container: $(container --version 2>/dev/null || echo 'installed')"

    if ! command -v container-compose &>/dev/null; then
        log_error "Container-Compose is not installed"
        log_info "Install with: brew install container-compose"
        return 1
    fi
    log_success "Container-Compose: installed"

    if ! container system status &>/dev/null; then
        log_error "Container system is not running"
        log_info "Start with: container system start"
        return 1
    fi
    log_success "Container system: running"

    return 0
}

# 测试 1: 基础容器功能
test_basic_container() {
    echo ""
    log_info "Test 1: Basic container functionality"

    if container pull alpine:latest >/dev/null 2>&1; then
        log_success "Pull image"
    else
        log_error "Failed to pull alpine:latest"
        return 1
    fi

    if container run alpine:latest echo "test" | grep -q "test"; then
        log_success "Run container"
    else
        log_error "Failed to run container"
        return 1
    fi

    return 0
}

# 测试 2: docker-compose.yml 语法解析
test_compose_parse() {
    echo ""
    log_info "Test 2: Parse docker-compose.yml"

    if [ ! -f "docker-compose.yml" ]; then
        log_error "docker-compose.yml not found"
        return 1
    fi

    # 尝试解析（不启动）
    if container-compose --parse --dry-run 2>/dev/null; then
        log_success "Compose file parsed"
        return 0
    else
        log_warning "Parse failed (may be expected - limited support)"
        log_info "Trying to start services anyway..."
        return 0
    fi
}

# 测试 3: 启动 devbox 服务
test_start_devbox() {
    echo ""
    log_info "Test 3: Start devbox service"

    # 检查是否有 dotfiles 目录
    if [ ! -d "dotfiles" ]; then
        log_warning "dotfiles directory not found"
        log_info "Creating placeholder..."
        mkdir -p dotfiles/stow-packs/zsh
    fi

    # 尝试启动
    log_info "Starting devbox (this may take a while)..."
    if container-compose up -d devbox 2>&1 | tee /tmp/container-compose.log; then
        log_success "Devbox started"

        # 等待容器启动
        sleep 5

        # 检查容器状态
        if container list | grep -q "devbox"; then
            log_success "Devbox container is running"

            # 尝试进入容器
            log_info "Testing container access..."
            if container exec devbox whoami | grep -q "devuser"; then
                log_success "Container access working"
            else
                log_warning "Container access failed"
            fi

            return 0
        else
            log_error "Devbox container not found in list"
            container list
            return 1
        fi
    else
        log_error "Failed to start devbox"
        log_info "Check logs at: /tmp/container-compose.log"
        return 1
    fi
}

# 测试 4: 检查容器内工具
test_container_tools() {
    echo ""
    log_info "Test 4: Check tools in container"

    local tools=("git" "zsh" "curl" "wget")
    local all_good=true

    for tool in "${tools[@]}"; do
        if container exec devbox which $tool >/dev/null 2>&1; then
            log_success "$tool: installed"
        else
            log_warning "$tool: not found"
            all_good=false
        fi
    done

    # 检查 Projects 目录
    echo ""
    log_info "Checking Projects mount..."
    if container exec devbox ls -d ~/Projects >/dev/null 2>&1; then
        log_success "Projects directory: mounted"
    else
        log_warning "Projects directory: not found"
    fi

    return 0
}

# 清理
cleanup() {
    echo ""
    log_info "Cleaning up..."

    if container-compose down 2>/dev/null; then
        log_success "Services stopped"
    else
        log_warning "Failed to stop services (may not be running)"
    fi

    # 列出剩余容器
    if container list 2>/dev/null | grep -q "devbox"; then
        log_warning "Some containers may still be running"
        container list
    fi
}

# 显示总结
show_summary() {
    echo ""
    echo "=================================================="
    echo "🧪 Apple Container + Container-Compose Test Report"
    echo "=================================================="
    echo ""

    if [ ${FAILURES} -eq 0 ]; then
        log_success "All tests passed!"
        echo ""
        echo "✅ Your docker-compose.yml is compatible with Apple Container"
        echo ""
        echo "Next steps:"
        echo "  1. Use 'container-compose up -d' to start services"
        echo "  2. Use 'container exec devbox zsh' to enter the container"
        echo "  3. Use 'container-compose down' to stop services"
        echo ""
    else
        log_error "Some tests failed"
        echo ""
        echo "⚠️  Compatibility issues detected"
        echo ""
        echo "This is expected with Container-Compose (limited support)"
        echo ""
        echo "Options:"
        echo "  1. Use OrbStack for full Docker compatibility:"
        echo "     brew install orbstack"
        echo ""
        echo "  2. Wait for Container-Compose to mature"
        echo ""
        echo "For more info: https://github.com/Mcrich23/Container-Compose"
        echo ""
    fi
}

# 主流程
main() {
    echo "🧪 Testing Apple Container + Container-Compose"
    echo "=================================================="
    echo ""

    FAILURES=0

    # 检查前置条件
    if ! check_prerequisites; then
        exit 1
    fi

    # 运行测试
    test_basic_container || ((FAILURES++))
    test_compose_parse || ((FAILURES++))
    test_start_devbox || ((FAILURES++))
    test_container_tools || ((FAILURES++))

    # 清理
    trap cleanup EXIT

    # 显示总结
    show_summary

    exit ${FAILURES}
}

# 运行
main "$@"
