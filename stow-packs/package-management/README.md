# Package Management Configuration

This package provides intelligent package management tools for your dotfiles setup.

## Features

- **Smart Package Manager**: Intelligent software download and update management
- **Package State Manager**: Track and manage software package installations and updates  
- **Smart Installer**: Intelligent software installation with caching and update management
- **Package Cache Management**: Avoid redundant downloads with intelligent caching
- **Update Detection**: Check for available updates across multiple package managers

## Files

### Configuration Files
- `~/.package-manager-config` - Main configuration file with aliases and functions
- `~/.config/package-manager/` - Configuration directory
- `~/.cache/package-manager/` - Cache directory for downloads
- `~/.local/state/package-manager/` - State directory for tracking installations

### Scripts
- `smart-package-manager.sh` - Main package management script
- `package-state-manager.sh` - Package state tracking script  
- `smart-installer.sh` - Smart package installer with caching

## Usage

### Basic Commands

```bash
# Smart install a package (checks if already installed)
smart-install git

# Batch install multiple packages
smart-install git node python tmux zsh

# Update a specific package
smart-install update git

# Check package status
smart-install status git

# List all available packages
smart-install list

# Clean package cache
smart-install clean-cache
```

### Package State Management

```bash
# Show package status
package-state status git

# Show all packages status
package-state status-all

# Check for updates
package-state check-updates

# Show system information
package-state system-info

# Show installation history
package-state history
```

### Package Manager Commands

```bash
# Smart package management
package-manager install git
package-manager update-all
package-manager status-all
package-manager clean-cache
```

## Configuration

### Environment Variables

```bash
# Cache directories
export PACKAGE_CACHE_DIR="$HOME/.cache/package-manager"
export PACKAGE_STATE_DIR="$HOME/.local/state/package-manager"
export PACKAGE_CONFIG_DIR="$HOME/.config/package-manager"

# Update settings
export PACKAGE_AUTO_UPDATE=false
export PACKAGE_UPDATE_INTERVAL=86400  # 24 hours
export PACKAGE_CACHE_EXPIRY=604800    # 7 days
```

### Aliases

```bash
# Quick installation aliases
alias install='smart-install'
alias pkg='smart-install'
alias pkg-install='smart-install install'
alias pkg-update='smart-install update'
alias pkg-status='smart-install status'
alias pkg-list='smart-install list'

# Package state management aliases
alias pkg-state='package-state'
alias pkg-status-all='package-state status-all'
alias pkg-check-updates='package-state check-updates'
alias pkg-system-info='package-state system-info'

# Package manager aliases
alias pkg-mgr='smart-package-manager'
alias pkg-upgrade-all='smart-package-manager update-all'
alias pkg-clean='smart-package-manager clean-cache'
```

### Functions

```bash
# Quick install function
quick_install() {
    local package="$1"
    if [ -z "$package" ]; then
        echo "Usage: quick_install <package>"
        return 1
    fi
    smart-install install "$package"
}

# Batch install function
batch_install() {
    if [ $# -eq 0 ]; then
        echo "Usage: batch_install <package1> [package2] ..."
        return 1
    fi
    smart-install batch "$@"
}

# Update all function
update_all_packages() {
    smart-package-manager update-all
    package-state check-updates
}

# Clean all function
clean_all_packages() {
    smart-package-manager clean-cache
    smart-install clean-cache
}

# Show system status
show_package_status() {
    package-state system-info
    package-state status-all
}
```

## Package Database

The smart installer includes a comprehensive database of common software packages:

### Development Tools
- git, node, python, go, rust, ruby, php, java
- make, cmake, ninja, meson, gradle, maven, ant

### Editors
- vim, nvim, vscode, zed, sublime, atom

### Browsers
- firefox, chrome, brave, edge, opera

### System Tools
- tmux, zsh, fish, bash, curl, wget, jq

### Utilities
- ripgrep, fd, exa, bat, htop, ncdu, tree, rsync, ssh

### Containers and Virtualization
- docker, virtualbox, vmware, vagrant, kubernetes, minikube

### Database
- mysql, postgresql, sqlite, redis, mongodb

### Cloud and DevOps
- aws, gcloud, azure, terraform, ansible, puppet, chef

## Integration with Existing Setup

### Shell Integration
The configuration automatically integrates with your existing shell setup:

```bash
# Source the configuration
source ~/.package-manager-config

# Add to your shell rc file
echo 'source ~/.package-manager-config' >> ~/.bashrc
```

### Privacy Protection
The package manager respects your privacy settings:

- No telemetry or usage tracking
- Local cache management
- No data collection
- Optional update checks

### Cross-Platform Support
Works on multiple platforms:

- **macOS**: Homebrew support
- **Linux**: APT, DNF, YUM, Pacman, Zypper, Emerge support
- **Windows**: Scoop, Chocolatey support (WSL/MSYS2)

## Cache Management

### Automatic Cache Cleaning
- Old downloads are automatically cleaned after 7 days
- Backup files are cleaned after 30 days
- Empty directories are automatically removed

### Manual Cache Management
```bash
# Clean all cache
clean_all_packages

# Clean specific package cache
smart-install clean-cache

# Show cache size
du -sh ~/.cache/package-manager/
```

## State Management

### Package State Tracking
- Installation history
- Version tracking
- Update status
- Last update timestamp

### State File Location
- Main state file: `~/.local/state/package-manager/packages.json`
- Configuration: `~/.config/package-manager/config.json`
- History log: `~/.local/state/package-manager/history.log`

## Usage Examples

### Daily Development Setup
```bash
# Install common development tools
batch_install git node python go tmux zsh

# Install editors
batch_install vim nvim vscode

# Install utilities
batch_install ripgrep fd exa bat htop
```

### System Maintenance
```bash
# Check for updates
pkg-check-updates

# Update all packages
update_all_packages

# Clean cache
clean_all_packages

# Show system status
show_package_status
```

### Project-Specific Setup
```bash
# Install project dependencies
batch_install git node python make

# Verify installations
pkg-status git
pkg-status node
pkg-status python
```

## Best Practices

### 1. Regular Updates
- Check for updates regularly
- Use batch operations for efficiency
- Clean cache periodically

### 2. Cache Management
- Monitor cache size
- Clean old downloads
- Use automatic cleanup

### 3. Privacy Protection
- The package manager respects your privacy settings
- No data collection or telemetry
- Local-only operation

### 4. System Integration
- Works with existing package managers
- Respects system configurations
- Cross-platform compatibility

## Troubleshooting

### Common Issues

1. **Package not found in database**
   - Check package name spelling
   - Use system package manager directly
   - Add custom package to database

2. **Permission errors**
   - Use sudo for system packages
   - Check user permissions
   - Verify package manager installation

3. **Cache issues**
   - Clean cache manually
   - Check disk space
   - Verify directory permissions

### Getting Help

```bash
# Show help for smart installer
smart-install help

# Show help for package state manager
package-state help

# Show help for package manager
smart-package-manager help
```

## Contributing

To add new packages to the database:

1. Edit the `PACKAGE_DB` array in `smart-installer.sh`
2. Add package information (name, URL, type, verification command)
3. Test the installation
4. Update documentation

## License

This package is part of your dotfiles setup and follows the same license terms.