#!/bin/bash
set -euo pipefail

# Apple Container + Container-Compose 安装脚本
# 适用于 macOS 26 + Apple Silicon

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
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查系统要求
check_requirements() {
    log_info "Checking system requirements..."

    # 检查 macOS 版本
    local macos_version=$(sw_vers -productVersion)
    local major_version=$(echo $macos_version | cut -d. -f1)

    if [ "$major_version" -lt 26 ]; then
        log_error "macOS 26 or later is required. Current: $macos_version"
        log_info "Consider upgrading to macOS 26 for full containerization support"
        return 1
    fi
    log_success "macOS version: $macos_version ✓"

    # 检查架构
    local arch=$(uname -m)
    if [ "$arch" != "arm64" ]; then
        log_error "Apple Silicon (arm64) is required. Current: $arch"
        return 1
    fi
    log_success "Architecture: Apple Silicon ✓"

    # 检查是否已安装 Docker（会冲突）
    if docker info >/dev/null 2>&1; then
        log_warning "Docker is currently running"
        log_warning "You may want to stop Docker Desktop to avoid conflicts"
        read -p "Continue anyway? [y/N]: " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi

    return 0
}

# 安装 Apple Container
install_apple_container() {
    log_info "Installing Apple Container..."

    # 检查是否已安装
    if command -v container &>/dev/null; then
        local version=$(container --version 2>/dev/null || echo "unknown")
        log_success "Apple Container is already installed: $version"

        read -p "Reinstall anyway? [y/N]: " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi

        log_info "Uninstalling existing version..."
        if [ -f /usr/local/bin/uninstall-container.sh ]; then
            sudo /usr/local/bin/uninstall-container.sh -k || true
        else
            log_warning "Uninstall script not found, skipping"
        fi
    fi

    # 获取最新版本
    log_info "Fetching latest release information..."
    local latest_url="https://github.com/apple/container/releases/latest"

    # 尝试从 GitHub API 获取最新版本
    local download_page="$HOME/Downloads/apple-container-releases.html"

    if [ ! -f "$download_page" ]; then
        log_info "Opening download page in browser..."
        log_info "Please download the .pkg file manually"
        sleep 2
        open "https://github.com/apple/container/releases"
    else
        log_info "Download page already opened, check your Downloads folder"
    fi

    echo ""
    log_warning "MANUAL INSTALLATION REQUIRED"
    echo ""
    echo "Steps:"
    echo "  1. Download the latest .pkg file from:"
    echo "     https://github.com/apple/container/releases"
    echo ""
    echo "  2. Double-click the .pkg file to install"
    echo ""
    echo "  3. Enter your administrator password when prompted"
    echo ""
    echo "  4. After installation, run: container system start"
    echo ""
    read -p "Press Enter after you've completed the installation..."

    # 验证安装
    if command -v container &>/dev/null; then
        log_success "Apple Container installed successfully"
        container --version
        return 0
    else
        log_error "Apple Container not found after installation"
        return 1
    fi
}

# 安装 Container-Compose
install_container_compose() {
    log_info "Installing Container-Compose..."

    if command -v container-compose &>/dev/null; then
        log_success "Container-Compose is already installed"
        return 0
    fi

    # 检查 Homebrew
    if ! command -v brew &>/dev/null; then
        log_error "Homebrew is required but not installed"
        log_info "Install Homebrew from: https://brew.sh"
        return 1
    fi

    # 安装
    brew update
    brew install container-compose

    if command -v container-compose &>/dev/null; then
        log_success "Container-Compose installed successfully"
        container-compose --version || true
        return 0
    else
        log_error "Container-Compose installation failed"
        return 1
    fi
}

# 启动服务
start_container_system() {
    log_info "Starting Apple Container system service..."

    if ! command -v container &>/dev/null; then
        log_error "Apple Container is not installed"
        return 1
    fi

    # 启动服务
    container system start

    # 等待服务启动
    sleep 3

    # 验证
    if container system status &>/dev/null; then
        log_success "Container system is running"
        return 0
    else
        log_error "Failed to start container system"
        return 1
    fi
}

# 测试基础功能
test_basic_functionality() {
    log_info "Testing basic container functionality..."

    # 测试拉取镜像
    log_info "Pulling test image (ubuntu:25.04)..."
    if container pull ubuntu:25.04; then
        log_success "Image pull successful"
    else
        log_error "Failed to pull image"
        return 1
    fi

    # 测试运行容器
    log_info "Running test container..."
    local test_output=$(container run ubuntu:25.04 echo "Hello from Apple Container" 2>&1)

    if echo "$test_output" | grep -q "Hello from Apple Container"; then
        log_success "Container execution successful"
        return 0
    else
        log_error "Container execution failed"
        log_error "Output: $test_output"
        return 1
    fi
}

# 显示使用说明
show_usage_info() {
    echo ""
    log_success "Apple Container + Container-Compose setup complete!"
    echo ""
    echo "📝 Useful commands:"
    echo ""
    echo "  container system status    - Check system status"
    echo "  container pull <image>     - Pull container image"
    echo "  container run <image>      - Run container"
    echo "  container list             - List running containers"
    echo "  container images           - List images"
    echo ""
    echo "  container-compose up       - Start services (with docker-compose.yml)"
    echo "  container-compose down     - Stop services"
    echo "  container-compose ps       - List services"
    echo ""
    echo "📚 Documentation:"
    echo "  https://github.com/apple/container"
    echo "  https://github.com/Mcrich23/Container-Compose"
    echo ""
}

# 主流程
main() {
    echo "🚀 Apple Container + Container-Compose Installation"
    echo "=================================================="
    echo ""

    # 检查要求
    if ! check_requirements; then
        log_error "System requirements not met"
        exit 1
    fi

    echo ""

    # 安装 Apple Container
    if ! install_apple_container; then
        log_error "Failed to install Apple Container"
        exit 1
    fi

    echo ""

    # 安装 Container-Compose
    if ! install_container_compose; then
        log_warning "Failed to install Container-Compose"
        log_warning "You can install it later with: brew install container-compose"
    fi

    echo ""

    # 启动服务
    if ! start_container_system; then
        log_error "Failed to start container system"
        exit 1
    fi

    echo ""

    # 测试基础功能
    if test_basic_functionality; then
        show_usage_info
        exit 0
    else
        log_error "Basic functionality test failed"
        exit 1
    fi
}

# 运行主流程
main "$@"
