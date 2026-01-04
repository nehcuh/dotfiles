#!/bin/bash
set -e

echo "🧪 Testing Docker configuration..."
echo ""

# Check Docker
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo "Please start Docker Desktop or OrbStack first"
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Build minimal devbox
echo "📦 Building devbox (minimal)..."
docker-compose build

echo ""
echo "🚀 Starting devbox..."
docker-compose up -d

echo ""
echo "⏳ Waiting for container to be ready..."
sleep 3

echo ""
echo "🔍 Checking container status..."
docker-compose ps

echo ""
echo "📊 Checking tools inside container..."
docker exec devbox zsh -c "
echo 'Node: \$(node --version)'
echo 'Python: \$(python --version 2>/dev/null || echo \"not found\")'
echo 'Go: \$(go version)'
echo 'Rust: \$(rustc --version)'
echo 'Git: \$(git --version)'
echo ''
echo 'Projects directory:'
ls -la ~/Projects 2>/dev/null | head -5 || echo '  (empty or not mounted)'
"

echo ""
echo "✅ Test complete!"
echo ""
echo "📝 Next steps:"
echo "  Enter container:  make shell"
echo "  Or:              docker exec -it devbox zsh"
echo "  View logs:       make logs"
echo "  Stop:            make down"
echo ""
