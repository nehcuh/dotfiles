@echo off
REM Windows Dotfiles Installer
REM This batch file provides a simple entry point for Windows users

echo 🚀 Cross-Platform Dotfiles Installer for Windows
echo ================================================
echo.

REM Check if PowerShell is available
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ PowerShell is not available. Please install PowerShell.
    exit /b 1
)

REM Check if we're in the dotfiles directory
if not exist "stow-packs" (
    echo ❌ stow-packs directory not found.
    echo Please run this script from the dotfiles directory.
    exit /b 1
)

echo ✅ PowerShell is available
echo ✅ Dotfiles directory found
echo.

REM Ask user what they want to do
echo What would you like to do?
echo 1. Install Windows packages
echo 2. Install dotfiles with stow
echo 3. Both (recommended)
echo 4. Exit
echo.

set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto install_packages
if "%choice%"=="2" goto install_dotfiles
if "%choice%"=="3" goto install_both
if "%choice%"=="4" goto exit
goto invalid_choice

:install_packages
echo.
echo 📦 Installing Windows packages...
powershell -ExecutionPolicy Bypass -File "%~dp0install-windows.ps1"
goto end

:install_dotfiles
echo.
echo 🔗 Installing dotfiles...
powershell -ExecutionPolicy Bypass -File "%~dp0stow.ps1" install
goto end

:install_both
echo.
echo 📦 Installing Windows packages...
powershell -ExecutionPolicy Bypass -File "%~dp0install-windows.ps1"
echo.
echo 🔗 Installing dotfiles...
powershell -ExecutionPolicy Bypass -File "%~dp0stow.ps1" install
goto end

:invalid_choice
echo.
echo ❌ Invalid choice. Please run the script again.
goto end

:exit
echo.
echo 👋 Goodbye!
goto end

:end
echo.
echo 🎉 Installation complete!
echo.
echo 📝 Next steps:
echo 1. Restart your terminal
echo 2. Run 'dotfiles-status' to check the status
echo 3. Use 'dotfiles-install' or 'dotfiles-remove' to manage packages
echo.
pause