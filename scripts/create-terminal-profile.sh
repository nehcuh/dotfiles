#!/bin/bash
# Create Terminal.app configuration file with Hack Nerd Font

set -e

OUTPUT_DIR="$HOME/.dotfiles/stow-packs/macos/Library"
OUTPUT_FILE="$OUTPUT_DIR/Hack-Nerd-Font.terminal"

mkdir -p "$OUTPUT_DIR"

# 创建 Terminal.app 配置文件
cat > "$OUTPUT_FILE" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIORootViewerType</key>
    <string>2</string>
    <key>ColumnCount</key>
    <integer>80</integer>
    <key>CommandString</key>
    <string></string>
    <key>CursorType</key>
    <string>Default</string>
    <key>Font</key>
    <data>
    YnBsaXN0MDDUAQIDBAUGFRZYJHVlJERUdBtfYGxlJnRvbnQCTGFwaXJl
    c01hY2ludG9zaCCFqVxOU0Jlc2VvZmZTVW5TZXJpYWxpemVkVk5T
    TXV0YWJsZURhdGFWJGNsYXNzV05TSW1hZ2VfEBBlcnJvcjpSRVBMQUNF
    TUVfEBBmcmFtZXdvcmtTZXJpYWxpaXphdGlvbl8QFndoaXRlTGV2
   ZWxNZXNzYWdlU291cmNlVk5TRGF0YV8QEk9iamVjdFdpZHRoW3Rp
    dGxlXHdlaWdodF8QEk9iamVjdEhlaWdodFtzaXplWGl0ZW1XaWR0
    aFtzaXplWGV4dGVuc2lvbl8QEk9iamVjdEZyYW1lW2Nvcm5lclxz
    dHlsZV9yb3VuZG1hc2tZWZhY2VzX3NpemVbY2xhc3Njb2RlX291
    dHB1dF8QEk9iamVjdENvbmZpZ3VyYXRpb25zXG1ldGFkYXRhXHdp
    ZHRoWGV4dGVuc2lvbltmaWxlbmFtZV8QEk9iamVjdENvbnRlbnRz
    X2FycmF5X2ljb25maWxlZGF0YWxhbHBoYWVtYW51YWxmbGFnc1ts
    b2NhdGlvblttYW51YWxtZXRhZGF0YVtjb25maWctY2xhc3NzX25v
    YW1lXHVuaXF1ZUtleXZtYXNrZmFjZXNbc2l6ZVtjb250ZW50c1tz
    aXplXGltYWdlW2l0ZW1bY2xhc3Njb2RlX2ljb25maWxlXGZpbGVk
    YXRhWm91dHB1dFtmaWxlbmFtZV8QEk9iamVjdEtleXNMaXN0
    W2tleXNdbmFtZXNbb2JqZWN0c1t2ZXJzaW9uXG5hbWVzgAMCAIAD
    gASAC18QEk9iamVjdFdpZHRoW2hlaWdodF8QEk9iamVjdEhl
    aWdodFt3aWR0aF8QEk9iamVjdEJvdW5kc1tjb3JuZXJfc3H/
    </data>
    <key>FontAntialias</key>
    <true/>
    <key>FontHeightSpacing</key>
    <real>1.004032258064516</real>
    <key>FontWidthSpacing</key>
    <real>1</real>
    <key>ProfileCurrentVersion</key>
    <real>2.04</real>
    <key>RowCount</key>
    <integer>25</integer>
    <key>Stretchability</key>
    <real>1.1</real>
    <key>TerminalType</key>
    <string>xterm-256color</string>
    <key>WKFontName</key>
    <string>HackNerdFont-Regular</string>
    <key>WKFontSize</key>
    <real>13</real>
    <key>name</key>
    <string>Dotfiles - Hack Nerd Font</string>
    <key>type</key>
    <string>Window Settings</string>
</dict>
</plist>
EOF

echo "✓ Terminal.app 配置文件已创建: $OUTPUT_FILE"
echo ""
echo "使用方法:"
echo "  1. 双击 $OUTPUT_FILE"
echo "  2. Terminal.app 将打开并导入配置"
echo "  3. 在 Terminal 偏好设置中，选择 'Dotfiles - Hack Nerd Font' 作为默认配置"
echo ""
echo "或者从命令行:"
echo "  open '$OUTPUT_FILE'"

# 添加到 .gitignore 如果需要
echo ""
echo "注意: 这个配置文件将被 stow 管理并链接到 ~/Library/"
