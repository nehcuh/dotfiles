# PowerShell profile configuration
# This file contains the cross-platform PowerShell profile setup

# Copy to PowerShell profile location:
# - Windows: $PROFILE.CurrentUserAllHosts
# - PowerShell 7+: $PROFILE

# Set environment variables
$env:DOTFILES = "$env:USERPROFILE\.dotfiles"
$env:EDITOR = "nvim"

# Add dotfiles bin to PATH if exists
if (Test-Path "$env:DOTFILES\bin") {
    $env:PATH = "$env:DOTFILES\bin;$env:PATH"
}

# Functions for common tasks
function Update-All {
    param(
        [switch]$Force
    )
    
    # Update scoop packages
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Updating Scoop packages..." -ForegroundColor Yellow
        scoop update
        if ($Force) {
            scoop cleanup --all
        }
    }
    
    # Update winget packages
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Updating Winget packages..." -ForegroundColor Yellow
        winget upgrade --all
    }
    
    # Update PowerShell modules
    Write-Host "Updating PowerShell modules..." -ForegroundColor Yellow
    Update-Module -Force
}

function Get-DotfilesStatus {
    Push-Location $env:DOTFILES
    try {
        Write-Host "Dotfiles Status:" -ForegroundColor Cyan
        git status
    }
    finally {
        Pop-Location
    }
}

function Update-Dotfiles {
    Push-Location $env:DOTFILES
    try {
        Write-Host "Updating dotfiles..." -ForegroundColor Yellow
        git pull
    }
    finally {
        Pop-Location
    }
}

function Install-Dotfiles {
    param(
        [string]$Package = "all"
    )
    
    Push-Location $env:DOTFILES
    try {
        if ($Package -eq "all") {
            .\stow.ps1 install
        }
        else {
            .\stow.ps1 install $Package
        }
    }
    finally {
        Pop-Location
    }
}

function Remove-Dotfiles {
    param(
        [string]$Package = "all"
    )
    
    Push-Location $env:DOTFILES
    try {
        if ($Package -eq "all") {
            .\stow.ps1 remove
        }
        else {
            .\stow.ps1 remove $Package
        }
    }
    finally {
        Pop-Location
    }
}

# Aliases
Set-Alias -Name update -Value Update-All
Set-Alias -Name dotfiles -Value Get-DotfilesStatus
Set-Alias -Name dotfiles-update -Value Update-Dotfiles
Set-Alias -Name dotfiles-install -Value Install-Dotfiles
Set-Alias -Name dotfiles-remove -Value Remove-Dotfiles

# Enhanced ls with eza if available
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza --icons --group-directories-first $args }
    function ll { eza -l --icons --group-directories-first $args }
    function la { eza -la --icons --group-directories-first $args }
    function tree { eza --tree --icons $args }
}

# Enhanced cat with bat if available
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat
}

# Enhanced cd with zoxide if available
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Import useful modules
$modules = @(
    "PSReadLine",
    "Terminal-Icons"
)

foreach ($module in $modules) {
    if (Get-Module -ListAvailable -Name $module) {
        Import-Module $module
    }
}

# PSReadLine settings
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -PredictionSource History -HistoryNoDuplicates
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

# FZF integration
if (Get-Module PSFzf -ListAvailable) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PsFzfOption -TabExpansion
}

# Git aliases
if (Get-Module git-aliases -ListAvailable) {
    Import-Module git-aliases -DisableNameChecking
}

# Welcome message
Write-Host "🚀 PowerShell profile loaded!" -ForegroundColor Green
Write-Host "Use 'Get-Alias | Where-Object {$_.Definition -like '*-Dotfiles*'}' to see dotfiles commands" -ForegroundColor Cyan