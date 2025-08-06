#!/usr/bin/env pwsh
# Cross-platform stow script for Windows (PowerShell)
# This script provides similar functionality to the bash stow.sh

param(
    [Parameter(Position=0)]
    [ValidateSet("install", "remove", "list", "status", "help")]
    [string]$Command = "help",
    
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Packages
)

# Set variables
$DOTFILES_DIR = $PSScriptRoot
$STOW_DIR = Join-Path $DOTFILES_DIR "stow-packs"
$TARGET_DIR = $env:USERPROFILE

# Colors for output
$colors = @{
    Red = "`e[0;31m"
    Green = "`e[0;32m"
    Yellow = "`e[1;33m"
    Blue = "`e[0;34m"
    Cyan = "`e[0;36m"
    NC = "`e[0m"
}

# Available packages
$AVAILABLE_PACKAGES = @("zsh", "git", "vim", "nvim", "tmux", "tools", "system", "windows")

function Write-ColorOutput {
    param(
        [string]$Color,
        [string]$Message
    )
    Write-Host "$($colors[$Color])$Message$($colors.NC)"
}

function Show-Help {
    Write-ColorOutput "Cyan" "Cross-Platform Stow Script for Windows"
    Write-Host ""
    Write-ColorOutput "Blue" "Usage: ./stow.ps1 [command] [package...]"
    Write-Host ""
    Write-ColorOutput "Blue" "Commands:"
    Write-Host "  install [package...]  - Install specified packages (or all if none specified)"
    Write-Host "  remove [package...]   - Remove specified packages (or all if none specified)"
    Write-Host "  list                  - List available packages"
    Write-Host "  status                - Show current stow status"
    Write-Host "  help                  - Show this help message"
    Write-Host ""
    Write-ColorOutput "Blue" "Available packages: $($AVAILABLE_PACKAGES -join ', ')"
    Write-Host ""
    Write-ColorOutput "Blue" "Examples:"
    Write-Host "  ./stow.ps1 install            # Install all packages"
    Write-Host "  ./stow.ps1 install zsh git    # Install only zsh and git"
    Write-Host "  ./stow.ps1 remove nvim        # Remove nvim package"
}

function Get-Packages {
    param(
        [string[]]$InputPackages
    )
    
    if ($InputPackages.Count -eq 0) {
        return $AVAILABLE_PACKAGES
    }
    return $InputPackages
}

function Show-PackageList {
    Write-ColorOutput "Blue" "Available packages:"
    foreach ($pkg in $AVAILABLE_PACKAGES) {
        $pkgPath = Join-Path $STOW_DIR $pkg
        if (Test-Path $pkgPath) {
            Write-ColorOutput "Green" "  ✓ $pkg"
        }
        else {
            Write-ColorOutput "Red" "  ✗ $pkg (not found)"
        }
    }
}

function New-Junction {
    param(
        [string]$Link,
        [string]$Target
    )
    
    if (Test-Path $Link) {
        Write-ColorOutput "Yellow" "Removing existing $Link"
        Remove-Item $Link -Recurse -Force
    }
    
    $parentDir = Split-Path $Link -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    
    cmd /c mklink /J $Link $Target
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Green" "✓ Created junction: $Link -> $Target"
    }
    else {
        Write-ColorOutput "Red" "✗ Failed to create junction: $Link -> $Target"
    }
}

function Remove-Junction {
    param(
        [string]$Link
    )
    
    if (Test-Path $Link) {
        Write-ColorOutput "Yellow" "Removing junction: $Link"
        Remove-Item $Link -Recurse -Force
        Write-ColorOutput "Green" "✓ Removed junction: $Link"
    }
    else {
        Write-ColorOutput "Yellow" "Junction not found: $Link"
    }
}

function Install-Package {
    param(
        [string]$Package
    )
    
    $pkgPath = Join-Path $STOW_DIR $Package
    if (-not (Test-Path $pkgPath)) {
        Write-ColorOutput "Red" "✗ Package $Package not found"
        return
    }
    
    Write-ColorOutput "Yellow" "Installing $Package..."
    
    # Get all files and directories in the package
    $items = Get-ChildItem $pkgPath -Recurse -Force
    
    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($STOW_DIR.Length + 1)
        $packageIndex = $relativePath.IndexOf([IO.Path]::DirectorySeparatorChar)
        if ($packageIndex -gt -1) {
            $relativePath = $relativePath.Substring($packageIndex + 1)
        }
        
        $targetPath = Join-Path $TARGET_DIR $relativePath
        
        if ($item.PSIsContainer) {
            # Create directory junction
            New-Junction -Link $targetPath -Target $item.FullName
        }
        else {
            # Create file hard link or copy
            $targetDir = Split-Path $targetPath -Parent
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            
            if (Test-Path $targetPath) {
                Write-ColorOutput "Yellow" "Removing existing $targetPath"
                Remove-Item $targetPath -Force
            }
            
            cmd /c mklink /H $targetPath $item.FullName
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "Green" "✓ Created hard link: $targetPath"
            }
            else {
                # Fallback to copy if hard link fails
                Copy-Item $item.FullName $targetPath -Force
                Write-ColorOutput "Green" "✓ Copied file: $targetPath"
            }
        }
    }
    
    Write-ColorOutput "Green" "✓ $Package installed"
}

function Remove-Package {
    param(
        [string]$Package
    )
    
    $pkgPath = Join-Path $STOW_DIR $Package
    if (-not (Test-Path $pkgPath)) {
        Write-ColorOutput "Red" "✗ Package $Package not found"
        return
    }
    
    Write-ColorOutput "Yellow" "Removing $Package..."
    
    # Get all files and directories in the package
    $items = Get-ChildItem $pkgPath -Recurse -Force
    
    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($STOW_DIR.Length + 1)
        $packageIndex = $relativePath.IndexOf([IO.Path]::DirectorySeparatorChar)
        if ($packageIndex -gt -1) {
            $relativePath = $relativePath.Substring($packageIndex + 1)
        }
        
        $targetPath = Join-Path $TARGET_DIR $relativePath
        
        if (Test-Path $targetPath) {
            Remove-Junction -Link $targetPath
        }
    }
    
    Write-ColorOutput "Green" "✓ $Package removed"
}

function Show-Status {
    Write-ColorOutput "Blue" "Current stow status:"
    
    foreach ($pkg in $AVAILABLE_PACKAGES) {
        $pkgPath = Join-Path $STOW_DIR $pkg
        if (Test-Path $pkgPath) {
            Write-ColorOutput "Yellow" "Checking $pkg:"
            
            $items = Get-ChildItem $pkgPath -Recurse -Force
            foreach ($item in $items) {
                $relativePath = $item.FullName.Substring($STOW_DIR.Length + 1)
                $packageIndex = $relativePath.IndexOf([IO.Path]::DirectorySeparatorChar)
                if ($packageIndex -gt -1) {
                    $relativePath = $relativePath.Substring($packageIndex + 1)
                }
                
                $targetPath = Join-Path $TARGET_DIR $relativePath
                
                if (Test-Path $targetPath) {
                    Write-ColorOutput "Green" "  ✓ $relativePath"
                }
                else {
                    Write-ColorOutput "Red" "  ✗ $relativePath"
                }
            }
        }
    }
}

# Main logic
switch ($Command) {
    "install" {
        $packagesToInstall = Get-Packages -InputPackages $Packages
        Write-ColorOutput "Green" "Installing packages: $($packagesToInstall -join ', ')"
        foreach ($pkg in $packagesToInstall) {
            Install-Package -Package $pkg
        }
    }
    "remove" {
        $packagesToRemove = Get-Packages -InputPackages $Packages
        Write-ColorOutput "Yellow" "Removing packages: $($packagesToRemove -join ', ')"
        foreach ($pkg in $packagesToRemove) {
            Remove-Package -Package $pkg
        }
    }
    "list" {
        Show-PackageList
    }
    "status" {
        Show-Status
    }
    "help" {
        Show-Help
    }
    default {
        Write-ColorOutput "Red" "Unknown command: $Command"
        Show-Help
        exit 1
    }
}