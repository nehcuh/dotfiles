#!/usr/bin/env pwsh
# Windows package installer for dotfiles
# Installs essential packages using Scoop and Winget

param(
    [switch]$Force,
    [switch]$Clean
)

# Colors for output
$colors = @{
    Red = "`e[0;31m"
    Green = "`e[0;32m"
    Yellow = "`e[1;33m"
    Blue = "`e[0;34m"
    Cyan = "`e[0;36m"
    NC = "`e[0m"
}

function Write-ColorOutput {
    param(
        [string]$Color,
        [string]$Message
    )
    Write-Host "$($colors[$Color])$Message$($colors.NC)"
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Scoop {
    Write-ColorOutput "Yellow" "Installing Scoop package manager..."
    
    # Set execution policy
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    
    # Install Scoop
    Invoke-RestMethod -Uri get.scoop.sh | Invoke-Expression
    
    # Configure scoop to use GitHub mirror for faster access
    scoop config SCOOP_REPO 'https://github.com/ScoopInstaller/Scoop'
    
    # Add extras bucket
    scoop bucket add extras
    
    Write-ColorOutput "Green" "✓ Scoop installed successfully"
}

function Install-Winget {
    if (-not (Test-Administrator)) {
        Write-ColorOutput "Yellow" "Winget installation requires administrator privileges"
        Write-ColorOutput "Yellow" "Please run this script as administrator to install Winget"
        return
    }
    
    Write-ColorOutput "Yellow" "Installing Winget package manager..."
    
    # Install App Installer from Microsoft Store
    # This is a simplified approach - in practice, Winget installation varies by Windows version
    try {
        # Try to install via PowerShell Gallery
        Install-Module -Name Microsoft.WinGet.Client -Force -AllowClobber
        Write-ColorOutput "Green" "✓ Winget installed successfully"
    }
    catch {
        Write-ColorOutput "Red" "Failed to install Winget automatically"
        Write-ColorOutput "Yellow" "Please install Winget from Microsoft Store manually"
    }
}

function Install-PowerShellModules {
    Write-ColorOutput "Yellow" "Installing PowerShell modules..."
    
    $modules = @(
        @{ Name = "PSReadLine"; Description = "Improved command line editing" },
        @{ Name = "Terminal-Icons"; Description = "File and folder icons for terminal" },
        @{ Name = "PSFzf"; Description = "Fuzzy finder integration" },
        @{ Name = "zoxide"; Description = "Smarter cd command" },
        @{ Name = "git-aliases"; Description = "Git command aliases" },
        @{ Name = "Posh-Git"; Description = "Git status in PowerShell prompt" }
    )
    
    foreach ($module in $modules) {
        Write-ColorOutput "Blue" "Installing $($module.Name) - $($module.Description)"
        try {
            Install-Module -Name $module.Name -Force -AllowClobber -Scope CurrentUser
            Write-ColorOutput "Green" "✓ $($module.Name) installed"
        }
        catch {
            Write-ColorOutput "Red" "✗ Failed to install $($module.Name)"
        }
    }
}

function Install-ScoopPackages {
    $packages = @(
        # Core utilities
        @{ Name = "git"; Description = "Git version control" },
        @{ Name = "gitui"; Description = "Git TUI" },
        @{ Name = "less"; Description = "Terminal pager" },
        @{ Name = "curl"; Description = "Command line URL transfer tool" },
        @{ Name = "wget"; Description = "Command line URL transfer tool" },
        
        # Modern tools
        @{ Name = "bat"; Description = "Cat command with syntax highlighting" },
        @{ Name = "bottom"; Description = "System monitor" },
        @{ Name = "btop"; Description = "System monitor" },
        @{ Name = "delta"; Description = "Syntax highlighting diff tool" },
        @{ Name = "duf"; Description = "Disk usage analyzer" },
        @{ Name = "dust"; Description = "Disk usage analyzer" },
        @{ Name = "eza"; Description = "Modern ls command" },
        @{ Name = "fzf"; Description = "Fuzzy finder" },
        @{ Name = "fd"; Description = "Find command alternative" },
        @{ Name = "gping"; Description = "Ping with graph" },
        @{ Name = "hyperfine"; Description = "Command line benchmarking" },
        @{ Name = "ripgrep"; Description = "Fast grep alternative" },
        @{ Name = "tealdeer"; Description = "Fast tldr client" },
        @{ Name = "zoxide"; Description = "Smarter cd command" },
        
        # Editors
        @{ Name = "neovim"; Description = "Neovim editor" },
        @{ Name = "vscode"; Description = "Visual Studio Code" },
        
        # Terminal multiplexer
        @{ Name = "tmux"; Description = "Terminal multiplexer" },
        
        # Utilities
        @{ Name = "starship"; Description = "Cross-shell prompt" },
        @{ Name = "7zip"; Description = "File archiver" },
        @{ Name = "everything"; Description = "File search utility" },
        
        # Development tools
        @{ Name = "nodejs-lts"; Description = "Node.js LTS" },
        @{ Name = "python"; Description = "Python" },
        @{ Name = "go"; Description = "Go programming language" },
        
        # Optional tools
        @{ Name = "wezterm"; Description = "Terminal emulator" }
    )
    
    foreach ($package in $packages) {
        Write-ColorOutput "Blue" "Installing $($package.Name) - $($package.Description)"
        try {
            scoop install $package.Name
            Write-ColorOutput "Green" "✓ $($package.Name) installed"
        }
        catch {
            Write-ColorOutput "Red" "✗ Failed to install $($package.Name)"
        }
    }
}

function Install-WingetPackages {
    $packages = @(
        # Windows-specific tools
        @{ Id = "Microsoft.PowerShell"; Description = "PowerShell 7+" },
        @{ Id = "Microsoft.WindowsTerminal"; Description = "Windows Terminal" },
        @{ Id = "Microsoft.VisualStudioCode"; Description = "Visual Studio Code" },
        @{ Id = "Git.Git"; Description = "Git for Windows" },
        @{ Id = "GitHub.cli"; Description = "GitHub CLI" },
        
        # Development tools
        @{ Id = "Microsoft.DotNet.SDK.7"; Description = ".NET 7 SDK" },
        @{ Id = "Microsoft.VisualStudio.2022.Community"; Description = "Visual Studio 2022" }
    )
    
    foreach ($package in $packages) {
        Write-ColorOutput "Blue" "Installing $($package.Description)"
        try {
            winget install --id $package.Id -e --accept-package-agreements --accept-source-agreements
            Write-ColorOutput "Green" "✓ $($package.Description) installed"
        }
        catch {
            Write-ColorOutput "Red" "✗ Failed to install $($package.Description)"
        }
    }
}

function Install-Fonts {
    Write-ColorOutput "Yellow" "Installing fonts..."
    
    $fonts = @(
        "Cascadia-Code",
        "FiraCode",
        "JetBrains-Mono",
        "SourceCodePro",
        "UbuntuMono"
    )
    
    foreach ($font in $fonts) {
        Write-ColorOutput "Blue" "Installing $font font"
        try {
            scoop install $font
            Write-ColorOutput "Green" "✓ $font font installed"
        }
        catch {
            Write-ColorOutput "Red" "✗ Failed to install $font font"
        }
    }
}

function Set-WindowsPreferences {
    Write-ColorOutput "Yellow" "Setting Windows preferences..."
    
    # Enable Windows features for developers
    $features = @(
        "Microsoft-Windows-Subsystem-Linux",
        "VirtualMachinePlatform",
        "Microsoft-Hyper-V",
        "TelnetClient"
    )
    
    if (Test-Administrator) {
        foreach ($feature in $features) {
            Write-ColorOutput "Blue" "Enabling $feature"
            try {
                Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
                Write-ColorOutput "Green" "✓ $feature enabled"
            }
            catch {
                Write-ColorOutput "Red" "✗ Failed to enable $feature"
            }
        }
    }
    else {
        Write-ColorOutput "Yellow" "Run as administrator to enable Windows features"
    }
}

function Invoke-Cleanup {
    Write-ColorOutput "Yellow" "Cleaning up..."
    
    # Clean scoop cache
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop cleanup --all
        Write-ColorOutput "Green" "✓ Scoop cache cleaned"
    }
    
    # Clean temporary files
    Clean-mgr /sagerun:1
    Write-ColorOutput "Green" "✓ Temporary files cleaned"
}

# Main installation process
Write-ColorOutput "Cyan" "Windows Dotfiles Package Installer"
Write-ColorOutput "Blue" "=================================="

# Check and install Scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Install-Scoop
}
else {
    Write-ColorOutput "Green" "✓ Scoop already installed"
}

# Install PowerShell modules
Install-PowerShellModules

# Install Scoop packages
Install-ScoopPackages

# Install Winget packages (if available)
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Install-WingetPackages
}
else {
    Write-ColorOutput "Yellow" "Winget not available, skipping Winget packages"
}

# Install fonts
Install-Fonts

# Set Windows preferences
Set-WindowsPreferences

# Cleanup if requested
if ($Clean) {
    Invoke-Cleanup
}

Write-ColorOutput "Green" "🎉 Windows package installation complete!"
Write-ColorOutput "Yellow" "Please restart your terminal to apply all changes"
Write-ColorOutput "Blue" "You can now use: ./stow.ps1 install windows"