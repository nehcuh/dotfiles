# Browser Privacy Protection

这个配置为 Web 浏览器提供了隐私保护的设计，将敏感数据和配置分离管理。

## 隐私保护的文件和目录

以下文件和目录会被 .gitignore 忽略，不会提交到代码仓库：

### Firefox 相关
- `.mozilla/firefox/*.default-release/` - Firefox 默认配置文件目录
- `.mozilla/firefox/*.default-esr/` - Firefox ESR 配置文件目录
- `.mozilla/firefox/profiles.ini` - Firefox 配置文件列表
- `.mozilla/firefox/user.js` - Firefox 用户配置文件
- `.mozilla/firefox/prefs.js` - Firefox 偏好设置
- `.mozilla/firefox/places.sqlite` - Firefox 历史记录数据库
- `.mozilla/firefox/cookies.sqlite` - Firefox Cookie 数据库
- `.mozilla/firefox/formhistory.sqlite` - Firefox 表单历史记录
- `.mozilla/firefox/downloads.sqlite` - Firefox 下载历史记录
- `.mozilla/firefox/webappsstore.sqlite` - Firefox Web 存储
- `.mozilla/firefox/signons.sqlite` - Firefox 登录信息
- `.mozilla/firefox/permissions.sqlite` - Firefox 权限设置
- `.cache/mozilla/firefox/` - Firefox 缓存目录

### Chrome/Chromium 相关
- `.config/google-chrome/` - Chrome 配置目录
- `.config/chromium/` - Chromium 配置目录
- `.config/google-chrome/Default/` - Chrome 默认配置文件
- `.config/chromium/Default/` - Chromium 默认配置文件
- `.cache/google-chrome/` - Chrome 缓存目录
- `.cache/chromium/` - Chromium 缓存目录
- `.config/google-chrome/History` - Chrome 历史记录
- `.config/google-chrome/Cookies` - Chrome Cookie 文件
- `.config/google-chrome/Bookmarks` - Chrome 书签
- `.config/google-chrome/Preferences` - Chrome 偏好设置
- `.config/google-chrome/Top Sites` - Chrome 热门网站
- `.config/google-chrome/Visited Links` - Chrome 访问链接

### Brave 相关
- `.config/BraveSoftware/Brave-Browser/` - Brave 配置目录
- `.config/BraveSoftware/Brave-Browser/Default/` - Brave 默认配置文件
- `.cache/BraveSoftware/Brave-Browser/` - Brave 缓存目录
- `.config/BraveSoftware/Brave-Browser/History` - Brave 历史记录
- `.config/BraveSoftware/Brave-Browser/Cookies` - Brave Cookie 文件
- `.config/BraveSoftware/Brave-Browser/Bookmarks` - Brave 书签
- `.config/BraveSoftware/Brave-Browser/Preferences` - Brave 偏好设置

### 通用浏览器文件
- `*.log` - 浏览器日志文件
- `*.tmp` - 临时文件
- `*.temp` - 临时文件
- `*.cache` - 缓存文件
- `*.bak` - 备份文件
- `*.backup` - 备份文件
- `*.old` - 旧文件
- `*.session` - 会话文件
- `*.state` - 状态文件

## 安全配置

### 1. Firefox 隐私设置

```javascript
// 禁用遥测和数据收集
user_pref("toolkit.telemetry.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("browser.safebrowsing.enabled", false);
user_pref("app.update.auto", false);
user_pref("services.sync.enabled", false);
```

### 2. Chrome/Chromium 隐私设置

```json
{
  "privacy": {
    "telemetry": {
      "enabled": false,
      "metrics": false,
      "crash_reporting": false
    },
    "auto_update": {
      "enabled": false
    },
    "sync": {
      "enabled": false
    },
    "data_collection": {
      "enabled": false
    }
  }
}
```

### 3. Brave 隐私设置

```json
{
  "privacy": {
    "telemetry": {
      "enabled": false,
      "brave_telemetry": false,
      "p3a": false
    },
    "auto_update": {
      "enabled": false
    },
    "sync": {
      "enabled": false
    },
    "brave_specific": {
      "brave_shields": {
        "enabled": true,
        "aggressive_mode": true
      },
      "brave_rewards": {
        "enabled": false
      }
    }
  }
}
```

## 使用方法

### 1. 应用配置

```bash
cd ~/.dotfiles
stow -d stow-packs -t ~ browser-privacy
```

### 2. 迁移现有配置（可选）

```bash
./scripts/migrate-browser-privacy.sh
```

### 3. 手动管理

如果你想手动管理浏览器隐私配置：

```bash
# 应用配置
stow -d stow-packs -t ~ browser-privacy

# 移除配置
stow -d stow-packs -t ~ -D browser-privacy
```

## 配置说明

`.browser_privacy_config` 文件包含以下隐私保护设置：

- **遥测禁用**: 完全禁用遥测数据收集
- **自动更新控制**: 禁用浏览器自动更新
- **同步功能**: 禁用浏览器同步功能
- **数据收集**: 禁用各种数据收集机制
- **缓存管理**: 配置浏览器缓存文件位置
- **安全设置**: 启用各种安全相关的设置

## 环境变量

以下环境变量可以控制浏览器的隐私行为：

- `FIREFOX_TELEMETRY_DISABLED=1` - 禁用 Firefox 遥测
- `FIREFOX_AUTO_UPDATE=0` - 禁用 Firefox 自动更新
- `FIREFOX_SYNC_DISABLED=1` - 禁用 Firefox 同步
- `FIREFOX_DATA_COLLECTION_DISABLED=1` - 禁用 Firefox 数据收集

- `CHROME_TELEMETRY_DISABLED=1` - 禁用 Chrome 遥测
- `CHROME_AUTO_UPDATE=0` - 禁用 Chrome 自动更新
- `CHROME_SYNC_DISABLED=1` - 禁用 Chrome 同步
- `CHROME_DATA_COLLECTION_DISABLED=1` - 禁用 Chrome 数据收集

- `BRAVE_TELEMETRY_DISABLED=1` - 禁用 Brave 遥测
- `BRAVE_AUTO_UPDATE=0` - 禁用 Brave 自动更新
- `BRAVE_SYNC_DISABLED=1` - 禁用 Brave 同步
- `BRAVE_DATA_COLLECTION_DISABLED=1` - 禁用 Brave 数据收集

## 浏览器别名

### Firefox 别名
- `firefox` - 基本隐私模式
- `firefox-safe` - 安全模式（禁用遥测和自动更新）
- `firefox-private` - 私密模式（禁用所有数据收集）

### Chrome 别名
- `chrome` - 基本隐私模式
- `chrome-safe` - 安全模式（禁用遥测和自动更新）
- `chrome-private` - 私密模式（禁用所有数据收集）

### Chromium 别名
- `chromium` - 基本隐私模式
- `chromium-safe` - 安全模式（禁用遥测和自动更新）
- `chromium-private` - 私密模式（禁用所有数据收集）

### Brave 别名
- `brave` - 基本隐私模式
- `brave-safe` - 安全模式（禁用遥测和自动更新）
- `brave-private` - 私密模式（禁用所有数据收集）

## 清理函数

### Firefox 清理函数
- `firefox_clean_cache` - 清理 Firefox 缓存
- `firefox_clean_data` - 清理 Firefox 数据
- `firefox_reset_profile` - 重置 Firefox 配置文件

### Chrome 清理函数
- `chrome_clean_cache` - 清理 Chrome 缓存
- `chrome_clean_data` - 清理 Chrome 数据

### Chromium 清理函数
- `chromium_clean_cache` - 清理 Chromium 缓存
- `chromium_clean_data` - 清理 Chromium 数据

### Brave 清理函数
- `brave_clean_cache` - 清理 Brave 缓存
- `brave_clean_data` - 清理 Brave 数据

### 通用清理函数
- `browsers_clean_all_cache` - 清理所有浏览器缓存
- `browsers_clean_all_data` - 清理所有浏览器数据

### 状态检查函数
- `browser_show_privacy_status` - 显示浏览器隐私状态
- `browser_privacy_check` - 检查浏览器隐私设置

## 注意事项

1. **首次使用**: 建议运行迁移脚本来移动现有的敏感配置
2. **重启浏览器**: 配置更改后需要重启浏览器
3. **扩展管理**: 某些扩展可能需要重新配置
4. **性能考虑**: 隐私模式可能会影响某些功能的性能
5. **网站兼容性**: 某些网站可能在隐私模式下无法正常工作

## 故障排除

### 配置不生效

```bash
# 重新加载配置
source ~/.browser_privacy_config

# 重启浏览器
# 关闭并重新打开浏览器
```

### 扩展问题
某些扩展可能会在隐私模式下受限，这是正常的隐私保护行为。

### 性能问题
如果遇到性能问题，可以尝试：

```bash
# 清理缓存
browsers_clean_all_cache

# 清理数据
browsers_clean_all_data
```

### Firefox 配置文件问题
如果 Firefox 配置文件出现问题：

```bash
# 重置 Firefox 配置文件
firefox_reset_profile
```

## 安全建议

1. **定期清理**: 定期清理缓存、历史记录和 Cookie
2. **禁用在线功能**: 除非必要，否则禁用所有在线功能
3. **使用隐私模式**: 优先使用隐私模式浏览网页
4. **监控文件访问**: 定期检查浏览器创建的文件和目录
5. **更新浏览器**: 定期更新浏览器以修复安全漏洞

## 与其他隐私包的区别

浏览器隐私包与其他编辑器隐私包的主要区别：

- **配置文件格式**: 浏览器使用 JSON 和 JavaScript 配置文件
- **数据类型**: 浏览器处理更多的敏感数据类型
- **网络功能**: 浏览器有更多的网络相关功能需要配置
- **扩展系统**: 浏览器扩展系统更复杂，需要更多隐私配置
- **同步功能**: 浏览器同步功能更强大，需要更严格的隐私控制

## 最佳实践

1. **定期备份**: 定期备份重要的书签和密码
2. **分层次配置**: 根据需求配置不同级别的隐私保护
3. **选择性启用**: 根据需要选择性启用某些功能
4. **监控日志**: 定期检查浏览器日志以发现异常
5. **使用插件**: 使用隐私保护插件增强安全性

## 故障排除常见问题

### 问题 1: 浏览器无法启动
**解决方案**: 检查配置文件语法，确保没有语法错误。

### 问题 2: 某些网站无法正常工作
**解决方案**: 临时降低隐私级别或添加网站例外。

### 问题 3: 扩展无法正常工作
**解决方案**: 检查扩展权限设置，或使用兼容的隐私模式。

### 问题 4: 同步功能无法使用
**解决方案**: 这是正常的隐私保护行为，如需同步请临时启用。

### 问题 5: 性能下降
**解决方案**: 清理缓存和数据，或调整隐私设置级别。

## 贡献指南

欢迎贡献新的浏览器隐私保护配置：

1. Fork 项目
2. 创建功能分支
3. 添加新的隐私保护配置
4. 测试配置
5. 提交 Pull Request

## 许可证

本配置采用 MIT 许可证。