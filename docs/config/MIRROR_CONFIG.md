# Mirror Configuration Guide

## Overview

The dotfiles system now includes **automatic mirror detection and configuration** for users in China. This significantly improves installation and update speeds for:

- Homebrew
- pip (Python)
- npm (Node.js)
- gem (Ruby)
- cargo (Rust)

## How It Works

### Automatic Detection

When you run `make install` or `./scripts/install.sh`, the system will:

1. **Detect your network environment** using multiple methods:
   - IP geolocation check (primary)
   - DNS response time comparison (backup)
   - System timezone check (fallback)

2. **Configure appropriate mirrors**:
   - If in China: Use high-speed Chinese mirrors
   - If outside China: Use official sources

### Detection Methods

The system uses a **multi-layered detection approach**:

#### Method 1: IP Geolocation (Primary)
```bash
# Queries multiple services with timeout:
- https://ipinfo.io/country (International)
- https://ipapi.co/country/ (International)
- https://ip.cn (Chinese service)
```

#### Method 2: DNS Speed Test (Backup, Linux only)
```bash
# Compares response times:
- 114.114.114.114 (China DNS)
- 8.8.8.8 (Google DNS)

# If China DNS is faster → Assume in China
```

#### Method 3: Timezone Check (Fallback)
```bash
# Checks if system timezone is:
- CST (China Standard Time)
- Contains "China"
```

## Manual Control

For a full list of install environment variables, see `docs/config/INSTALL_FLAGS.md`.

### Skip Auto-Detection

If you're offline or behind a restricted network:

```bash
DOTFILES_SKIP_MIRROR_DETECT=1 make install
```

### Force China Mirrors

If auto-detection fails but you're in China:

```bash
# Environment variable method
DOTFILES_FORCE_CHINA_MIRROR=true make install

# Or use the mirror management script
~/.dotfiles/scripts/manage-mirrors.sh china
```

### Force International Mirrors

If you're in China but prefer international sources:

```bash
# Environment variable method
DOTFILES_FORCE_NO_MIRROR=true make install

# Or use the mirror management script
~/.dotfiles/scripts/manage-mirrors.sh international
```

### Check Current Status

```bash
~/.dotfiles/scripts/manage-mirrors.sh status
```

Output example:
```
Current Mirror Configuration
================================
Mode: China (auto-detected)

Package Manager Sources:
------------------------
  pip:        https://mirrors.aliyun.com/pypi/simple/
  npm:        https://registry.npmmirror.com
  gem:        http://mirrors.aliyun.com/rubygems/
  cargo:      git://mirrors.ustc.edu.cn/crates.io-index

Homebrew Configuration:
-----------------------
  Bottles:    https://mirrors.ustc.edu.cn/homebrew-bottles
  Core:       https://mirrors.ustc.edu.cn/homebrew-core.git
```

## Mirror Sources

### China Mirrors (When IN_CHINA=true)

| Package Manager | Mirror Source | Location |
|----------------|---------------|----------|
| Homebrew (bottles) | USTC | https://mirrors.ustc.edu.cn/homebrew-bottles |
| Homebrew (core) | USTC | https://mirrors.ustc.edu.cn/homebrew-core.git |
| Homebrew (cask) | USTC | https://mirrors.ustc.edu.cn/homebrew-cask.git |
| pip | Aliyun | https://mirrors.aliyun.com/pypi/simple/ |
| npm | npmmirror (Taobao) | https://registry.npmmirror.com |
| gem | Aliyun | http://mirrors.aliyun.com/rubygems/ |
| cargo | USTC | git://mirrors.ustc.edu.cn/crates.io-index |

### International Sources (When IN_CHINA=false)

| Package Manager | Source |
|----------------|--------|
| Homebrew | Official (GitHub) |
| pip | https://pypi.org/simple/ |
| npm | https://registry.npmjs.org |
| gem | https://rubygems.org/ |
| cargo | https://github.com/rust-lang/crates.io-index |

## Configuration Files

### Managed by Stow Packages

Mirror settings are selected by installing one of these Stow packages:

- `stow-packs/mirrors-china/`: China mirrors
- `stow-packs/mirrors-international/`: Official sources

These packages provide:
- `~/.pip.conf`
- `~/.npmrc`
- `~/.gemrc`
- `~/.config/cargo.toml`

For Homebrew bottles in China, the installer exports `HOMEBREW_BOTTLE_DOMAIN` for the current session and prints a snippet you can add to a local shell config (e.g. `~/.zshrc.local`) if you want persistence.

Switching Homebrew tap remotes (e.g. `homebrew/core`) is opt-in because it rewrites your local brew configuration:

```bash
DOTFILES_HOMEBREW_TAP_CHINA_MIRRORS=true make install
```

### Backup Location

No repo files are rewritten during install anymore, so there is no mirror backup directory to manage.

## Homebrew Installation

### Standard Installation (International)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### China Installation Notes

When `IN_CHINA=true`, the installer sets these environment variables for speed:

```bash
# Sets environment variables for faster download
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"

# By default it still uses the official Homebrew install script.
# To opt-in to a third-party China installer:
DOTFILES_HOMEBREW_USE_CHINA_INSTALLER=true make install
```

## Troubleshooting

### Detection Issues

If detection is incorrect:

**Solution 1: Use environment variables**
```bash
# Force China mirrors
export DOTFILES_FORCE_CHINA_MIRROR=true
~/.dotfiles/scripts/manage-mirrors.sh china

# Force international mirrors
export DOTFILES_FORCE_NO_MIRROR=true
~/.dotfiles/scripts/manage-mirrors.sh international
```

**Solution 2: Check manually**
```bash
~/.dotfiles/scripts/manage-mirrors.sh status
```

### Mirror Not Working

If a mirror is slow or unavailable:

1. **Switch to the other mode**:
   ```bash
   ~/.dotfiles/scripts/manage-mirrors.sh international  # or 'china'
   ```

2. **Re-run auto-detection**:
   ```bash
   ~/.dotfiles/scripts/manage-mirrors.sh auto
   ```

3. **Re-run auto-detection**:
   ```bash
   ~/.dotfiles/scripts/manage-mirrors.sh auto
   ```

### Homebrew Installation Failed

If Homebrew installation fails:

```bash
# Remove failed installation
sudo rm -rf /opt/homebrew /usr/local/Homebrew

# Try with explicit mirror setting
DOTFILES_FORCE_CHINA_MIRROR=true make install
```

## Performance Comparison

### Installation Speed (Estimated)

| Environment | Without Mirror | With Mirror |
|-------------|---------------|-------------|
| China | 10-30 minutes | 2-5 minutes |
| International | 2-5 minutes | 2-5 minutes |
| China (Homebrew) | Often timeout | 3-5 minutes |

### Package Installation

```bash
# Example: Installing a large package
brew install python

# China with mirror: ~30 seconds
# China without mirror: 5-10 minutes or timeout
# International: ~30 seconds
```

## Advanced Usage

### Script Integration

Use in your own scripts:

```bash
#!/bin/bash

# Source the mirror detection
source ~/.dotfiles/scripts/lib/china-mirror.sh

# Detect environment
detect_china

# Use in conditional logic
if [[ "$IN_CHINA" == "true" ]]; then
    echo "Using China mirror: $CHINA_MIRROR_URL"
else
    echo "Using official source"
fi
```

### Custom Mirror Sources

To use custom mirrors, edit the files directly:

```bash
# Edit pip mirror
vim ~/.dotfiles/stow-packs/tools/.pip.conf

# Edit npm mirror
vim ~/.dotfiles/stow-packs/tools/.npmrc

# Re-apply
make install
```

## Environment Variables Reference

| Variable | Values | Description |
|----------|--------|-------------|
| `DOTFILES_FORCE_CHINA_MIRROR` | `true`/`false` | Force China mirrors regardless of detection |
| `DOTFILES_FORCE_NO_MIRROR` | `true`/`false` | Force international mirrors |
| `HOMEBREW_BOTTLE_DOMAIN` | URL | Homebrew binary mirror |
| `HOMEBREW_BREW_GIT_REMOTE` | URL | Homebrew git repository |
| `HOMEBREW_CORE_GIT_REMOTE` | URL | Homebrew Core git repository |
| `DOTFILES_HOMEBREW_TAP_CHINA_MIRRORS` | boolean | Switch brew tap remotes to China mirrors (opt-in) |

## See Also

- [Quick Start Guide](../guides/QUICKSTART.md)
- [Dotfiles Management](./DOTFILES_MANAGEMENT.md)
- [Main README](../../README.md)
