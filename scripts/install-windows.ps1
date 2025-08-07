# Cross-Platform Dotfiles Installer for Windows
# PowerShell script for Windows native support

# Version
$DotfilesVersion = "1.0.0"

# Ensure we're running as admin if needed
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Some operations may require administrator privileges."
    Write-Warning "If you encounter permission issues, please restart this script as administrator."
}

# Colors for output
function Write-ColorOutput {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$ForegroundColor = "White"
    )
    
    Write-Host $Message -ForegroundColor $ForegroundColor
}

function Write-Info {
    param ([string]$Message)
    Write-ColorOutput "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param ([string]$Message)
    Write-ColorOutput "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param ([string]$Message)
    Write-ColorOutput "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param ([string]$Message)
    Write-ColorOutput "[ERROR] $Message" -ForegroundColor Red
}

# Print header
function Show-Header {
    Clear-Host
    Write-ColorOutput "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-ColorOutput "║                    Cross-Platform Dotfiles                   ║" -ForegroundColor Cyan
    Write-ColorOutput "║                    Windows Installer v$DotfilesVersion                 ║" -ForegroundColor Cyan
    Write-ColorOutput "║                    PowerShell Edition                        ║" -ForegroundColor Cyan
    Write-ColorOutput "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Info "Windows Edition: $((Get-WmiObject -class Win32_OperatingSystem).Caption)"
    Write-Info "PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-Host ""
}

# Check if command exists
function Test-Command {
    param ([string]$Command)
    
    return (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Install package manager if needed
function Install-PackageManager {
    # Check for Scoop first
    if (-not (Test-Command "scoop")) {
        Write-Warning "Scoop package manager not found. Installing..."
        try {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
            Write-Success "Scoop installed successfully"
            
            # Add extras bucket
            scoop bucket add extras
            Write-Success "Added extras bucket to Scoop"
        }
        catch {
            Write-Error "Failed to install Scoop: $_"
            
            # Try WinGet as fallback
            if (-not (Test-Command "winget")) {
                Write-Warning "WinGet not found. Attempting to install..."
                try {
                    # For Windows 10 1809 or later, try to install WinGet
                    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
                    Write-Success "WinGet installed successfully"
                }
                catch {
                    Write-Error "Failed to install WinGet: $_"
                    Write-Warning "Please install a package manager manually (Scoop, WinGet, or Chocolatey)"
                    return $false
                }
            }
        }
    }
    
    return $true
}

# Install prerequisites
function Install-Prerequisites {
    Write-Info "Installing prerequisites..."
    
    # Install package manager if needed
    if (-not (Install-PackageManager)) {
        return $false
    }
    
    # Install Git if not already installed
    if (-not (Test-Command "git")) {
        Write-Warning "Git not found. Installing..."
        
        if (Test-Command "scoop") {
            scoop install git
        }
        elseif (Test-Command "winget") {
            winget install --id Git.Git -e --source winget
        }
        else {
            Write-Error "No package manager available to install Git"
            Write-Warning "Please install Git manually from https://git-scm.com/download/win"
            return $false
        }
        
        # Verify Git was installed
        if (-not (Test-Command "git")) {
            Write-Error "Failed to install Git"
            return $false
        }
        
        Write-Success "Git installed successfully"
    }
    else {
        Write-Success "Git is already installed"
    }
    
    # Install other essential tools
    $tools = @("curl", "wget")
    foreach ($tool in $tools) {
        if (-not (Test-Command $tool)) {
            Write-Warning "$tool not found. Installing..."
            
            if (Test-Command "scoop") {
                scoop install $tool
            }
            elseif (Test-Command "winget") {
                winget install --id $tool -e --source winget
            }
            else {
                Write-Warning "Skipping $tool installation (no package manager available)"
                continue
            }
            
            if (Test-Command $tool) {
                Write-Success "$tool installed successfully"
            }
            else {
                Write-Warning "Failed to install $tool"
            }
        }
        else {
            Write-Success "$tool is already installed"
        }
    }
    
    Write-Success "Prerequisites installed"
    return $true
}

# Clone dotfiles repository
function Clone-Dotfiles {
    param (
        [string]$DotfilesRepo = "https://github.com/nehcuh/dotfiles.git",
        [string]$DotfilesDir = "$env:USERPROFILE\.dotfiles"
    )
    
    if (-not (Test-Path $DotfilesDir)) {
        Write-Info "Cloning dotfiles repository..."
        
        try {
            git clone $DotfilesRepo $DotfilesDir
            Write-Success "Dotfiles cloned to $DotfilesDir"
        }
        catch {
            Write-Error "Failed to clone dotfiles repository: $_"
            return $false
        }
    }
    else {
        Write-Warning "Dotfiles directory already exists"
        $response = Read-Host "Do you want to update the existing dotfiles? [Y/n]"
        
        if ($response -ne "n" -and $response -ne "N") {
            Write-Info "Updating dotfiles..."
            
            try {
                Push-Location $DotfilesDir
                
                # Check for local changes
                $status = git status --porcelain
                if ($status) {
                    Write-Warning "Stashing local changes..."
                    git stash push -m "Backup before update $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
                }
                
                # Pull latest changes
                git pull origin main 2>$null
                if ($LASTEXITCODE -ne 0) {
                    git pull origin master 2>$null
                }
                
                if ($LASTEXITCODE -ne 0) {
                    Write-Warning "Update failed. Re-cloning repository..."
                    Pop-Location
                    Remove-Item -Recurse -Force $DotfilesDir
                    git clone $DotfilesRepo $DotfilesDir
                }
                else {
                    Pop-Location
                }
                
                Write-Success "Dotfiles updated"
            }
            catch {
                Write-Error "Failed to update dotfiles: $_"
                return $false
            }
        }
        else {
            Write-Info "Using existing dotfiles..."
        }
    }
    
    # Create configuration file if it doesn't exist
    $configFile = Join-Path $DotfilesDir "dotfiles.conf"
    $templateFile = Join-Path $DotfilesDir "dotfiles.conf.template"
    
    if (-not (Test-Path $configFile)) {
        if (Test-Path $templateFile) {
            Write-Info "Creating configuration file from template..."
            Copy-Item $templateFile $configFile
            Write-Success "Configuration file created: $configFile"
            Write-Warning "You may want to customize it for your needs"
        }
        else {
            Write-Warning "Configuration template not found, creating minimal configuration..."
            @"
# Dotfiles Configuration
GITHUB_USERNAME="nehcuh"
DOTFILES_REPO="https://github.com/nehcuh/dotfiles.git"
DOTFILES_DIR="$($DotfilesDir -replace '\\', '\\')"
STOW_DIR="`${DOTFILES_DIR}/stow-packs"
TARGET_DIR="$($env:USERPROFILE -replace '\\', '\\')"
"@ | Out-File -FilePath $configFile -Encoding utf8
            Write-Success "Minimal configuration file created: $configFile"
        }
    }
    
    return $true
}

# Create symbolic links for Windows
function Install-WindowsSymlinks {
    param (
        [string]$DotfilesDir = "$env:USERPROFILE\.dotfiles",
        [string]$StowDir = "$env:USERPROFILE\.dotfiles\stow-packs",
        [string]$TargetDir = $env:USERPROFILE
    )
    
    Write-Info "Installing Windows configuration files..."
    
    # Check if we have admin rights for symlinks
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    # Windows-specific packages
    $packages = @("windows", "git", "nvim", "tools")
    
    foreach ($package in $packages) {
        $packageDir = Join-Path $StowDir $package
        
        if (Test-Path $packageDir) {
            Write-Info "Installing $package..."
            
            # Get all files in the package directory (recursively)
            $files = Get-ChildItem -Path $packageDir -Recurse -File
            
            foreach ($file in $files) {
                # Calculate relative path from package root
                $relativePath = $file.FullName.Substring($packageDir.Length + 1)
                
                # Skip if the path starts with "home/"
                if ($relativePath.StartsWith("home\")) {
                    $relativePath = $relativePath.Substring(5)
                }
                
                # Calculate target path
                $targetPath = Join-Path $TargetDir $relativePath
                $targetDir = Split-Path -Parent $targetPath
                
                # Create target directory if it doesn't exist
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
                
                # Check if target file exists and is not a symlink
                if (Test-Path $targetPath) {
                    $existingItem = Get-Item $targetPath -Force
                    if (-not $existingItem.LinkType) {
                        # Backup existing file
                        $backupDir = "$env:USERPROFILE\.dotfiles-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                        if (-not (Test-Path $backupDir)) {
                            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
                        }
                        
                        $backupPath = Join-Path $backupDir $relativePath
                        $backupPathDir = Split-Path -Parent $backupPath
                        
                        if (-not (Test-Path $backupPathDir)) {
                            New-Item -ItemType Directory -Path $backupPathDir -Force | Out-Null
                        }
                        
                        Copy-Item $targetPath $backupPath -Force
                        Remove-Item $targetPath -Force
                        Write-Warning "  Backed up $relativePath"
                    }
                    else {
                        # Remove existing symlink
                        Remove-Item $targetPath -Force
                    }
                }
                
                # Create symlink or junction
                try {
                    if ($isAdmin) {
                        # Create symbolic link
                        New-Item -ItemType SymbolicLink -Path $targetPath -Target $file.FullName -Force | Out-Null
                    }
                    else {
                        # Create junction or hard link as fallback
                        Copy-Item $file.FullName $targetPath -Force
                        Write-Warning "  Created copy instead of symlink for $relativePath (no admin rights)"
                    }
                    
                    Write-Success "  ✓ Linked $relativePath"
                }
                catch {
                    Write-Error "  ✗ Failed to link $relativePath: $_"
                }
            }
        }
        else {
            Write-Warning "Package $package not found"
        }
    }
    
    Write-Success "Windows configuration files installed"
    return $true
}

# Install Windows Terminal settings
function Install-WindowsTerminal {
    $terminalSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    $terminalSettingsFile = Join-Path $terminalSettingsDir "settings.json"
    $dotfilesTerminalSettings = "$env:USERPROFILE\.dotfiles\stow-packs\windows\home\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    
    if (Test-Path $dotfilesTerminalSettings) {
        Write-Info "Installing Windows Terminal settings..."
        
        # Create directory if it doesn't exist
        if (-not (Test-Path $terminalSettingsDir)) {
            New-Item -ItemType Directory -Path $terminalSettingsDir -Force | Out-Null
        }
        
        # Backup existing settings if they exist
        if (Test-Path $terminalSettingsFile) {
            $backupFile = "$terminalSettingsFile.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item $terminalSettingsFile $backupFile
            Write-Warning "Backed up existing Windows Terminal settings to $backupFile"
        }
        
        # Copy settings
        Copy-Item $dotfilesTerminalSettings $terminalSettingsFile -Force
        Write-Success "Windows Terminal settings installed"
    }
    else {
        Write-Warning "Windows Terminal settings not found in dotfiles"
    }
}

# Install PowerShell profile
function Install-PowerShellProfile {
    $profileDir = Split-Path -Parent $PROFILE
    $dotfilesPSProfile = "$env:USERPROFILE\.dotfiles\stow-packs\windows\home\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    
    if (Test-Path $dotfilesPSProfile) {
        Write-Info "Installing PowerShell profile..."
        
        # Create profile directory if it doesn't exist
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        
        # Backup existing profile if it exists
        if (Test-Path $PROFILE) {
            $backupFile = "$PROFILE.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item $PROFILE $backupFile
            Write-Warning "Backed up existing PowerShell profile to $backupFile"
        }
        
        # Copy profile
        Copy-Item $dotfilesPSProfile $PROFILE -Force
        Write-Success "PowerShell profile installed"
    }
    else {
        Write-Warning "PowerShell profile not found in dotfiles"
    }
}

# Install Neovim configuration
function Install-Neovim {
    $nvimConfigDir = "$env:LOCALAPPDATA\nvim"
    $dotfilesNvimConfig = "$env:USERPROFILE\.dotfiles\stow-packs\nvim\.config\nvim"
    
    if (Test-Path $dotfilesNvimConfig) {
        Write-Info "Installing Neovim configuration..."
        
        # Check if Neovim is installed
        if (-not (Test-Command "nvim")) {
            Write-Warning "Neovim not found. Installing..."
            
            if (Test-Command "scoop") {
                scoop install neovim
            }
            elseif (Test-Command "winget") {
                winget install --id Neovim.Neovim -e --source winget
            }
            else {
                Write-Warning "No package manager available to install Neovim"
                Write-Warning "Please install Neovim manually from https://github.com/neovim/neovim/releases"
                return $false
            }
            
            # Verify Neovim was installed
            if (-not (Test-Command "nvim")) {
                Write-Error "Failed to install Neovim"
                return $false
            }
            
            Write-Success "Neovim installed successfully"
        }
        
        # Backup existing configuration if it exists
        if (Test-Path $nvimConfigDir) {
            $backupDir = "$nvimConfigDir.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item $nvimConfigDir $backupDir -Recurse
            Write-Warning "Backed up existing Neovim configuration to $backupDir"
            Remove-Item $nvimConfigDir -Recurse -Force
        }
        
        # Create config directory
        New-Item -ItemType Directory -Path $nvimConfigDir -Force | Out-Null
        
        # Copy configuration
        Copy-Item "$dotfilesNvimConfig\*" $nvimConfigDir -Recurse -Force
        Write-Success "Neovim configuration installed"
    }
    else {
        Write-Warning "Neovim configuration not found in dotfiles"
    }
}

# Install Git configuration
function Install-GitConfig {
    $gitConfigTemplate = "$env:USERPROFILE\.dotfiles\stow-packs\git\.gitconfig_local.template"
    $gitConfigLocal = "$env:USERPROFILE\.gitconfig_local"
    $gitConfig = "$env:USERPROFILE\.gitconfig"
    
    Write-Info "Setting up Git configuration..."
    
    # Check if Git is installed
    if (-not (Test-Command "git")) {
        Write-Error "Git not installed"
        return $false
    }
    
    # Copy .gitconfig
    $dotfilesGitConfig = "$env:USERPROFILE\.dotfiles\stow-packs\git\.gitconfig"
    if (Test-Path $dotfilesGitConfig) {
        Copy-Item $dotfilesGitConfig $gitConfig -Force
        Write-Success "Copied .gitconfig"
    }
    
    # Create .gitconfig_local if it doesn't exist
    if (Test-Path $gitConfigTemplate -and -not (Test-Path $gitConfigLocal)) {
        Copy-Item $gitConfigTemplate $gitConfigLocal
        Write-Success "Created .gitconfig_local from template"
        Write-Warning "Please edit $gitConfigLocal with your name and email"
    }
    elseif (-not (Test-Path $gitConfigLocal)) {
        # Ask for Git user information
        $gitName = Read-Host "Please enter your Git username"
        $gitEmail = Read-Host "Please enter your Git email"
        
        # Create .gitconfig_local
        @"
[user]
    name = $gitName
    email = $gitEmail
"@ | Out-File -FilePath $gitConfigLocal -Encoding utf8
        
        Write-Success "Created .gitconfig_local with provided information"
    }
    else {
        Write-Success ".gitconfig_local already exists"
    }
    
    Write-Success "Git configuration set up successfully"
    return $true
}

# Main installation process
function Install-Dotfiles {
    Show-Header
    
    # Install prerequisites
    if (-not (Install-Prerequisites)) {
        Write-Error "Failed to install prerequisites"
        return
    }
    
    # Clone dotfiles repository
    if (-not (Clone-Dotfiles)) {
        Write-Error "Failed to clone dotfiles repository"
        return
    }
    
    # Install Windows symlinks
    if (-not (Install-WindowsSymlinks)) {
        Write-Error "Failed to install Windows symlinks"
        # Continue anyway
    }
    
    # Install Windows Terminal settings
    Install-WindowsTerminal
    
    # Install PowerShell profile
    Install-PowerShellProfile
    
    # Install Neovim configuration
    Install-Neovim
    
    # Install Git configuration
    if (-not (Install-GitConfig)) {
        Write-Warning "Failed to set up Git configuration"
        # Continue anyway
    }
    
    # Final message
    Write-Success "Installation complete!"
    Write-Info "You may need to restart your terminal to apply all changes"
    Write-Info "You can manage your dotfiles with:"
    Write-Info "  cd $env:USERPROFILE\.dotfiles"
    Write-Info "  .\scripts\install-windows.ps1"
    Write-Info "Happy coding!"
}

# Run the installation
Install-Dotfiles